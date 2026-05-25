# app_jade / CORE / controlador_destinatarios.py

from pathlib import Path
from typing import Any, Optional
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import date

from PySide6.QtCore import QObject, Slot

from ..calendario_asistencia import (
    obtener_periodo_semanal,
    obtener_periodo_mensual,
)
from ..generador_lista_asistencia import generar_lista_asistencia


class ControladorDestinatarios(QObject):
    """
    Controlador encargado de registrar, listar destinatarios,
    eliminar destinatarios y generar listas de asistencia por turno.
    Guarda los datos en un archivo JSON operativo del sistema.
    """

    def __init__(self) -> None:
        super().__init__()

        self.base_dir = Path(__file__).resolve().parent.parent
        self.data_dir = self.base_dir / "data"
        self.config_dir = self.base_dir / "config"

        self.destinatarios_path = self.data_dir / "destinatarios.json"
        self.config_sede_path = self.config_dir / "configuracion_sede.json"

        self._asegurar_archivo_destinatarios()

    def _asegurar_archivo_destinatarios(self) -> None:
        self.data_dir.mkdir(parents=True, exist_ok=True)

        if not self.destinatarios_path.exists():
            with self.destinatarios_path.open("w", encoding="utf-8") as archivo:
                json.dump([], archivo, ensure_ascii=False, indent=4)

    def _leer_destinatarios(self) -> list[dict[str, Any]]:
        self._asegurar_archivo_destinatarios()

        try:
            with self.destinatarios_path.open("r", encoding="utf-8") as archivo:
                datos = json.load(archivo)

            if isinstance(datos, list):
                return datos

            return []

        except Exception as error:
            print(f"ERROR al leer destinatarios: {error}")
            return []

    def _guardar_destinatarios(self, destinatarios: list[dict[str, Any]]) -> None:
        self._asegurar_archivo_destinatarios()

        with self.destinatarios_path.open("w", encoding="utf-8") as archivo:
            json.dump(destinatarios, archivo, ensure_ascii=False, indent=4)

    def _normalizar_texto(self, valor: Any) -> str:
        return str(valor).strip()

    def _normalizar_texto_busqueda(self, valor: Any) -> str:
        texto = str(valor).strip().lower()

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

        texto = re.sub(r"\s+", " ", texto)

        return texto.strip()

    def _normalizar_turno(self, valor: Any) -> str:
        turno = str(valor).strip().lower()

        reemplazos = {
            "á": "a",
            "é": "e",
            "í": "i",
            "ó": "o",
            "ú": "u",
        }

        for original, reemplazo in reemplazos.items():
            turno = turno.replace(original, reemplazo)

        if turno in ["manana", "mañana"]:
            return "mañana"

        if turno == "tarde":
            return "tarde"

        return ""

    def _validar_nombre_o_apellido(self, valor: str) -> bool:
        """
        Acepta letras, acentos, ñ, espacios, apóstrofe y guion.
        """
        patron = r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'-]+$"
        return bool(re.match(patron, valor))

    def _obtener_siguiente_id(self, destinatarios: list[dict[str, Any]]) -> int:
        if not destinatarios:
            return 1

        ids = []

        for destinatario in destinatarios:
            try:
                ids.append(int(destinatario.get("id", 0)))
            except Exception:
                continue

        if not ids:
            return 1

        return max(ids) + 1

    def _buscar_duplicado_destinatario(
        self,
        destinatarios: list[dict[str, Any]],
        nombre: str,
        apellido: str,
        id_excluido: Any = None,
    ) -> Optional[dict[str, Any]]:
        nombre_normalizado = self._normalizar_texto_busqueda(nombre)
        apellido_normalizado = self._normalizar_texto_busqueda(apellido)

        if not nombre_normalizado or not apellido_normalizado:
            return None

        for destinatario in destinatarios:
            try:
                id_actual = int(destinatario.get("id", 0))
            except Exception:
                id_actual = 0

            if id_excluido is not None and id_actual == id_excluido:
                continue

            nombre_actual = self._normalizar_texto_busqueda(
                destinatario.get("nombre", "")
            )
            apellido_actual = self._normalizar_texto_busqueda(
                destinatario.get("apellido", "")
            )

            if not nombre_actual or not apellido_actual:
                continue

            coincide_directo = (
                nombre_actual == nombre_normalizado
                and apellido_actual == apellido_normalizado
            )

            coincide_invertido = (
                nombre_actual == apellido_normalizado
                and apellido_actual == nombre_normalizado
            )

            if coincide_directo or coincide_invertido:
                return destinatario

        return None

    @Slot("QVariantMap", result=str)
    def registrarDestinatario(self, datos: dict[str, Any]) -> str:
        try:
            nombre = self._normalizar_texto(datos.get("nombre", ""))
            apellido = self._normalizar_texto(datos.get("apellido", ""))
            turno = self._normalizar_turno(datos.get("turno", ""))

            if not nombre:
                return "ERROR|El nombre es obligatorio."

            if not apellido:
                return "ERROR|El apellido es obligatorio."

            if not self._validar_nombre_o_apellido(nombre):
                return "ERROR|El nombre contiene caracteres no permitidos."

            if not self._validar_nombre_o_apellido(apellido):
                return "ERROR|El apellido contiene caracteres no permitidos."

            if turno not in ["mañana", "tarde"]:
                return "ERROR|El turno debe ser mañana o tarde."

            destinatarios = self._leer_destinatarios()

            duplicado = self._buscar_duplicado_destinatario(
                destinatarios=destinatarios,
                nombre=nombre,
                apellido=apellido,
            )

            if duplicado is not None:
                nombre_existente = self._normalizar_texto(duplicado.get("nombre", ""))
                apellido_existente = self._normalizar_texto(duplicado.get("apellido", ""))
                turno_existente = self._normalizar_turno(duplicado.get("turno", ""))
                detalle_turno = f" - turno {turno_existente}" if turno_existente else ""
                return (
                    "ERROR|El destinatario ya fue registrado previamente: "
                    f"{apellido_existente}, {nombre_existente}{detalle_turno}"
                )

            nuevo_destinatario = {
                "id": self._obtener_siguiente_id(destinatarios),
                "nombre": nombre,
                "apellido": apellido,
                "turno": turno,
            }

            destinatarios.append(nuevo_destinatario)

            destinatarios.sort(
                key=lambda item: (
                    str(item.get("apellido", "")).lower(),
                    str(item.get("nombre", "")).lower(),
                )
            )

            self._guardar_destinatarios(destinatarios)

            return (
                "OK|Destinatario registrado correctamente: "
                f"{apellido}, {nombre} - turno {turno}"
            )

        except Exception as error:
            return f"ERROR|No se pudo registrar el destinatario: {error}"

    @Slot(result="QVariantList")
    def listarDestinatarios(self) -> list[dict[str, Any]]:
        destinatarios = self._leer_destinatarios()

        destinatarios.sort(
            key=lambda item: (
                str(item.get("apellido", "")).lower(),
                str(item.get("nombre", "")).lower(),
            )
        )

        return destinatarios

    @Slot(str, result="QVariantList")
    def listarDestinatariosPorTurno(self, turno: str) -> list[dict[str, Any]]:
        turno_normalizado = self._normalizar_turno(turno)

        if turno_normalizado not in ["mañana", "tarde"]:
            return self.listarDestinatarios()

        destinatarios = self._leer_destinatarios()

        filtrados = [
            destinatario
            for destinatario in destinatarios
            if self._normalizar_turno(destinatario.get("turno", "")) == turno_normalizado
        ]

        filtrados.sort(
            key=lambda item: (
                str(item.get("apellido", "")).lower(),
                str(item.get("nombre", "")).lower(),
            )
        )

        return filtrados


    @Slot(str, str, result="QVariantList")
    def buscarDestinatarios(self, busqueda: str, filtro_turno: str = "todos") -> list[dict[str, Any]]:
        termino = self._normalizar_texto_busqueda(busqueda)
        turno_normalizado = self._normalizar_turno(filtro_turno)

        if not termino:
            if turno_normalizado in ["mañana", "tarde"]:
                return self.listarDestinatariosPorTurno(turno_normalizado)

            return self.listarDestinatarios()

        destinatarios = self._leer_destinatarios()
        palabras_busqueda = [
            palabra
            for palabra in termino.split(" ")
            if palabra.strip()
        ]

        filtrados = []

        for destinatario in destinatarios:
            turno_destinatario = self._normalizar_turno(destinatario.get("turno", ""))

            if turno_normalizado in ["mañana", "tarde"] and turno_destinatario != turno_normalizado:
                continue

            nombre = self._normalizar_texto_busqueda(destinatario.get("nombre", ""))
            apellido = self._normalizar_texto_busqueda(destinatario.get("apellido", ""))
            nombre_completo = f"{nombre} {apellido}".strip()
            apellido_nombre = f"{apellido} {nombre}".strip()

            coincide = all(
                palabra in nombre_completo or palabra in apellido_nombre
                for palabra in palabras_busqueda
            )

            if coincide:
                filtrados.append(destinatario)

        filtrados.sort(
            key=lambda item: (
                str(item.get("apellido", "")).lower(),
                str(item.get("nombre", "")).lower(),
            )
        )

        return filtrados

    @Slot(int, "QVariantMap", result=str)
    def modificarDestinatario(self, id_destinatario: int, datos: dict[str, Any]) -> str:
        try:
            try:
                id_buscado = int(id_destinatario)
            except Exception:
                return "ERROR|El identificador del destinatario no es válido."

            nombre = self._normalizar_texto(datos.get("nombre", ""))
            apellido = self._normalizar_texto(datos.get("apellido", ""))
            turno = self._normalizar_turno(datos.get("turno", ""))

            if not nombre:
                return "ERROR|El nombre es obligatorio."

            if not apellido:
                return "ERROR|El apellido es obligatorio."

            if not self._validar_nombre_o_apellido(nombre):
                return "ERROR|El nombre contiene caracteres no permitidos."

            if not self._validar_nombre_o_apellido(apellido):
                return "ERROR|El apellido contiene caracteres no permitidos."

            if turno not in ["mañana", "tarde"]:
                return "ERROR|El turno debe ser mañana o tarde."

            destinatarios = self._leer_destinatarios()

            duplicado = self._buscar_duplicado_destinatario(
                destinatarios=destinatarios,
                nombre=nombre,
                apellido=apellido,
                id_excluido=id_buscado,
            )

            if duplicado is not None:
                nombre_existente = self._normalizar_texto(duplicado.get("nombre", ""))
                apellido_existente = self._normalizar_texto(duplicado.get("apellido", ""))
                turno_existente = self._normalizar_turno(duplicado.get("turno", ""))
                detalle_turno = f" - turno {turno_existente}" if turno_existente else ""
                return (
                    "ERROR|Ya existe otro destinatario registrado con ese nombre y apellido: "
                    f"{apellido_existente}, {nombre_existente}{detalle_turno}"
                )

            destinatario_modificado = None

            for destinatario in destinatarios:
                try:
                    if int(destinatario.get("id", 0)) == id_buscado:
                        destinatario["nombre"] = nombre
                        destinatario["apellido"] = apellido
                        destinatario["turno"] = turno
                        destinatario_modificado = destinatario
                        break
                except Exception:
                    continue

            if destinatario_modificado is None:
                return "ERROR|No se encontró el destinatario indicado."

            destinatarios.sort(
                key=lambda item: (
                    str(item.get("apellido", "")).lower(),
                    str(item.get("nombre", "")).lower(),
                )
            )

            self._guardar_destinatarios(destinatarios)

            return f"OK|Destinatario modificado correctamente: {apellido}, {nombre} - turno {turno}"

        except Exception as error:
            return f"ERROR|No se pudo modificar el destinatario: {error}"

    # ============================================================
    # ELIMINACIÓN DE DESTINATARIOS
    # ============================================================

    @Slot(int, result=str)
    def eliminarDestinatario(self, id_destinatario: int) -> str:
        try:
            try:
                id_buscado = int(id_destinatario)
            except Exception:
                return "ERROR|El identificador del destinatario no es válido."

            destinatarios = self._leer_destinatarios()

            destinatario_encontrado = None

            for destinatario in destinatarios:
                try:
                    if int(destinatario.get("id", 0)) == id_buscado:
                        destinatario_encontrado = destinatario
                        break
                except Exception:
                    continue

            if destinatario_encontrado is None:
                return "ERROR|No se encontró el destinatario indicado."

            destinatarios_filtrados = []

            for destinatario in destinatarios:
                try:
                    if int(destinatario.get("id", 0)) != id_buscado:
                        destinatarios_filtrados.append(destinatario)
                except Exception:
                    destinatarios_filtrados.append(destinatario)

            self._guardar_destinatarios(destinatarios_filtrados)

            apellido = self._normalizar_texto(destinatario_encontrado.get("apellido", ""))
            nombre = self._normalizar_texto(destinatario_encontrado.get("nombre", ""))

            return f"OK|Destinatario eliminado correctamente: {apellido}, {nombre}"

        except Exception as error:
            return f"ERROR|No se pudo eliminar el destinatario: {error}"

    # ============================================================
    # CONFIGURACIÓN AUXILIAR
    # ============================================================

    def _obtener_nombre_sede(self) -> str:
        if not self.config_sede_path.exists():
            return ""

        try:
            with self.config_sede_path.open("r", encoding="utf-8") as archivo:
                configuracion = json.load(archivo)

            return str(configuracion.get("nombreSede", "")).strip()

        except Exception as error:
            print(f"ERROR al leer sede para lista de asistencia: {error}")
            return ""

    # ============================================================
    # GENERACIÓN DE LISTAS DE ASISTENCIA
    # ============================================================

    def _obtener_carpeta_listas_asistencia(self) -> Path:
        carpeta = self.base_dir / "output" / "listas_asistencia"
        carpeta.mkdir(parents=True, exist_ok=True)
        return carpeta.resolve()

    def _limpiar_nombre_archivo(self, texto: str) -> str:
        texto = str(texto).strip().lower()

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

    def _crear_ruta_lista_asistencia(self, turno: str, tipo_lista: str) -> Path:
        carpeta = self._obtener_carpeta_listas_asistencia()

        fecha = date.today().strftime("%Y_%m_%d")
        turno_limpio = self._limpiar_nombre_archivo(turno)
        tipo_limpio = self._limpiar_nombre_archivo(tipo_lista)

        nombre_base = f"lista_asistencia_{tipo_limpio}_turno_{turno_limpio}_{fecha}"
        extension = ".xlsx"

        ruta = carpeta / f"{nombre_base}{extension}"

        contador = 1

        while ruta.exists():
            ruta = carpeta / f"{nombre_base}_{contador}{extension}"
            contador += 1

        return ruta.resolve()

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

    def _generar_lista_asistencia(self, turno: str, tipo_lista: str) -> str:
        try:
            turno_normalizado = self._normalizar_turno(turno)

            if turno_normalizado not in ["mañana", "tarde"]:
                return "ERROR|El turno debe ser mañana o tarde."

            if tipo_lista == "semanal":
                periodo = obtener_periodo_semanal()
            elif tipo_lista == "mensual":
                periodo = obtener_periodo_mensual()
            else:
                return "ERROR|El tipo de lista debe ser semanal o mensual."

            destinatarios = self.listarDestinatariosPorTurno(turno_normalizado)

            ruta_salida = self._crear_ruta_lista_asistencia(
                turno=turno_normalizado,
                tipo_lista=tipo_lista,
            )

            sede = self._obtener_nombre_sede()

            generar_lista_asistencia(
                destinatarios=destinatarios,
                turno=turno_normalizado,
                ruta_salida=ruta_salida,
                periodo=periodo,
                sede=sede,
            )

            if not ruta_salida.exists():
                return f"ERROR|El archivo no se generó en la ruta esperada: {ruta_salida}"

            self._abrir_archivo(ruta_salida)

            return f"OK|Lista de asistencia {tipo_lista} generada correctamente: {ruta_salida}"

        except Exception as error:
            return f"ERROR|No se pudo generar la lista de asistencia: {error}"

    @Slot(str, result=str)
    def generarListaSemanalPorTurno(self, turno: str) -> str:
        return self._generar_lista_asistencia(
            turno=turno,
            tipo_lista="semanal",
        )

    @Slot(str, result=str)
    def generarListaMensualPorTurno(self, turno: str) -> str:
        return self._generar_lista_asistencia(
            turno=turno,
            tipo_lista="mensual",
        )

    @Slot(str, result=str)
    def generarListaAsistenciaPorTurno(self, turno: str) -> str:
        """
        Compatibilidad temporal con la interfaz actual.

        Por ahora genera lista semanal para no romper los botones existentes.
        Después reemplazamos la interfaz para que tenga botones separados:
        - Generar semanal mañana/tarde
        - Generar mensual mañana/tarde
        """
        return self.generarListaSemanalPorTurno(turno)

