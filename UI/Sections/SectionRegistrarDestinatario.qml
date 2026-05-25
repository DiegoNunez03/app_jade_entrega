// UI / Sections / SectionRegistrarDestinatario.qml

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
    property int maxCoincidenciasVisibles: 5

    property var erroresValidacion: []
    property var erroresCampos: ({})

    function limpiarErroresValidacion() {
        root.erroresValidacion = []
        root.erroresCampos = ({})
    }

    function aplicarErroresValidacion(errores) {
        var mapaErrores = {}

        if (errores) {
            for (var i = 0; i < errores.length; i++) {
                if (errores[i].campo !== undefined && errores[i].campo !== null) {
                    mapaErrores[errores[i].campo] = true
                }
            }
        }

        root.erroresCampos = mapaErrores
    }

    function campoTieneError(campoId) {
        return root.erroresCampos[campoId] === true
    }

    function mensajeDesdeResultado(resultado) {
        var texto = String(resultado || "").trim()

        if (texto.indexOf("ERROR|") === 0) {
            return texto.substring(6).trim()
        }

        if (texto.indexOf("OK|") === 0) {
            return texto.substring(3).trim()
        }

        return texto
    }

    function inferirCampoError(mensaje) {
        var texto = String(mensaje || "").toLowerCase()

        if (texto.indexOf("nombre") >= 0 && texto.indexOf("apellido") < 0) {
            return "nombre"
        }

        if (texto.indexOf("apellido") >= 0 && texto.indexOf("nombre") < 0) {
            return "apellido"
        }

        if (texto.indexOf("turno") >= 0) {
            return "turno"
        }

        return ""
    }

    function erroresDesdeResultado(resultado) {
        var mensaje = root.mensajeDesdeResultado(resultado)

        if (mensaje === "") {
            return []
        }

        var campo = root.inferirCampoError(mensaje)

        if (campo !== "") {
            return [{
                campo: campo,
                mensaje: mensaje
            }]
        }

        return [mensaje]
    }

    function limpiarFormulario() {
        inputNombre.text = ""
        inputApellido.text = ""
        turnoManiana.checked = true
        turnoTarde.checked = false
        root.turnoManianaActivo = true
        coincidenciasModel.clear()
        root.limpiarErroresValidacion()
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

    function actualizarCoincidencias() {
        coincidenciasModel.clear()

        var nombre = inputNombre.text.trim()
        var apellido = inputApellido.text.trim()

        if (nombre === "" && apellido === "") {
            return
        }

        var busqueda = (apellido + " " + nombre).trim()
        var coincidencias = controladorDestinatarios.buscarDestinatarios(busqueda, "todos")

        for (var i = 0; i < coincidencias.length && i < root.maxCoincidenciasVisibles; i++) {
            coincidenciasModel.append({
                idDestinatario: coincidencias[i].id,
                nombre: coincidencias[i].nombre,
                apellido: coincidencias[i].apellido,
                turno: coincidencias[i].turno
            })
        }
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

        if (resultado.startsWith("ERROR|")) {
            var errores = root.erroresDesdeResultado(resultado)

            root.erroresValidacion = errores
            root.aplicarErroresValidacion(errores)

            return
        }

        root.limpiarErroresValidacion()

        if (resultado.startsWith("OK|")) {
            root.limpiarFormulario()
        }
    }

    ButtonGroup {
        id: grupoTurno
    }

    ListModel {
        id: coincidenciasModel
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

                ValidationMessageBox {
                    id: validationBox

                    width: parent.width
                    errores: root.erroresValidacion
                    titulo: "Corregí los datos del destinatario:"
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
                            campoId: "nombre"
                            campoObligatorio: true
                            tieneError: root.campoTieneError(campoId)

                            InputText {
                                id: inputNombre
                                anchors.fill: parent
                                anchors.rightMargin: 28
                                label: fieldNombre.labelConObligatorio("Nombre")
                                placeholder: "Ingresá el nombre"
                                width: parent.width

                                onTextChanged: {
                                    root.limpiarErroresValidacion()
                                    root.actualizarCoincidencias()
                                }
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
                            campoId: "apellido"
                            campoObligatorio: true
                            tieneError: root.campoTieneError(campoId)

                            InputText {
                                id: inputApellido
                                anchors.fill: parent
                                anchors.rightMargin: 28
                                label: fieldApellido.labelConObligatorio("Apellido")
                                placeholder: "Ingresá el apellido"
                                width: parent.width

                                onTextChanged: {
                                    root.limpiarErroresValidacion()
                                    root.actualizarCoincidencias()
                                }
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
                            id: fieldTurno

                            width: parent.width
                            height: 72
                            radius: 10
                            color: "#FFFFFF"
                            border.color: root.campoTieneError("turno") ? "#DC2626" : "#E5E7EB"
                            border.width: root.campoTieneError("turno") ? 2 : 1

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
                                        root.limpiarErroresValidacion()
                                    }
                                }

                                RadioButton {
                                    id: turnoTarde
                                    text: "Tarde"
                                    ButtonGroup.group: grupoTurno
                                    anchors.verticalCenter: parent.verticalCenter

                                    onClicked: {
                                        root.turnoManianaActivo = false
                                        root.limpiarErroresValidacion()
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: coincidenciasContainer

                    width: parent.width
                    height: coincidenciasModel.count > 0 ? 132 : 0
                    radius: 12
                    color: "#FFFBEB"
                    border.color: "#FBBF24"
                    border.width: coincidenciasModel.count > 0 ? 1 : 0
                    visible: coincidenciasModel.count > 0
                    clip: true

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8

                        Text {
                            text: "Posibles destinatarios ya registrados"
                            color: "#92400E"
                            font.family: AppTheme.fuenteCuerpo
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            text: "Revisá esta lista antes de registrar para evitar duplicados."
                            color: "#92400E"
                            font.family: AppTheme.fuenteCuerpo
                            font.pixelSize: 11
                        }

                        ListView {
                            width: parent.width
                            height: 62
                            clip: true
                            model: coincidenciasModel

                            delegate: Text {
                                width: ListView.view.width
                                height: 22
                                text: "• " + model.apellido + ", " + model.nombre + " - turno " + model.turno
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteCuerpo
                                font.pixelSize: 12
                                elide: Text.ElideRight
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
                            root.limpiarErroresValidacion()
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
                        text: root.mensajeDesdeResultado(root.mensajeEstado)
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

        property string campoId: ""
        property bool campoObligatorio: true
        property bool tieneError: false

        function labelConObligatorio(texto) {
            return fieldBox.campoObligatorio ? texto + " *" : texto
        }

        radius: 10
        color: "#FFFFFF"
        border.color: fieldBox.tieneError ? "#DC2626" : "#E5E7EB"
        border.width: fieldBox.tieneError ? 2 : 1

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