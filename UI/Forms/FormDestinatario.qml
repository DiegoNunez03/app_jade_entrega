// UI/Forms/FormDestinatario.qml

import QtQuick
import QtQuick.Controls

import Components 1.0
import Theme 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 600
    height: 200
    color: "transparent"
    clip: true

    signal datosCapturados(var datos)

    property var datosDestinatario: ({})
    property bool edadAutomatica: false

    // =====================================================
    // VALIDACIÓN VISUAL
    // =====================================================

    property var erroresCampos: ({})

    function limpiarErroresValidacion() {
        root.erroresCampos = ({})
    }

    function aplicarErroresValidacion(errores) {
        var mapaErrores = {}

        if (errores) {
            for (var i = 0; i < errores.length; i++) {
                mapaErrores[errores[i].campo] = true
            }
        }

        root.erroresCampos = mapaErrores
    }

    function campoTieneError(campoId) {
        return root.erroresCampos[campoId] === true
    }

    // =====================================================
    // POSICIONAMIENTO INTERNO DEL FORMULARIO
    // =====================================================

    property real camposX: 10
    property real camposY: 10

    // =====================================================
    // MEDIDAS RESPONSIVE
    // =====================================================

    readonly property bool modoCompacto: root.width < 720
    readonly property bool modoAmplio: root.width >= 860

    property real formularioAncho: Math.min(
        root.modoAmplio ? 900 : 840,
        Math.max(0, root.width - (root.camposX * 2))
    )

    property real espacioCampos: root.modoCompacto ? 16 : 24

    property real altoCampo: root.modoCompacto ? 72 : 78
    property real altoBloqueEscolarizado: root.altoCampo
    property real altoBloqueDireccion: root.modoCompacto ? 112 : 122

    readonly property real anchoMitad: (root.formularioAncho - root.espacioCampos) / 2

    readonly property real espacioVerticalFormulario: root.modoCompacto
        ? 12
        : root.modoAmplio
            ? 22
            : 18

    readonly property real contenidoAltoFormulario: columFields.implicitHeight + root.camposY

    // Dirección reconstruida internamente desde la interfaz
    readonly property string direccionCompleta: (
        inputCalle.text.trim() + " " + inputNumero.text.trim()
    ).trim()

    function limpiarCampos() {
        inputNombre.text = ""
        inputApellido.text = ""
        inputDNI.text = ""
        inputCalle.text = ""
        inputNumero.text = ""
        inputFechaNacimiento.text = ""

        if (!root.edadAutomatica) {
            inputEdad.text = ""
        }

        escolarizadoSi.checked = false
        escolarizadoNo.checked = false

        datosDestinatario = ({})
        root.limpiarErroresValidacion()
    }

    function capturarDatos() {
        datosDestinatario = {
            nombre: inputNombre.text,
            apellido: inputApellido.text,
            dni: inputDNI.text,

            calle: inputCalle.text,
            numero: inputNumero.text,

            direccion: root.direccionCompleta,

            escolarizado: escolarizadoSi.checked
                ? "Sí"
                : escolarizadoNo.checked
                    ? "No"
                    : "Sin seleccionar",

            edad: root.edadAutomatica ? "" : inputEdad.text,
            fechaNacimiento: inputFechaNacimiento.text
        }

        Logger.linea()
        Logger.bloque("FORM DESTINATARIO", "datos capturados", datosDestinatario)
        root.datosCapturados(datosDestinatario)
    }

    Flickable {
        id: scrollFormDestinatario

        anchors.fill: parent
        clip: true

        contentWidth: width
        contentHeight: columFields.implicitHeight + root.camposY + 24

        Column {
            id: columFields

            x: Math.round((root.width - root.formularioAncho) / 2)
            y: root.camposY

            width: root.formularioAncho
            spacing: root.espacioVerticalFormulario

            // =====================================================
            // FILA 1: NOMBRE + APELLIDO
            // =====================================================

            Row {
                id: filaNombreApellido

                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldNombre

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "nombre"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputNombre

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldNombre.labelConObligatorio("Nombre")
                        placeholder: "Mario"
                        width: parent.width
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
                    }
                }

                FieldBox {
                    id: fieldApellido

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "apellido"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputApellido

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldApellido.labelConObligatorio("Apellido")
                        placeholder: "Alarcon"
                        width: parent.width
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
                    }
                }
            }

            // =====================================================
            // FILA 2: DNI + ESCOLARIZADO
            // =====================================================

            Row {
                id: filaDniEscolarizado

                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldDni

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "dni"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputDNI

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldDni.labelConObligatorio("DNI")
                        placeholder: "12233344"
                        width: parent.width
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Números\n- Sin puntos\n- Sin espacios"
                    }
                }

                Rectangle {
                    id: bloqueEscolarizado

                    property bool campoObligatorio: true
                    property bool tieneError: root.campoTieneError("escolarizado")
                    readonly property string tituloCampo: campoObligatorio ? "Escolarizado *" : "Escolarizado"

                    width: root.anchoMitad
                    height: root.altoBloqueEscolarizado

                    radius: 10
                    color: "#FFFFFF"
                    border.color: bloqueEscolarizado.tieneError ? "#DC2626" : "#E5E7EB"
                    border.width: bloqueEscolarizado.tieneError ? 2 : 1

                    Column {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 42
                        anchors.topMargin: root.modoCompacto ? 8 : 10
                        anchors.bottomMargin: 8

                        spacing: root.modoCompacto ? 6 : 8

                        Text {
                            text: bloqueEscolarizado.tituloCampo

                            color: bloqueEscolarizado.tieneError
                                   ? "#DC2626"
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Row {
                            spacing: 22

                            ButtonGroup {
                                id: grupoEscolarizado
                            }

                            RadioButton {
                                id: escolarizadoSi

                                text: "Sí"
                                ButtonGroup.group: grupoEscolarizado
                            }

                            RadioButton {
                                id: escolarizadoNo

                                text: "No"
                                ButtonGroup.group: grupoEscolarizado
                            }
                        }
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 10
                        anchors.rightMargin: 12

                        mensaje: "- Selección obligatoria\n- Una sola opción"
                    }
                }
            }

            // =====================================================
            // BLOQUE DIRECCIÓN
            // =====================================================

            Rectangle {
                id: bloqueDireccion

                readonly property bool tieneErrorDireccion: root.campoTieneError("calle")
                                                          || root.campoTieneError("numero")

                width: parent.width
                height: root.altoBloqueDireccion

                radius: 12
                color: "#FFFFFF"
                border.color: bloqueDireccion.tieneErrorDireccion ? "#DC2626" : "#E8E0FF"
                border.width: bloqueDireccion.tieneErrorDireccion ? 2 : 1

                Row {
                    anchors.fill: parent
                    anchors.margins: root.modoCompacto ? 10 : 14

                    spacing: root.modoCompacto ? 12 : 16

                    Rectangle {
                        id: iconoDireccion

                        width: root.modoCompacto ? 42 : 48
                        height: parent.height
                        radius: 10

                        color: "#F4EFFF"

                        Text {
                            anchors.centerIn: parent

                            text: "⌖"

                            color: AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: root.modoCompacto ? 21 : 24
                            font.bold: true
                        }
                    }

                    Column {
                        width: parent.width - iconoDireccion.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: root.modoCompacto ? 8 : 10

                        Text {
                            text: "Dirección"

                            color: bloqueDireccion.tieneErrorDireccion
                                   ? "#DC2626"
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 15
                            font.bold: true
                        }

                        Row {
                            id: filaDireccion

                            width: parent.width
                            spacing: root.espacioCampos

                            FieldBox {
                                id: fieldCalle

                                width: (filaDireccion.width - root.espacioCampos) * 0.66
                                height: root.altoCampo

                                campoId: "calle"
                                campoObligatorio: true
                                tieneError: root.campoTieneError(campoId)

                                InputText {
                                    id: inputCalle

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldCalle.labelConObligatorio("Calle")
                                    placeholder: "Miguel Cane"
                                    width: parent.width
                                }

                                FieldHelpIcon {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: 2
                                    anchors.rightMargin: 2

                                    mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios"
                                }
                            }

                            FieldBox {
                                id: fieldNumero

                                width: (filaDireccion.width - root.espacioCampos) * 0.34
                                height: root.altoCampo

                                campoId: "numero"
                                campoObligatorio: true
                                tieneError: root.campoTieneError(campoId)

                                InputText {
                                    id: inputNumero

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldNumero.labelConObligatorio("Número")
                                    placeholder: "xxx"
                                    width: parent.width
                                }

                                FieldHelpIcon {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: 2
                                    anchors.rightMargin: 2

                                    mensaje: "- Números\n- Letras\n- Barra\n- Guion"
                                }
                            }
                        }
                    }
                }
            }

            // =====================================================
            // FILA 3: EDAD + FECHA NACIMIENTO
            // =====================================================

            Row {
                id: filaEdadFecha

                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldEdad

                    visible: !root.edadAutomatica

                    width: root.edadAutomatica
                           ? 0
                           : root.anchoMitad

                    height: root.altoCampo

                    campoId: "edad"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputEdad

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldEdad.labelConObligatorio("Edad")
                        placeholder: "12"
                        width: parent.width
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Números\n- Edad válida\n- Sin espacios"
                    }
                }

                FieldBox {
                    id: fieldFechaNacimiento

                    width: root.edadAutomatica
                           ? parent.width
                           : root.anchoMitad

                    height: root.altoCampo

                    campoId: "fechaNacimiento"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputFechaNacimiento

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldFechaNacimiento.labelConObligatorio("Fecha nacimiento")
                        placeholder: "dd/mm/aaaa"
                        width: parent.width
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Formato dd/mm/aaaa\n- Números\n- Barras separadoras"
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

    // =====================================================
    // COMPONENTE INTERNO: CONTENEDOR BLANCO DE CAMPO
    // =====================================================

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


