# app_jade / CORE / main.py

import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


# ============================================================
# CONFIGURACIÓN DE RUTAS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.append(str(BASE_DIR))

# ============================================================
# RECURSOS QML COMPILADOS
# ============================================================

import resources

# ============================================================
# CONTROLADORES PYTHON
# ============================================================

from CORE.controladores.controlador_altas import ControladorAltas
from CORE.controladores.controlador_bajas import ControladorBajas
from CORE.controladores.controlador_configuracion import ControladorConfiguracion
from CORE.controladores.controlador_destinatarios import ControladorDestinatarios
from CORE.fuente_manager import FuenteManager
from CORE.utils.diagnostico_visual import imprimir_diagnostico_visual

# ============================================================
# APLICACIÓN
# ============================================================

app = QGuiApplication(sys.argv)

# Diagnóstico visual temporal para comparar Linux vs Windows.
# No modifica la interfaz ni el comportamiento de JADE.
# imprimir_diagnostico_visual(app)

engine = QQmlApplicationEngine()

# ============================================================
# REGISTRO DE CONTROLADORES PARA QML
# ============================================================

controlador_altas = ControladorAltas()
controlador_bajas = ControladorBajas()
controlador_configuracion = ControladorConfiguracion()
controlador_destinatarios = ControladorDestinatarios()
fuente_manager = FuenteManager()

engine.rootContext().setContextProperty(
    "controladorAltas",
    controlador_altas
)

engine.rootContext().setContextProperty(
    "controladorBajas",
    controlador_bajas
)

engine.rootContext().setContextProperty(
    "controladorConfiguracion",
    controlador_configuracion
)

engine.rootContext().setContextProperty(
    "controladorDestinatarios",
    controlador_destinatarios
)

engine.rootContext().setContextProperty(
    "fuenteManager",
    fuente_manager
)

# ============================================================
# CARGA DE QML
# ============================================================

engine.addImportPath("qrc:/qml/UI")
engine.load(QUrl("qrc:/qml/UI/Main.qml"))

if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())

