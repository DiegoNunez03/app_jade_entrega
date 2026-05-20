// UI / Structures / SectionSolicitudesGeneradas.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Components 1.0
import Theme 1.0
import Layout 1.0
import Structures 1.0


Rectangle {
    id: root

    color: AppTheme.colorFondo

    property string mensajeEstado: ""

    readonly property bool modoCompacto: root.width < 1030

    function cargarSolicitudes() {
        solicitudesModel.clear()

        let solicitudes = controladorConfiguracion.listarSolicitudesGeneradas()

        for (let i = 0; i < solicitudes.length; i++) {
            solicitudesModel.append({
                nombreArchivo: solicitudes[i].nombreArchivo,
                rutaArchivo: solicitudes[i].rutaArchivo,
                fechaModificacion: solicitudes[i].fechaModificacion,
                tamanioBytes: solicitudes[i].tamanioBytes
            })
        }

        if (solicitudesModel.count === 0) {
            root.mensajeEstado = "Todavía no hay solicitudes generadas."
        } else {
            root.mensajeEstado = "Solicitudes encontradas: " + solicitudesModel.count
        }
    }

    function abrirSolicitud(ruta) {
        let resultado = controladorConfiguracion.abrirSolicitudGenerada(ruta)
        console.log("[SECTION SOLICITUDES GENERADAS] abrir solicitud:", resultado)
        root.mensajeEstado = resultado
    }

    function abrirCarpetaSolicitudes() {
        let resultado = controladorConfiguracion.abrirCarpetaSolicitudesGeneradas()
        console.log("[SECTION SOLICITUDES GENERADAS] abrir carpeta:", resultado)
        root.mensajeEstado = resultado
    }

    Component.onCompleted: {
        root.cargarSolicitudes()
    }

    onVisibleChanged: {
        if (visible) {
            root.cargarSolicitudes()
        }
    }

    ListModel {
        id: solicitudesModel
    }

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerContainer

            width: parent.width
            height: AppLayout.formHeaderHeight
            color: AppTheme.colorSuperficieAlternativa
            clip: true

            HomeHeader {
                anchors.fill: parent

                modoHeader: "formulario"
                titulo: "SOLICITUDES GENERADAS"
                descripcion: "Consultá y abrí las solicitudes de alta creadas por el sistema."

                etiquetaSuperior: ""
                iconoPersonaSource: ""
                formularioSource: ""

                mostrarIndicadorPasos: false
                formularioHeaderLeftMargin: root.modoCompacto ? 80 : 160
                formularioHeaderRightMargin: root.modoCompacto ? 40 : 64
            }
        }

        Rectangle {
            id: contenido

            width: parent.width
            height: parent.height - headerContainer.height
            color: "#FFFFFF"

            Column {
                id: columnaPrincipal

                anchors.fill: parent
                anchors.margins: 32
                spacing: 18

                Row {
                    id: filaTitulo

                    width: parent.width
                    height: root.modoCompacto ? 104 : 52
                    spacing: 12

                    Text {
                        id: tituloSeccion

                        text: "Archivos internos del sistema"
                        color: AppTheme.colorTextoPrincipal
                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 24
                        font.bold: true

                        anchors.verticalCenter: root.modoCompacto ? undefined : parent.verticalCenter
                        y: root.modoCompacto ? 0 : 0
                    }

                    Item {
                        visible: !root.modoCompacto
                        width: 1
                        height: 1
                        Layout.fillWidth: true
                    }

                    Row {
                        visible: !root.modoCompacto

                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        CustonButton2 {
                            id: botonActualizar

                            tipo: "custom"
                            textoCustom: "Actualizar"
                            iconoCustom: ""
                            variante: "secondary"

                            width: 150
                            height: 42

                            onClicked: {
                                root.cargarSolicitudes()
                            }
                        }

                        CustonButton2 {
                            id: botonAbrirCarpeta

                            tipo: "custom"
                            textoCustom: "Abrir carpeta"
                            iconoCustom: ""
                            variante: "primary"

                            width: 170
                            height: 42

                            onClicked: {
                                root.abrirCarpetaSolicitudes()
                            }
                        }
                    }

                    Row {
                        visible: root.modoCompacto

                        y: 58
                        spacing: 12

                        CustonButton2 {
                            tipo: "custom"
                            textoCustom: "Actualizar"
                            iconoCustom: ""
                            variante: "secondary"

                            width: 150
                            height: 42

                            onClicked: {
                                root.cargarSolicitudes()
                            }
                        }

                        CustonButton2 {
                            tipo: "custom"
                            textoCustom: "Abrir carpeta"
                            iconoCustom: ""
                            variante: "primary"

                            width: 170
                            height: 42

                            onClicked: {
                                root.abrirCarpetaSolicitudes()
                            }
                        }
                    }
                }

                Rectangle {
                    id: tabla

                    width: parent.width
                    height: Math.max(
                        220,
                        columnaPrincipal.height
                        - filaTitulo.height
                        - (columnaPrincipal.spacing * 1)
                    )

                    radius: 14
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1
                    clip: true

                    Rectangle {
                        id: encabezadoTabla

                        width: parent.width
                        height: 46
                        color: "#F3F4F6"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18
                            spacing: 12

                            Text {
                                width: root.modoCompacto ? parent.width * 0.50 : parent.width * 0.48
                                text: "Archivo"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                width: root.modoCompacto ? parent.width * 0.25 : parent.width * 0.22
                                text: "Fecha"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                visible: !root.modoCompacto
                                width: parent.width * 0.12
                                text: "Tamaño"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                width: root.modoCompacto ? parent.width * 0.18 : parent.width * 0.12
                                text: "Acción"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Text {
                        visible: solicitudesModel.count === 0
                        anchors.centerIn: parent

                        text: "No hay solicitudes generadas para mostrar."
                        color: AppTheme.colorTextoSecundario

                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 15
                    }

                    ListView {
                        id: listaSolicitudes

                        anchors.top: encabezadoTabla.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        clip: true
                        model: solicitudesModel
                        visible: solicitudesModel.count > 0

                        ScrollBar.vertical: ScrollBar {}

                        delegate: Rectangle {
                            width: listaSolicitudes.width
                            height: 58
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9FAFB"

                            border.color: "#EEF2F7"
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 12

                                Text {
                                    width: root.modoCompacto ? parent.width * 0.50 : parent.width * 0.48

                                    text: model.nombreArchivo
                                    elide: Text.ElideRight

                                    color: AppTheme.colorTextoPrincipal
                                    font.family: AppTheme.fuenteCuerpo
                                    font.pixelSize: 13

                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: root.modoCompacto ? parent.width * 0.25 : parent.width * 0.22

                                    text: model.fechaModificacion
                                    elide: Text.ElideRight

                                    color: AppTheme.colorTextoSecundario
                                    font.family: AppTheme.fuenteCuerpo
                                    font.pixelSize: 13

                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    visible: !root.modoCompacto
                                    width: parent.width * 0.12

                                    text: Math.max(1, Math.round(model.tamanioBytes / 1024)) + " KB"

                                    color: AppTheme.colorTextoSecundario
                                    font.family: AppTheme.fuenteCuerpo
                                    font.pixelSize: 13

                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Button {
                                    width: root.modoCompacto ? 72 : 90
                                    height: 32

                                    text: "Abrir"

                                    anchors.verticalCenter: parent.verticalCenter

                                    onClicked: {
                                        root.abrirSolicitud(model.rutaArchivo)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}