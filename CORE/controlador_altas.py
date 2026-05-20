# app_jade / CORE / controlador_altas.py

from pathlib import Path
from typing import Any
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import date, datetime

from PySide6.QtCore import QObject, Slot

from .generador_excel import generar_solicitud_alta
from .validaciones import (
    validar_solicitud_alta,
    validar_destinatario_o_tutor,
    validar_responsable,
    errores_a_texto,
)


class ControladorAltas(QObject):
    """
    Puente entre QML y el generador de Excel.
    Recibe datos desde QML, los adapta al formato del generador
    y produce la solicitud de alta en Excel.
    """

    # ============================================================
    # VALIDACIONES POR PASO
    # ============================================================

    @Slot("QVariantMap", result="QVariantMap")
    def validarDestinatario(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Valida solo los datos del paso Destinatario.
        Se usa al presionar Siguiente en Alta Destinatario.
        """
        errores = validar_destinatario_o_tutor(datos)

        return {
            "valido": len(errores) == 0,
            "errores": errores,
            "mensaje": errores_a_texto(errores),
        }

    @Slot("QVariantMap", result="QVariantMap")
    def validarTutor(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Valida solo los datos del paso Tutor.
        Reutiliza las mismas reglas que Destinatario.
        """
        errores = validar_destinatario_o_tutor(datos)

        return {
            "valido": len(errores) == 0,
            "errores": errores,
            "mensaje": errores_a_texto(errores),
        }

    @Slot("QVariantMap", result="QVariantMap")
    def validarResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Valida solo los datos del paso Responsable Adulto.
        Se usa al presionar Siguiente en Alta Destinatario.
        """
        errores = validar_responsable(datos)

        return {
            "valido": len(errores) == 0,
            "errores": errores,
            "mensaje": errores_a_texto(errores),
        }

    # ============================================================
    # GENERACIÓN DE SOLICITUD
    # ============================================================

    @Slot("QVariantMap", result=str)
    def generarSolicitud(self, datos: dict[str, Any]) -> str:
        try:
            # Validación final de seguridad.
            # La validación principal se hace por paso desde QML.
            resultado_validacion = validar_solicitud_alta(datos)

            if not resultado_validacion["valido"]:
                errores = errores_a_texto(resultado_validacion["errores"])
                return f"ERROR|No se pudo generar la solicitud:\n{errores}"

            datos_excel = self._mapear_datos_destinatario(datos)

            ruta_salida = self._crear_ruta_salida(datos_excel)

            generar_solicitud_alta(
                datos=datos_excel,
                ruta_salida=ruta_salida,
            )

            if not ruta_salida.exists():
                return f"ERROR|El archivo no se generó en la ruta esperada: {ruta_salida}"

            ruta_copia_externa = self._copiar_a_carpeta_externa_si_corresponde(ruta_salida)

            self._abrir_archivo(ruta_salida)

            if ruta_copia_externa:
                return (
                    f"OK|Solicitud generada correctamente: {ruta_salida}\n"
                    f"Copia externa generada en: {ruta_copia_externa}"
                )

            return f"OK|Solicitud generada correctamente: {ruta_salida}"

        except Exception as error:
            return f"ERROR|No se pudo generar la solicitud: {error}"

    @Slot("QVariantMap", result="QVariantMap")
    def prepararDatosSolicitud(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Prepara los datos finales de la solicitud sin generar el archivo Excel.
        Sirve para previsualización.
        """
        try:
            return self._mapear_datos_destinatario(datos)

        except Exception as error:
            print(f"ERROR al preparar datos de solicitud: {error}")
            return {
                "error": f"No se pudieron preparar los datos de la solicitud: {error}"
            }

    def _obtener_fecha_actual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    def _calcular_edad(self, fecha_nacimiento: str) -> str:
        """
        Calcula la edad a partir de una fecha de nacimiento en formato dd/mm/aaaa.
        Si la fecha está vacía o tiene formato inválido, devuelve cadena vacía.
        """
        fecha_nacimiento = str(fecha_nacimiento).strip()

        if not fecha_nacimiento:
            return ""

        try:
            nacimiento = datetime.strptime(fecha_nacimiento, "%d/%m/%Y").date()
            hoy = date.today()
            edad = hoy.year - nacimiento.year

            if (hoy.month, hoy.day) < (nacimiento.month, nacimiento.day):
                edad -= 1

            return str(edad)

        except ValueError:
            return ""

    def _cargar_configuracion_sede(self) -> dict[str, Any]:
        base_dir = Path(__file__).resolve().parent.parent
        config_path = base_dir / "config" / "configuracion_sede.json"

        configuracion_vacia = {
            "nombreSede": "",
            "origen": "",
            "municipio": "",
            "localidad": "",
            "barrio": "",
            "fechaAutomatica": True,
            "edadAutomatica": True,
            "fechaActual": self._obtener_fecha_actual(),
        }

        if not config_path.exists():
            return configuracion_vacia

        try:
            with config_path.open("r", encoding="utf-8") as archivo:
                configuracion = json.load(archivo)

            return {
                "nombreSede": str(configuracion.get("nombreSede", "")),
                "origen": str(configuracion.get("origen", "")),
                "municipio": str(configuracion.get("municipio", "")),
                "localidad": str(configuracion.get("localidad", "")),
                "barrio": str(configuracion.get("barrio", "")),
                "fechaAutomatica": bool(configuracion.get("fechaAutomatica", True)),
                "edadAutomatica": bool(configuracion.get("edadAutomatica", True)),
                "fechaActual": str(configuracion.get("fechaActual", self._obtener_fecha_actual())),
            }

        except Exception as error:
            print(f"ERROR al cargar configuración de sede: {error}")
            return configuracion_vacia

    def _cargar_configuracion_guardado(self) -> dict[str, Any]:
        base_dir = Path(__file__).resolve().parent.parent
        config_dir = base_dir / "config"
        config_path = config_dir / "configuracion_guardado.json"

        configuracion_vacia = {
            "carpeta_copia_externa_solicitudes": ""
        }

        config_dir.mkdir(parents=True, exist_ok=True)

        if not config_path.exists():
            with config_path.open("w", encoding="utf-8") as archivo:
                json.dump(configuracion_vacia, archivo, indent=4, ensure_ascii=False)

            return configuracion_vacia

        try:
            with config_path.open("r", encoding="utf-8") as archivo:
                configuracion = json.load(archivo)

            return {
                "carpeta_copia_externa_solicitudes": str(
                    configuracion.get("carpeta_copia_externa_solicitudes", "")
                )
            }

        except Exception as error:
            print(f"ERROR al cargar configuración de guardado: {error}")
            return configuracion_vacia

    def _mapear_datos_destinatario(self, datos: dict[str, Any]) -> dict[str, Any]:
        configuracion_sede = self._cargar_configuracion_sede()

        fecha_automatica = bool(configuracion_sede.get("fechaAutomatica", True))
        edad_automatica = bool(configuracion_sede.get("edadAutomatica", True))

        fecha = (
            self._obtener_fecha_actual()
            if fecha_automatica
            else configuracion_sede.get("fechaActual", "")
        )

        edad_destinatario = (
            self._calcular_edad(datos.get("fechaNacimiento", ""))
            if edad_automatica
            else datos.get("edad", "")
        )

        edad_responsable = (
            self._calcular_edad(datos.get("responsableFechaNacimiento", ""))
            if edad_automatica
            else datos.get("responsableEdad", "")
        )

        return {
            "fecha": fecha,
            "origen": configuracion_sede.get("origen", ""),
            "municipio": configuracion_sede.get("municipio", ""),
            "sede": configuracion_sede.get("nombreSede", ""),
            "barrio": configuracion_sede.get("barrio", ""),
            "localidad": configuracion_sede.get("localidad", ""),

            "destinatario_nombre": datos.get("nombre", ""),
            "destinatario_apellido": datos.get("apellido", ""),
            "destinatario_dni": datos.get("dni", ""),
            "destinatario_direccion": datos.get("direccion", ""),
            "destinatario_fecha_nacimiento": datos.get("fechaNacimiento", ""),
            "destinatario_edad": edad_destinatario,
            "destinatario_escolarizado": datos.get("escolarizado", ""),

            "responsable_nombre": datos.get("responsableNombre", ""),
            "responsable_apellido": datos.get("responsableApellido", ""),
            "responsable_telefono": datos.get("responsableTelefono", ""),
            "responsable_domicilio": datos.get("responsableDomicilio", ""),
            "responsable_dni": datos.get("responsableDni", ""),
            "responsable_parentesco": datos.get("responsableParentesco", ""),
            "responsable_fecha_nacimiento": datos.get("responsableFechaNacimiento", ""),
            "responsable_edad": edad_responsable,
        }

    def _crear_ruta_salida(self, datos_excel: dict[str, Any]) -> Path:
        base_dir = Path(__file__).resolve().parent.parent

        output_dir = base_dir / "output" / "solicitudes_generadas"
        output_dir.mkdir(parents=True, exist_ok=True)

        nombre = str(datos_excel.get("destinatario_nombre", "")).strip()
        apellido = str(datos_excel.get("destinatario_apellido", "")).strip()

        nombre_completo = f"{nombre} {apellido}".strip()

        if not nombre_completo:
            nombre_completo = "sin_nombre"

        nombre_limpio = self._limpiar_nombre_archivo(nombre_completo)

        nombre_base = f"solicitud_de_alta_{nombre_limpio}"
        extension = ".xlsx"

        ruta = output_dir / f"{nombre_base}{extension}"

        contador = 1

        while ruta.exists():
            ruta = output_dir / f"{nombre_base}_{contador}{extension}"
            contador += 1

        return ruta.resolve()

    def _copiar_a_carpeta_externa_si_corresponde(self, ruta_origen: Path) -> Path | None:
        configuracion = self._cargar_configuracion_guardado()

        carpeta_externa = str(
            configuracion.get("carpeta_copia_externa_solicitudes", "")
        ).strip()

        if not carpeta_externa:
            return None

        ruta_carpeta_externa = Path(carpeta_externa).expanduser()
        ruta_carpeta_externa.mkdir(parents=True, exist_ok=True)

        ruta_destino = ruta_carpeta_externa / ruta_origen.name

        contador = 1
        nombre_base = ruta_origen.stem
        extension = ruta_origen.suffix

        while ruta_destino.exists():
            ruta_destino = ruta_carpeta_externa / f"{nombre_base}_{contador}{extension}"
            contador += 1

        shutil.copy2(ruta_origen, ruta_destino)

        return ruta_destino.resolve()

    def _limpiar_nombre_archivo(self, texto: str) -> str:
        texto = texto.strip().lower()

        reemplazos = {
            "á": "a",
            "é": "e",
            "í": "i",
            "ó": "o",
            "ú": "u",
            "ñ": "n",
        }

        for original, reemplazo in reemplazos.items():
            texto = texto.replace(original, reemplazo)

        texto = re.sub(r"[^a-zA-Z0-9 _-]", "", texto)
        texto = re.sub(r"\s+", "_", texto)
        texto = re.sub(r"_+", "_", texto)

        return texto.strip("_")

    def _abrir_archivo(self, ruta: Path) -> None:
        ruta = ruta.resolve()

        if sys.platform.startswith("linux"):
            libreoffice = shutil.which("libreoffice")

            if libreoffice:
                subprocess.Popen(
                    [libreoffice, "--calc", str(ruta)],
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



