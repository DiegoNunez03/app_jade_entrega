// AppJade / UI / Main.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import QtQuick.Shapes

import Components 1.0
import Structures 1.0
import Theme 1.0
import Layout 1.0

import "Utils/Logger.js" as Logger


ApplicationWindow {
    id: mainWindow

    width: 1400
    height: 920
    visible: true
    title: "Sistema JADE"
    color: AppTheme.colorFondo
    minimumWidth: 900
    minimumHeight: 600

    // PROPIEDADES
    property int sectionActive: 1
    property bool edadAutomaticaGlobal: false

    NavBar {
        id: sidebar

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        // **************************************************************
        // Opción 1 / SectionActive 1 -> HOME
        // Opción 2 / SectionActive 2 -> Solicitud Alta Destinatario
        // Opción 3 / SectionActive 3 -> Solicitud Alta Tutor
        // Opción 4 / SectionActive 4 -> Solicitud Baja
        // Opción 5 / SectionActive 5 -> Configuración
        // Opción 6 / SectionActive 6 -> Solicitudes generadas
        // Opción 7 / SectionActive 7 -> Registrar destinatario
        // Opción 8 / SectionActive 8 -> Lista de destinatarios
        // **************************************************************

        onOpcionSeleccionada: function(opcion) {
            if (opcion === 1) {
                mainWindow.sectionActive = 1
                return
            }

            if (opcion === 2) {
                mainWindow.sectionActive = 2
                sectiontwo.abrirAltaDestinatarioDesdeMenu()
                return
            }

            if (opcion === 3) {
                mainWindow.sectionActive = 3
                sectiontree.abrirAltaTutorDesdeMenu()
                return
            }

            if (opcion === 4) {
                // mainWindow.sectionActive = 4
                console.log("[MAIN → Baja pendiente de implementación]")
                return
            }

            if (opcion === 5) {
                mainWindow.sectionActive = 5
                return
            }

            if (opcion === 6) {
                mainWindow.sectionActive = 6
                return
            }

            if (opcion === 7) {
                mainWindow.sectionActive = 7
                return
            }

            if (opcion === 8) {
                mainWindow.sectionActive = 8
                return
            }
        }
    }

    SectionOne {
        id: sectionone

        x: sidebar.width
        y: 0
        width: mainWindow.width - sidebar.width
        height: mainWindow.height

        visible: mainWindow.sectionActive === 1

        onAltaSolicitada: {
            console.log("MAIN → navegando a sección de altas destinatario")
            mainWindow.sectionActive = 2
            sidebar.selectionoption = 2
            sectiontwo.abrirAltaDestinatarioDesdeMenu()
        }

        onBajaSolicitada: {
            console.log("MAIN → navegación a bajas pendiente")
            // mainWindow.sectionActive = 4
            // sidebar.selectionoption = 4
        }

        onConfiguracionSedeSolicitada: {
            console.log("MAIN → navegando a configuración de sede")
            mainWindow.sectionActive = 5
            sidebar.selectionoption = 5
        }

        onHistorialSolicitado: {
            console.log("MAIN → navegando a solicitudes generadas")
            mainWindow.sectionActive = 6
            sidebar.selectionoption = 6
        }

        onListaAsistenciaSolicitada: {
            console.log("MAIN → navegando a lista de destinatarios")
            mainWindow.sectionActive = 8
            sidebar.selectionoption = 8
        }

        onRegistrarDestinatarioSolicitado: {
            console.log("MAIN → navegando a registrar destinatario")
            mainWindow.sectionActive = 7
            sidebar.selectionoption = 7
        }
    }

    SectionTwo {
        id: sectiontwo

        x: sidebar.width
        y: 0
        width: mainWindow.width - sidebar.width
        height: mainWindow.height

        visible: mainWindow.sectionActive === 2

        edadAutomatica: mainWindow.edadAutomaticaGlobal
    }

    SectionTree {
        id: sectiontree

        x: sidebar.width
        y: 0
        width: mainWindow.width - sidebar.width
        height: mainWindow.height

        visible: mainWindow.sectionActive === 3

        edadAutomatica: mainWindow.edadAutomaticaGlobal
    }

    SectionFive {
        id: sectionFive

        x: sidebar.width
        y: 0
        width: mainWindow.width - sidebar.width
        height: mainWindow.height

        visible: mainWindow.sectionActive === 5

        edadAutomaticaActual: mainWindow.edadAutomaticaGlobal

        onEdadAutomaticaCambiada: function(valor) {
            mainWindow.edadAutomaticaGlobal = valor

            // Logger.linea() || NO BORRAR
            // Logger.simple("MAIN", "edad automática global actualizada", mainWindow.edadAutomaticaGlobal) || NO BORRAR
            // Logger.linea() || NO BORRAR
        }
    }

    SectionSolicitudesGeneradas {
        id: sectionSolicitudesGeneradas

        x: sidebar.width
        y: 0
        width: mainWindow.width - sidebar.width
        height: mainWindow.height

        visible: mainWindow.sectionActive === 6
    }

    SectionRegistrarDestinatario {
        id: sectionRegistrarDestinatario

        x: sidebar.width
        y: 0
        width: mainWindow.width - sidebar.width
        height: mainWindow.height

        visible: mainWindow.sectionActive === 7
    }

    SectionListaDestinatarios {
        id: sectionListaDestinatarios

        x: sidebar.width
        y: 0
        width: mainWindow.width - sidebar.width
        height: mainWindow.height

        visible: mainWindow.sectionActive === 8
    }
}

