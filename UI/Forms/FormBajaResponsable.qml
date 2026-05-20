// UI/Forms/FormBajaResponsable.qml

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

    property var datosResponsableBaja: ({})

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
    property real altoBloqueInformado: root.modoCompacto ? 78 : 84

    readonly property real anchoMitad: (root.formularioAncho - root.espacioCampos) / 2

    readonly property real espacioVerticalFormulario: root.modoCompacto
        ? 12
        : root.modoAmplio
            ? 22
            : 18

    readonly property real contenidoAltoFormulario: columFields.implicitHeight + root.camposY

    readonly property string nombreCompletoResponsable: (
        inputNombre.text.trim() + " " + inputApellido.text.trim()
    ).trim()

    // =====================================================
    // FUNCIONES
    // =====================================================

    function limpiarCampos() {
        inputNombre.text = ""
        inputApellido.text = ""

        comboRelacion.currentIndex = 0

        informadoSi.checked = false
        informadoNo.checked = false

        root.datosResponsableBaja = ({})
        root.limpiarErroresValidacion()
    }

    function capturarDatos() {
        root.datosResponsableBaja = {
            bajaResponsableNombre: inputNombre.text,
            bajaResponsableApellido: inputApellido.text,
            bajaResponsableNombreCompleto: root.nombreCompletoResponsable,
            bajaResponsableRelacion: comboRelacion.currentText,

            bajaResponsableInformado: informadoSi.checked
                ? "Sí"
                : informadoNo.checked
                    ? "No"
                    : "Sin seleccionar"
        }

        Logger.linea()
        Logger.bloque(
            "FORM BAJA RESPONSABLE",
            "datos capturados",
            root.datosResponsableBaja
        )

        root.datosCapturados(root.datosResponsableBaja)
    }

    Flickable {
        id: scrollFormResponsableBaja

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

                    campoId: "bajaResponsableNombre"
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

                    campoId: "bajaResponsableApellido"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputApellido

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldApellido.labelConObligatorio("Apellido")
                        placeholder: "Pérez"
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
            // RELACIÓN CON EL JOVEN
            // =====================================================

            FieldBox {
                id: fieldRelacion

                width: parent.width
                height: root.altoCampo

                campoId: "bajaResponsableRelacion"
                campoObligatorio: true
                tieneError: root.campoTieneError(campoId)

                Column {
                    anchors.fill: parent
                    anchors.rightMargin: 28

                    spacing: 5

                    Text {
                        text: fieldRelacion.labelConObligatorio("Relación con el joven")

                        color: fieldRelacion.tieneError
                               ? "#DC2626"
                               : AppTheme.colorPrimario

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 16
                        font.bold: true
                    }

                    ComboBox {
                        id: comboRelacion

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

            // =====================================================
            // RESPONSABLE ADULTO INFORMADO
            // =====================================================

            Rectangle {
                id: bloqueInformado

                property bool tieneError: root.campoTieneError("bajaResponsableInformado")
                readonly property string tituloCampo: "¿El adulto responsable está al tanto de la baja? *"

                width: parent.width
                height: root.altoBloqueInformado

                radius: 10
                color: "#FFFFFF"
                border.color: bloqueInformado.tieneError ? "#DC2626" : "#E5E7EB"
                border.width: bloqueInformado.tieneError ? 2 : 1

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 42
                    anchors.topMargin: root.modoCompacto ? 8 : 10
                    anchors.bottomMargin: 8

                    spacing: root.modoCompacto ? 6 : 8

                    Text {
                        text: bloqueInformado.tituloCampo

                        color: bloqueInformado.tieneError
                               ? "#DC2626"
                               : AppTheme.colorPrimario

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Row {
                        spacing: 28

                        ButtonGroup {
                            id: grupoInformado
                        }

                        RadioButton {
                            id: informadoSi

                            text: "Sí"
                            ButtonGroup.group: grupoInformado
                        }

                        RadioButton {
                            id: informadoNo

                            text: "No"
                            ButtonGroup.group: grupoInformado
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