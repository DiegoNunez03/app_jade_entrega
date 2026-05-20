// UI/Components/FieldHelpIcon.qml

import QtQuick
import QtQuick.Controls
import Theme 1.0


Item {
    id: root

    property string mensaje: "Información del campo"

    width: 18
    height: 18

    component FieldBox: Rectangle {
        id: fieldBox

        property bool campoObligatorio: true

        function labelConObligatorio(texto) {
            return fieldBox.campoObligatorio ? texto + " *" : texto
        }

        radius: 10
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1

        default property alias content: contentHost.data

        Item {
            id: contentHost

            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.topMargin: 8
            anchors.bottomMargin: 8
        }
    }

    Text {
        anchors.centerIn: parent

        text: "ⓘ"

        color: AppTheme.colorPrimario

        font.family: AppTheme.fuenteTitulo
        font.pixelSize: 15
        font.bold: true
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    ToolTip.visible: mouseArea.containsMouse
    ToolTip.text: root.mensaje
    ToolTip.delay: 250
    ToolTip.timeout: 6000
}