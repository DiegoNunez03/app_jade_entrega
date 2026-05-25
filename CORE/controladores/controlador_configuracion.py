# app_jade / CORE / controladores / controlador_configuracion.py

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import unicodedata
from datetime import date, datetime
from pathlib import Path
from urllib.parse import urlparse, unquote
from typing import Any

from pydantic import BaseModel, ValidationError, field_validator
from PySide6.QtCore import QObject, Slot

from CORE.dominio.errores import (
    errores_a_texto,
    mensaje_resultado,
)
from CORE.dominio.reglas import validar_reglas_contexto_institucional
from CORE.mapeadores.mapeador_dominio import mapear_contexto_institucional
from CORE.schemas.base_schema import (
    UbicacionSchema,
    PATRON_TEXTO_PERSONA,
    PATRON_TEXTO_CON_NUMEROS,
    validar_texto_obligatorio,
    validar_patron,
)
from CORE.schemas.contexto_institucional_schema import ContextoInstitucionalSchema
from CORE.schemas.personas_schema import (
    PersonalInstitucionalSchema,
    validar_fecha_texto_dd_mm_aaaa,
)


# ============================================================
# SCHEMAS INTERNOS DEL CONTROLADOR
# ============================================================

class DatosSedeSchema(BaseModel):
    origen: str
    nombre_sede: str
    ubicacion: UbicacionSchema

    @field_validator("origen")
    @classmethod
    def validar_origen(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Origen")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_PERSONA,
            mensaje_usuario="Origen: solo permite letras, acentos y espacios.",
            mensaje_tecnico=(
                f"DatosSedeSchema.origen recibió '{valor}'. "
                "Patrón esperado: letras, acentos y espacios."
            ),
        )

    @field_validator("nombre_sede")
    @classmethod
    def validar_nombre_sede(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Nombre de sede")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_CON_NUMEROS,
            mensaje_usuario="Nombre de sede: solo permite letras, números, acentos y espacios.",
            mensaje_tecnico=(
                f"DatosSedeSchema.nombre_sede recibió '{valor}'. "
                "Patrón esperado: letras, números, acentos y espacios."
            ),
        )


class ConfiguracionAutomaticaSchema(BaseModel):
    fechaAutomatica: bool
    edadAutomatica: bool
    fechaActual: str

    @field_validator("fechaActual")
    @classmethod
    def validar_fecha_actual(cls, valor: str) -> str:
        return validar_fecha_texto_dd_mm_aaaa(
            valor=valor,
            campo="Fecha manual",
            clase="ConfiguracionAutomaticaSchema",
            atributo="fechaActual",
        )


# ============================================================
# CONTROLADOR
# ============================================================

