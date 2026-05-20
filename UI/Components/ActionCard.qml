import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import Theme 1.0
import Layout 1.0


Item {
    id: root

    width: 300
    height: AppLayout.actionCardHeight

    // ===============================
    // PROPIEDADES EXPORTABLES
    // ===============================

    property string titulo: "Título"
    property string descripcion: "Descripción breve de la acción."

    // Compatibilidad con íconos de texto
    property string icono: "+"

    // Nuevo: soporte para íconos de imagen
    property string iconoSource: ""

    property color iconoColor: AppTheme.colorAcento
    property color iconoFondo: AppTheme.colorAcentoSuave

    signal clicked()

    // ===============================
    // ESTADO INTERACTIVO
    // ===============================

    property bool hovered: mouseArea.containsMouse

    // ===============================
    // SOMBRA
    // ===============================

    MultiEffect {
        id: cardShadow

        anchors.fill: card
        source: card

        shadowEnabled: true
        shadowColor: "#26000000"
        shadowOpacity: root.hovered ? 0.28 : 0.12
        shadowBlur: root.hovered ? 0.55 : 0.25
        shadowVerticalOffset: root.hovered ? 8 : 3
        shadowHorizontalOffset: 0

        visible: true
        z: 0

        Behavior on shadowOpacity {
            NumberAnimation {
                duration: AppTheme.animationFast
                easing.type: Easing.OutQuad
            }
        }

        Behavior on shadowBlur {
            NumberAnimation {
                duration: AppTheme.animationFast
                easing.type: Easing.OutQuad
            }
        }

        Behavior on shadowVerticalOffset {
            NumberAnimation {
                duration: AppTheme.animationFast
                easing.type: Easing.OutQuad
            }
        }
    }

    // ===============================
    // TARJETA
    // ===============================

    Rectangle {
        id: card

        anchors.fill: parent

        radius: AppTheme.cardRadius
        color: AppTheme.cardFondo

        border.width: root.hovered ? 2 : 1
        border.color: root.hovered ? AppTheme.colorPrimario : AppTheme.cardBorde

        scale: root.hovered ? 1.015 : 1.0
        z: 1

        Behavior on scale {
            NumberAnimation {
                duration: AppTheme.animationFast
                easing.type: Easing.OutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: AppTheme.animationFast
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: AppTheme.animationFast
            }
        }

        RowLayout {
            anchors.fill: parent

            anchors.margins: AppLayout.esCompacto
                             ? AppTheme.spacingMd
                             : AppTheme.spacingXl

            spacing: AppLayout.esCompacto
                     ? AppTheme.spacingMd
                     : AppTheme.spacingXl

            Rectangle {
                id: iconContainer

                Layout.preferredWidth: AppLayout.esCompacto
                                       ? Math.max(48, AppLayout.actionCardIconSize - 18)
                                       : Math.max(58, AppLayout.actionCardIconSize - 14)

                Layout.preferredHeight: AppLayout.esCompacto
                                        ? Math.max(48, AppLayout.actionCardIconSize - 18)
                                        : Math.max(58, AppLayout.actionCardIconSize - 14)

                Layout.alignment: Qt.AlignTop

                radius: AppTheme.radiusFull
                color: root.iconoFondo

                Image {
                    id: iconImage

                    visible: root.iconoSource !== ""

                    anchors.centerIn: parent

                    width: parent.width * 0.56
                    height: parent.height * 0.56

                    source: root.iconoSource
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    // mipmap: true
                }

                Text {
                    id: iconText

                    visible: root.iconoSource === ""

                    anchors.centerIn: parent

                    text: root.icono
                    color: root.iconoColor

                    font.family: AppTheme.fuenteTitulo
                    font.pixelSize: AppLayout.esCompacto
                                    ? Math.max(18, AppLayout.actionCardIconFontSize - 4)
                                    : AppLayout.actionCardIconFontSize

                    font.weight: AppTheme.fontWeightRegular
                }
            }

            Column {
                id: textColumn

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: AppTheme.spacingSm

                Text {
                    text: root.titulo

                    width: parent.width
                    color: AppTheme.colorTextoPrincipal

                    font.family: AppTheme.fuenteTitulo
                    font.pixelSize: AppLayout.actionCardTitleSize
                    font.weight: AppTheme.pesoTituloTarjeta

                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    text: root.descripcion

                    width: parent.width
                    color: AppTheme.colorTextoSecundario

                    font.family: AppTheme.fuenteCuerpo
                    font.pixelSize: AppLayout.actionCardDescriptionSize
                    font.weight: AppTheme.pesoTextoSecundario

                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                    maximumLineCount: AppLayout.esCompacto ? 3 : 4
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: root.clicked()
        }
    }
}