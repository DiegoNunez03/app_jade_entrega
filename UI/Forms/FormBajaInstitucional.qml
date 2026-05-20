// UI/Forms/FormBajaInstitucional.qml

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

    property var datosInstitucionales: ({})

    // Estos valores después los puede completar SectionFour
    // leyendo la configuración guardada del sistema.
    property string centroEnvion: "Centro Envión"
    property string sedeConfigurada: ""

    property var profesionalesIntervinientes: ([])

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
    property real altoBloqueSede: root.modoCompacto ? 96 : 104
    property real altoBloqueProfesionales: root.modoCompacto ? 170 : 184

    readonly property real anchoMitad: (root.formularioAncho - root.espacioCampos) / 2

    readonly property real espacioVerticalFormulario: root.modoCompacto
        ? 12
        : root.modoAmplio
            ? 22
            : 18

    readonly property real contenidoAltoFormulario: columFields.implicitHeight + root.camposY

    // =====================================================
    // HELPERS
    // =====================================================

    function valorSeguro(valor) {
        return valor === undefined || valor === null || valor === "" ? "-" : valor
    }

    function textoProfesionales() {
        if (!root.profesionalesIntervinientes || root.profesionalesIntervinientes.length === 0) {
            return ""
        }

        return root.profesionalesIntervinientes.join(" / ")
    }

    function agregarProfesional() {
        var valor = inputProfesional.text.trim()

        if (valor === "") {
            return
        }

        var nuevaLista = []

        for (var i = 0; i < root.profesionalesIntervinientes.length; i++) {
            nuevaLista.push(root.profesionalesIntervinientes[i])
        }

        nuevaLista.push(valor)

        root.profesionalesIntervinientes = nuevaLista
        inputProfesional.text = ""

        root.limpiarErrorCampo("profesionalesIntervinientes")

        Logger.bloque(
            "FORM BAJA INSTITUCIONAL",
            "profesionales actualizados",
            root.profesionalesIntervinientes
        )
    }

    function quitarProfesional(indice) {
        var nuevaLista = []

        for (var i = 0; i < root.profesionalesIntervinientes.length; i++) {
            if (i !== indice) {
                nuevaLista.push(root.profesionalesIntervinientes[i])
            }
        }

        root.profesionalesIntervinientes = nuevaLista
    }

    function limpiarErrorCampo(campoId) {
        if (!root.erroresCampos || root.erroresCampos[campoId] !== true) {
            return
        }

        var nuevoMapa = {}

        for (var clave in root.erroresCampos) {
            if (clave !== campoId) {
                nuevoMapa[clave] = root.erroresCampos[clave]
            }
        }

        root.erroresCampos = nuevoMapa
    }

    function limpiarCampos() {
        inputModalidad.text = ""
        inputProfesional.text = ""
        inputCoordinadora.text = ""
        inputFechaBaja.text = ""

        root.profesionalesIntervinientes = []
        root.datosInstitucionales = ({})

        root.limpiarErroresValidacion()
    }

    function capturarDatos() {
        // Si el usuario escribió un profesional pero no tocó "Agregar",
        // lo incorporamos igual antes de capturar.
        if (inputProfesional.text.trim() !== "") {
            root.agregarProfesional()
        }

        root.datosInstitucionales = {
            centroEnvion: root.centroEnvion,
            sede: root.sedeConfigurada,
            modalidad: inputModalidad.text,
            profesionalesIntervinientes: root.profesionalesIntervinientes,
            profesionalesIntervinientesTexto: root.textoProfesionales(),
            coordinadora: inputCoordinadora.text,
            fechaBaja: inputFechaBaja.text
        }

        Logger.linea()
        Logger.bloque(
            "FORM BAJA INSTITUCIONAL",
            "datos capturados",
            root.datosInstitucionales
        )

        root.datosCapturados(root.datosInstitucionales)
    }

    Flickable {
        id: scrollFormInstitucional

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
            // BLOQUE SEDE / CENTRO
            // =====================================================

            Rectangle {
                id: bloqueSede

                readonly property bool tieneErrorSede: root.campoTieneError("centroEnvion")
                                                    || root.campoTieneError("sede")

                width: parent.width
                height: root.altoBloqueSede

                radius: 12
                color: "#FFFFFF"
                border.color: bloqueSede.tieneErrorSede ? "#DC2626" : "#E8E0FF"
                border.width: bloqueSede.tieneErrorSede ? 2 : 1

                Row {
                    anchors.fill: parent
                    anchors.margins: root.modoCompacto ? 10 : 14

                    spacing: root.modoCompacto ? 12 : 16

                    Rectangle {
                        id: iconoSede

                        width: root.modoCompacto ? 42 : 48
                        height: parent.height
                        radius: 10

                        color: "#F4EFFF"

                        Text {
                            anchors.centerIn: parent

                            text: "▣"

                            color: AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: root.modoCompacto ? 20 : 23
                            font.bold: true
                        }
                    }

                    Column {
                        width: parent.width - iconoSede.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 8

                        Text {
                            text: "Datos del centro"

                            color: bloqueSede.tieneErrorSede
                                   ? "#DC2626"
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 15
                            font.bold: true
                        }

                        Row {
                            width: parent.width
                            spacing: root.espacioCampos

                            Rectangle {
                                width: root.anchoMitad
                                height: 42
                                radius: 8
                                color: "#FAFAFA"
                                border.color: "#E5E7EB"
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    anchors.topMargin: 4

                                    spacing: 1

                                    Text {
                                        text: "Centro Envión"
                                        color: AppTheme.colorTextoSecundario
                                        font.family: AppTheme.fuenteCuerpo
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: root.valorSeguro(root.centroEnvion)
                                        color: AppTheme.colorTextoPrincipal
                                        font.family: AppTheme.fuenteCuerpo
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }
                            }

                            Rectangle {
                                width: root.anchoMitad
                                height: 42
                                radius: 8
                                color: "#FAFAFA"
                                border.color: "#E5E7EB"
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    anchors.topMargin: 4

                                    spacing: 1

                                    Text {
                                        text: "Sede"
                                        color: AppTheme.colorTextoSecundario
                                        font.family: AppTheme.fuenteCuerpo
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: root.valorSeguro(root.sedeConfigurada)
                                        color: AppTheme.colorTextoPrincipal
                                        font.family: AppTheme.fuenteCuerpo
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // =====================================================
            // FILA 1: MODALIDAD + FECHA BAJA
            // =====================================================

            Row {
                id: filaModalidadFecha

                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldModalidad

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "modalidad"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputModalidad

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldModalidad.labelConObligatorio("Modalidad")
                        placeholder: "Tradicional"
                        width: parent.width
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Ejemplo: Tradicional\n- Texto libre"
                    }
                }

                FieldBox {
                    id: fieldFechaBaja

                    width: root.anchoMitad
                    height: root.altoCampo

                    campoId: "fechaBaja"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    InputText {
                        id: inputFechaBaja

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldFechaBaja.labelConObligatorio("Fecha de baja")
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
            }

            // =====================================================
            // BLOQUE PROFESIONALES INTERVINIENTES
            // =====================================================

            Rectangle {
                id: bloqueProfesionales

                readonly property bool tieneErrorProfesionales: root.campoTieneError("profesionalesIntervinientes")

                width: parent.width
                height: root.altoBloqueProfesionales

                radius: 12
                color: "#FFFFFF"
                border.color: bloqueProfesionales.tieneErrorProfesionales ? "#DC2626" : "#E8E0FF"
                border.width: bloqueProfesionales.tieneErrorProfesionales ? 2 : 1

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10

                    spacing: 10

                    Row {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Profesional interviniente *"

                            color: bloqueProfesionales.tieneErrorProfesionales
                                   ? "#DC2626"
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 16
                            font.bold: true
                        }

                        FieldHelpIcon {
                            anchors.verticalCenter: parent.verticalCenter

                            mensaje: "- Cargar uno o más profesionales\n- Escribir nombre, apellido y rol si corresponde\n- Presionar Agregar"
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: root.espacioCampos

                        FieldBox {
                            id: fieldProfesional

                            width: parent.width - buttonAgregarProfesional.width - root.espacioCampos
                            height: root.altoCampo

                            campoId: "profesionalTemporal"
                            campoObligatorio: false
                            tieneError: root.campoTieneError("profesionalesIntervinientes")

                            InputText {
                                id: inputProfesional

                                anchors.fill: parent
                                anchors.rightMargin: 28

                                label: "Profesional"
                                placeholder: "García Laura Fabiana - PSP"
                                width: parent.width
                            }

                            FieldHelpIcon {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 2
                                anchors.rightMargin: 2

                                mensaje: "- Nombre y apellido\n- Rol opcional\n- Ejemplo: PSP / TS"
                            }
                        }

                        Button {
                            id: buttonAgregarProfesional

                            width: 112
                            height: root.altoCampo

                            text: "Agregar"

                            onClicked: {
                                root.agregarProfesional()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: 8

                        color: "#FAFAFA"
                        border.color: "#E5E7EB"
                        border.width: 1

                        clip: true

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            verticalAlignment: Text.AlignVCenter

                            text: root.profesionalesIntervinientes.length === 0
                                  ? "Todavía no se agregó ningún profesional."
                                  : root.textoProfesionales()

                            color: root.profesionalesIntervinientes.length === 0
                                   ? AppTheme.colorTextoSecundario
                                   : AppTheme.colorTextoPrincipal

                            font.family: AppTheme.fuenteCuerpo
                            font.pixelSize: 13
                            font.bold: root.profesionalesIntervinientes.length > 0

                            elide: Text.ElideRight
                        }
                    }
                }
            }

            // =====================================================
            // FILA 2: COORDINADORA
            // =====================================================

            FieldBox {
                id: fieldCoordinadora

                width: parent.width
                height: root.altoCampo

                campoId: "coordinadora"
                campoObligatorio: true
                tieneError: root.campoTieneError(campoId)

                InputText {
                    id: inputCoordinadora

                    anchors.fill: parent
                    anchors.rightMargin: 28

                    label: fieldCoordinadora.labelConObligatorio("Coordinadora")
                    placeholder: "Candela Rossi"
                    width: parent.width
                }

                FieldHelpIcon {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 2
                    anchors.rightMargin: 2

                    mensaje: "- Nombre y apellido\n- Texto libre"
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