class ControladorConfiguracion(QObject):
    """
    Controlador para configuración institucional.

    Trabaja con la estructura nueva:

    {
        "origen": "...",
        "nombre_sede": "...",
        "ubicacion": {
            "municipio": "...",
            "localidad": "...",
            "barrio": ""
        },
        "coordinador": {
            "nombre": "...",
            "apellido": "...",
            "rol": {
                "nombre": "...",
                "siglas": "..."
            }
        },
        "profesionales": [
            {
                "nombre": "...",
                "apellido": "...",
                "rol": {
                    "nombre": "...",
                    "siglas": "..."
                }
            }
        ],
        "fechaAutomatica": true,
        "edadAutomatica": true,
        "fechaActual": "23/05/2026"
    }
    """

    def __init__(self) -> None:
        super().__init__()

        self.base_dir = Path(__file__).resolve().parent.parent.parent
        self.config_dir = self.base_dir / "config"

        self.config_path = self.config_dir / "configuracion_sede_v2.json"
        self.config_guardado_path = self.config_dir / "configuracion_guardado.json"

        self.config_dir.mkdir(parents=True, exist_ok=True)

    # ============================================================
    # API QML - GUARDADO POR SECCIONES
    # ============================================================

    @Slot("QVariantMap", result=str)
    def guardarDatosSede(self, datos: dict[str, Any]) -> str:
        """
        Guarda solo la sección de datos de sede / ubicación.

        No valida coordinador.
        No valida profesionales.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar datos de sede")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            datos_sede = self._normalizar_datos_sede_recibidos(datos)
            schema = DatosSedeSchema(**datos_sede)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        configuracion = self._leer_configuracion_sede()
        configuracion["origen"] = schema.origen
        configuracion["nombre_sede"] = schema.nombre_sede
        configuracion["ubicacion"] = schema.ubicacion.model_dump(mode="json")

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot("QVariantMap", result=str)
    def agregarProfesional(self, datos: dict[str, Any]) -> str:
        """
        Valida un profesional individual y lo agrega a la lista.
        Si es inválido, no se agrega.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Agregar profesional")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            profesional = PersonalInstitucionalSchema(**datos)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        configuracion = self._leer_configuracion_sede()
        profesionales = list(configuracion.get("profesionales", []))

        clave_nueva = self._clave_profesional(profesional.model_dump(mode="json"))

        for profesional_existente in profesionales:
            if self._clave_profesional(profesional_existente) == clave_nueva:
                mensaje = "Profesionales: ese profesional ya fue agregado."

                print("[ERROR DOMINIO]")
                print(mensaje)

                return f"ERROR|{mensaje}"

        profesionales.append(profesional.model_dump(mode="json"))
        configuracion["profesionales"] = profesionales

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot(int, result=str)
    def eliminarProfesional(self, indice: int) -> str:
        """
        Elimina un profesional puntual de la lista por índice.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Eliminar profesional")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        configuracion = self._leer_configuracion_sede()
        profesionales = list(configuracion.get("profesionales", []))

        if indice < 0 or indice >= len(profesionales):
            mensaje = "Profesionales: no se pudo eliminar el profesional seleccionado."

            print("[ERROR]")
            print(mensaje)

            return f"ERROR|{mensaje}"

        profesionales.pop(indice)
        configuracion["profesionales"] = profesionales

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot("QVariantMap", result=str)
    def guardarCoordinador(self, datos: dict[str, Any]) -> str:
        """
        Guarda solo la sección de coordinador/coordinadora.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar coordinador")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            coordinador = PersonalInstitucionalSchema(**datos)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        configuracion = self._leer_configuracion_sede()
        configuracion["coordinador"] = coordinador.model_dump(mode="json")

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    # ============================================================
    # API QML - CONFIGURACIÓN AUTOMÁTICA
    # ============================================================

    @Slot("QVariantMap", result=str)
    def guardarConfiguracionAutomatica(self, datos: dict[str, Any]) -> str:
        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar configuración automática")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            fecha_automatica = bool(
                datos.get("fechaAutomatica", True)
            )

            datos_schema = {
                "fechaAutomatica": fecha_automatica,
                "edadAutomatica": bool(
                    datos.get("edadAutomatica", True)
                ),
                "fechaActual": (
                    self.obtenerFechaActual()
                    if fecha_automatica
                    else str(datos.get("fechaActual", "")).strip()
                ),
            }

            schema = ConfiguracionAutomaticaSchema(**datos_schema)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        except Exception as error:
            return f"ERROR|No se pudo guardar la configuración automática: {error}"

        configuracion = self._leer_configuracion_sede()

        configuracion["fechaAutomatica"] = schema.fechaAutomatica
        configuracion["edadAutomatica"] = schema.edadAutomatica
        configuracion["fechaActual"] = schema.fechaActual

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot(result="QVariantMap")
    def cargarConfiguracionAutomatica(self) -> dict[str, Any]:
        configuracion = self._leer_configuracion_sede()

        fecha_automatica = bool(configuracion.get("fechaAutomatica", True))
        edad_automatica = bool(configuracion.get("edadAutomatica", True))

        if fecha_automatica:
            fecha_actual = self.obtenerFechaActual()
        else:
            fecha_actual = str(
                configuracion.get("fechaActual", self.obtenerFechaActual())
            ).strip()

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Cargar configuración automática")
        print("=" * 70)
        print("[DATOS ENVIADOS CORRECTAMENTE]")

        return {
            "fechaAutomatica": fecha_automatica,
            "edadAutomatica": edad_automatica,
            "fechaActual": fecha_actual,
        }

    @Slot(result=str)
    def obtenerFechaActual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    # ============================================================
    # API QML - GUARDADO COMPLETO / RESPALDO TEMPORAL
    # ============================================================

    @Slot("QVariantMap", result=str)
    def guardarConfiguracionSede(self, datos: dict[str, Any]) -> str:
        """
        Guardado completo de configuración institucional.

        Se mantiene como respaldo temporal para validar y guardar todo junto
        si alguna parte de la interfaz todavía lo necesita.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar configuración institucional completa")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            schema = ContextoInstitucionalSchema(**datos)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        contexto = mapear_contexto_institucional(schema)
        errores_dominio = validar_reglas_contexto_institucional(contexto)

        if errores_dominio:
            mensaje_usuario = errores_a_texto(errores_dominio)

            print("[ERROR DOMINIO]")
            print(mensaje_usuario)

            return f"ERROR|{mensaje_usuario}"

        self._guardar_configuracion_sede(schema)

        mensaje = mensaje_resultado(errores_dominio)

        print("[RESULTADO]")
        print(mensaje)
        print(f"[ARCHIVO] {self.config_path}")

        return f"OK|{mensaje}"

    @Slot(result="QVariantMap")
    def cargarConfiguracionSede(self) -> dict[str, Any]:
        """
        Carga la configuración institucional.

        No exige que la configuración esté completa, porque ahora se puede
        guardar por secciones.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Cargar configuración institucional")
        print("=" * 70)

        configuracion = self._leer_configuracion_sede()

        print("[DATOS ENVIADOS CORRECTAMENTE]")

        return configuracion


    # ============================================================
    # CONFIGURACIÓN DE GUARDADO / COPIA EXTERNA DE SOLICITUDES
    # ============================================================

    def _configuracion_guardado_vacia(self) -> dict[str, Any]:
        return {
            "carpeta_copia_externa_solicitudes": ""
        }

    def _leer_configuracion_guardado(self) -> dict[str, Any]:
        self.config_dir.mkdir(parents=True, exist_ok=True)

        if not self.config_guardado_path.exists():
            configuracion_vacia = self._configuracion_guardado_vacia()
            self._guardar_configuracion_guardado(configuracion_vacia)
            return configuracion_vacia

        try:
            with self.config_guardado_path.open("r", encoding="utf-8") as archivo:
                configuracion = json.load(archivo)

            return {
                "carpeta_copia_externa_solicitudes": str(
                    configuracion.get("carpeta_copia_externa_solicitudes", "")
                ).strip()
            }

        except Exception as error:
            print(f"ERROR al cargar configuración de guardado: {error}")
            return self._configuracion_guardado_vacia()

    def _guardar_configuracion_guardado(self, configuracion: dict[str, Any]) -> None:
        self.config_dir.mkdir(parents=True, exist_ok=True)

        with self.config_guardado_path.open("w", encoding="utf-8") as archivo:
            json.dump(configuracion, archivo, ensure_ascii=False, indent=4)

    def _normalizar_ruta_recibida(self, ruta: str) -> str:
        """
        Normaliza rutas recibidas desde QML.

        Acepta:
        - /home/usuario/Documentos
        - file:///home/usuario/Documentos

        Devuelve una ruta absoluta en formato del sistema.
        """
        ruta = str(ruta).strip()

        if not ruta:
            return ""

        if ruta.startswith("file://"):
            ruta_parseada = urlparse(ruta)
            ruta = unquote(ruta_parseada.path)

        return str(Path(ruta).expanduser().resolve())

    @Slot(result="QVariantMap")
    def cargarConfiguracionGuardado(self) -> dict[str, Any]:
        configuracion = self._leer_configuracion_guardado()

        ruta = str(
            configuracion.get("carpeta_copia_externa_solicitudes", "")
        ).strip()

        return {
            "carpetaCopiaExternaSolicitudes": ruta,
            "tieneCarpetaCopiaExterna": bool(ruta),
            "archivoConfiguracion": str(self.config_guardado_path),
        }

    @Slot(result=str)
    def obtenerCarpetaCopiaExternaSolicitudes(self) -> str:
        configuracion = self._leer_configuracion_guardado()

        return str(
            configuracion.get("carpeta_copia_externa_solicitudes", "")
        ).strip()

    @Slot(str, result=str)
    def guardarCarpetaCopiaExternaSolicitudes(self, ruta: str) -> str:
        try:
            ruta_normalizada = self._normalizar_ruta_recibida(ruta)

            if not ruta_normalizada:
                return "ERROR|No se recibió una carpeta válida."

            carpeta = Path(ruta_normalizada)

            if carpeta.exists() and not carpeta.is_dir():
                return f"ERROR|La ruta seleccionada no es una carpeta: {carpeta}"

            carpeta.mkdir(parents=True, exist_ok=True)

            configuracion = self._leer_configuracion_guardado()
            configuracion["carpeta_copia_externa_solicitudes"] = str(carpeta)

            self._guardar_configuracion_guardado(configuracion)

            return f"OK|Carpeta externa de copia guardada correctamente: {carpeta}"

        except Exception as error:
            return f"ERROR|No se pudo guardar la carpeta externa de copia: {error}"

    @Slot(result=str)
    def restablecerCarpetaCopiaExternaSolicitudes(self) -> str:
        try:
            configuracion = self._leer_configuracion_guardado()
            configuracion["carpeta_copia_externa_solicitudes"] = ""

            self._guardar_configuracion_guardado(configuracion)

            return "OK|Carpeta externa de copia restablecida correctamente"

        except Exception as error:
            return f"ERROR|No se pudo restablecer la carpeta externa de copia: {error}"

    # ============================================================
    # SOLICITUDES GENERADAS / LISTADO Y APERTURA DE ARCHIVOS
    # ============================================================

    def _obtener_carpeta_solicitudes_generadas(self) -> Path:
        carpeta = self.base_dir / "output" / "solicitudes_generadas"
        carpeta.mkdir(parents=True, exist_ok=True)
        return carpeta.resolve()

    def _formatear_fecha_archivo(self, timestamp: float) -> str:
        return datetime.fromtimestamp(timestamp).strftime("%d/%m/%Y %H:%M")

    def _ruta_esta_dentro_de_carpeta(self, ruta: Path, carpeta_base: Path) -> bool:
        try:
            ruta_resuelta = ruta.resolve()
            carpeta_resuelta = carpeta_base.resolve()
            ruta_resuelta.relative_to(carpeta_resuelta)
            return True
        except ValueError:
            return False

    def _abrir_ruta_sistema(self, ruta: Path) -> None:
        ruta = ruta.resolve()

        if sys.platform.startswith("linux"):
            libreoffice = shutil.which("libreoffice")

            if ruta.is_file() and ruta.suffix.lower() in [".xlsx", ".xls"] and libreoffice:
                subprocess.Popen(
                    [libreoffice, "--calc", str(ruta)],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return

            if ruta.is_file() and ruta.suffix.lower() in [".docx", ".doc"] and libreoffice:
                subprocess.Popen(
                    [libreoffice, "--writer", str(ruta)],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return

            subprocess.Popen(
                ["xdg-open", str(ruta)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return

        if sys.platform == "darwin":
            subprocess.Popen(
                ["open", str(ruta)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return

        if os.name == "nt":
            os.startfile(str(ruta))

    @Slot(result="QVariantList")
    def listarSolicitudesGeneradas(self) -> list[dict[str, Any]]:
        try:
            carpeta = self._obtener_carpeta_solicitudes_generadas()

            archivos = []

            for patron in ("*.xlsx", "*.xls", "*.docx", "*.doc"):
                for ruta in carpeta.glob(patron):
                    if not ruta.is_file():
                        continue

                    # Evita mostrar archivos temporales de LibreOffice/Word.
                    if ruta.name.startswith("~$") or ruta.name.startswith(".~lock."):
                        continue

                    estadisticas = ruta.stat()

                    archivos.append({
                        "nombreArchivo": ruta.name,
                        "rutaArchivo": str(ruta.resolve()),
                        "fechaModificacion": self._formatear_fecha_archivo(
                            estadisticas.st_mtime
                        ),
                        "tamanioBytes": estadisticas.st_size,
                        "timestampModificacion": estadisticas.st_mtime,
                    })

            archivos.sort(
                key=lambda archivo: archivo.get("timestampModificacion", 0),
                reverse=True
            )

            # QML no necesita el timestamp interno.
            for archivo in archivos:
                archivo.pop("timestampModificacion", None)

            return archivos

        except Exception as error:
            print(f"ERROR al listar solicitudes generadas: {error}")
            return []

    @Slot(str, result=str)
    def abrirSolicitudGenerada(self, ruta: str) -> str:
        try:
            carpeta_base = self._obtener_carpeta_solicitudes_generadas()
            ruta_archivo = Path(self._normalizar_ruta_recibida(ruta))

            if not ruta_archivo.exists():
                return f"ERROR|El archivo no existe: {ruta_archivo}"

            if not ruta_archivo.is_file():
                return f"ERROR|La ruta no corresponde a un archivo: {ruta_archivo}"

            if not self._ruta_esta_dentro_de_carpeta(ruta_archivo, carpeta_base):
                return "ERROR|Por seguridad, solo se pueden abrir solicitudes generadas dentro de la carpeta interna del sistema."

            self._abrir_ruta_sistema(ruta_archivo)

            return f"OK|Solicitud abierta correctamente: {ruta_archivo}"

        except Exception as error:
            return f"ERROR|No se pudo abrir la solicitud generada: {error}"

    @Slot(result=str)
    def abrirCarpetaSolicitudesGeneradas(self) -> str:
        try:
            carpeta = self._obtener_carpeta_solicitudes_generadas()

            self._abrir_ruta_sistema(carpeta)

            return f"OK|Carpeta de solicitudes generadas abierta correctamente: {carpeta}"

        except Exception as error:
            return f"ERROR|No se pudo abrir la carpeta de solicitudes generadas: {error}"


    # ============================================================
    # LECTURA / ESCRITURA
    # ============================================================

    def _leer_configuracion_sede(self) -> dict[str, Any]:
        if not self.config_path.exists():
            return self._configuracion_sede_vacia()

        try:
            with self.config_path.open("r", encoding="utf-8") as archivo:
                datos = json.load(archivo)

            return self._normalizar_configuracion_sede(datos)

        except Exception as error:
            print(f"[ERROR AL CARGAR CONFIGURACIÓN] {error}")
            return self._configuracion_sede_vacia()

    def _guardar_configuracion_sede(
        self,
        schema: ContextoInstitucionalSchema,
    ) -> None:
        datos = schema.model_dump(mode="json")
        self._guardar_diccionario_configuracion(datos)

    def _guardar_diccionario_configuracion(
        self,
        configuracion: dict[str, Any],
    ) -> None:
        self.config_dir.mkdir(parents=True, exist_ok=True)

        datos = self._normalizar_configuracion_sede(configuracion)

        with self.config_path.open("w", encoding="utf-8") as archivo:
            json.dump(datos, archivo, ensure_ascii=False, indent=4)

    def _configuracion_sede_vacia(self) -> dict[str, Any]:
        return {
            "origen": "",
            "nombre_sede": "",
            "ubicacion": {
                "municipio": "",
                "localidad": "",
                "barrio": "",
            },
            "coordinador": {
                "nombre": "",
                "apellido": "",
                "rol": {
                    "nombre": "",
                    "siglas": "",
                },
            },
            "profesionales": [],
            "fechaAutomatica": True,
            "edadAutomatica": True,
            "fechaActual": self._obtener_fecha_actual(),
        }

    def _normalizar_configuracion_sede(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        configuracion = self._configuracion_sede_vacia()

        configuracion["origen"] = str(datos.get("origen", "")).strip()
        configuracion["nombre_sede"] = str(datos.get("nombre_sede", "")).strip()

        ubicacion = datos.get("ubicacion", {}) or {}

        configuracion["ubicacion"] = {
            "municipio": str(ubicacion.get("municipio", "")).strip(),
            "localidad": str(ubicacion.get("localidad", "")).strip(),
            "barrio": str(ubicacion.get("barrio", "")).strip(),
        }

        coordinador = datos.get("coordinador", {}) or {}
        rol_coordinador = coordinador.get("rol", {}) or {}

        configuracion["coordinador"] = {
            "nombre": str(coordinador.get("nombre", "")).strip(),
            "apellido": str(coordinador.get("apellido", "")).strip(),
            "rol": {
                "nombre": str(rol_coordinador.get("nombre", "")).strip(),
                "siglas": str(rol_coordinador.get("siglas", "")).strip(),
            },
        }

        profesionales = datos.get("profesionales", []) or []
        profesionales_normalizados: list[dict[str, Any]] = []

        if isinstance(profesionales, list):
            for profesional in profesionales:
                if not isinstance(profesional, dict):
                    continue

                rol = profesional.get("rol", {}) or {}

                profesionales_normalizados.append({
                    "nombre": str(profesional.get("nombre", "")).strip(),
                    "apellido": str(profesional.get("apellido", "")).strip(),
                    "rol": {
                        "nombre": str(rol.get("nombre", "")).strip(),
                        "siglas": str(rol.get("siglas", "")).strip(),
                    },
                })

        configuracion["profesionales"] = profesionales_normalizados

        configuracion["fechaAutomatica"] = bool(
            datos.get("fechaAutomatica", True)
        )
        configuracion["edadAutomatica"] = bool(
            datos.get("edadAutomatica", True)
        )
        configuracion["fechaActual"] = str(
            datos.get("fechaActual", self._obtener_fecha_actual())
        ).strip()

        return configuracion

    def _normalizar_datos_sede_recibidos(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Acepta estructura nueva y también algunos nombres antiguos por seguridad.
        """

        ubicacion = datos.get("ubicacion", {}) or {}

        return {
            "origen": str(datos.get("origen", "")).strip(),
            "nombre_sede": str(
                datos.get("nombre_sede", datos.get("nombreSede", ""))
            ).strip(),
            "ubicacion": {
                "municipio": str(
                    ubicacion.get("municipio", datos.get("municipio", ""))
                ).strip(),
                "localidad": str(
                    ubicacion.get("localidad", datos.get("localidad", ""))
                ).strip(),
                "barrio": str(
                    ubicacion.get("barrio", datos.get("barrio", ""))
                ).strip(),
            },
        }

    def _obtener_fecha_actual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    # ============================================================
    # DUPLICADOS / CLAVES
    # ============================================================

    def _clave_profesional(
        self,
        profesional: dict[str, Any],
    ) -> str:
        rol = profesional.get("rol", {}) or {}

        partes = [
            profesional.get("nombre", ""),
            profesional.get("apellido", ""),
            rol.get("nombre", ""),
        ]

        return "|".join(self._normalizar_texto_clave(parte) for parte in partes)

    def _normalizar_texto_clave(self, valor: Any) -> str:
        texto = str(valor).strip().lower()

        texto = unicodedata.normalize("NFD", texto)
        texto = "".join(
            caracter
            for caracter in texto
            if unicodedata.category(caracter) != "Mn"
        )

        return texto

    # ============================================================
    # FORMATO DE ERRORES PYDANTIC
    # ============================================================

    def _mensaje_usuario_pydantic(self, error: ValidationError) -> str:
        mensajes: list[str] = []

        for detalle in error.errors():
            campo = self._obtener_campo_error(detalle)
            mensaje = str(detalle.get("msg", "")).strip()

            if campo:
                mensajes.append(f"{campo}: {mensaje}")
            else:
                mensajes.append(mensaje)

        return "\n".join(mensajes)

    def _mensaje_tecnico_pydantic(self, error: ValidationError) -> str:
        mensajes: list[str] = []

        for detalle in error.errors():
            campo = self._obtener_campo_error(detalle)
            contexto = detalle.get("ctx") or {}
            mensaje_tecnico = str(contexto.get("mensaje_tecnico", "")).strip()

            if mensaje_tecnico:
                mensajes.append(f"{campo}: {mensaje_tecnico}")
            else:
                mensajes.append(str(detalle))

        return "\n".join(mensajes)

    def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
        ubicacion = detalle_error.get("loc", [])

        return " → ".join(str(parte) for parte in ubicacion)

