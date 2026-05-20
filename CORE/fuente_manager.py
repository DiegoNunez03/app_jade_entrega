# CORE/fuente_manager.py

from __future__ import annotations

import logging
import platform
from typing import Iterable

from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtGui import QFontDatabase


logger = logging.getLogger(__name__)


class FuenteManager(QObject):
    """
    Detecta la mejor fuente disponible en el sistema operativo
    y la expone a QML mediante la propiedad fuenteActiva.
    """

    fuenteActivaChanged = Signal()
    fuentesDisponiblesChanged = Signal()

    def __init__(self, fuentes_prioridad: Iterable[str] | None = None) -> None:
        super().__init__()

        self._sistema_detectado: str = self._detectar_sistema()

        self._fuentes_prioridad: list[str] = list(fuentes_prioridad) if fuentes_prioridad else [
            "Inter",
            "Segoe UI",
            "Noto Sans",
            "DejaVu Sans",
            "Liberation Sans",
            "Arial",
            "Sans Serif",
        ]

        self._fuentes_disponibles: list[str] = self._cargar_fuentes_disponibles()
        self._fuente_activa: str = self._detectar_fuente()

        logger.info("Sistema detectado: %s", self._sistema_detectado)
        logger.info("Fuente activa seleccionada: %s", self._fuente_activa)

    # =====================================================
    # DETECCIÓN
    # =====================================================

    def _detectar_sistema(self) -> str:
        """
        Detecta el sistema operativo de forma simple.
        """
        sistema = platform.system()

        if sistema == "Windows":
            return "Windows"

        if sistema == "Linux":
            return "Linux"

        if sistema == "Darwin":
            return "macOS"

        return sistema or "Desconocido"

    def _cargar_fuentes_disponibles(self) -> list[str]:
        """
        Obtiene las familias de fuentes disponibles para Qt.
        """
        try:
            familias = QFontDatabase.families()
            return sorted(set(familias))
        except Exception as error:
            logger.exception("No se pudieron cargar las fuentes disponibles: %s", error)
            return []

    def _detectar_fuente(self) -> str:
        """
        Selecciona la primera fuente disponible según la lista de prioridad.
        Si ninguna aparece, devuelve Sans Serif.
        """
        fuentes_disponibles_normalizadas = {
            fuente.lower(): fuente
            for fuente in self._fuentes_disponibles
        }

        for fuente_prioritaria in self._fuentes_prioridad:
            clave = fuente_prioritaria.lower()

            if clave in fuentes_disponibles_normalizadas:
                return fuentes_disponibles_normalizadas[clave]

        return "Sans Serif"

    def _existe_fuente(self, nombre_fuente: str) -> bool:
        """
        Verifica si una fuente existe en el sistema.
        La comparación es case-insensitive.
        """
        if not nombre_fuente:
            return False

        nombre_normalizado = nombre_fuente.strip().lower()

        return any(
            fuente.lower() == nombre_normalizado
            for fuente in self._fuentes_disponibles
        )

    # =====================================================
    # PROPIEDADES EXPUESTAS A QML
    # =====================================================

    @Property(str, constant=True)
    def sistemaDetectado(self) -> str:
        return self._sistema_detectado

    @Property(str, notify=fuenteActivaChanged)
    def fuenteActiva(self) -> str:
        return self._fuente_activa

    @Property(list, notify=fuentesDisponiblesChanged)
    def fuentesDisponibles(self) -> list[str]:
        return self._fuentes_disponibles

    @Property(list, constant=True)
    def fuentesPrioridad(self) -> list[str]:
        return self._fuentes_prioridad

    # =====================================================
    # MÉTODOS INVOCABLES DESDE QML / TEST
    # =====================================================

    @Slot(result=str)
    def detectarFuente(self) -> str:
        nueva_fuente = self._detectar_fuente()
        self._actualizar_fuente_activa(nueva_fuente)
        return self._fuente_activa

    @Slot()
    def recargarFuentes(self) -> None:
        self._fuentes_disponibles = self._cargar_fuentes_disponibles()
        self.fuentesDisponiblesChanged.emit()

        nueva_fuente = self._detectar_fuente()
        self._actualizar_fuente_activa(nueva_fuente)

    @Slot(str, result=bool)
    def usarFuente(self, nombre_fuente: str) -> bool:
        if not nombre_fuente:
            return False

        nombre_fuente = nombre_fuente.strip()

        if not self._existe_fuente(nombre_fuente):
            logger.warning("La fuente solicitada no está disponible: %s", nombre_fuente)
            return False

        self._actualizar_fuente_activa(nombre_fuente)
        return True

    @Slot(str, result=bool)
    def fuenteExiste(self, nombre_fuente: str) -> bool:
        return self._existe_fuente(nombre_fuente)

    @Slot(result=str)
    def obtenerResumen(self) -> str:
        return (
            f"Sistema detectado: {self._sistema_detectado}\n"
            f"Fuente activa: {self._fuente_activa}\n"
            f"Cantidad de fuentes disponibles: {len(self._fuentes_disponibles)}"
        )


    def imprimir_diagnostico(self) -> None:
        """
        Imprime un diagnóstico reducido por consola.
        Útil para verificar que la detección de sistema y fuente funciona.
        """

        print("=" * 70)
        print("DIAGNÓSTICO DE FUENTES")
        print("=" * 70)

        print(f"Sistema detectado: {self._sistema_detectado}")
        print(f"Fuente activa seleccionada: {self._fuente_activa}")

        print()
        print("Fuentes aplicadas por rol visual:")
        print(f"  - Títulos: {self._fuente_activa}")
        print(f"  - Subtítulos: {self._fuente_activa}")
        print(f"  - Cuerpo: {self._fuente_activa}")
        print(f"  - Etiquetas: {self._fuente_activa}")
        print(f"  - Inputs: {self._fuente_activa}")
        print(f"  - Botones: {self._fuente_activa}")
        print(f"  - Errores: {self._fuente_activa}")
        print(f"  - Navegación: {self._fuente_activa}")
        print(f"  - Stepper: {self._fuente_activa}")

        print()
        print("Fuentes de prioridad:")
        for indice, fuente in enumerate(self._fuentes_prioridad, start=1):
            estado = "DISPONIBLE" if self._existe_fuente(fuente) else "NO DISPONIBLE"
            print(f"  {indice}. {fuente}: {estado}")

        print("=" * 70)

    # =====================================================
    # MÉTODOS INTERNOS
    # =====================================================

    def _actualizar_fuente_activa(self, nueva_fuente: str) -> None:
        if not nueva_fuente:
            nueva_fuente = "Sans Serif"

        if nueva_fuente == self._fuente_activa:
            return

        self._fuente_activa = nueva_fuente
        self.fuenteActivaChanged.emit()

        logger.info("Fuente activa actualizada: %s", self._fuente_activa)