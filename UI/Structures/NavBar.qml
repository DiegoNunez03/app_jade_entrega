// UI / Structures / NavBar.qml

import QtQuick
import QtQuick.Controls

import Components 1.0
import Theme 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    // =====================================================
    // MEDIDAS GENERALES
    // =====================================================

    property int barWidth: 210

    width: barWidth
    height: parent ? parent.height : 600

    color: "#111827"

    /*
        Mapeo propuesto según Main.qml:

        Opción 1 / SectionActive 1 -> HOME
        Opción 2 / SectionActive 2 -> Solicitud Alta Destinatario
        Opción 3 / SectionActive 3 -> Solicitud Alta Tutor
        Opción 4 / SectionActive 4 -> Solicitud Baja
        Opción 5 / SectionActive 5 -> Configuración
        Opción 6 / SectionActive 6 -> Solicitudes generadas
        Opción 7 / SectionActive 7 -> Registrar destinatario
        Opción 8 / SectionActive 8 -> Lista de destinatarios
    */

    property int selectionoption: 1
    signal opcionSeleccionada(int opcion)

    // =====================================================
    // ESTADO DEL SUBMENÚ
    // =====================================================

    property bool menuAltaDesplegado: false

    readonly property bool altaActiva: root.selectionoption === 2 || root.selectionoption === 3

    // =====================================================
    // LOGO / MARCA
    // =====================================================

    Item {
        id: marca

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.topMargin: 22
        anchors.leftMargin: 20
        anchors.rightMargin: 18

        height: 160

        Image {
            id: logoJade

            anchors.centerIn: parent

            width: 200
            height: 200

            source: "qrc:/qml/UI/Assets/icon_jade.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }



    // =====================================================
    // MENÚ
    // =====================================================

    Column {
        id: menu

        anchors.top: marca.bottom
        anchors.topMargin: 38

        anchors.left: parent.left
        anchors.right: parent.right

        spacing: 30

        // =================================================
        // SECCIÓN PRINCIPAL
        // =================================================

        Column {
            id: seccionPrincipal

            width: parent.width
            spacing: 10

            Text {
                text: "PRINCIPAL"

                anchors.left: parent.left
                anchors.leftMargin: 24
                color: "#6B7280"

                font.family: AppTheme.fuenteCuerpo
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 0.8
            }

            CustonButton {
                id: buttonInicio

                anchors.horizontalCenter: parent.horizontalCenter
                iconSource: "qrc:/qml/UI/Assets/icon/icon_home.svg"
                active: root.selectionoption === 1

                onClicked: {
                    root.selectionoption = 1
                    root.menuAltaDesplegado = false
                    root.opcionSeleccionada(1)

                    Logger.linea()
                    Logger.simple("Sidebar", "sección → inicio")
                }
            }

            // =================================================
            // ALTA - BOTÓN PRINCIPAL DESPLEGABLE
            // =================================================

            Rectangle {
                id: buttonSolicitudAlta

                width: 180
                height: 46
                radius: 9

                anchors.horizontalCenter: parent.horizontalCenter

                color: root.altaActiva || mouseAlta.containsMouse
                       ? "#6D45D8"
                       : "transparent"

                border.width: 0

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 14

                    spacing: 14

                    Image {
                        id: iconoSolicitudAlta
                        width: 22
                        height: parent.height
                        source: "qrc:/qml/UI/Assets/icon/icon_solicitud_alta.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        opacity: root.altaActiva || mouseAlta.containsMouse ? 1.0 : 0.75
                    }

                    Text {
                        text: "Alta"

                        width: parent.width - 22 - 14 - 20

                        anchors.verticalCenter: parent.verticalCenter

                        color: root.altaActiva || mouseAlta.containsMouse
                               ? "#FFFFFF"
                               : "#D1D5DB"

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 13
                        font.bold: true

                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.menuAltaDesplegado ? "⌃" : "⌄"

                        anchors.verticalCenter: parent.verticalCenter

                        color: root.altaActiva || mouseAlta.containsMouse
                               ? "#FFFFFF"
                               : "#D1D5DB"

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                MouseArea {
                    id: mouseAlta

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.menuAltaDesplegado = !root.menuAltaDesplegado

                        Logger.linea()
                        Logger.simple(
                            "Sidebar",
                            root.menuAltaDesplegado
                                ? "menú alta → desplegado"
                                : "menú alta → contraído"
                        )
                    }
                }
            }

            // =================================================
            // SUBMENÚ ALTA
            // =================================================

            Rectangle {
                id: submenuAlta

                visible: root.menuAltaDesplegado
                opacity: root.menuAltaDesplegado ? 1 : 0

                width: 170
                height: 104
                radius: 10

                anchors.horizontalCenter: parent.horizontalCenter

                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 8

                    spacing: 4

                    SubMenuButton {
                        id: submenuDestinatario

                        width: parent.width

                        label: "Destinatario"
                        iconText: "♙"
                        active: root.selectionoption === 2

                        onClicked: {
                            root.selectionoption = 2
                            root.opcionSeleccionada(2)

                            Logger.linea()
                            Logger.simple("Sidebar", "alta → destinatario")
                        }
                    }

                    SubMenuButton {
                        id: submenuTutor

                        width: parent.width

                        label: "Tutor"
                        iconText: "♙"
                        active: root.selectionoption === 3

                        onClicked: {
                            root.selectionoption = 3
                            root.opcionSeleccionada(3)

                            Logger.linea()
                            Logger.simple("Sidebar", "alta → tutor")
                        }
                    }
                }
            }

            // =================================================
            // BAJA
            // =================================================

            CustonButton {
                id: buttonSolicitudBaja

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Baja"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitud_baja.svg"

                active: root.selectionoption === 4

                onClicked: {
                    root.selectionoption = 4
                    root.menuAltaDesplegado = false
                    root.opcionSeleccionada(4)

                    Logger.linea()
                    Logger.simple("Sidebar", "sección → baja")
                }
            }

            // =================================================
            // REGISTRAR DESTINATARIO
            // =================================================

            CustonButton {
                id: buttonRegistrarDestinatario

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Destinatario"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_nuevo_destinatario.svg"

                active: root.selectionoption === 7

                onClicked: {
                    root.selectionoption = 7
                    root.menuAltaDesplegado = false
                    root.opcionSeleccionada(7)

                    Logger.linea()
                    Logger.simple("Sidebar", "sección → registrar destinatario")
                }
            }

            // =================================================
            // LISTA DE DESTINATARIOS
            // =================================================

            CustonButton {
                id: buttonListaDestinatarios

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Asistencia"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_lista.svg"

                active: root.selectionoption === 8

                onClicked: {
                    root.selectionoption = 8
                    root.menuAltaDesplegado = false
                    root.opcionSeleccionada(8)

                    Logger.linea()
                    Logger.simple("Sidebar", "sección → lista de destinatarios")
                }
            }

            // =================================================
            // SOLICITUDES GENERADAS
            // =================================================

            CustonButton {
                id: buttonSolicitudesGeneradas

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Solicitudes"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitudes.svg"

                active: root.selectionoption === 6

                onClicked: {
                    root.selectionoption = 6
                    root.menuAltaDesplegado = false
                    root.opcionSeleccionada(6)

                    Logger.linea()
                    Logger.simple("Sidebar", "sección → solicitudes generadas")
                }
            }
        }

        // =================================================
        // SECCIÓN AJUSTES
        // =================================================

        Column {
            id: seccionAjustes

            width: parent.width
            spacing: 10

            Text {
                text: "AJUSTES"

                anchors.left: parent.left
                anchors.leftMargin: 24

                color: "#6B7280"

                font.family: AppTheme.fuenteCuerpo
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 0.8
            }

            CustonButton {
                id: buttonConfiguracion

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Configuración"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"

                active: root.selectionoption === 5

                onClicked: {
                    root.selectionoption = 5
                    root.menuAltaDesplegado = false
                    root.opcionSeleccionada(5)

                    Logger.linea()
                    Logger.simple("Sidebar", "sección → configuración")
                }
            }
        }
    }

    // =====================================================
    // COMPONENTE INTERNO: BOTÓN DE SUBMENÚ
    // =====================================================

    component SubMenuButton: Rectangle {
        id: subButton

        property string label: "Opción"
        property string iconText: "•"
        property bool active: false

        signal clicked()

        height: 42
        radius: 8

        color: subButton.active || mouseSub.containsMouse
               ? "#F0E7FF"
               : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12

            spacing: 12

            Text {
                text: subButton.iconText

                width: 22
                height: parent.height

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: subButton.active || mouseSub.containsMouse
                       ? AppTheme.colorPrimario
                       : "#6B7280"

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 17
                font.bold: true
            }

            Text {
                text: subButton.label

                anchors.verticalCenter: parent.verticalCenter

                color: subButton.active || mouseSub.containsMouse
                       ? AppTheme.colorPrimario
                       : "#111827"

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 13
                font.bold: subButton.active
            }
        }

        MouseArea {
            id: mouseSub

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                subButton.clicked()
            }
        }
    }
}
