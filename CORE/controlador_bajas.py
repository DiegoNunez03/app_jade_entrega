# app_jade / CORE / controlador_bajas.py

from pathlib import Path
from typing import Any
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import date

from PySide6.QtCore import QObject, Slot

from .validaciones import (
    validar_baja_institucional,
    validar_baja_beneficiario,
    validar_baja_responsable,
    validar_solicitud_baja,
    errores_a_texto,
)

from .generador_baja import generar_solicitud_baja


class ControladorBajas(QObject):
    """
    Puente entre QML y el generador de solicitud de baja.

    Recibe datos desde QML, valida por pasos, prepara datos para
    previsualización y genera la solicitud en formato DOCX.
    """

    # ============================================================
    # VALIDACIONES POR PASO
    # ============================================================

    @Slot("QVariantMap", result="QVariantMap")
    def validarBajaInstitucional(self, datos: dict[str, Any]) -> dict[str, Any]:
        return validar_baja_institucional(datos)

    @Slot("QVariantMap", result="QVariantMap")
    def validarBajaBeneficiario(self, datos: dict[str, Any]) -> dict[str, Any]:
        return validar_baja_beneficiario(datos)

    @Slot("QVariantMap", result="QVariantMap")
    def validarBajaResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
        return validar_baja_responsable(datos)

    # ============================================================
    # PREVISUALIZACIÓN
    # ============================================================

    @Slot("QVariantMap", result="QVariantMap")
    def prepararDatosBaja(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Prepara los datos finales de la baja sin generar archivos.
        Se usa para la previsualización QML.
        """
        try:
            return self._mapear_datos_baja(datos)

        except Exception as error:
            print(f"ERROR al preparar datos de baja: {error}")
            return {
                "error": f"No se pudieron preparar los datos de la baja: {error}"
            }

    # ============================================================
    # GENERACIÓN
    # ============================================================

    @Slot("QVariantMap", result=str)
    def generarSolicitudBaja(self, datos: dict[str, Any]) -> str:
        try:
            datos_baja = self._mapear_datos_baja(datos)

            resultado_validacion = validar_solicitud_baja(datos_baja)

            if not resultado_validacion["valido"]:
                errores = errores_a_texto(resultado_validacion["errores"])
                return f"ERROR|No se pudo generar la solicitud de baja:\n{errores}"

            ruta_docx = self._crear_ruta_salida(datos_baja)

            generar_solicitud_baja(
                datos=datos_baja,
                ruta_docx=ruta_docx,
            )

            if not ruta_docx.exists():
                return f"ERROR|El archivo DOCX no se generó en la ruta esperada: {ruta_docx}"

            copias_externas = self._copiar_archivos_a_carpeta_externa_si_corresponde(
                [ruta_docx]
            )

            self._abrir_archivo(ruta_docx)

            mensaje = f"OK|Solicitud de baja generada correctamente:\nDOCX: {ruta_docx}"

            if copias_externas:
                mensaje += "\nCopias externas generadas:"
                for ruta_copia in copias_externas:
                    mensaje += f"\n- {ruta_copia}"

            return mensaje

        except Exception as error:
            return f"ERROR|No se pudo generar la solicitud de baja: {error}"

    # ============================================================
    # MAPEO DE DATOS
    # ============================================================

    def _mapear_datos_baja(self, datos: dict[str, Any]) -> dict[str, Any]:
        configuracion_sede = self._cargar_configuracion_sede()

        sede_configurada = str(configuracion_sede.get("nombreSede", "")).strip()

        datos_mapeados = {
            # Institucional
            "centroEnvion": str(datos.get("centroEnvion", "Centro Envión")).strip(),
            "sede": str(datos.get("sede", sede_configurada)).strip() or sede_configurada,
            "modalidad": str(datos.get("modalidad", "")).strip(),
            "profesionalesIntervinientes": self._normalizar_lista_profesionales(
                datos.get("profesionalesIntervinientes", [])
            ),
            "profesionalesIntervinientesTexto": str(
                datos.get("profesionalesIntervinientesTexto", "")
            ).strip(),
            "coordinadora": str(datos.get("coordinadora", "")).strip(),
            "fechaBaja": str(datos.get("fechaBaja", "")).strip(),

            # Beneficiario
            "bajaTipoBeneficiario": str(datos.get("bajaTipoBeneficiario", "")).strip(),
            "bajaNombre": str(datos.get("bajaNombre", "")).strip(),
            "bajaApellido": str(datos.get("bajaApellido", "")).strip(),
            "bajaNombreCompleto": str(datos.get("bajaNombreCompleto", "")).strip(),
            "bajaTipoDni": str(datos.get("bajaTipoDni", "")).strip(),
            "bajaDni": str(datos.get("bajaDni", "")).strip(),
            "bajaFechaIngreso": str(datos.get("bajaFechaIngreso", "")).strip(),
            "bajaMotivo": str(datos.get("bajaMotivo", "")).strip(),

            # Responsable Adulto
            "bajaResponsableNombre": str(datos.get("bajaResponsableNombre", "")).strip(),
            "bajaResponsableApellido": str(datos.get("bajaResponsableApellido", "")).strip(),
            "bajaResponsableNombreCompleto": str(
                datos.get("bajaResponsableNombreCompleto", "")
            ).strip(),
            "bajaResponsableRelacion": str(
                datos.get("bajaResponsableRelacion", "")
            ).strip(),
            "bajaResponsableInformado": str(
                datos.get("bajaResponsableInformado", "")
            ).strip(),

            # Datos útiles para documento
            "fechaEmision": self._obtener_fecha_actual(),
        }

        if not datos_mapeados["profesionalesIntervinientesTexto"]:
            datos_mapeados["profesionalesIntervinientesTexto"] = " / ".join(
                datos_mapeados["profesionalesIntervinientes"]
            )

        if not datos_mapeados["bajaNombreCompleto"]:
            datos_mapeados["bajaNombreCompleto"] = (
                f"{datos_mapeados['bajaNombre']} {datos_mapeados['bajaApellido']}"
            ).strip()

        if not datos_mapeados["bajaResponsableNombreCompleto"]:
            datos_mapeados["bajaResponsableNombreCompleto"] = (
                f"{datos_mapeados['bajaResponsableNombre']} "
                f"{datos_mapeados['bajaResponsableApellido']}"
            ).strip()

        datos_mapeados.update(
            self._crear_marcas_documento(datos_mapeados)
        )

        return datos_mapeados

    def _crear_marcas_documento(self, datos: dict[str, Any]) -> dict[str, str]:
        """
        Crea marcas auxiliares para el documento:
        - tipo beneficiario;
        - responsable informado;
        - motivo seleccionado.
        """

        tipo = datos.get("bajaTipoBeneficiario", "")
        informado = datos.get("bajaResponsableInformado", "")
        motivo = datos.get("bajaMotivo", "")

        motivos = [
            "Encontrarse privado de la libertad",
            "Fallecimiento",
            "Haber cumplimentado con todos los acuerdos para su egreso",
            "Liquidaciones consecutivas impagas",
            "Mudanza a otro Municipio",
            "Negativa a cumplir con su Acuerdo de Compromiso",
            "Negativa del Joven a participar",
            "Negativa o dificultades al momento de la socialización",
            "Pase de Destinatario a Tutor",
            "Pase de Tutor a Destinatario",
            "Trabajo Formal",
            "Otros motivos",
        ]

        marcas = {
            "marcaTipoDestinatario": "X" if tipo == "Destinatario" else "",
            "marcaTipoTutor": "X" if tipo == "Tutor" else "",
            "marcaResponsableInformadoSi": "X" if informado in {"Sí", "Si"} else "",
            "marcaResponsableInformadoNo": "X" if informado == "No" else "",
        }

        for indice, motivo_actual in enumerate(motivos, start=1):
            campo = f"marcaMotivo{indice:02d}"
            marcas[campo] = "X" if motivo == motivo_actual else ""

        return marcas

    # ============================================================
    # CONFIGURACIÓN
    # ============================================================

    def _obtener_fecha_actual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

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
                "fechaActual": str(
                    configuracion.get("fechaActual", self._obtener_fecha_actual())
                ),
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

    # ============================================================
    # RUTAS Y ARCHIVOS
    # ============================================================

    def _crear_ruta_salida(self, datos_baja: dict[str, Any]) -> Path:
        base_dir = Path(__file__).resolve().parent.parent

        output_dir = base_dir / "output" / "solicitudes_generadas"
        output_dir.mkdir(parents=True, exist_ok=True)

        nombre_completo = str(datos_baja.get("bajaNombreCompleto", "")).strip()

        if not nombre_completo:
            nombre = str(datos_baja.get("bajaNombre", "")).strip()
            apellido = str(datos_baja.get("bajaApellido", "")).strip()
            nombre_completo = f"{nombre} {apellido}".strip()

        if not nombre_completo:
            nombre_completo = "sin_nombre"

        nombre_limpio = self._limpiar_nombre_archivo(nombre_completo)

        nombre_base = f"solicitud_de_baja_{nombre_limpio}"
        extension = ".docx"

        ruta = output_dir / f"{nombre_base}{extension}"

        contador = 1

        while ruta.exists():
            ruta = output_dir / f"{nombre_base}_{contador}{extension}"
            contador += 1

        return ruta.resolve()

    def _copiar_archivos_a_carpeta_externa_si_corresponde(
        self,
        rutas_origen: list[Path],
    ) -> list[Path]:
        configuracion = self._cargar_configuracion_guardado()

        carpeta_externa = str(
            configuracion.get("carpeta_copia_externa_solicitudes", "")
        ).strip()

        if not carpeta_externa:
            return []

        ruta_carpeta_externa = Path(carpeta_externa).expanduser()
        ruta_carpeta_externa.mkdir(parents=True, exist_ok=True)

        rutas_copiadas: list[Path] = []

        for ruta_origen in rutas_origen:
            if not ruta_origen.exists():
                continue

            ruta_destino = ruta_carpeta_externa / ruta_origen.name

            contador = 1
            nombre_base = ruta_origen.stem
            extension = ruta_origen.suffix

            while ruta_destino.exists():
                ruta_destino = ruta_carpeta_externa / f"{nombre_base}_{contador}{extension}"
                contador += 1

            shutil.copy2(ruta_origen, ruta_destino)
            rutas_copiadas.append(ruta_destino.resolve())

        return rutas_copiadas

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

    def _normalizar_lista_profesionales(self, valor: Any) -> list[str]:
        if isinstance(valor, list):
            return [str(item).strip() for item in valor if str(item).strip()]

        if isinstance(valor, tuple):
            return [str(item).strip() for item in valor if str(item).strip()]

        texto = str(valor).strip()

        if not texto:
            return []

        return [parte.strip() for parte in texto.split("/") if parte.strip()]

    def _abrir_archivo(self, ruta: Path) -> None:
        ruta = ruta.resolve()

        if sys.platform.startswith("linux"):
            libreoffice = shutil.which("libreoffice")

            if libreoffice:
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


