import QtQuick

Rectangle {
    id: label

    // Propiedades modificables desde afuera
    property string texto: "LABEL"
    property color colorFondo: "#ffffff"
    property color colorBorde: "#222222"
    property color colorTexto: "#111111"

    property int radioBorde: 6
    property int grosorBorde: 1
    property int tamanoFuente: 13

    width: 160
    height: 34

    color: label.colorFondo
    radius: label.radioBorde

    border.color: label.colorBorde
    border.width: label.grosorBorde

    Text {
        anchors.centerIn: parent
        text: label.texto

        color: label.colorTexto
        font.family: "Arial"
        font.pixelSize: label.tamanoFuente
        font.bold: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}