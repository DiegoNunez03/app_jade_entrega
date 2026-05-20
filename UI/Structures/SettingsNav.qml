// UI / Structures / SettingsNav.qml

import QtQuick
import QtQuick.Controls

import Theme 1.0


Rectangle {
    id: root
    width: 280
    height: 420
    color: "#FFFFFF"

    // =====================================================
    // ESTADO
    // =====================================================

    /*
        1 -> Configuración sede
        2 -> Configuración texto
        3 -> Configuración general
    */

    property int selectedOption: 1

    signal opcionSeleccionada(int opcion)

    // =====================================================
    // DISPONIBILIDAD CONFIGURABLE DESDE SECTIONFIVE
    // =====================================================

    property bool sedeDisponible: true
    property bool textoDisponible: true
    property bool generalDisponible: true

    // =====================================================
    // CONTENIDO
    // =====================================================

    Column {
        id: opciones

        anchors.fill: parent
        anchors.topMargin: 26
        anchors.leftMargin: 18
        anchors.rightMargin: 18

        spacing: 14

        SettingsNavButton {
            id: buttonSede

            width: parent.width

            label: "Configuración sede"
            iconText: "▣"
            active: root.selectedOption === 1
            disponible: root.sedeDisponible
            tooltipBloqueado: "Esta configuración está disponible."

            onClicked: {
                if (!buttonSede.disponible) {
                    return
                }

                root.selectedOption = 1
                root.opcionSeleccionada(1)
            }
        }

        SettingsNavButton {
            id: buttonTexto

            width: parent.width

            label: "Configuración texto"
            iconText: "T"
            active: root.selectedOption === 2
            disponible: root.textoDisponible
            tooltipBloqueado: "Configuración de texto pendiente de implementación."

            onClicked: {
                if (!buttonTexto.disponible) {
                    return
                }

                root.selectedOption = 2
                root.opcionSeleccionada(2)
            }
        }

        SettingsNavButton {
            id: buttonGeneral

            width: parent.width

            label: "Configuración general"
            iconText: "⚙"
            active: root.selectedOption === 3
            disponible: root.generalDisponible
            tooltipBloqueado: "Configuración general pendiente de implementación."

            onClicked: {
                if (!buttonGeneral.disponible) {
                    return
                }

                root.selectedOption = 3
                root.opcionSeleccionada(3)
            }
        }
    }

    // =====================================================
    // INDICADOR LATERAL DE OPCIÓN ACTIVA
    // =====================================================

    Rectangle {
        id: indicadorActivo

        visible: root.selectedOption === 1
                 ? root.sedeDisponible
                 : root.selectedOption === 2
                   ? root.textoDisponible
                   : root.generalDisponible

        width: 4
        height: 52
        radius: 2

        x: 0

        y: opciones.y
           + (root.selectedOption === 1
              ? buttonSede.y
              : root.selectedOption === 2
                ? buttonTexto.y
                : buttonGeneral.y)

        color: AppTheme.colorPrimario

        Behavior on y {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutQuad
            }
        }
    }

    // =====================================================
    // COMPONENTE INTERNO: BOTÓN DE OPCIÓN
    // =====================================================

    component SettingsNavButton: Rectangle {
        id: button

        property string label: "Opción"
        property string iconText: "•"
        property bool active: false
        property bool disponible: true
        property string tooltipBloqueado: "Opción no disponible."

        signal clicked()

        height: 52
        radius: 10

        opacity: button.disponible ? 1.0 : 0.48

        color: button.active && button.disponible
               ? "#F0E7FF"
               : mouseArea.containsMouse && button.disponible
                 ? "#F7F2FF"
                 : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 140
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 14

            spacing: 14

            Text {
                text: button.iconText

                width: 24
                height: parent.height

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: button.disponible
                       ? button.active || mouseArea.containsMouse
                         ? AppTheme.colorPrimario
                         : "#6B7280"
                       : "#9CA3AF"

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 20
                font.bold: true
            }

            Text {
                text: button.label

                anchors.verticalCenter: parent.verticalCenter

                color: button.disponible
                       ? button.active || mouseArea.containsMouse
                         ? AppTheme.colorPrimario
                         : AppTheme.colorTextoSecundario
                       : "#9CA3AF"

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 15
                font.bold: button.active && button.disponible
            }

            Item {
                width: 1
                height: 1
            }
        }

        Text {
            visible: !button.disponible

            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            text: "Bloqueado"

            color: "#9CA3AF"

            font.family: AppTheme.fuenteCuerpo
            font.pixelSize: 10
            font.bold: true
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: button.disponible
                         ? Qt.PointingHandCursor
                         : Qt.ForbiddenCursor

            onClicked: {
                if (!button.disponible) {
                    return
                }

                button.clicked()
            }
        }

        ToolTip.visible: mouseArea.containsMouse && !button.disponible
        ToolTip.text: button.tooltipBloqueado
        ToolTip.delay: 350
        ToolTip.timeout: 2500
    }
}