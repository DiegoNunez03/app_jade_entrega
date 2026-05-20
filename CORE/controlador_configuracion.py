# app_jade / CORE / controlador_configuracion.py

from pathlib import Path
from typing import Any
import json
import os
import shutil
import subprocess
import sys
from datetime import date, datetime
from urllib.parse import urlparse, unquote

from PySide6.QtCore import QObject, Slot


class ControladorConfiguracion(QObject):
    """
    Controlador encargado de guardar y cargar configuraciones del sistema.
    """

    def __init__(self) -> None:
        super().__init__()

        self.base_dir = Path(__file__).resolve().parent.parent
        self.config_dir = self.base_dir / "config"

        self.config_path = self.config_dir / "configuracion_sede.json"
        self.config_guardado_path = self.config_dir / "configuracion_guardado.json"

        self.config_dir.mkdir(parents=True, exist_ok=True)

    @Slot("QVariantMap", result=str)
    def guardarConfiguracionAutomatica(self, datos: dict[str, Any]) -> str:
        try:
            configuracion_actual = self._leer_configuracion_general()

            configuracion_actual["fechaAutomatica"] = bool(datos.get("fechaAutomatica", True))
            configuracion_actual["edadAutomatica"] = bool(datos.get("edadAutomatica", True))
            configuracion_actual["fechaActual"] = str(
                datos.get("fechaActual", self.obtenerFechaActual())
            ).strip()

            self._guardar_configuracion_general(configuracion_actual)

            return "OK|Configuración automática guardada correctamente"

        except Exception as error:
            return f"ERROR|No se pudo guardar la configuración automática: {error}"

    @Slot(result="QVariantMap")
    def cargarConfiguracionAutomatica(self) -> dict[str, Any]:
        configuracion = self._leer_configuracion_general()

        fecha_automatica = bool(configuracion.get("fechaAutomatica", True))
        edad_automatica = bool(configuracion.get("edadAutomatica", True))

        if fecha_automatica:
            fecha_actual = self.obtenerFechaActual()
        else:
            fecha_actual = str(
                configuracion.get("fechaActual", self.obtenerFechaActual())
            ).strip()

        return {
            "fechaAutomatica": fecha_automatica,
            "edadAutomatica": edad_automatica,
            "fechaActual": fecha_actual,
        }

    @Slot(result=str)
    def obtenerFechaActual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    def _leer_configuracion_general(self) -> dict[str, Any]:
        if not self.config_path.exists():
            return {}

        try:
            with self.config_path.open("r", encoding="utf-8") as archivo:
                return json.load(archivo)

        except Exception:
            return {}

    def _guardar_configuracion_general(self, configuracion: dict[str, Any]) -> None:
        self.config_dir.mkdir(parents=True, exist_ok=True)

        with self.config_path.open("w", encoding="utf-8") as archivo:
            json.dump(configuracion, archivo, ensure_ascii=False, indent=4)

    @Slot("QVariantMap", result=str)
    def guardarConfiguracionSede(self, datos: dict[str, Any]) -> str:
        try:
            configuracion_actual = self._leer_configuracion_general()

            configuracion_actual["nombreSede"] = str(datos.get("nombreSede", "")).strip()
            configuracion_actual["origen"] = str(datos.get("origen", "")).strip()
            configuracion_actual["municipio"] = str(datos.get("municipio", "")).strip()
            configuracion_actual["localidad"] = str(datos.get("localidad", "")).strip()
            configuracion_actual["barrio"] = str(datos.get("barrio", "")).strip()

            self._guardar_configuracion_general(configuracion_actual)

            return f"OK|Configuración de sede guardada correctamente: {self.config_path}"

        except Exception as error:
            return f"ERROR|No se pudo guardar la configuración de sede: {error}"

    @Slot(result="QVariantMap")
    def cargarConfiguracionSede(self) -> dict[str, Any]:
        try:
            if not self.config_path.exists():
                return {
                    "nombreSede": "",
                    "origen": "",
                    "municipio": "",
                    "localidad": "",
                    "barrio": "",
                    "fechaActual": self.obtenerFechaActual(),
                }

            with self.config_path.open("r", encoding="utf-8") as archivo:
                configuracion = json.load(archivo)

            return {
                "nombreSede": str(configuracion.get("nombreSede", "")),
                "origen": str(configuracion.get("origen", "")),
                "municipio": str(configuracion.get("municipio", "")),
                "localidad": str(configuracion.get("localidad", "")),
                "barrio": str(configuracion.get("barrio", "")),
                "fechaActual": self.obtenerFechaActual(),
            }

        except Exception as error:
            print(f"ERROR al cargar configuración de sede: {error}")

            return {
                "nombreSede": "",
                "origen": "",
                "municipio": "",
                "localidad": "",
                "barrio": "",
                "fechaActual": self.obtenerFechaActual(),
            }

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

            for ruta in carpeta.glob("*.xlsx"):
                if not ruta.is_file():
                    continue

                estadisticas = ruta.stat()

                archivos.append({
                    "nombreArchivo": ruta.name,
                    "rutaArchivo": str(ruta.resolve()),
                    "fechaModificacion": self._formatear_fecha_archivo(
                        estadisticas.st_mtime
                    ),
                    "tamanioBytes": estadisticas.st_size,
                })

            archivos.sort(
                key=lambda archivo: archivo.get("fechaModificacion", ""),
                reverse=True
            )

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