// UI / Components / ValidationMessageBox.qml

import QtQuick
import QtQuick.Controls

import Theme 1.0


Rectangle {
    id: root

    property string titulo: "Corregí los siguientes errores:"
    property var errores: []
    property bool mostrar: root.errores && root.errores.length > 0

    property color colorLinea: "#DC2626"
    property color colorIconoFondo: "#FEE2E2"
    property color colorIconoTexto: "#B91C1C"
    property color colorTitulo: AppTheme.colorTextoPrincipal
    property color colorTexto: AppTheme.colorTextoPrincipal
    property color colorTextoSecundario: AppTheme.colorTextoSecundario

    property int margenHorizontal: 18
    property int margenVertical: 16
    property int espacioInterno: 12

    visible: root.mostrar

    width: parent ? parent.width : 600
    height: root.mostrar
            ? Math.max(0, contenido.implicitHeight + (root.margenVertical * 2))
            : 0

    color: "transparent"
    clip: true

    function textoError(error) {
        if (typeof error === "string") {
            return error
        }

        if (!error) {
            return ""
        }

        var campo = ""
        var mensaje = ""

        if (error.campo !== undefined && error.campo !== null) {
            campo = String(error.campo).trim()
        }

        if (error.mensaje !== undefined && error.mensaje !== null) {
            mensaje = String(error.mensaje).trim()
        }

        if (campo !== "" && mensaje !== "") {
            return campo + ": " + mensaje
        }

        if (mensaje !== "") {
            return mensaje
        }

        if (campo !== "") {
            return campo
        }

        return String(error)
    }

    Rectangle {
        id: lineaSuperior

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 2
        color: root.colorLinea
    }

    Row {
        id: contenido

        anchors.top: lineaSuperior.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: root.margenHorizontal
        anchors.rightMargin: root.margenHorizontal
        anchors.topMargin: root.margenVertical
        anchors.bottomMargin: root.margenVertical

        spacing: root.espacioInterno

        Rectangle {
            id: iconoContainer

            width: 40
            height: 40
            radius: 20

            color: root.colorIconoFondo

            Text {
                anchors.centerIn: parent

                text: "!"
                color: root.colorIconoTexto

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 22
                font.bold: true
            }
        }

        Column {
            id: columnaTexto

            width: Math.max(
                0,
                contenido.width
                - iconoContainer.width
                - contenido.spacing
            )

            spacing: 8

            Text {
                width: parent.width

                text: root.titulo
                color: root.colorTitulo

                wrapMode: Text.WordWrap

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 15
                font.bold: true
            }

            Repeater {
                model: root.errores || []

                delegate: Text {
                    width: columnaTexto.width

                    text: "• " + root.textoError(modelData)
                    color: root.colorTextoSecundario

                    wrapMode: Text.WordWrap

                    font.family: AppTheme.fuenteCuerpo
                    font.pixelSize: 13
                    lineHeight: 1.15
                }
            }
        }
    }

    Rectangle {
        id: lineaInferior

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1
        color: "#FCA5A5"
    }
}