// UI / Components / CustonButton2.qml

import QtQuick
import QtQuick.Controls
import Theme 1.0

Button {
    id: root

    // =====================================================
    // PROPIEDADES EXPORTABLES
    // =====================================================

    /*
        tipo:
        - "siguiente"
        - "anterior"
        - "generar"
        - "custom"

        variante:
        - "primary"
        - "secondary"
    */

    property string tipo: "custom"
    property string variante: "primary"

    property string texto: "Siguiente"

    property string textoCustom: texto
    property string iconoCustom: ""

    readonly property bool esPrimary: variante === "primary"
    readonly property bool esSecondary: variante === "secondary"

    readonly property string textoBoton: tipo === "generar"
                                         ? "Generar solicitud"
                                         : tipo === "custom"
                                           ? textoCustom
                                           : ""

    readonly property string iconoBoton: tipo === "anterior"
                                         ? "←"
                                         : tipo === "siguiente"
                                           ? "→"
                                           : tipo === "generar"
                                             ? "▣"
                                             : iconoCustom

    readonly property bool mostrarTexto: textoBoton !== ""
    readonly property bool mostrarIcono: iconoBoton !== ""

    // =====================================================
    // MEDIDAS
    // =====================================================

    width: tipo === "generar" ? 190 : 58
    height: 46

    hoverEnabled: true

    padding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    // =====================================================
    // FONDO
    // =====================================================

    background: Item {
        id: fondoRoot

        Rectangle {
            id: fondoPrimary

            anchors.fill: parent
            radius: 13
            visible: root.esPrimary

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: root.enabled
                           ? root.down
                             ? "#4F2BB8"
                             : root.hovered
                               ? "#8B5CF6"
                               : "#6D45D8"
                           : "#D1D5DB"
                }

                GradientStop {
                    position: 1.0
                    color: root.enabled
                           ? root.down
                             ? "#2563EB"
                             : root.hovered
                               ? "#38BDF8"
                               : "#4F8DF7"
                           : "#E5E7EB"
                }
            }

            opacity: root.enabled ? 1.0 : 0.65
            scale: root.down ? 0.97 : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        Rectangle {
            id: fondoSecondary

            anchors.fill: parent
            radius: 13
            visible: root.esSecondary

            color: root.down
                   ? "#EEE7FF"
                   : root.hovered
                     ? "#F4EFFF"
                     : "#FFFFFF"

            border.width: 1
            border.color: root.enabled
                          ? AppTheme.colorPrimario
                          : "#D1D5DB"

            opacity: root.enabled ? 1.0 : 0.65
            scale: root.down ? 0.97 : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }
    }

    // =====================================================
    // CONTENIDO
    // =====================================================

    contentItem: Item {
        id: contenidoRoot

        Row {
            id: contenido

            anchors.centerIn: parent

            spacing: root.tipo === "generar" ? 10 : 0

            Text {
                id: textoBotonItem

                visible: root.mostrarTexto
                text: root.textoBoton

                color: root.esPrimary
                       ? "#FFFFFF"
                       : AppTheme.colorPrimario

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 14
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: iconoBotonItem

                visible: root.mostrarIcono
                text: root.iconoBoton
                width: implicitWidth
                height: implicitHeight
                color: root.esPrimary ? "#FFFFFF" : AppTheme.colorPrimario

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: root.tipo === "generar" ? 18 : root.tipo === "custom" ? 20 : 25
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}