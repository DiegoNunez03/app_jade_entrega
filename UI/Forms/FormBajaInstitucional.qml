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

    // Estos valores los completa SectionFour leyendo la configuración guardada.
    property string centroEnvion: "Centro Envión"
    property string sedeConfigurada: ""
    property string coordinadoraConfigurada: ""
    property var profesionalesConfigurados: ([])

    // Configuración automática de fecha recibida desde SectionFour.
    property bool fechaAutomatica: true
    property string fechaActual: ""

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
    property real altoBloqueProfesionales: root.modoCompacto ? 188 : 204

    readonly property real anchoMitad: (root.formularioAncho - root.espacioCampos) / 2

    readonly property real espacioVerticalFormulario: root.modoCompacto
        ? 12
        : root.modoAmplio
            ? 22
            : 18

    readonly property real contenidoAltoFormulario: columFields.implicitHeight + root.camposY

    readonly property var modeloProfesionalesDisponibles: (
        root.profesionalesConfigurados && root.profesionalesConfigurados.length > 0
            ? root.profesionalesConfigurados
            : ["No hay profesionales configurados"]
    )

    readonly property real altoListaProfesionales: root.profesionalesIntervinientes.length <= 1
        ? 42
        : Math.min(96, 28 + (root.profesionalesIntervinientes.length * 22))

    // =====================================================
    // HELPERS
    // =====================================================

    function valorSeguro(valor) {
        return valor === undefined || valor === null || valor === "" ? "-" : valor
    }

    function obtenerFechaBajaFinal() {
        return root.fechaActual
    }

    function textoProfesionales() {
        if (!root.profesionalesIntervinientes || root.profesionalesIntervinientes.length === 0) {
            return ""
        }

        return root.profesionalesIntervinientes.join(" / ")
    }

    function textoProfesionalesLista() {
        if (!root.profesionalesIntervinientes || root.profesionalesIntervinientes.length === 0) {
            return "Todavía no se agregó ningún profesional."
        }

        return "• " + root.profesionalesIntervinientes.join("\n• ")
    }

    function agregarProfesional() {
        if (!root.profesionalesConfigurados || root.profesionalesConfigurados.length === 0) {
            return
        }

        var valor = comboProfesional.currentText.trim()

        if (valor === "" || valor === "No hay profesionales configurados") {
            return
        }

        var nuevaLista = []

        for (var i = 0; i < root.profesionalesIntervinientes.length; i++) {
            nuevaLista.push(root.profesionalesIntervinientes[i])
        }

        if (nuevaLista.indexOf(valor) === -1) {
            nuevaLista.push(valor)
        }

        root.profesionalesIntervinientes = nuevaLista

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
        comboModalidad.currentIndex = 0

        if (comboProfesional.count > 0) {
            comboProfesional.currentIndex = 0
        }

        root.profesionalesIntervinientes = []
        root.datosInstitucionales = ({})

        root.limpiarErroresValidacion()
    }

    function capturarDatos() {
        root.datosInstitucionales = {
            centroEnvion: root.centroEnvion,
            sede: root.sedeConfigurada,
            modalidad: comboModalidad.currentText,
            profesionalesIntervinientes: root.profesionalesIntervinientes,
            profesionalesIntervinientesTexto: root.textoProfesionales(),
            coordinadora: root.coordinadoraConfigurada,
            fechaBaja: root.obtenerFechaBajaFinal()
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
            // FILA 1: MODALIDAD
            // =====================================================

            Row {
                id: filaModalidadFecha

                width: parent.width
                spacing: 0

                FieldBox {
                    id: fieldModalidad

                    width: parent.width
                    height: root.altoCampo

                    campoId: "modalidad"
                    campoObligatorio: true
                    tieneError: root.campoTieneError(campoId)

                    Column {
                        anchors.fill: parent
                        anchors.rightMargin: 28

                        spacing: 5

                        Text {
                            text: fieldModalidad.labelConObligatorio("Modalidad")

                            color: fieldModalidad.tieneError
                                   ? "#DC2626"
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 16
                            font.bold: true
                        }

                        ComboBox {
                            id: comboModalidad

                            width: parent.width
                            height: 36

                            model: [
                                "Tradicional"
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

                            mensaje: "- Seleccionar un profesional configurado\n- Presionar Agregar\n- Se puede agregar más de uno"
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

                            Column {
                                anchors.fill: parent
                                anchors.rightMargin: 28

                                spacing: 5

                                Text {
                                    text: "Profesional"

                                    color: fieldProfesional.tieneError
                                           ? "#DC2626"
                                           : AppTheme.colorPrimario

                                    font.family: AppTheme.fuenteTitulo
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                ComboBox {
                                    id: comboProfesional

                                    width: parent.width
                                    height: 36

                                    enabled: root.profesionalesConfigurados.length > 0
                                    model: root.modeloProfesionalesDisponibles
                                }
                            }

                            FieldHelpIcon {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 2
                                anchors.rightMargin: 2

                                mensaje: "- Se carga desde Configuración\n- Si no aparece nadie, agregá profesionales en Configuración/Sede"
                            }
                        }

                        Button {
                            id: buttonAgregarProfesional

                            width: 112
                            height: root.altoCampo

                            text: "Agregar"
                            enabled: root.profesionalesConfigurados.length > 0

                            onClicked: {
                                root.agregarProfesional()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: root.altoListaProfesionales
                        radius: 8

                        color: "#FAFAFA"
                        border.color: "#E5E7EB"
                        border.width: 1

                        clip: true

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            anchors.topMargin: 6
                            anchors.bottomMargin: 6

                            verticalAlignment: root.profesionalesIntervinientes.length <= 1
                                               ? Text.AlignVCenter
                                               : Text.AlignTop

                            text: root.textoProfesionalesLista()

                            color: root.profesionalesIntervinientes.length === 0
                                   ? AppTheme.colorTextoSecundario
                                   : AppTheme.colorTextoPrincipal

                            font.family: AppTheme.fuenteCuerpo
                            font.pixelSize: 13
                            font.bold: root.profesionalesIntervinientes.length > 0

                            wrapMode: Text.WordWrap
                        }
                    }
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