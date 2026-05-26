// UI/Sections/SectionFour.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import Forms 1.0
import Components 1.0
import Structures 1.0
import Theme 1.0
import Layout 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 800
    height: 300
    // color: AppTheme.colorFondo
    color: "#fff"

    //***********************************************************
    //  PROPIEDADES PARA LÓGICA DEL FORMULARIO
    //***********************************************************

    property int pasoBajaActual: 1
    property bool solicitudGenerada: false

    readonly property int pasoInstitucional: 1
    readonly property int pasoBeneficiario: 2
    readonly property int pasoResponsable: 3
    readonly property int pasoPrevisualizacion: 4

    readonly property string bajaHeaderPasoActual: root.pasoBajaActual + " de 4"

    property var datosInstitucionalesCapturados: ({})
    property var datosBeneficiarioCapturados: ({})
    property var datosResponsableCapturados: ({})
    property var datosCompletosCapturados: ({})
    property var datosSolicitudPreparada: ({})

    property string centroEnvionConfigurado: "Centro Envión"
    property string sedeConfigurada: ""
    property string coordinadoraConfigurada: ""
    property var profesionalesConfigurados: ([])

    property bool fechaAutomatica: true
    property string fechaActual: ""

    property var erroresValidacionInstitucional: []
    property var erroresValidacionBeneficiario: []
    property var erroresValidacionResponsable: []

    //***********************************************************
    //  PROPIEDADES PARA TÍTULOS Y TEXTOS
    //***********************************************************

    readonly property string headerTitle: root.pasoBajaActual === root.pasoInstitucional
                                           ? "Datos institucionales"
                                           : root.pasoBajaActual === root.pasoBeneficiario
                                             ? "Beneficiario y motivo"
                                             : root.pasoBajaActual === root.pasoResponsable
                                               ? "Responsable Adulto"
                                               : "Previsualización"

    readonly property string headerDescription: root.pasoBajaActual === root.pasoInstitucional
                                                ? "Completá los datos institucionales necesarios para la solicitud de baja."
                                                : root.pasoBajaActual === root.pasoBeneficiario
                                                  ? "Completá los datos del beneficiario y seleccioná el motivo de baja."
                                                  : root.pasoBajaActual === root.pasoResponsable
                                                    ? "Completá los datos del responsable adulto vinculados a la baja."
                                                    : "Revisá los datos cargados antes de generar la solicitud de baja."

    readonly property string bajaHeaderIconoSource: root.pasoBajaActual === root.pasoInstitucional
                                                    ? "qrc:/qml/UI/Assets/icon_configuracion.png"
                                                    : root.pasoBajaActual === root.pasoBeneficiario
                                                      ? "qrc:/qml/UI/Assets/icon_destinatario.png"
                                                      : root.pasoBajaActual === root.pasoResponsable
                                                        ? "qrc:/qml/UI/Assets/icon_ra.png"
                                                        : "qrc:/qml/UI/Assets/icon_destinatario.png"

    //***********************************************************
    //  PROPIEDADES PARA MEDIDAS
    //***********************************************************

    readonly property bool modoCompacto: root.width < 1030
    readonly property bool modoMuyCompacto: root.width < 820

    readonly property int actionBarHeight: root.modoCompacto ? 64 : 78
    readonly property int validationBoxSpacing: 12

    readonly property int validationBoxHeight: validationBox.visible
                                           ? validationBox.height + root.validationBoxSpacing
                                           : 0

    readonly property int areaFormY: homeHeader.height
    readonly property int areaFormHeight: Math.max(
        0,
        root.height - homeHeader.height - root.actionBarHeight
    )

    readonly property int actionBarY: Math.min(
        root.height - root.actionBarHeight,
        homeHeader.height + root.validationBoxHeight + (
            root.pasoBajaActual === root.pasoInstitucional
                ? formBajaInstitucional.contenidoAltoFormulario
                : root.pasoBajaActual === root.pasoBeneficiario
                    ? formBajaBeneficiario.contenidoAltoFormulario
                    : root.pasoBajaActual === root.pasoResponsable
                        ? formBajaResponsable.contenidoAltoFormulario
                        : areaForm.height
        ) + 12
    )

    readonly property int formMaxWidth: 920

    readonly property int formOuterMargin: root.modoMuyCompacto
                                           ? 24
                                           : root.modoCompacto
                                             ? 48
                                             : 80

    readonly property int formContentWidth: Math.min(
        root.formMaxWidth,
        Math.max(0, areaForm.width - (root.formOuterMargin * 2))
    )

    readonly property int formContentX: Math.round(
        (areaForm.width - root.formContentWidth) / 2
    )

    readonly property int formInnerX: root.modoCompacto ? 16 : 24
    readonly property int formInnerY: root.modoCompacto ? 22 : 30

    readonly property int actionBarHorizontalMargin: root.modoMuyCompacto
                                                     ? 24
                                                     : root.modoCompacto
                                                       ? 48
                                                       : 80

    readonly property int actionButtonY: root.modoCompacto
                                         ? 6
                                         : Math.round((actionBar.height - buttonPrincipal.height) / 2)

    //***********************************************************
    //  FUNCIONES DE ORQUESTACIÓN
    //***********************************************************

    function cargarConfiguracionBaja() {
        if (controladorBajas && controladorBajas.obtenerConfiguracionBaja) {
            var configuracion = controladorBajas.obtenerConfiguracionBaja()

            root.centroEnvionConfigurado = configuracion.centroEnvion || ""
            root.sedeConfigurada = configuracion.sede || ""
            root.coordinadoraConfigurada = configuracion.coordinadora || ""
            root.profesionalesConfigurados = configuracion.profesionalesIntervinientes || []

            Logger.bloque(
                "SECTION FOUR",
                "configuración de baja cargada",
                JSON.stringify(configuracion)
            )
        }
    }

    function volverPasoAnterior() {
        if (root.pasoBajaActual === root.pasoBeneficiario) {
            root.pasoBajaActual = root.pasoInstitucional
            return
        }

        if (root.pasoBajaActual === root.pasoResponsable) {
            root.pasoBajaActual = root.pasoBeneficiario
            return
        }

        if (root.pasoBajaActual === root.pasoPrevisualizacion) {
            root.pasoBajaActual = root.pasoResponsable
            return
        }
    }

    function registrarErroresValidacion(origen, resultadoValidacion) {
        Logger.linea()
        Logger.simple(origen, "validación rechazada")

        if (resultadoValidacion && resultadoValidacion.mensaje) {
            Logger.bloque(origen, "errores", resultadoValidacion.mensaje)
        } else {
            Logger.bloque(origen, "errores", JSON.stringify(resultadoValidacion))
        }
    }

    function erroresDesdeResultadoValidacion(resultadoValidacion) {
        if (!resultadoValidacion) {
            return []
        }

        if (resultadoValidacion.errores && resultadoValidacion.errores.length !== undefined) {
            return resultadoValidacion.errores
        }

        if (resultadoValidacion.mensaje) {
            return [String(resultadoValidacion.mensaje)]
        }

        return []
    }

    function limpiarErroresValidacionBaja() {
        root.erroresValidacionInstitucional = []
        root.erroresValidacionBeneficiario = []
        root.erroresValidacionResponsable = []
    }

    function erroresValidacionPasoActual() {
        if (root.pasoBajaActual === root.pasoInstitucional) {
            return root.erroresValidacionInstitucional
        }

        if (root.pasoBajaActual === root.pasoBeneficiario) {
            return root.erroresValidacionBeneficiario
        }

        if (root.pasoBajaActual === root.pasoResponsable) {
            return root.erroresValidacionResponsable
        }

        return []
    }

    function unirDatosBaja() {
        var datosCompletos = {}

        for (var claveInstitucional in root.datosInstitucionalesCapturados) {
            datosCompletos[claveInstitucional] =
                    root.datosInstitucionalesCapturados[claveInstitucional]
        }

        for (var claveBeneficiario in root.datosBeneficiarioCapturados) {
            datosCompletos[claveBeneficiario] =
                    root.datosBeneficiarioCapturados[claveBeneficiario]
        }

        for (var claveResponsable in root.datosResponsableCapturados) {
            datosCompletos[claveResponsable] =
                    root.datosResponsableCapturados[claveResponsable]
        }

        root.datosCompletosCapturados = datosCompletos

        Logger.bloque(
            "SECTION FOUR",
            "datos completos de baja capturados",
            root.datosCompletosCapturados
        )
    }

    function prepararPrevisualizacionBaja() {
        root.unirDatosBaja()
        root.limpiarErroresValidacionBaja()

        if (controladorBajas && controladorBajas.prepararDatosBaja) {
            root.datosSolicitudPreparada = controladorBajas.prepararDatosBaja(
                root.datosCompletosCapturados
            )
        } else {
            root.datosSolicitudPreparada = root.datosCompletosCapturados
        }

        Logger.bloque(
            "SECTION FOUR",
            "datos preparados para previsualización de baja",
            root.datosSolicitudPreparada
        )
    }

    function ejecutarAccionPrincipal() {
        if (root.pasoBajaActual === root.pasoInstitucional) {
            formBajaInstitucional.capturarDatos()
            return
        }

        if (root.pasoBajaActual === root.pasoBeneficiario) {
            formBajaBeneficiario.capturarDatos()
            return
        }

        if (root.pasoBajaActual === root.pasoResponsable) {
            formBajaResponsable.capturarDatos()
            return
        }

        if (root.pasoBajaActual === root.pasoPrevisualizacion) {
            Logger.bloque(
                "SECTION FOUR",
                "datos enviados para generar baja",
                root.datosCompletosCapturados
            )

            var resultado = ""

            if (controladorBajas && controladorBajas.generarSolicitudBaja) {
                resultado = controladorBajas.generarSolicitudBaja(
                    root.datosCompletosCapturados
                )
            } else {
                resultado = "ERROR|No existe controladorBajas.generarSolicitudBaja"
            }

            Logger.simple("SECTION FOUR", "resultado Python", resultado)

            if (String(resultado).startsWith("ERROR|")) {
                return
            }

            root.limpiarFormulariosEntradaBaja()
            root.solicitudGenerada = true
            return
        }
    }

    function limpiarFormulariosEntradaBaja() {
        formBajaInstitucional.limpiarCampos()
        formBajaBeneficiario.limpiarCampos()
        formBajaResponsable.limpiarCampos()

        root.datosInstitucionalesCapturados = ({})
        root.datosBeneficiarioCapturados = ({})
        root.datosResponsableCapturados = ({})
        root.datosCompletosCapturados = ({})

        root.limpiarErroresValidacionBaja()
    }

    function reiniciarSolicitudBaja() {
        root.limpiarFormulariosEntradaBaja()

        root.datosSolicitudPreparada = ({})
        root.pasoBajaActual = root.pasoInstitucional
        root.solicitudGenerada = false
    }

    function abrirBajaDesdeMenu() {
        root.cargarConfiguracionBaja()

        root.pasoBajaActual = root.pasoInstitucional
        root.solicitudGenerada = false

        root.limpiarErroresValidacionBaja()

        formBajaInstitucional.limpiarErroresValidacion()
        formBajaBeneficiario.limpiarErroresValidacion()
        formBajaResponsable.limpiarErroresValidacion()
    }

    Component.onCompleted: {
        root.cargarConfiguracionBaja()
    }

    //***********************************************************
    //  HEADER
    //***********************************************************

    HomeHeader {
        id: homeHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: AppLayout.formHeaderHeight

        modoHeader: "formulario"

        titulo: root.headerTitle
        descripcion: root.headerDescription

        mostrarIconoPersona: true
        iconoPersonaSource: root.bajaHeaderIconoSource

        mostrarIndicadorPasos: !root.modoCompacto
        pasoLabel: "PASO ACTUAL"
        pasoValor: root.pasoBajaActual + " de 4"
        pasoDescripcion: root.headerDescription

        formularioSource: ""

        pasoActualFormulario: root.pasoBajaActual
    }

    //***********************************************************
    //  ÁREA DE FORMULARIOS
    //***********************************************************

    Rectangle {
        id: areaForm

        anchors.top: homeHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: "transparent"
        z: 1
        clip: true

        ValidationMessageBox {
            id: validationBox

            x: root.formContentX
            y: 0

            width: root.formContentWidth
            errores: root.erroresValidacionPasoActual()

            titulo: root.pasoBajaActual === root.pasoInstitucional
                    ? "Corregí los datos institucionales:"
                    : root.pasoBajaActual === root.pasoBeneficiario
                      ? "Corregí los datos del beneficiario:"
                      : "Corregí los datos del responsable:"
        }

        FormBajaInstitucional {
            id: formBajaInstitucional

            x: root.formContentX
            y: root.validationBoxHeight

            width: root.formContentWidth
            height: areaForm.height

            camposX: root.formInnerX
            camposY: root.formInnerY

            centroEnvion: root.centroEnvionConfigurado
            sedeConfigurada: root.sedeConfigurada
            coordinadoraConfigurada: root.coordinadoraConfigurada
            profesionalesConfigurados: root.profesionalesConfigurados

            fechaAutomatica: root.fechaAutomatica
            fechaActual: root.fechaActual

            visible: root.pasoBajaActual === root.pasoInstitucional

            onDatosCapturados: function(datos) {
                Logger.linea()
                Logger.bloque(
                    "SECTION FOUR",
                    "datos recibidos de FormBajaInstitucional",
                    JSON.stringify(datos)
                )

                var resultadoValidacion = { valido: true, errores: [], mensaje: "" }

                if (controladorBajas && controladorBajas.validarBajaInstitucional) {
                    resultadoValidacion = controladorBajas.validarBajaInstitucional(datos)
                }

                if (!resultadoValidacion.valido) {
                    formBajaInstitucional.aplicarErroresValidacion(resultadoValidacion.errores)

                    root.erroresValidacionInstitucional = root.erroresDesdeResultadoValidacion(resultadoValidacion)
                    root.erroresValidacionBeneficiario = []
                    root.erroresValidacionResponsable = []
                    root.registrarErroresValidacion(
                        "VALIDACIÓN BAJA INSTITUCIONAL",
                        resultadoValidacion
                    )
                    return
                }

                formBajaInstitucional.limpiarErroresValidacion()

                root.erroresValidacionInstitucional = []
                root.erroresValidacionBeneficiario = []
                root.erroresValidacionResponsable = []
                root.datosInstitucionalesCapturados = datos
                root.pasoBajaActual = root.pasoBeneficiario
            }
        }

        FormBajaBeneficiario {
            id: formBajaBeneficiario

            x: root.formContentX
            y: root.validationBoxHeight

            width: root.formContentWidth
            height: areaForm.height

            camposX: root.formInnerX
            camposY: root.formInnerY

            visible: root.pasoBajaActual === root.pasoBeneficiario

            onDatosCapturados: function(datos) {
                Logger.linea()
                Logger.bloque(
                    "SECTION FOUR",
                    "datos recibidos de FormBajaBeneficiario",
                    JSON.stringify(datos)
                )

                var resultadoValidacion = { valido: true, errores: [], mensaje: "" }

                if (controladorBajas && controladorBajas.validarBajaBeneficiario) {
                    resultadoValidacion = controladorBajas.validarBajaBeneficiario(datos)
                }

                if (!resultadoValidacion.valido) {
                    formBajaBeneficiario.aplicarErroresValidacion(resultadoValidacion.errores)

                    root.erroresValidacionBeneficiario = root.erroresDesdeResultadoValidacion(resultadoValidacion)
                    root.erroresValidacionInstitucional = []
                    root.erroresValidacionResponsable = []
                    root.registrarErroresValidacion(
                        "VALIDACIÓN BAJA BENEFICIARIO",
                        resultadoValidacion
                    )
                    return
                }

                formBajaBeneficiario.limpiarErroresValidacion()

                root.erroresValidacionBeneficiario = []
                root.erroresValidacionInstitucional = []
                root.erroresValidacionResponsable = []
                root.datosBeneficiarioCapturados = datos
                root.pasoBajaActual = root.pasoResponsable
            }
        }

        FormBajaResponsable {
            id: formBajaResponsable

            x: root.formContentX
            y: root.validationBoxHeight

            width: root.formContentWidth
            height: areaForm.height

            camposX: root.formInnerX
            camposY: root.formInnerY

            visible: root.pasoBajaActual === root.pasoResponsable

            onDatosCapturados: function(datos) {
                Logger.linea()
                Logger.bloque(
                    "SECTION FOUR",
                    "datos recibidos de FormBajaResponsable",
                    JSON.stringify(datos)
                )

                var resultadoValidacion = { valido: true, errores: [], mensaje: "" }

                if (controladorBajas && controladorBajas.validarBajaResponsable) {
                    resultadoValidacion = controladorBajas.validarBajaResponsable(datos)
                }

                if (!resultadoValidacion.valido) {
                    formBajaResponsable.aplicarErroresValidacion(resultadoValidacion.errores)

                    root.erroresValidacionResponsable = root.erroresDesdeResultadoValidacion(resultadoValidacion)
                    root.erroresValidacionInstitucional = []
                    root.erroresValidacionBeneficiario = []
                    root.registrarErroresValidacion(
                        "VALIDACIÓN BAJA RESPONSABLE",
                        resultadoValidacion
                    )
                    return
                }

                formBajaResponsable.limpiarErroresValidacion()

                root.erroresValidacionResponsable = []
                root.erroresValidacionInstitucional = []
                root.erroresValidacionBeneficiario = []
                root.datosResponsableCapturados = datos

                root.prepararPrevisualizacionBaja()
                root.pasoBajaActual = root.pasoPrevisualizacion
            }
        }

        FormPrevisualizacionBaja {
            id: formPrevisualizacionBaja

            x: root.formContentX
            y: 0

            width: root.formContentWidth
            height: areaForm.height

            visible: root.pasoBajaActual === root.pasoPrevisualizacion

            datosSolicitud: root.datosSolicitudPreparada

            onVolverSolicitado: {
                root.pasoBajaActual = root.pasoResponsable
            }

            onGenerarSolicitado: {
                root.ejecutarAccionPrincipal()
            }
        }
    }

    //***********************************************************
    //  BOTONES GLOBALES DEL FLUJO
    //***********************************************************

    Item {
        id: actionBar

        anchors.left: parent.left
        anchors.right: parent.right

        y: root.actionBarY
        height: root.actionBarHeight
        z: 3

        CustonButton2 {
            id: buttonAnterior

            visible: root.pasoBajaActual !== root.pasoInstitucional

            tipo: "anterior"
            variante: "secondary"

            x: root.actionBarHorizontalMargin
            y: root.actionButtonY

            onClicked: {
                root.volverPasoAnterior()
            }
        }

        CustonButton2 {
            id: buttonPrincipal

            tipo: root.pasoBajaActual === root.pasoPrevisualizacion
                  ? "generar"
                  : "siguiente"

            variante: "primary"

            x: actionBar.width - root.actionBarHorizontalMargin - buttonPrincipal.width
            y: root.actionButtonY

            onClicked: {
                root.ejecutarAccionPrincipal()
            }
        }

        CustonButton2 {
            id: buttonNuevaSolicitud

            visible: root.solicitudGenerada

            tipo: "custom"
            textoCustom: "Nueva solicitud"
            variante: "secondary"

            width: buttonPrincipal.width
            height: buttonPrincipal.height

            x: buttonPrincipal.x - width - 28
            y: root.actionButtonY

            onClicked: {
                root.reiniciarSolicitudBaja()
            }
        }
    }
}