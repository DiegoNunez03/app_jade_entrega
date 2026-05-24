// UI / Forms / FormResponsable.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import Components 1.0
import Forms 1.0
import Theme 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 800
    height: 300
    color: "transparent"
    clip: true

    signal datosCapturados(var datos)
    signal volverSolicitado()

    property var datosResponsable: ({})
    property bool edadAutomatica: false

    property string domicilioDestinatario: ""
    property bool usarDomicilioDestinatario: false

    property string calleDestinatario: ""
    property string numeroDestinatario: ""

    property string calleManualAnterior: ""
    property string numeroManualAnterior: ""

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
    property real altoBloqueDomicilio: root.modoCompacto ? 122 : 132
    property real altoBloqueTelefono: root.modoCompacto ? 112 : 118
    property real altoBloqueMismoDomicilio: 54

    readonly property real anchoMitad: (root.formularioAncho - root.espacioCampos) / 2

    readonly property real espacioVerticalFormulario: root.modoCompacto
        ? 12
        : root.modoAmplio
            ? 22
            : 18

    readonly property real contenidoAltoFormulario: columFields.implicitHeight + root.camposY

    // =====================================================
    // VALORES RECONSTRUIDOS INTERNAMENTE
    // =====================================================

    readonly property string domicilioManualCompleto: (
        inputCalle.text.trim() + " " + inputNumero.text.trim()
    ).trim()

    readonly property string domicilioFinal: root.usarDomicilioDestinatario
                                             ? root.domicilioDestinatario
                                             : root.domicilioManualCompleto

    readonly property string telefonoCompleto: (
        inputCodigoArea.text.trim() + " " + inputNumeroTelefono.text.trim()
    ).trim()

    function limpiarCampos() {
        inputNombre.text = ""
        inputApellido.text = ""
        inputDNI.text = ""
        inputCalle.text = ""
        inputNumero.text = ""
        inputCodigoArea.text = ""
        inputNumeroTelefono.text = ""
        inputFechaNacimiento.text = ""

        if (!root.edadAutomatica) {
            inputEdad.text = ""
        }

        comboParentesco.currentIndex = 0

        checkMismoDomicilio.checked = false
        root.usarDomicilioDestinatario = false
        root.calleManualAnterior = ""
        root.numeroManualAnterior = ""

        datosResponsable = ({})
        root.limpiarErroresValidacion()
    }

    function capturarDatos() {
        root.datosResponsable = {
            responsableNombre: inputNombre.text,
            responsableApellido: inputApellido.text,

            // Datos planos actuales.
            // Se mantienen para no romper controlador_altas.py,
            // previsualización ni generación Excel.
            responsableTelefono: root.telefonoCompleto,
            responsableDomicilio: root.domicilioFinal,

            // Datos estructurados nuevos.
            // Estos son los que después puede consumir el backend/schema.
            responsableDireccionSchema: {
                calle: inputCalle.text,
                numero: inputNumero.text
            },

            responsableTelefonoSchema: {
                codigo_area: inputCodigoArea.text,
                numero: inputNumeroTelefono.text
            },

            responsableDni: inputDNI.text,
            responsableParentesco: comboParentesco.currentText,
            responsableFechaNacimiento: inputFechaNacimiento.text,
            responsableEdad: root.edadAutomatica ? "" : inputEdad.text
        }

        Logger.bloque("FORM RESPONSABLE", "datos capturados", root.datosResponsable)
        root.datosCapturados(root.datosResponsable)
    }

    Flickable {
        id: scrollFormResponsable

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

                    campoId: "responsableNombre"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputNombre

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldNombre.labelConObligatorio("Nombre")
                        placeholder: "Juan"
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

                    campoId: "responsableApellido"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputApellido

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldApellido.labelConObligatorio("Apellido")
                        placeholder: "Perez"
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
            // FILA 2: DNI + PARENTESCO
            // =====================================================

            Row {
                id: filaDniParentesco

                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldDni

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "responsableDni"
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

                FieldBox {
                    id: fieldParentesco

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "responsableParentesco"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    Column {
                        anchors.fill: parent
                        anchors.rightMargin: 28

                        spacing: 5

                        Text {
                            text: fieldParentesco.labelConObligatorio("Parentesco")

                            color: fieldParentesco.tieneError
                                   ? "#DC2626"
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 16
                            font.bold: true
                        }

                        ComboBox {
                            id: comboParentesco

                            width: parent.width
                            height: 36

                            model: [
                                "Madre",
                                "Padre",
                                "Tutor Legal",
                                "Abuela",
                                "Abuelo",
                                "Tía",
                                "Tío",
                                "Hermana",
                                "Hermano",
                                "Otro"
                            ]
                        }
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Selección obligatoria\n- Una sola opción"
                    }
                }
            }

            // =====================================================
            // BLOQUE DOMICILIO
            // =====================================================

            Rectangle {
                id: bloqueDomicilio

                readonly property bool tieneErrorDomicilio: root.campoTieneError("responsableDomicilio")

                width: parent.width
                height: root.altoBloqueDomicilio

                radius: 12
                color: "#FFFFFF"
                border.color: bloqueDomicilio.tieneErrorDomicilio ? "#DC2626" : "#E8E0FF"
                border.width: bloqueDomicilio.tieneErrorDomicilio ? 2 : 1

                Row {
                    anchors.fill: parent
                    anchors.margins: root.modoCompacto ? 10 : 14

                    spacing: root.modoCompacto ? 12 : 16

                    Rectangle {
                        id: iconoDomicilio

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
                        width: parent.width - iconoDomicilio.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: root.modoCompacto ? 8 : 10

                        Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "Domicilio"

                                color: bloqueDomicilio.tieneErrorDomicilio
                                       ? "#DC2626"
                                       : AppTheme.colorPrimario

                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 15
                                font.bold: true
                            }

                            FieldHelpIcon {
                                anchors.verticalCenter: parent.verticalCenter

                                mensaje: "- Completar calle y número\n- Usar mismo domicilio si corresponde"
                            }
                        }

                        Row {
                            id: filaDomicilio

                            width: parent.width
                            spacing: root.espacioCampos

                            FieldBox {
                                id: fieldCalle

                                width: (filaDomicilio.width - root.espacioCampos) * 0.66
                                height: root.altoCampo

                                campoId: "responsableDomicilio"
                                campoObligatorio: !root.usarDomicilioDestinatario
                                tieneError: root.campoTieneError("responsableDomicilio")

                                enabled: !root.usarDomicilioDestinatario
                                opacity: root.usarDomicilioDestinatario ? 0.55 : 1.0

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

                                width: (filaDomicilio.width - root.espacioCampos) * 0.34
                                height: root.altoCampo

                                campoId: "responsableDomicilio"
                                campoObligatorio: !root.usarDomicilioDestinatario
                                tieneError: root.campoTieneError("responsableDomicilio")

                                enabled: !root.usarDomicilioDestinatario
                                opacity: root.usarDomicilioDestinatario ? 0.55 : 1.0

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
            // MISMO DOMICILIO QUE DESTINATARIO
            // =====================================================

            Rectangle {
                id: bloqueMismoDomicilio

                property bool tieneError: root.campoTieneError("responsableDomicilio")

                width: parent.width
                height: root.altoBloqueMismoDomicilio

                radius: 10
                color: "#FFFFFF"
                border.color: bloqueMismoDomicilio.tieneError ? "#DC2626" : "#E5E7EB"
                border.width: bloqueMismoDomicilio.tieneError ? 2 : 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    spacing: 12

                    CheckBox {
                        id: checkMismoDomicilio
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Mismo domicilio que destinatario"
                        checked: false

                        onCheckedChanged: {
                            root.usarDomicilioDestinatario = checked

                            if (checked) {
                                root.calleManualAnterior = inputCalle.text
                                root.numeroManualAnterior = inputNumero.text

                                inputCalle.text = root.calleDestinatario
                                inputNumero.text = root.numeroDestinatario

                                Logger.simple(
                                    "FORM RESPONSABLE",
                                    "usa domicilio destinatario",
                                    root.domicilioDestinatario
                                )
                            } else {
                                inputCalle.text = root.calleManualAnterior
                                inputNumero.text = root.numeroManualAnterior
                            }
                        }
                    }

                    FieldHelpIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        mensaje: "- Usar domicilio cargado en destinatario\n- Desactiva calle y número"
                    }
                }
            }

            // =====================================================
            // BLOQUE TELÉFONO
            // =====================================================

            Rectangle {
                id: bloqueTelefono

                readonly property bool tieneErrorTelefono: root.campoTieneError("responsableTelefono")
                                                        || root.campoTieneError("responsableCodigoArea")
                                                        || root.campoTieneError("responsableNumeroTelefono")

                width: parent.width
                height: root.altoBloqueTelefono

                radius: 12
                color: "#FFFFFF"
                border.color: bloqueTelefono.tieneErrorTelefono ? "#DC2626" : "#D5F4F7"
                border.width: bloqueTelefono.tieneErrorTelefono ? 2 : 1

                Row {
                    anchors.fill: parent
                    anchors.margins: root.modoCompacto ? 10 : 14

                    spacing: root.modoCompacto ? 12 : 16

                    Rectangle {
                        id: iconoTelefono

                        width: root.modoCompacto ? 42 : 48
                        height: parent.height
                        radius: 10

                        color: "#E7FAFC"

                        Text {
                            anchors.centerIn: parent

                            text: "☎"

                            color: "#0E9AA5"

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: root.modoCompacto ? 21 : 24
                            font.bold: true
                        }
                    }

                    Column {
                        width: parent.width - iconoTelefono.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: root.modoCompacto ? 8 : 10

                        Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "Teléfono de contacto"

                                color: bloqueTelefono.tieneErrorTelefono
                                       ? "#DC2626"
                                       : "#0E9AA5"

                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 15
                                font.bold: true
                            }

                            FieldHelpIcon {
                                anchors.verticalCenter: parent.verticalCenter

                                mensaje: "- Completar número de área\n- Completar número de teléfono"
                            }
                        }

                        Row {
                            id: filaTelefono

                            width: parent.width
                            spacing: root.espacioCampos

                            FieldBox {
                                id: fieldCodigoArea

                                width: (filaTelefono.width - root.espacioCampos) * 0.36
                                height: root.altoCampo

                                campoId: "responsableCodigoArea"
                                campoObligatorio: true
                                tieneError: root.campoTieneError("responsableTelefono")
                                            || root.campoTieneError("responsableCodigoArea")

                                InputText {
                                    id: inputCodigoArea

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldCodigoArea.labelConObligatorio("N° de área")
                                    placeholder: "2932"
                                    width: parent.width
                                }

                                FieldHelpIcon {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: 2
                                    anchors.rightMargin: 2

                                    mensaje: "- Números\n- Sin espacios"
                                }
                            }

                            FieldBox {
                                id: fieldNumeroTelefono

                                width: (filaTelefono.width - root.espacioCampos) * 0.64
                                height: root.altoCampo

                                campoId: "responsableNumeroTelefono"
                                campoObligatorio: true
                                tieneError: root.campoTieneError("responsableTelefono")
                                            || root.campoTieneError("responsableNumeroTelefono")

                                InputText {
                                    id: inputNumeroTelefono

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldNumeroTelefono.labelConObligatorio("N° de teléfono")
                                    placeholder: "1234567"
                                    width: parent.width
                                }

                                FieldHelpIcon {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: 2
                                    anchors.rightMargin: 2

                                    mensaje: "- Números\n- Sin espacios"
                                }
                            }
                        }
                    }
                }
            }

            // =====================================================
            // FILA FINAL: EDAD + FECHA NACIMIENTO
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

                    campoId: "responsableEdad"
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

                    campoId: "responsableFechaNacimiento"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputFechaNacimiento

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldFechaNacimiento.labelConObligatorio("Fecha nacimiento")
                        placeholder: "01/01/2001"
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