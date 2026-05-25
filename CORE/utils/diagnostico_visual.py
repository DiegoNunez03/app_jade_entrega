from PySide6.QtCore import QSysInfo
from PySide6.QtGui import QGuiApplication


def _formatear_porcentaje_escala(valor: float) -> str:
    """
    Convierte un factor de escala Qt en porcentaje legible.
    Ejemplo:
    1.0  -> 100%
    1.25 -> 125%
    1.5  -> 150%
    """
    try:
        return f"{round(valor * 100)}%"
    except Exception:
        return "No disponible"


def _interpretar_perfil_visual(device_pixel_ratio: float, dpi_logico: float) -> str:
    """
    Devuelve una interpretación inicial del entorno visual.
    No modifica nada. Solo ayuda a leer el diagnóstico.
    """

    if device_pixel_ratio >= 1.45 or dpi_logico >= 140:
        return "Escalado alto probable"
    if device_pixel_ratio >= 1.20 or dpi_logico >= 115:
        return "Escalado medio probable"
    if device_pixel_ratio <= 1.05 and dpi_logico <= 105:
        return "Escalado base probable"

    return "Perfil visual intermedio o no estándar"


def imprimir_diagnostico_visual(app: QGuiApplication) -> None:
    """
    Imprime información visual del entorno actual.

    Objetivo:
    - Comparar Linux vs Windows.
    - Detectar diferencias de escala, DPI, resolución y fuente.
    - No modifica la interfaz.
    - No cambia comportamiento de JADE.
    """

    print("\n" + "=" * 70)
    print("DIAGNÓSTICO VISUAL JADE")
    print("=" * 70)

    # Sistema / plataforma
    print(f"Sistema operativo detectado: {QSysInfo.prettyProductName()}")
    print(f"Kernel / tipo de sistema: {QSysInfo.kernelType()}")
    print(f"Versión kernel: {QSysInfo.kernelVersion()}")
    print(f"Arquitectura CPU: {QSysInfo.currentCpuArchitecture()}")
    print(f"Plataforma Qt: {QGuiApplication.platformName()}")

    # Fuente activa
    fuente = app.font()

    print("\n--- Fuente activa de la aplicación ---")
    print(f"Familia: {fuente.family()}")
    print(f"Point size: {fuente.pointSize()}")
    print(f"Pixel size: {fuente.pixelSize()}")
    print(f"Peso: {fuente.weight()}")
    print(f"Itálica: {fuente.italic()}")

    # Pantalla principal
    pantalla = app.primaryScreen()

    if pantalla is None:
        print("\nNo se pudo detectar pantalla principal.")
        print("=" * 70 + "\n")
        return

    geometria = pantalla.geometry()
    disponible = pantalla.availableGeometry()

    device_pixel_ratio = pantalla.devicePixelRatio()
    dpi_logico = pantalla.logicalDotsPerInch()
    dpi_fisico = pantalla.physicalDotsPerInch()

    print("\n--- Pantalla principal ---")
    print(f"Nombre pantalla: {pantalla.name()}")

    print("\n--- Resolución ---")
    print(f"Resolución total: {geometria.width()}x{geometria.height()}")
    print(f"Resolución disponible: {disponible.width()}x{disponible.height()}")

    print("\n--- Escala / DPI ---")
    print(f"Device Pixel Ratio: {device_pixel_ratio}")
    print(f"Escala estimada por DPR: {_formatear_porcentaje_escala(device_pixel_ratio)}")
    print(f"DPI lógico: {dpi_logico}")
    print(f"DPI lógico X: {pantalla.logicalDotsPerInchX()}")
    print(f"DPI lógico Y: {pantalla.logicalDotsPerInchY()}")
    print(f"DPI físico: {dpi_fisico}")
    print(f"DPI físico X: {pantalla.physicalDotsPerInchX()}")
    print(f"DPI físico Y: {pantalla.physicalDotsPerInchY()}")

    print("\n--- Interpretación inicial ---")
    print(f"Perfil visual estimado: {_interpretar_perfil_visual(device_pixel_ratio, dpi_logico)}")

    print("=" * 70 + "\n")