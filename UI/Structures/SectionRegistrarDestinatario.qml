// UI / Structures / SectionRegistrarDestinatario.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Components 1.0
import Theme 1.0
import Layout 1.0
import Structures 1.0

Rectangle {
    id: root

    color: "#FFFFFF"

    property string mensajeEstado: ""
    property bool turnoManianaActivo: true

    function limpiarFormulario() {
        inputNombre.text = ""
        inputApellido.text = ""
        turnoManiana.checked = true
        turnoTarde.checked = false
        root.turnoManianaActivo = true
    }

    function obtenerTurnoSeleccionado() {
        if (turnoManiana.checked) {
            return "mañana"
        }

        if (turnoTarde.checked) {
            return "tarde"
        }

        return ""
    }

    function registrarDestinatario() {
        var datos = {
            nombre: inputNombre.text,
            apellido: inputApellido.text,
            turno: root.obtenerTurnoSeleccionado()
        }

        var resultado = controladorDestinatarios.registrarDestinatario(datos)

        root.mensajeEstado = resultado

        console.log("[SECTION REGISTRAR DESTINATARIO] resultado:", resultado)

        if (resultado.startsWith("OK|")) {
            root.limpiarFormulario()
        }
    }

    ButtonGroup {
        id: grupoTurno
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
                titulo: "REGISTRAR DESTINATARIO"
                descripcion: "Cargá los datos mínimos del destinatario para incluirlo en las listas de asistencia."
                iconoPersonaSource: ""
                // formularioSource: "qrc:/qml/UI/Assets/form.png"
                mostrarIndicadorPasos: false
            }
        }

        Rectangle {
            id: contenido

            width: parent.width
            height: parent.height - headerContainer.height
            color: "#FFFFFF"

            Column {
                id: columnaPrincipal

                width: Math.min(parent.width - 80, 760)
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 36
                spacing: 18

                Text {
                    text: "Datos del destinatario"
                    color: AppTheme.colorTextoPrincipal
                    font.family: AppTheme.fuenteTitulo
                    font.pixelSize: 24
                    font.bold: true
                }

                Text {
                    text: "Este registro se guarda en un archivo interno del sistema y luego se usará para generar las listas de asistencia por turno."
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: AppTheme.colorTextoSecundario
                    font.family: AppTheme.fuenteCuerpo
                    font.pixelSize: 13
                }

                Rectangle {
                    id: tarjetaFormulario

                    width: parent.width
                    height: 330
                    radius: 16
                    color: "#F9FAFB"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 18

                        FieldBox {
                            id: fieldNombre
                            width: parent.width
                            height: 78
                            campoObligatorio: true

                            InputText {
                                id: inputNombre
                                anchors.fill: parent
                                anchors.rightMargin: 28
                                label: fieldNombre.labelConObligatorio("Nombre")
                                placeholder: "Ingresá el nombre"
                                width: parent.width
                            }

                            FieldHelpIcon {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 2
                                anchors.rightMargin: 2
                                mensaje: "- Letras\n- Acentos\n- Espacios\n- Guion\n- Apóstrofe"
                            }
                        }

                        FieldBox {
                            id: fieldApellido
                            width: parent.width
                            height: 78
                            campoObligatorio: true

                            InputText {
                                id: inputApellido
                                anchors.fill: parent
                                anchors.rightMargin: 28
                                label: fieldApellido.labelConObligatorio("Apellido")
                                placeholder: "Ingresá el apellido"
                                width: parent.width
                            }

                            FieldHelpIcon {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 2
                                anchors.rightMargin: 2
                                mensaje: "- Letras\n- Acentos\n- Espacios\n- Guion\n- Apóstrofe"
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 72
                            radius: 10
                            color: "#FFFFFF"
                            border.color: "#E5E7EB"
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 24

                                Text {
                                    text: "Turno *"
                                    color: AppTheme.colorTextoPrincipal
                                    font.family: AppTheme.fuenteCuerpo
                                    font.pixelSize: 13
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                RadioButton {
                                    id: turnoManiana
                                    text: "Mañana"
                                    checked: true
                                    ButtonGroup.group: grupoTurno
                                    anchors.verticalCenter: parent.verticalCenter

                                    onClicked: {
                                        root.turnoManianaActivo = true
                                    }
                                }

                                RadioButton {
                                    id: turnoTarde
                                    text: "Tarde"
                                    ButtonGroup.group: grupoTurno
                                    anchors.verticalCenter: parent.verticalCenter

                                    onClicked: {
                                        root.turnoManianaActivo = false
                                    }
                                }
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: 54
                    spacing: 12

                    Item {
                        width: 1
                        height: 1
                        Layout.fillWidth: true
                    }

                    CustonButton2 {
                        id: botonLimpiar
                        tipo: "custom"
                        textoCustom: "Limpiar"
                        iconoCustom: "↺"
                        variante: "secondary"
                        width: 150
                        height: 46

                        onClicked: {
                            root.limpiarFormulario()
                            root.mensajeEstado = ""
                        }
                    }

                    CustonButton2 {
                        id: botonRegistrar
                        tipo: "custom"
                        textoCustom: "Registrar"
                        iconoCustom: "+"
                        variante: "primary"
                        width: 170
                        height: 46

                        onClicked: {
                            root.registrarDestinatario()
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 46
                    radius: 10
                    color: root.mensajeEstado.startsWith("ERROR|") ? "#FEF2F2" : "#F9FAFB"
                    border.color: root.mensajeEstado.startsWith("ERROR|") ? "#FCA5A5" : "#E5E7EB"
                    border.width: 1
                    visible: root.mensajeEstado !== ""

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.mensajeEstado
                        elide: Text.ElideRight
                        color: root.mensajeEstado.startsWith("ERROR|") ? "#991B1B" : AppTheme.colorTextoSecundario
                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 13
                    }
                }
            }
        }
    }

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
}