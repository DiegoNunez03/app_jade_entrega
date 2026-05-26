// UI / Components / CustonButton.qml

import QtQuick
import QtQuick.Controls
import Theme 1.0

Button {
    id: root

    // =====================================================
    // PROPIEDADES EXPORTABLES
    // =====================================================

    property string label: "Inicio"
    property string iconText: "⌂"
    property string iconSource: ""

    property bool active: false
    property bool compactMode: false

    // Modo visual pensado para sidebar oscura
    property color normalTextColor: "#D1D5DB"
    property color activeTextColor: "#FFFFFF"
    property color hoverTextColor: "#FFFFFF"

    property color normalBackgroundColor: "transparent"
    property color activeBackgroundColor: "#6D45D8"
    property color hoverBackgroundColor: "#1F2937"
    property color pressedBackgroundColor: "#4F2BB8"

    property int iconSize: 20
    property int textSize: 14

    property int buttonWidth: 182
    property int buttonHeight: 46
    property int radiusSize: 12

    width: buttonWidth
    height: buttonHeight

    flat: true
    hoverEnabled: true

    padding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    // =====================================================
    // TOOLTIP
    // =====================================================

    ToolTip.visible: root.hovered && root.compactMode
    ToolTip.text: root.label
    ToolTip.delay: 550
    ToolTip.timeout: 2600

    // =====================================================
    // FONDO
    // =====================================================

    background: Rectangle {
        id: fondo

        anchors.fill: parent
        radius: root.radiusSize

        color: root.active
               ? root.activeBackgroundColor
               : root.down
                 ? root.pressedBackgroundColor
                 : root.hovered
                   ? root.hoverBackgroundColor
                   : root.normalBackgroundColor

        border.width: root.active ? 1 : 0
        border.color: root.active ? "#8B5CF6" : "transparent"

        scale: root.down ? 0.97 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 230
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuad
            }
        }
    }

    // =====================================================
    // INDICADOR ACTIVO LATERAL
    // =====================================================

    Rectangle {
        id: indicadorActivo

        width: 4
        height: parent.height * 0.55
        radius: 2

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        color: "#FFFFFF"

        visible: root.active
        opacity: root.active ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 220
            }
        }
    }

    // =====================================================
    // CONTENIDO
    // =====================================================

    contentItem: Row {
        id: contenido

        anchors.fill: parent
        anchors.leftMargin: root.compactMode ? 0 : 18
        anchors.rightMargin: root.compactMode ? 0 : 14

        spacing: root.compactMode ? 0 : 12

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Item {
            width: root.compactMode ? parent.width : 28
            height: parent.height

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Image {
                visible: root.iconSource !== ""
                source: root.iconSource

                anchors.centerIn: parent

                width: root.iconSize
                height: root.iconSize

                fillMode: Image.PreserveAspectFit
                smooth: true

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

            Text {
                id: icono

                visible: root.iconSource === ""
                text: root.iconText

                anchors.centerIn: parent

                width: root.iconSize
                height: root.iconSize

                color: root.active
                       ? root.activeTextColor
                       : root.hovered
                         ? root.hoverTextColor
                         : root.normalTextColor

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: root.iconSize
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 230
                    }
                }

                Behavior on font.pixelSize {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Text {
            id: texto

            visible: !root.compactMode
            opacity: root.compactMode ? 0 : 1

            text: root.label

            height: parent.height

            color: root.active
                   ? root.activeTextColor
                   : root.hovered
                     ? root.hoverTextColor
                     : root.normalTextColor

            font.family: AppTheme.fuenteCuerpo
            font.pixelSize: root.textSize
            font.bold: root.active

            verticalAlignment: Text.AlignVCenter

            Behavior on color {
                ColorAnimation {
                    duration: 230
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }
    }
}