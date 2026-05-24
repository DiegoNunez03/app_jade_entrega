// UI/Forms/FormBajaBeneficiario.qml

import QtQuick
import QtQuick.Controls

import Components 1.0
import Theme 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 800
    height: 300
    color: "transparent"
    clip: true

    signal datosCapturados(var datos)

    property var datosBeneficiario: ({})

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
    // POSICIONAMIENTO INTERNO
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
    property real altoBloqueTipoBeneficiario: root.modoCompacto ? 78 : 84
    property real altoBloqueMotivo: root.modoCompacto ? 84 : 90

    readonly property real anchoMitad: (root.formularioAncho - root.espacioCampos) / 2

    readonly property real espacioVerticalFormulario: root.modoCompacto
        ? 12
        : root.modoAmplio
            ? 22
            : 18

    readonly property real contenidoAltoFormulario: columFields.implicitHeight + root.camposY

    readonly property string nombreCompleto: (
        inputNombre.text.trim() + " " + inputApellido.text.trim()
    ).trim()

    // =====================================================
    // FUNCIONES
    // =====================================================

    function limpiarCampos() {
        beneficiarioDestinatario.checked = false
        beneficiarioTutor.checked = false

        inputNombre.text = ""
        inputApellido.text = ""
        comboTipoDni.currentIndex = 0
        inputDni.text = ""
        inputFechaIngreso.text = ""

        comboMotivo.currentIndex = 0

        root.datosBeneficiario = ({})
        root.limpiarErroresValidacion()
    }

    function capturarDatos() {
        root.datosBeneficiario = {
            bajaTipoBeneficiario: beneficiarioDestinatario.checked
                ? "Destinatario"
                : beneficiarioTutor.checked
                    ? "Tutor"
                    : "Sin seleccionar",

            bajaNombre: inputNombre.text,
            bajaApellido: inputApellido.text,
            bajaNombreCompleto: root.nombreCompleto,

            bajaTipoDni: comboTipoDni.currentText,
            bajaDni: inputDni.text,
            bajaFechaIngreso: inputFechaIngreso.text,

            bajaMotivo: comboMotivo.currentText
        }

        Logger.linea()
        Logger.bloque(
            "FORM BAJA BENEFICIARIO",
            "datos capturados",
            root.datosBeneficiario
        )

        root.datosCapturados(root.datosBeneficiario)
    }

    Flickable {
        id: scrollFormBeneficiario

        anchors.fill: parent
        clip: true

        contentWidth: width
        contentHeight: columFields.implicitHeight + root.camposY + 24

        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        Column {
            id: columFields

            x: Math.round((root.width - root.formularioAncho) / 2)
            y: root.camposY

            width: root.formularioAncho
            spacing: root.espacioVerticalFormulario

            // =====================================================
            // TIPO DE BENEFICIARIO
            // =====================================================

            Rectangle {
                id: bloqueTipoBeneficiario

                property bool tieneError: root.campoTieneError("bajaTipoBeneficiario")
                readonly property string tituloCampo: "Tipo de beneficiario *"

                width: parent.width
                height: root.altoBloqueTipoBeneficiario

                radius: 10
                color: "#FFFFFF"
                border.color: bloqueTipoBeneficiario.tieneError ? "#DC2626" : "#E5E7EB"
                border.width: bloqueTipoBeneficiario.tieneError ? 2 : 1

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 42
                    anchors.topMargin: root.modoCompacto ? 8 : 10
                    anchors.bottomMargin: 8

                    spacing: root.modoCompacto ? 6 : 8

                    Text {
                        text: bloqueTipoBeneficiario.tituloCampo

                        color: bloqueTipoBeneficiario.tieneError
                               ? "#DC2626"
                               : AppTheme.colorPrimario

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Row {
                        spacing: 28

                        ButtonGroup {
                            id: grupoTipoBeneficiario
                        }

                        RadioButton {
                            id: beneficiarioDestinatario

                            text: "Destinatario"
                            ButtonGroup.group: grupoTipoBeneficiario
                        }

                        RadioButton {
                            id: beneficiarioTutor

                            text: "Tutor"
                            ButtonGroup.group: grupoTipoBeneficiario
                        }
                    }
                }

                FieldHelpIcon {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.rightMargin: 12

                    mensaje: "- Selección obligatoria\n- Una sola opción\n- El sistema tachará la opción que no corresponda"
                }
            }

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

                    campoId: "bajaNombre"
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

                    campoId: "bajaApellido"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputApellido

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldApellido.labelConObligatorio("Apellido")
                        placeholder: "Alarcón"
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
            // FILA 2: TIPO DNI + DNI
            // =====================================================

            Row {
                id: filaTipoDniDni

                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldTipoDni

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "bajaTipoDni"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    Column {
                        anchors.fill: parent
                        anchors.rightMargin: 28
                        spacing: 4

                        Text {
                            text: fieldTipoDni.labelConObligatorio("Tipo")

                            color: fieldTipoDni.tieneError
                                   ? "#DC2626"
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 15
                            font.bold: true
                        }

                        ComboBox {
                            id: comboTipoDni

                            width: parent.width
                            height: 38

                            model: [
                                "DNI"
                            ]

                            currentIndex: 0
                        }
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Selección obligatoria\n- Por ahora se usa DNI"
                    }
                }

                FieldBox {
                    id: fieldDni

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "bajaDni"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputDni

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
            }

            // =====================================================
            // FILA 3: FECHA INGRESO
            // =====================================================

            FieldBox {
                id: fieldFechaIngreso

                width: parent.width
                height: root.altoCampo

                campoId: "bajaFechaIngreso"
                campoObligatorio: true
                tieneError: root.campoTieneError(campoId)

                InputText {
                    id: inputFechaIngreso

                    anchors.fill: parent
                    anchors.rightMargin: 28

                    label: fieldFechaIngreso.labelConObligatorio("Fecha de ingreso a Envión")
                    placeholder: "dd/mm/aaaa"
                    width: parent.width
                }

                FieldHelpIcon {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 2
                    anchors.rightMargin: 2

                    mensaje: "- Formato dd/mm/aaaa\n- Fecha manual por ahora"
                }
            }

            // =====================================================
            // MOTIVO DE BAJA
            // =====================================================

            Rectangle {
                id: bloqueMotivo

                property bool tieneError: root.campoTieneError("bajaMotivo")

                width: parent.width
                height: root.altoBloqueMotivo

                radius: 10
                color: "#FFFFFF"
                border.color: bloqueMotivo.tieneError ? "#DC2626" : "#E5E7EB"
                border.width: bloqueMotivo.tieneError ? 2 : 1

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 42
                    anchors.topMargin: root.modoCompacto ? 8 : 10
                    anchors.bottomMargin: 8

                    spacing: root.modoCompacto ? 6 : 8

                    Text {
                        text: "Motivo de baja *"

                        color: bloqueMotivo.tieneError
                               ? "#DC2626"
                               : AppTheme.colorPrimario

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 16
                        font.bold: true
                    }

                    ComboBox {
                        id: comboMotivo

                        width: parent.width
                        height: 38

                        model: [
                            "Encontrarse privado de la libertad",
                            "Fallecimiento",
                            "Haber cumplimentado con todos los acuerdos para su egreso",
                            "Liquidaciones consecutivas impagas",
                            "Mudanza a otro Municipio",
                            "Negativa a cumplir con su Acuerdo de Compromiso",
                            "Negativa del Joven a participar",
                            "Negativa o dificultades al momento de la socialización",
                            "Pase de Destinatario a Tutor",
                            "Pase de Tutor a Destinatario",
                            "Trabajo Formal",
                            "Otros motivos"
                        ]
                    }
                }

                FieldHelpIcon {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.rightMargin: 12

                    mensaje: "- Selección obligatoria\n- Se marcará con X en el documento\n- En v1 no se cargan aclaraciones adicionales"
                }
            }
        }
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