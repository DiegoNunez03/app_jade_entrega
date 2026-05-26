
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

    property bool barraPlegada: false

    readonly property int barWidthExpandida: 210
    readonly property int barWidthPlegada: 74

    readonly property int anchoBotonExpandido: 180
    readonly property int anchoBotonPlegado: 46

    readonly property int iconoExpandido: 20
    readonly property int iconoPlegado: 28

    property int barWidth: barraPlegada ? barWidthPlegada : barWidthExpandida

    width: barWidth
    height: parent ? parent.height : 600

    color: "#111827"
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

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
    // LOGO / MARCA / BOTÓN PLEGAR-DESPLEGAR
    // =====================================================

    Item {
        id: marca

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.topMargin: 22
        anchors.leftMargin: root.barraPlegada ? 8 : 20
        anchors.rightMargin: root.barraPlegada ? 8 : 18

        height: root.barraPlegada ? 74 : 150

        Behavior on height {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: botonLogoJade

            anchors.centerIn: parent

            width: root.barraPlegada ? 120 : 120
            height: root.barraPlegada ? 120 : 120

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Image {
                id: logoJade

                anchors.centerIn: parent

                width: parent.width
                height: parent.height

                source: "qrc:/qml/UI/Assets/icon_jade.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true

                opacity: mouseLogoJade.containsMouse ? 0.82 : 1.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }

            MouseArea {
                id: mouseLogoJade

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.barraPlegada = !root.barraPlegada

                    if (root.barraPlegada) {
                        root.menuAltaDesplegado = false
                    }

                    Logger.linea()
                    Logger.simple(
                        "Sidebar",
                        root.barraPlegada
                            ? "barra lateral → plegada"
                            : "barra lateral → desplegada"
                    )
                }
            }
        }
    }



    // =====================================================
    // MENÚ
    // =====================================================

    Column {
        id: menu

        anchors.top: marca.bottom
        anchors.topMargin: root.barraPlegada ? 18 : 34

        anchors.left: parent.left
        anchors.right: parent.right

        spacing: root.barraPlegada ? 22 : 30

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

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

                visible: !root.barraPlegada
                opacity: root.barraPlegada ? 0 : 1

                color: "#6B7280"

                font.family: AppTheme.fuenteCuerpo
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 0.8

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }

            CustonButton {
                id: buttonInicio

                width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

                compactMode: root.barraPlegada
                iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Inicio"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_home.svg"

                active: root.selectionoption === 1

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

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

                width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido
                height: 46
                radius: 9

                anchors.horizontalCenter: parent.horizontalCenter

                color: root.altaActiva || mouseAlta.containsMouse
                       ? "#6D45D8"
                       : "transparent"

                border.width: 0
                clip: true

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: root.barraPlegada ? 0 : 20
                    anchors.rightMargin: root.barraPlegada ? 0 : 14

                    spacing: root.barraPlegada ? 0 : 14

                    Item {
                        width: root.barraPlegada ? parent.width : 22
                        height: parent.height

                        Image {
                            id: iconoSolicitudAlta

                            anchors.centerIn: parent

                            width: root.barraPlegada ? root.iconoPlegado : 22
                            height: root.barraPlegada ? root.iconoPlegado : 22

                            source: "qrc:/qml/UI/Assets/icon/icon_solicitud_alta.svg"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            opacity: root.altaActiva || mouseAlta.containsMouse ? 1.0 : 0.75

                            Behavior on width {
                                NumberAnimation {
                                    duration: 160
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: 160
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    Text {
                        text: "Alta"

                        visible: !root.barraPlegada
                        opacity: root.barraPlegada ? 0 : 1

                        width: parent.width - 22 - 14 - 20

                        anchors.verticalCenter: parent.verticalCenter

                        color: root.altaActiva || mouseAlta.containsMouse
                               ? "#FFFFFF"
                               : "#D1D5DB"

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 13
                        font.bold: true

                        elide: Text.ElideRight

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }

                    Text {
                        text: root.menuAltaDesplegado ? "⌃" : "⌄"

                        visible: !root.barraPlegada
                        opacity: root.barraPlegada ? 0 : 1

                        anchors.verticalCenter: parent.verticalCenter

                        color: root.altaActiva || mouseAlta.containsMouse
                               ? "#FFFFFF"
                               : "#D1D5DB"

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 16
                        font.bold: true

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouseAlta

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (root.barraPlegada) {
                            root.barraPlegada = false
                            root.menuAltaDesplegado = true
                        } else {
                            root.menuAltaDesplegado = !root.menuAltaDesplegado
                        }

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

                visible: root.menuAltaDesplegado && !root.barraPlegada
                opacity: root.menuAltaDesplegado && !root.barraPlegada ? 1 : 0

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

                width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

                compactMode: root.barraPlegada
                iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Baja"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitud_baja.svg"

                active: root.selectionoption === 4

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

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

                width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

                compactMode: root.barraPlegada
                iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Destinatario"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_nuevo_destinatario.svg"

                active: root.selectionoption === 7

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

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

                width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

                compactMode: root.barraPlegada
                iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Asistencia"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_lista.svg"

                active: root.selectionoption === 8

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

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

                width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

                compactMode: root.barraPlegada
                iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Solicitudes"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitudes.svg"

                active: root.selectionoption === 6

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

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

                visible: !root.barraPlegada
                opacity: root.barraPlegada ? 0 : 1

                color: "#6B7280"

                font.family: AppTheme.fuenteCuerpo
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 0.8

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }

            CustonButton {
                id: buttonConfiguracion

                width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

                compactMode: root.barraPlegada
                iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

                anchors.horizontalCenter: parent.horizontalCenter

                label: "Configuración"
                iconSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"

                active: root.selectionoption === 5

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

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





// // UI / Structures / NavBar.qml

// import QtQuick
// import QtQuick.Controls

// import Components 1.0
// import Theme 1.0

// import "../Utils/Logger.js" as Logger


// Rectangle {
//     id: root

//     // =====================================================
//     // MEDIDAS GENERALES
//     // =====================================================

//     property bool barraPlegada: false

//     readonly property int barWidthExpandida: 210
//     readonly property int barWidthPlegada: 74

//     readonly property int anchoBotonExpandido: 180
//     readonly property int anchoBotonPlegado: 46

//     readonly property int iconoExpandido: 20
//     readonly property int iconoPlegado: 28

//     property int barWidth: barraPlegada ? barWidthPlegada : barWidthExpandida

//     width: barWidth
//     height: parent ? parent.height : 600

//     color: "#111827"
//     clip: true

//     Behavior on width {
//         NumberAnimation {
//             duration: 180
//             easing.type: Easing.OutCubic
//         }
//     }

//     /*
//         Mapeo propuesto según Main.qml:

//         Opción 1 / SectionActive 1 -> HOME
//         Opción 2 / SectionActive 2 -> Solicitud Alta Destinatario
//         Opción 3 / SectionActive 3 -> Solicitud Alta Tutor
//         Opción 4 / SectionActive 4 -> Solicitud Baja
//         Opción 5 / SectionActive 5 -> Configuración
//         Opción 6 / SectionActive 6 -> Solicitudes generadas
//         Opción 7 / SectionActive 7 -> Registrar destinatario
//         Opción 8 / SectionActive 8 -> Lista de destinatarios
//     */

//     property int selectionoption: 1
//     signal opcionSeleccionada(int opcion)

//     // =====================================================
//     // ESTADO DEL SUBMENÚ
//     // =====================================================

//     property bool menuAltaDesplegado: false

//     readonly property bool altaActiva: root.selectionoption === 2 || root.selectionoption === 3

//     // =====================================================
//     // BOTÓN PLEGAR / DESPLEGAR
//     // =====================================================

//     Rectangle {
//         id: buttonToggleSidebar

//         width: 34
//         height: 34
//         radius: 10

//         anchors.top: parent.top
//         anchors.right: parent.right
//         anchors.topMargin: 14
//         anchors.rightMargin: root.barraPlegada ? 20 : 14

//         color: mouseToggleSidebar.containsMouse ? "#374151" : "#1F2937"
//         border.color: "#374151"
//         border.width: 1

//         z: 10

//         Behavior on color {
//             ColorAnimation {
//                 duration: 120
//             }
//         }

//         Text {
//             anchors.centerIn: parent

//             text: root.barraPlegada ? "›" : "‹"

//             color: "#E5E7EB"

//             font.family: AppTheme.fuenteTitulo
//             font.pixelSize: 22
//             font.bold: true
//         }

//         MouseArea {
//             id: mouseToggleSidebar

//             anchors.fill: parent
//             hoverEnabled: true
//             cursorShape: Qt.PointingHandCursor

//             onClicked: {
//                 root.barraPlegada = !root.barraPlegada

//                 if (root.barraPlegada) {
//                     root.menuAltaDesplegado = false
//                 }

//                 Logger.linea()
//                 Logger.simple(
//                     "Sidebar",
//                     root.barraPlegada
//                         ? "barra lateral → plegada"
//                         : "barra lateral → desplegada"
//                 )
//             }
//         }
//     }

//     // =====================================================
//     // LOGO / MARCA
//     // =====================================================

//     Item {
//         id: marca

//         anchors.top: parent.top
//         anchors.left: parent.left
//         anchors.right: parent.right

//         anchors.topMargin: 22
//         anchors.leftMargin: root.barraPlegada ? 8 : 20
//         anchors.rightMargin: root.barraPlegada ? 8 : 18

//         height: root.barraPlegada ? 92 : 160

//         Behavior on height {
//             NumberAnimation {
//                 duration: 180
//                 easing.type: Easing.OutCubic
//             }
//         }

//         Image {
//             id: logoJade

//             anchors.centerIn: parent

//             width: root.barraPlegada ? 58 : 200
//             height: root.barraPlegada ? 58 : 200

//             source: "qrc:/qml/UI/Assets/icon_jade.png"
//             fillMode: Image.PreserveAspectFit
//             smooth: true
//             mipmap: true

//             Behavior on width {
//                 NumberAnimation {
//                     duration: 180
//                     easing.type: Easing.OutCubic
//                 }
//             }

//             Behavior on height {
//                 NumberAnimation {
//                     duration: 180
//                     easing.type: Easing.OutCubic
//                 }
//             }
//         }
//     }



//     // =====================================================
//     // MENÚ
//     // =====================================================

//     Column {
//         id: menu

//         anchors.top: marca.bottom
//         anchors.topMargin: root.barraPlegada ? 22 : 38

//         anchors.left: parent.left
//         anchors.right: parent.right

//         spacing: root.barraPlegada ? 22 : 30

//         Behavior on anchors.topMargin {
//             NumberAnimation {
//                 duration: 180
//                 easing.type: Easing.OutCubic
//             }
//         }

//         // =================================================
//         // SECCIÓN PRINCIPAL
//         // =================================================

//         Column {
//             id: seccionPrincipal

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "PRINCIPAL"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24

//                 visible: !root.barraPlegada
//                 opacity: root.barraPlegada ? 0 : 1

//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 120
//                     }
//                 }
//             }

//             CustonButton {
//                 id: buttonInicio

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 compactMode: root.barraPlegada
//                 iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Inicio"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_home.svg"

//                 active: root.selectionoption === 1

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 1
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(1)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → inicio")
//                 }
//             }

//             // =================================================
//             // ALTA - BOTÓN PRINCIPAL DESPLEGABLE
//             // =================================================

//             Rectangle {
//                 id: buttonSolicitudAlta

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido
//                 height: 46
//                 radius: 9

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: root.altaActiva || mouseAlta.containsMouse
//                        ? "#6D45D8"
//                        : "transparent"

//                 border.width: 0
//                 clip: true

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 Behavior on color {
//                     ColorAnimation {
//                         duration: 140
//                     }
//                 }

//                 Row {
//                     anchors.fill: parent
//                     anchors.leftMargin: root.barraPlegada ? 0 : 20
//                     anchors.rightMargin: root.barraPlegada ? 0 : 14

//                     spacing: root.barraPlegada ? 0 : 14

//                     Item {
//                         width: root.barraPlegada ? parent.width : 22
//                         height: parent.height

//                         Image {
//                             id: iconoSolicitudAlta

//                             anchors.centerIn: parent

//                             width: root.barraPlegada ? root.iconoPlegado : 22
//                             height: root.barraPlegada ? root.iconoPlegado : 22

//                             source: "qrc:/qml/UI/Assets/icon/icon_solicitud_alta.svg"
//                             fillMode: Image.PreserveAspectFit
//                             smooth: true
//                             opacity: root.altaActiva || mouseAlta.containsMouse ? 1.0 : 0.75

//                             Behavior on width {
//                                 NumberAnimation {
//                                     duration: 160
//                                     easing.type: Easing.OutCubic
//                                 }
//                             }

//                             Behavior on height {
//                                 NumberAnimation {
//                                     duration: 160
//                                     easing.type: Easing.OutCubic
//                                 }
//                             }
//                         }
//                     }

//                     Text {
//                         text: "Alta"

//                         visible: !root.barraPlegada
//                         opacity: root.barraPlegada ? 0 : 1

//                         width: parent.width - 22 - 14 - 20

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 13
//                         font.bold: true

//                         elide: Text.ElideRight

//                         Behavior on opacity {
//                             NumberAnimation {
//                                 duration: 120
//                             }
//                         }
//                     }

//                     Text {
//                         text: root.menuAltaDesplegado ? "⌃" : "⌄"

//                         visible: !root.barraPlegada
//                         opacity: root.barraPlegada ? 0 : 1

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 16
//                         font.bold: true

//                         Behavior on opacity {
//                             NumberAnimation {
//                                 duration: 120
//                             }
//                         }
//                     }
//                 }

//                 MouseArea {
//                     id: mouseAlta

//                     anchors.fill: parent
//                     hoverEnabled: true
//                     cursorShape: Qt.PointingHandCursor

//                     onClicked: {
//                         if (root.barraPlegada) {
//                             root.barraPlegada = false
//                             root.menuAltaDesplegado = true
//                         } else {
//                             root.menuAltaDesplegado = !root.menuAltaDesplegado
//                         }

//                         Logger.linea()
//                         Logger.simple(
//                             "Sidebar",
//                             root.menuAltaDesplegado
//                                 ? "menú alta → desplegado"
//                                 : "menú alta → contraído"
//                         )
//                     }
//                 }
//             }

//             // =================================================
//             // SUBMENÚ ALTA
//             // =================================================

//             Rectangle {
//                 id: submenuAlta

//                 visible: root.menuAltaDesplegado && !root.barraPlegada
//                 opacity: root.menuAltaDesplegado && !root.barraPlegada ? 1 : 0

//                 width: 170
//                 height: 104
//                 radius: 10

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: "#FFFFFF"
//                 border.color: "#E5E7EB"
//                 border.width: 1

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 140
//                     }
//                 }

//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 8

//                     spacing: 4

//                     SubMenuButton {
//                         id: submenuDestinatario

//                         width: parent.width

//                         label: "Destinatario"
//                         iconText: "♙"
//                         active: root.selectionoption === 2

//                         onClicked: {
//                             root.selectionoption = 2
//                             root.opcionSeleccionada(2)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → destinatario")
//                         }
//                     }

//                     SubMenuButton {
//                         id: submenuTutor

//                         width: parent.width

//                         label: "Tutor"
//                         iconText: "♙"
//                         active: root.selectionoption === 3

//                         onClicked: {
//                             root.selectionoption = 3
//                             root.opcionSeleccionada(3)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → tutor")
//                         }
//                     }
//                 }
//             }

//             // =================================================
//             // BAJA
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudBaja

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 compactMode: root.barraPlegada
//                 iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Baja"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitud_baja.svg"

//                 active: root.selectionoption === 4

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 4
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(4)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → baja")
//                 }
//             }

//             // =================================================
//             // REGISTRAR DESTINATARIO
//             // =================================================

//             CustonButton {
//                 id: buttonRegistrarDestinatario

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 compactMode: root.barraPlegada
//                 iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Destinatario"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_nuevo_destinatario.svg"

//                 active: root.selectionoption === 7

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 7
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(7)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → registrar destinatario")
//                 }
//             }

//             // =================================================
//             // LISTA DE DESTINATARIOS
//             // =================================================

//             CustonButton {
//                 id: buttonListaDestinatarios

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 compactMode: root.barraPlegada
//                 iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Asistencia"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_lista.svg"

//                 active: root.selectionoption === 8

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 8
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(8)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → lista de destinatarios")
//                 }
//             }

//             // =================================================
//             // SOLICITUDES GENERADAS
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudesGeneradas

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 compactMode: root.barraPlegada
//                 iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Solicitudes"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitudes.svg"

//                 active: root.selectionoption === 6

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 6
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(6)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → solicitudes generadas")
//                 }
//             }
//         }

//         // =================================================
//         // SECCIÓN AJUSTES
//         // =================================================

//         Column {
//             id: seccionAjustes

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "AJUSTES"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24

//                 visible: !root.barraPlegada
//                 opacity: root.barraPlegada ? 0 : 1

//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 120
//                     }
//                 }
//             }

//             CustonButton {
//                 id: buttonConfiguracion

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 compactMode: root.barraPlegada
//                 iconSize: root.barraPlegada ? root.iconoPlegado : root.iconoExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Configuración"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"

//                 active: root.selectionoption === 5

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 5
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(5)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → configuración")
//                 }
//             }
//         }
//     }

//     // =====================================================
//     // COMPONENTE INTERNO: BOTÓN DE SUBMENÚ
//     // =====================================================

//     component SubMenuButton: Rectangle {
//         id: subButton

//         property string label: "Opción"
//         property string iconText: "•"
//         property bool active: false

//         signal clicked()

//         height: 42
//         radius: 8

//         color: subButton.active || mouseSub.containsMouse
//                ? "#F0E7FF"
//                : "transparent"

//         Behavior on color {
//             ColorAnimation {
//                 duration: 120
//             }
//         }

//         Row {
//             anchors.fill: parent
//             anchors.leftMargin: 14
//             anchors.rightMargin: 12

//             spacing: 12

//             Text {
//                 text: subButton.iconText

//                 width: 22
//                 height: parent.height

//                 horizontalAlignment: Text.AlignHCenter
//                 verticalAlignment: Text.AlignVCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#6B7280"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 17
//                 font.bold: true
//             }

//             Text {
//                 text: subButton.label

//                 anchors.verticalCenter: parent.verticalCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#111827"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 13
//                 font.bold: subButton.active
//             }
//         }

//         MouseArea {
//             id: mouseSub

//             anchors.fill: parent
//             hoverEnabled: true
//             cursorShape: Qt.PointingHandCursor

//             onClicked: {
//                 subButton.clicked()
//             }
//         }
//     }
// }



// // UI / Structures / NavBar.qml

// import QtQuick
// import QtQuick.Controls

// import Components 1.0
// import Theme 1.0

// import "../Utils/Logger.js" as Logger


// Rectangle {
//     id: root

//     // =====================================================
//     // MEDIDAS GENERALES
//     // =====================================================

//     property bool barraPlegada: false

//     readonly property int barWidthExpandida: 210
//     readonly property int barWidthPlegada: 74

//     readonly property int anchoBotonExpandido: 180
//     readonly property int anchoBotonPlegado: 46

//     property int barWidth: barraPlegada ? barWidthPlegada : barWidthExpandida

//     width: barWidth
//     height: parent ? parent.height : 600

//     color: "#111827"
//     clip: true

//     Behavior on width {
//         NumberAnimation {
//             duration: 180
//             easing.type: Easing.OutCubic
//         }
//     }

//     /*
//         Mapeo propuesto según Main.qml:

//         Opción 1 / SectionActive 1 -> HOME
//         Opción 2 / SectionActive 2 -> Solicitud Alta Destinatario
//         Opción 3 / SectionActive 3 -> Solicitud Alta Tutor
//         Opción 4 / SectionActive 4 -> Solicitud Baja
//         Opción 5 / SectionActive 5 -> Configuración
//         Opción 6 / SectionActive 6 -> Solicitudes generadas
//         Opción 7 / SectionActive 7 -> Registrar destinatario
//         Opción 8 / SectionActive 8 -> Lista de destinatarios
//     */

//     property int selectionoption: 1
//     signal opcionSeleccionada(int opcion)

//     // =====================================================
//     // ESTADO DEL SUBMENÚ
//     // =====================================================

//     property bool menuAltaDesplegado: false

//     readonly property bool altaActiva: root.selectionoption === 2 || root.selectionoption === 3

//     // =====================================================
//     // BOTÓN PLEGAR / DESPLEGAR
//     // =====================================================

//     Rectangle {
//         id: buttonToggleSidebar

//         width: 34
//         height: 34
//         radius: 10

//         anchors.top: parent.top
//         anchors.right: parent.right
//         anchors.topMargin: 14
//         anchors.rightMargin: root.barraPlegada ? 20 : 14

//         color: mouseToggleSidebar.containsMouse ? "#374151" : "#1F2937"
//         border.color: "#374151"
//         border.width: 1

//         z: 10

//         Behavior on color {
//             ColorAnimation {
//                 duration: 120
//             }
//         }

//         Text {
//             anchors.centerIn: parent

//             text: root.barraPlegada ? "›" : "‹"

//             color: "#E5E7EB"

//             font.family: AppTheme.fuenteTitulo
//             font.pixelSize: 22
//             font.bold: true
//         }

//         MouseArea {
//             id: mouseToggleSidebar

//             anchors.fill: parent
//             hoverEnabled: true
//             cursorShape: Qt.PointingHandCursor

//             onClicked: {
//                 root.barraPlegada = !root.barraPlegada

//                 if (root.barraPlegada) {
//                     root.menuAltaDesplegado = false
//                 }

//                 Logger.linea()
//                 Logger.simple(
//                     "Sidebar",
//                     root.barraPlegada
//                         ? "barra lateral → plegada"
//                         : "barra lateral → desplegada"
//                 )
//             }
//         }
//     }

//     // =====================================================
//     // LOGO / MARCA
//     // =====================================================

//     Item {
//         id: marca

//         anchors.top: parent.top
//         anchors.left: parent.left
//         anchors.right: parent.right

//         anchors.topMargin: 22
//         anchors.leftMargin: root.barraPlegada ? 8 : 20
//         anchors.rightMargin: root.barraPlegada ? 8 : 18

//         height: root.barraPlegada ? 92 : 160

//         Behavior on height {
//             NumberAnimation {
//                 duration: 180
//                 easing.type: Easing.OutCubic
//             }
//         }

//         Image {
//             id: logoJade

//             anchors.centerIn: parent

//             width: root.barraPlegada ? 58 : 200
//             height: root.barraPlegada ? 58 : 200

//             source: "qrc:/qml/UI/Assets/icon_jade.png"
//             fillMode: Image.PreserveAspectFit
//             smooth: true
//             mipmap: true

//             Behavior on width {
//                 NumberAnimation {
//                     duration: 180
//                     easing.type: Easing.OutCubic
//                 }
//             }

//             Behavior on height {
//                 NumberAnimation {
//                     duration: 180
//                     easing.type: Easing.OutCubic
//                 }
//             }
//         }
//     }



//     // =====================================================
//     // MENÚ
//     // =====================================================

//     Column {
//         id: menu

//         anchors.top: marca.bottom
//         anchors.topMargin: root.barraPlegada ? 22 : 38

//         anchors.left: parent.left
//         anchors.right: parent.right

//         spacing: root.barraPlegada ? 22 : 30

//         Behavior on anchors.topMargin {
//             NumberAnimation {
//                 duration: 180
//                 easing.type: Easing.OutCubic
//             }
//         }

//         // =================================================
//         // SECCIÓN PRINCIPAL
//         // =================================================

//         Column {
//             id: seccionPrincipal

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "PRINCIPAL"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24

//                 visible: !root.barraPlegada
//                 opacity: root.barraPlegada ? 0 : 1

//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 120
//                     }
//                 }
//             }

//             CustonButton {
//                 id: buttonInicio

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Inicio"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_home.svg"

//                 active: root.selectionoption === 1

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 1
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(1)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → inicio")
//                 }
//             }

//             // =================================================
//             // ALTA - BOTÓN PRINCIPAL DESPLEGABLE
//             // =================================================

//             Rectangle {
//                 id: buttonSolicitudAlta

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido
//                 height: 46
//                 radius: 9

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: root.altaActiva || mouseAlta.containsMouse
//                        ? "#6D45D8"
//                        : "transparent"

//                 border.width: 0
//                 clip: true

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 Behavior on color {
//                     ColorAnimation {
//                         duration: 140
//                     }
//                 }

//                 Row {
//                     anchors.fill: parent
//                     anchors.leftMargin: root.barraPlegada ? 12 : 20
//                     anchors.rightMargin: root.barraPlegada ? 12 : 14

//                     spacing: root.barraPlegada ? 0 : 14

//                     Image {
//                         id: iconoSolicitudAlta
//                         width: 22
//                         height: parent.height
//                         source: "qrc:/qml/UI/Assets/icon/icon_solicitud_alta.svg"
//                         fillMode: Image.PreserveAspectFit
//                         smooth: true
//                         opacity: root.altaActiva || mouseAlta.containsMouse ? 1.0 : 0.75
//                     }

//                     Text {
//                         text: "Alta"

//                         visible: !root.barraPlegada
//                         opacity: root.barraPlegada ? 0 : 1

//                         width: parent.width - 22 - 14 - 20

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 13
//                         font.bold: true

//                         elide: Text.ElideRight

//                         Behavior on opacity {
//                             NumberAnimation {
//                                 duration: 120
//                             }
//                         }
//                     }

//                     Text {
//                         text: root.menuAltaDesplegado ? "⌃" : "⌄"

//                         visible: !root.barraPlegada
//                         opacity: root.barraPlegada ? 0 : 1

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 16
//                         font.bold: true

//                         Behavior on opacity {
//                             NumberAnimation {
//                                 duration: 120
//                             }
//                         }
//                     }
//                 }

//                 MouseArea {
//                     id: mouseAlta

//                     anchors.fill: parent
//                     hoverEnabled: true
//                     cursorShape: Qt.PointingHandCursor

//                     onClicked: {
//                         if (root.barraPlegada) {
//                             root.barraPlegada = false
//                             root.menuAltaDesplegado = true
//                         } else {
//                             root.menuAltaDesplegado = !root.menuAltaDesplegado
//                         }

//                         Logger.linea()
//                         Logger.simple(
//                             "Sidebar",
//                             root.menuAltaDesplegado
//                                 ? "menú alta → desplegado"
//                                 : "menú alta → contraído"
//                         )
//                     }
//                 }
//             }

//             // =================================================
//             // SUBMENÚ ALTA
//             // =================================================

//             Rectangle {
//                 id: submenuAlta

//                 visible: root.menuAltaDesplegado && !root.barraPlegada
//                 opacity: root.menuAltaDesplegado && !root.barraPlegada ? 1 : 0

//                 width: 170
//                 height: 104
//                 radius: 10

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: "#FFFFFF"
//                 border.color: "#E5E7EB"
//                 border.width: 1

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 140
//                     }
//                 }

//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 8

//                     spacing: 4

//                     SubMenuButton {
//                         id: submenuDestinatario

//                         width: parent.width

//                         label: "Destinatario"
//                         iconText: "♙"
//                         active: root.selectionoption === 2

//                         onClicked: {
//                             root.selectionoption = 2
//                             root.opcionSeleccionada(2)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → destinatario")
//                         }
//                     }

//                     SubMenuButton {
//                         id: submenuTutor

//                         width: parent.width

//                         label: "Tutor"
//                         iconText: "♙"
//                         active: root.selectionoption === 3

//                         onClicked: {
//                             root.selectionoption = 3
//                             root.opcionSeleccionada(3)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → tutor")
//                         }
//                     }
//                 }
//             }

//             // =================================================
//             // BAJA
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudBaja

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Baja"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitud_baja.svg"

//                 active: root.selectionoption === 4

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 4
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(4)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → baja")
//                 }
//             }

//             // =================================================
//             // REGISTRAR DESTINATARIO
//             // =================================================

//             CustonButton {
//                 id: buttonRegistrarDestinatario

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Destinatario"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_nuevo_destinatario.svg"

//                 active: root.selectionoption === 7

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 7
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(7)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → registrar destinatario")
//                 }
//             }

//             // =================================================
//             // LISTA DE DESTINATARIOS
//             // =================================================

//             CustonButton {
//                 id: buttonListaDestinatarios

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Asistencia"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_lista.svg"

//                 active: root.selectionoption === 8

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 8
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(8)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → lista de destinatarios")
//                 }
//             }

//             // =================================================
//             // SOLICITUDES GENERADAS
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudesGeneradas

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Solicitudes"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitudes.svg"

//                 active: root.selectionoption === 6

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 6
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(6)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → solicitudes generadas")
//                 }
//             }
//         }

//         // =================================================
//         // SECCIÓN AJUSTES
//         // =================================================

//         Column {
//             id: seccionAjustes

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "AJUSTES"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24

//                 visible: !root.barraPlegada
//                 opacity: root.barraPlegada ? 0 : 1

//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 120
//                     }
//                 }
//             }

//             CustonButton {
//                 id: buttonConfiguracion

//                 width: root.barraPlegada ? root.anchoBotonPlegado : root.anchoBotonExpandido

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Configuración"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"

//                 active: root.selectionoption === 5

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 onClicked: {
//                     root.selectionoption = 5
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(5)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → configuración")
//                 }
//             }
//         }
//     }

//     // =====================================================
//     // COMPONENTE INTERNO: BOTÓN DE SUBMENÚ
//     // =====================================================

//     component SubMenuButton: Rectangle {
//         id: subButton

//         property string label: "Opción"
//         property string iconText: "•"
//         property bool active: false

//         signal clicked()

//         height: 42
//         radius: 8

//         color: subButton.active || mouseSub.containsMouse
//                ? "#F0E7FF"
//                : "transparent"

//         Behavior on color {
//             ColorAnimation {
//                 duration: 120
//             }
//         }

//         Row {
//             anchors.fill: parent
//             anchors.leftMargin: 14
//             anchors.rightMargin: 12

//             spacing: 12

//             Text {
//                 text: subButton.iconText

//                 width: 22
//                 height: parent.height

//                 horizontalAlignment: Text.AlignHCenter
//                 verticalAlignment: Text.AlignVCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#6B7280"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 17
//                 font.bold: true
//             }

//             Text {
//                 text: subButton.label

//                 anchors.verticalCenter: parent.verticalCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#111827"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 13
//                 font.bold: subButton.active
//             }
//         }

//         MouseArea {
//             id: mouseSub

//             anchors.fill: parent
//             hoverEnabled: true
//             cursorShape: Qt.PointingHandCursor

//             onClicked: {
//                 subButton.clicked()
//             }
//         }
//     }
// }




// // UI / Structures / NavBar.qml

// import QtQuick
// import QtQuick.Controls

// import Components 1.0
// import Theme 1.0

// import "../Utils/Logger.js" as Logger


// Rectangle {
//     id: root

//     // =====================================================
//     // MEDIDAS GENERALES
//     // =====================================================

//     property bool barraPlegada: false

//     readonly property int barWidthExpandida: 210
//     readonly property int barWidthPlegada: 74

//     property int barWidth: barraPlegada ? barWidthPlegada : barWidthExpandida

//     width: barWidth
//     height: parent ? parent.height : 600

//     color: "#111827"
//     clip: true

//     Behavior on width {
//         NumberAnimation {
//             duration: 180
//             easing.type: Easing.OutCubic
//         }
//     }

//     /*
//         Mapeo propuesto según Main.qml:

//         Opción 1 / SectionActive 1 -> HOME
//         Opción 2 / SectionActive 2 -> Solicitud Alta Destinatario
//         Opción 3 / SectionActive 3 -> Solicitud Alta Tutor
//         Opción 4 / SectionActive 4 -> Solicitud Baja
//         Opción 5 / SectionActive 5 -> Configuración
//         Opción 6 / SectionActive 6 -> Solicitudes generadas
//         Opción 7 / SectionActive 7 -> Registrar destinatario
//         Opción 8 / SectionActive 8 -> Lista de destinatarios
//     */

//     property int selectionoption: 1
//     signal opcionSeleccionada(int opcion)

//     // =====================================================
//     // ESTADO DEL SUBMENÚ
//     // =====================================================

//     property bool menuAltaDesplegado: false

//     readonly property bool altaActiva: root.selectionoption === 2 || root.selectionoption === 3

//     // =====================================================
//     // BOTÓN PLEGAR / DESPLEGAR
//     // =====================================================

//     Rectangle {
//         id: buttonToggleSidebar

//         width: 34
//         height: 34
//         radius: 10

//         anchors.top: parent.top
//         anchors.right: parent.right
//         anchors.topMargin: 14
//         anchors.rightMargin: root.barraPlegada ? 20 : 14

//         color: mouseToggleSidebar.containsMouse ? "#374151" : "#1F2937"
//         border.color: "#374151"
//         border.width: 1

//         z: 10

//         Behavior on color {
//             ColorAnimation {
//                 duration: 120
//             }
//         }

//         Text {
//             anchors.centerIn: parent

//             text: root.barraPlegada ? "›" : "‹"

//             color: "#E5E7EB"

//             font.family: AppTheme.fuenteTitulo
//             font.pixelSize: 22
//             font.bold: true
//         }

//         MouseArea {
//             id: mouseToggleSidebar

//             anchors.fill: parent
//             hoverEnabled: true
//             cursorShape: Qt.PointingHandCursor

//             onClicked: {
//                 root.barraPlegada = !root.barraPlegada

//                 if (root.barraPlegada) {
//                     root.menuAltaDesplegado = false
//                 }

//                 Logger.linea()
//                 Logger.simple(
//                     "Sidebar",
//                     root.barraPlegada
//                         ? "barra lateral → plegada"
//                         : "barra lateral → desplegada"
//                 )
//             }
//         }
//     }

//     // =====================================================
//     // LOGO / MARCA
//     // =====================================================

//     Item {
//         id: marca

//         anchors.top: parent.top
//         anchors.left: parent.left
//         anchors.right: parent.right

//         anchors.topMargin: 22
//         anchors.leftMargin: root.barraPlegada ? 8 : 20
//         anchors.rightMargin: root.barraPlegada ? 8 : 18

//         height: root.barraPlegada ? 92 : 160

//         Behavior on height {
//             NumberAnimation {
//                 duration: 180
//                 easing.type: Easing.OutCubic
//             }
//         }

//         Image {
//             id: logoJade

//             anchors.centerIn: parent

//             width: root.barraPlegada ? 58 : 200
//             height: root.barraPlegada ? 58 : 200

//             source: "qrc:/qml/UI/Assets/icon_jade.png"
//             fillMode: Image.PreserveAspectFit
//             smooth: true
//             mipmap: true

//             Behavior on width {
//                 NumberAnimation {
//                     duration: 180
//                     easing.type: Easing.OutCubic
//                 }
//             }

//             Behavior on height {
//                 NumberAnimation {
//                     duration: 180
//                     easing.type: Easing.OutCubic
//                 }
//             }
//         }
//     }



//     // =====================================================
//     // MENÚ
//     // =====================================================

//     Column {
//         id: menu

//         anchors.top: marca.bottom
//         anchors.topMargin: root.barraPlegada ? 22 : 38

//         anchors.left: parent.left
//         anchors.right: parent.right

//         spacing: root.barraPlegada ? 22 : 30

//         Behavior on anchors.topMargin {
//             NumberAnimation {
//                 duration: 180
//                 easing.type: Easing.OutCubic
//             }
//         }

//         // =================================================
//         // SECCIÓN PRINCIPAL
//         // =================================================

//         Column {
//             id: seccionPrincipal

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "PRINCIPAL"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24

//                 visible: !root.barraPlegada
//                 opacity: root.barraPlegada ? 0 : 1

//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 120
//                     }
//                 }
//             }

//             CustonButton {
//                 id: buttonInicio

//                 anchors.horizontalCenter: parent.horizontalCenter
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_home.svg"
//                 active: root.selectionoption === 1

//                 onClicked: {
//                     root.selectionoption = 1
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(1)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → inicio")
//                 }
//             }

//             // =================================================
//             // ALTA - BOTÓN PRINCIPAL DESPLEGABLE
//             // =================================================

//             Rectangle {
//                 id: buttonSolicitudAlta

//                 width: root.barraPlegada ? 46 : 180
//                 height: 46
//                 radius: 9

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: root.altaActiva || mouseAlta.containsMouse
//                        ? "#6D45D8"
//                        : "transparent"

//                 border.width: 0
//                 clip: true

//                 Behavior on width {
//                     NumberAnimation {
//                         duration: 180
//                         easing.type: Easing.OutCubic
//                     }
//                 }

//                 Behavior on color {
//                     ColorAnimation {
//                         duration: 140
//                     }
//                 }

//                 Row {
//                     anchors.fill: parent
//                     anchors.leftMargin: root.barraPlegada ? 12 : 20
//                     anchors.rightMargin: root.barraPlegada ? 12 : 14

//                     spacing: root.barraPlegada ? 0 : 14

//                     Image {
//                         id: iconoSolicitudAlta
//                         width: 22
//                         height: parent.height
//                         source: "qrc:/qml/UI/Assets/icon/icon_solicitud_alta.svg"
//                         fillMode: Image.PreserveAspectFit
//                         smooth: true
//                         opacity: root.altaActiva || mouseAlta.containsMouse ? 1.0 : 0.75
//                     }

//                     Text {
//                         text: "Alta"

//                         visible: !root.barraPlegada
//                         opacity: root.barraPlegada ? 0 : 1

//                         width: parent.width - 22 - 14 - 20

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 13
//                         font.bold: true

//                         elide: Text.ElideRight

//                         Behavior on opacity {
//                             NumberAnimation {
//                                 duration: 120
//                             }
//                         }
//                     }

//                     Text {
//                         text: root.menuAltaDesplegado ? "⌃" : "⌄"

//                         visible: !root.barraPlegada
//                         opacity: root.barraPlegada ? 0 : 1

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 16
//                         font.bold: true

//                         Behavior on opacity {
//                             NumberAnimation {
//                                 duration: 120
//                             }
//                         }
//                     }
//                 }

//                 MouseArea {
//                     id: mouseAlta

//                     anchors.fill: parent
//                     hoverEnabled: true
//                     cursorShape: Qt.PointingHandCursor

//                     onClicked: {
//                         if (root.barraPlegada) {
//                             root.barraPlegada = false
//                             root.menuAltaDesplegado = true
//                         } else {
//                             root.menuAltaDesplegado = !root.menuAltaDesplegado
//                         }

//                         Logger.linea()
//                         Logger.simple(
//                             "Sidebar",
//                             root.menuAltaDesplegado
//                                 ? "menú alta → desplegado"
//                                 : "menú alta → contraído"
//                         )
//                     }
//                 }
//             }

//             // =================================================
//             // SUBMENÚ ALTA
//             // =================================================

//             Rectangle {
//                 id: submenuAlta

//                 visible: root.menuAltaDesplegado && !root.barraPlegada
//                 opacity: root.menuAltaDesplegado && !root.barraPlegada ? 1 : 0

//                 width: 170
//                 height: 104
//                 radius: 10

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: "#FFFFFF"
//                 border.color: "#E5E7EB"
//                 border.width: 1

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 140
//                     }
//                 }

//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 8

//                     spacing: 4

//                     SubMenuButton {
//                         id: submenuDestinatario

//                         width: parent.width

//                         label: "Destinatario"
//                         iconText: "♙"
//                         active: root.selectionoption === 2

//                         onClicked: {
//                             root.selectionoption = 2
//                             root.opcionSeleccionada(2)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → destinatario")
//                         }
//                     }

//                     SubMenuButton {
//                         id: submenuTutor

//                         width: parent.width

//                         label: "Tutor"
//                         iconText: "♙"
//                         active: root.selectionoption === 3

//                         onClicked: {
//                             root.selectionoption = 3
//                             root.opcionSeleccionada(3)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → tutor")
//                         }
//                     }
//                 }
//             }

//             // =================================================
//             // BAJA
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudBaja

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Baja"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitud_baja.svg"

//                 active: root.selectionoption === 4

//                 onClicked: {
//                     root.selectionoption = 4
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(4)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → baja")
//                 }
//             }

//             // =================================================
//             // REGISTRAR DESTINATARIO
//             // =================================================

//             CustonButton {
//                 id: buttonRegistrarDestinatario

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Destinatario"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_nuevo_destinatario.svg"

//                 active: root.selectionoption === 7

//                 onClicked: {
//                     root.selectionoption = 7
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(7)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → registrar destinatario")
//                 }
//             }

//             // =================================================
//             // LISTA DE DESTINATARIOS
//             // =================================================

//             CustonButton {
//                 id: buttonListaDestinatarios

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Asistencia"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_lista.svg"

//                 active: root.selectionoption === 8

//                 onClicked: {
//                     root.selectionoption = 8
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(8)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → lista de destinatarios")
//                 }
//             }

//             // =================================================
//             // SOLICITUDES GENERADAS
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudesGeneradas

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Solicitudes"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitudes.svg"

//                 active: root.selectionoption === 6

//                 onClicked: {
//                     root.selectionoption = 6
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(6)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → solicitudes generadas")
//                 }
//             }
//         }

//         // =================================================
//         // SECCIÓN AJUSTES
//         // =================================================

//         Column {
//             id: seccionAjustes

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "AJUSTES"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24

//                 visible: !root.barraPlegada
//                 opacity: root.barraPlegada ? 0 : 1

//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 120
//                     }
//                 }
//             }

//             CustonButton {
//                 id: buttonConfiguracion

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: root.barraPlegada ? "" : "Configuración"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"

//                 active: root.selectionoption === 5

//                 onClicked: {
//                     root.selectionoption = 5
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(5)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → configuración")
//                 }
//             }
//         }
//     }

//     // =====================================================
//     // COMPONENTE INTERNO: BOTÓN DE SUBMENÚ
//     // =====================================================

//     component SubMenuButton: Rectangle {
//         id: subButton

//         property string label: "Opción"
//         property string iconText: "•"
//         property bool active: false

//         signal clicked()

//         height: 42
//         radius: 8

//         color: subButton.active || mouseSub.containsMouse
//                ? "#F0E7FF"
//                : "transparent"

//         Behavior on color {
//             ColorAnimation {
//                 duration: 120
//             }
//         }

//         Row {
//             anchors.fill: parent
//             anchors.leftMargin: 14
//             anchors.rightMargin: 12

//             spacing: 12

//             Text {
//                 text: subButton.iconText

//                 width: 22
//                 height: parent.height

//                 horizontalAlignment: Text.AlignHCenter
//                 verticalAlignment: Text.AlignVCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#6B7280"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 17
//                 font.bold: true
//             }

//             Text {
//                 text: subButton.label

//                 anchors.verticalCenter: parent.verticalCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#111827"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 13
//                 font.bold: subButton.active
//             }
//         }

//         MouseArea {
//             id: mouseSub

//             anchors.fill: parent
//             hoverEnabled: true
//             cursorShape: Qt.PointingHandCursor

//             onClicked: {
//                 subButton.clicked()
//             }
//         }
//     }
// }



// // UI / Structures / NavBar.qml

// import QtQuick
// import QtQuick.Controls

// import Components 1.0
// import Theme 1.0

// import "../Utils/Logger.js" as Logger


// Rectangle {
//     id: root

//     // =====================================================
//     // MEDIDAS GENERALES
//     // =====================================================

//     property int barWidth: 210

//     width: barWidth
//     height: parent ? parent.height : 600

//     color: "#111827"

//     /*
//         Mapeo propuesto según Main.qml:

//         Opción 1 / SectionActive 1 -> HOME
//         Opción 2 / SectionActive 2 -> Solicitud Alta Destinatario
//         Opción 3 / SectionActive 3 -> Solicitud Alta Tutor
//         Opción 4 / SectionActive 4 -> Solicitud Baja
//         Opción 5 / SectionActive 5 -> Configuración
//         Opción 6 / SectionActive 6 -> Solicitudes generadas
//         Opción 7 / SectionActive 7 -> Registrar destinatario
//         Opción 8 / SectionActive 8 -> Lista de destinatarios
//     */

//     property int selectionoption: 1
//     signal opcionSeleccionada(int opcion)

//     // =====================================================
//     // ESTADO DEL SUBMENÚ
//     // =====================================================

//     property bool menuAltaDesplegado: false

//     readonly property bool altaActiva: root.selectionoption === 2 || root.selectionoption === 3

//     // =====================================================
//     // LOGO / MARCA
//     // =====================================================

//     Item {
//         id: marca

//         anchors.top: parent.top
//         anchors.left: parent.left
//         anchors.right: parent.right

//         anchors.topMargin: 22
//         anchors.leftMargin: 20
//         anchors.rightMargin: 18

//         height: 160

//         Image {
//             id: logoJade

//             anchors.centerIn: parent

//             width: 200
//             height: 200

//             source: "qrc:/qml/UI/Assets/icon_jade.png"
//             fillMode: Image.PreserveAspectFit
//             smooth: true
//             mipmap: true
//         }
//     }



//     // =====================================================
//     // MENÚ
//     // =====================================================

//     Column {
//         id: menu

//         anchors.top: marca.bottom
//         anchors.topMargin: 38

//         anchors.left: parent.left
//         anchors.right: parent.right

//         spacing: 30

//         // =================================================
//         // SECCIÓN PRINCIPAL
//         // =================================================

//         Column {
//             id: seccionPrincipal

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "PRINCIPAL"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24
//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8
//             }

//             CustonButton {
//                 id: buttonInicio

//                 anchors.horizontalCenter: parent.horizontalCenter
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_home.svg"
//                 active: root.selectionoption === 1

//                 onClicked: {
//                     root.selectionoption = 1
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(1)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → inicio")
//                 }
//             }

//             // =================================================
//             // ALTA - BOTÓN PRINCIPAL DESPLEGABLE
//             // =================================================

//             Rectangle {
//                 id: buttonSolicitudAlta

//                 width: 180
//                 height: 46
//                 radius: 9

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: root.altaActiva || mouseAlta.containsMouse
//                        ? "#6D45D8"
//                        : "transparent"

//                 border.width: 0

//                 Behavior on color {
//                     ColorAnimation {
//                         duration: 140
//                     }
//                 }

//                 Row {
//                     anchors.fill: parent
//                     anchors.leftMargin: 20
//                     anchors.rightMargin: 14

//                     spacing: 14

//                     Image {
//                         id: iconoSolicitudAlta
//                         width: 22
//                         height: parent.height
//                         source: "qrc:/qml/UI/Assets/icon/icon_solicitud_alta.svg"
//                         fillMode: Image.PreserveAspectFit
//                         smooth: true
//                         opacity: root.altaActiva || mouseAlta.containsMouse ? 1.0 : 0.75
//                     }

//                     Text {
//                         text: "Alta"

//                         width: parent.width - 22 - 14 - 20

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 13
//                         font.bold: true

//                         elide: Text.ElideRight
//                     }

//                     Text {
//                         text: root.menuAltaDesplegado ? "⌃" : "⌄"

//                         anchors.verticalCenter: parent.verticalCenter

//                         color: root.altaActiva || mouseAlta.containsMouse
//                                ? "#FFFFFF"
//                                : "#D1D5DB"

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 16
//                         font.bold: true
//                     }
//                 }

//                 MouseArea {
//                     id: mouseAlta

//                     anchors.fill: parent
//                     hoverEnabled: true
//                     cursorShape: Qt.PointingHandCursor

//                     onClicked: {
//                         root.menuAltaDesplegado = !root.menuAltaDesplegado

//                         Logger.linea()
//                         Logger.simple(
//                             "Sidebar",
//                             root.menuAltaDesplegado
//                                 ? "menú alta → desplegado"
//                                 : "menú alta → contraído"
//                         )
//                     }
//                 }
//             }

//             // =================================================
//             // SUBMENÚ ALTA
//             // =================================================

//             Rectangle {
//                 id: submenuAlta

//                 visible: root.menuAltaDesplegado
//                 opacity: root.menuAltaDesplegado ? 1 : 0

//                 width: 170
//                 height: 104
//                 radius: 10

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 color: "#FFFFFF"
//                 border.color: "#E5E7EB"
//                 border.width: 1

//                 Behavior on opacity {
//                     NumberAnimation {
//                         duration: 140
//                     }
//                 }

//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 8

//                     spacing: 4

//                     SubMenuButton {
//                         id: submenuDestinatario

//                         width: parent.width

//                         label: "Destinatario"
//                         iconText: "♙"
//                         active: root.selectionoption === 2

//                         onClicked: {
//                             root.selectionoption = 2
//                             root.opcionSeleccionada(2)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → destinatario")
//                         }
//                     }

//                     SubMenuButton {
//                         id: submenuTutor

//                         width: parent.width

//                         label: "Tutor"
//                         iconText: "♙"
//                         active: root.selectionoption === 3

//                         onClicked: {
//                             root.selectionoption = 3
//                             root.opcionSeleccionada(3)

//                             Logger.linea()
//                             Logger.simple("Sidebar", "alta → tutor")
//                         }
//                     }
//                 }
//             }

//             // =================================================
//             // BAJA
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudBaja

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Baja"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitud_baja.svg"

//                 active: root.selectionoption === 4

//                 onClicked: {
//                     root.selectionoption = 4
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(4)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → baja")
//                 }
//             }

//             // =================================================
//             // REGISTRAR DESTINATARIO
//             // =================================================

//             CustonButton {
//                 id: buttonRegistrarDestinatario

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Destinatario"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_nuevo_destinatario.svg"

//                 active: root.selectionoption === 7

//                 onClicked: {
//                     root.selectionoption = 7
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(7)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → registrar destinatario")
//                 }
//             }

//             // =================================================
//             // LISTA DE DESTINATARIOS
//             // =================================================

//             CustonButton {
//                 id: buttonListaDestinatarios

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Asistencia"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_lista.svg"

//                 active: root.selectionoption === 8

//                 onClicked: {
//                     root.selectionoption = 8
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(8)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → lista de destinatarios")
//                 }
//             }

//             // =================================================
//             // SOLICITUDES GENERADAS
//             // =================================================

//             CustonButton {
//                 id: buttonSolicitudesGeneradas

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Solicitudes"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_solicitudes.svg"

//                 active: root.selectionoption === 6

//                 onClicked: {
//                     root.selectionoption = 6
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(6)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → solicitudes generadas")
//                 }
//             }
//         }

//         // =================================================
//         // SECCIÓN AJUSTES
//         // =================================================

//         Column {
//             id: seccionAjustes

//             width: parent.width
//             spacing: 10

//             Text {
//                 text: "AJUSTES"

//                 anchors.left: parent.left
//                 anchors.leftMargin: 24

//                 color: "#6B7280"

//                 font.family: AppTheme.fuenteCuerpo
//                 font.pixelSize: 11
//                 font.bold: true
//                 font.letterSpacing: 0.8
//             }

//             CustonButton {
//                 id: buttonConfiguracion

//                 anchors.horizontalCenter: parent.horizontalCenter

//                 label: "Configuración"
//                 iconSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"

//                 active: root.selectionoption === 5

//                 onClicked: {
//                     root.selectionoption = 5
//                     root.menuAltaDesplegado = false
//                     root.opcionSeleccionada(5)

//                     Logger.linea()
//                     Logger.simple("Sidebar", "sección → configuración")
//                 }
//             }
//         }
//     }

//     // =====================================================
//     // COMPONENTE INTERNO: BOTÓN DE SUBMENÚ
//     // =====================================================

//     component SubMenuButton: Rectangle {
//         id: subButton

//         property string label: "Opción"
//         property string iconText: "•"
//         property bool active: false

//         signal clicked()

//         height: 42
//         radius: 8

//         color: subButton.active || mouseSub.containsMouse
//                ? "#F0E7FF"
//                : "transparent"

//         Behavior on color {
//             ColorAnimation {
//                 duration: 120
//             }
//         }

//         Row {
//             anchors.fill: parent
//             anchors.leftMargin: 14
//             anchors.rightMargin: 12

//             spacing: 12

//             Text {
//                 text: subButton.iconText

//                 width: 22
//                 height: parent.height

//                 horizontalAlignment: Text.AlignHCenter
//                 verticalAlignment: Text.AlignVCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#6B7280"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 17
//                 font.bold: true
//             }

//             Text {
//                 text: subButton.label

//                 anchors.verticalCenter: parent.verticalCenter

//                 color: subButton.active || mouseSub.containsMouse
//                        ? AppTheme.colorPrimario
//                        : "#111827"

//                 font.family: AppTheme.fuenteTitulo
//                 font.pixelSize: 13
//                 font.bold: subButton.active
//             }
//         }

//         MouseArea {
//             id: mouseSub

//             anchors.fill: parent
//             hoverEnabled: true
//             cursorShape: Qt.PointingHandCursor

//             onClicked: {
//                 subButton.clicked()
//             }
//         }
//     }
// }
