// UI / Components / InputText.qml

import QtQuick
import QtQuick.Controls

Item {
    id: root

    width: 360
    height: 80

    property string label: "Full Name"
    property string placeholder: "Alarcon"
    property alias text: input.text

    property color labelColor: "#6f63c7"
    property color placeholderColor: "#7f7f7f"
    property color textColor: "#333333"

    property color lineColor: "#b8b8b8"
    property color lineFocusColor: "#6f63c7"

    Text {
        id: titulo

        anchors.top: parent.top
        anchors.left: parent.left

        text: root.label

        font.family: "Arial"
        font.pixelSize: 18
        font.bold: true

        color: root.labelColor
    }

    TextField {
        id: input

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titulo.bottom
        anchors.topMargin: 8

        height: 34

        hoverEnabled: true

        placeholderText: root.placeholder

        color: root.textColor
        placeholderTextColor: root.placeholderColor

        font.family: "Arial"
        font.pixelSize: 15

        background: Rectangle {
            color: input.hovered || input.activeFocus
                   ? "#11000000"
                   : "transparent"

            radius: 4
            border.width: 0
        }

        padding: 0
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
    }

    Rectangle {
        id: lineaInferior

        anchors.left: input.left
        anchors.right: input.right
        anchors.top: input.bottom
        anchors.topMargin: 4

        height: input.activeFocus || input.hovered ? 2 : 1

        color: input.activeFocus || input.hovered
               ? root.lineFocusColor
               : root.lineColor
    }
}
