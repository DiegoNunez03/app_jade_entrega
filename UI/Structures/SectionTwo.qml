// UI/Structures/SectionTwo.qml
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
    color: AppTheme.colorFondo

    //***********************************************************
    //  PROPIEDADES PARA LÓGICA DEL FORMULARIO
    //***********************************************************

    property bool edadAutomatica: false
    property int pasoAltaActual: 1

    property bool solicitudGenerada: false

    readonly property int pasoDestinatario: 1
    readonly property int pasoResponsable: 2
    readonly property int pasoPrevisualizacion: 3

    readonly property string altaHeaderPasoActual: root.pasoAltaActual + " de 3"

    property var datosDestinatarioCapturados: ({})
    property var datosResponsableCapturados: ({})
    property var datosCompletosCapturados: ({})
    property var datosSolicitudPreparada: ({})

    // Mensajes de validación por paso.
    property string mensajeValidacionDestinatario: ""
    property string mensajeValidacionResponsable: ""

    //***********************************************************
    //  PROPIEDADES PARA TÍTULOS Y TEXTOS
    //***********************************************************

    readonly property string headerTitle: root.pasoAltaActual === root.pasoDestinatario
                                           ? "Destinatario"
                                           : root.pasoAltaActual === root.pasoResponsable
                                             ? "Responsable Adulto"
                                             : "Previsualización"

    readonly property string headerDescription: root.pasoAltaActual === root.pasoDestinatario
                                                ? "Completá la información personal del destinatario para continuar con el proceso."
                                                : root.pasoAltaActual === root.pasoResponsable
                                                  ? "Completá la información del responsable adulto para continuar con la solicitud."
                                                  : "Revisá los datos cargados antes de generar la solicitud."

    readonly property string altaHeaderIconoSource: root.pasoAltaActual === root.pasoDestinatario
                                                    ? "qrc:/qml/UI/Assets/icon_destinatario.png"
                                                    : root.pasoAltaActual === root.pasoResponsable
                                                      ? "qrc:/qml/UI/Assets/icon_ra.png"
                                                      : "qrc:/qml/UI/Assets/icon_destinatario.png"

    //***********************************************************
    //  PROPIEDADES PARA MEDIDAS
    //***********************************************************

    readonly property bool modoCompacto: root.width < 1030
    readonly property bool modoMuyCompacto: root.width < 820

    readonly property int actionBarHeight: root.modoCompacto ? 64 : 78

    readonly property int areaFormY: homeHeader.height
    readonly property int areaFormHeight: Math.max(
        0,
        root.height - homeHeader.height - root.actionBarHeight
    )

    readonly property int actionBarY: Math.min(
        root.height - root.actionBarHeight,
        homeHeader.height + (
            root.pasoAltaActual === root.pasoDestinatario
                ? formDestinatario.contenidoAltoFormulario
                : root.pasoAltaActual === root.pasoResponsable
                    ? formResponsable.contenidoAltoFormulario
                    : areaForm.height
        ) + 12
    )

    /*
        Medidas controladas desde SectionTwo.

        - El formulario tiene un ancho máximo.
        - En compacto usa casi todo el ancho disponible.
        - camposX queda pequeño porque el centrado lo hace SectionTwo.
    */
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

    function volverPasoAnterior() {
        if (root.pasoAltaActual === root.pasoResponsable) {
            root.pasoAltaActual = root.pasoDestinatario
            return
        }

        if (root.pasoAltaActual === root.pasoPrevisualizacion) {
            root.pasoAltaActual = root.pasoResponsable
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

    function ejecutarAccionPrincipal() {
        if (root.pasoAltaActual === root.pasoDestinatario) {
            formDestinatario.capturarDatos()
            return
        }

        if (root.pasoAltaActual === root.pasoResponsable) {
            formResponsable.capturarDatos()
            return
        }

        if (root.pasoAltaActual === root.pasoPrevisualizacion) {
            Logger.bloque(
                "SECTION TWO",
                "datos enviados para generar solicitud",
                root.datosCompletosCapturados
            )

            let resultado = controladorAltas.generarSolicitud(root.datosCompletosCapturados)
            Logger.simple("SECTION TWO", "resultado Python", resultado)

            if (String(resultado).startsWith("ERROR|")) {
                return
            }

            root.limpiarFormulariosEntradaAlta()
            root.solicitudGenerada = true
            return
        }
    }

    function limpiarFormulariosEntradaAlta() {
        formDestinatario.limpiarCampos()
        formResponsable.limpiarCampos()

        root.datosDestinatarioCapturados = ({})
        root.datosResponsableCapturados = ({})
        root.datosCompletosCapturados = ({})
        root.mensajeValidacionDestinatario = ""
        root.mensajeValidacionResponsable = ""
    }

    function reiniciarSolicitudAlta() {
        root.limpiarFormulariosEntradaAlta()

        root.datosSolicitudPreparada = ({})
        root.pasoAltaActual = root.pasoDestinatario
        root.solicitudGenerada = false
    }

    function abrirAltaDestinatarioDesdeMenu() {
        root.pasoAltaActual = root.pasoDestinatario
        root.solicitudGenerada = false
        root.mensajeValidacionDestinatario = ""
        root.mensajeValidacionResponsable = ""

        formDestinatario.limpiarErroresValidacion()
        formResponsable.limpiarErroresValidacion()
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
        iconoPersonaSource: root.altaHeaderIconoSource

        mostrarIndicadorPasos: !root.modoCompacto
        pasoLabel: "PASO ACTUAL"
        pasoValor: root.pasoAltaActual + " de 3"
        pasoDescripcion: root.headerDescription

        formularioSource: ""

        pasoActualFormulario: root.pasoAltaActual
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

        FormDestinatario {
            id: formDestinatario

            x: root.formContentX
            y: 0

            width: root.formContentWidth
            height: areaForm.height

            camposX: root.formInnerX
            camposY: root.formInnerY

            edadAutomatica: root.edadAutomatica
            visible: root.pasoAltaActual === root.pasoDestinatario

            onDatosCapturados: function(datos) {
                Logger.linea()
                Logger.bloque(
                    "SECTION TWO",
                    "datos recibidos de FormDestinatario",
                    JSON.stringify(datos)
                )

                let resultadoValidacion = controladorAltas.validarDestinatario(datos)

                if (!resultadoValidacion.valido) {
                    formDestinatario.aplicarErroresValidacion(resultadoValidacion.errores)

                    root.mensajeValidacionDestinatario = resultadoValidacion.mensaje || ""
                    root.registrarErroresValidacion("VALIDACIÓN DESTINATARIO", resultadoValidacion)
                    return
                }

                formDestinatario.limpiarErroresValidacion()

                root.mensajeValidacionDestinatario = ""
                root.datosDestinatarioCapturados = datos
                root.pasoAltaActual = root.pasoResponsable
            }
        }

        FormResponsable {
            id: formResponsable

            x: root.formContentX
            y: 0

            width: root.formContentWidth
            height: areaForm.height

            camposX: root.formInnerX
            camposY: root.formInnerY

            edadAutomatica: root.edadAutomatica
            visible: root.pasoAltaActual === root.pasoResponsable

            domicilioDestinatario: root.datosDestinatarioCapturados.direccion || ""
            calleDestinatario: root.datosDestinatarioCapturados.calle || ""
            numeroDestinatario: root.datosDestinatarioCapturados.numero || ""

            onVolverSolicitado: {
                root.pasoAltaActual = root.pasoDestinatario
            }

            onDatosCapturados: function(datos) {
                Logger.bloque("SECTION TWO", "datos responsable capturados", datos)

                let resultadoValidacion = controladorAltas.validarResponsable(datos)

                if (!resultadoValidacion.valido) {
                    // La función se agrega en el próximo paso dentro de FormResponsable.qml.
                    // Mientras tanto, la validación ya bloquea el avance y muestra errores en consola.
                    if (formResponsable.aplicarErroresValidacion) {
                        formResponsable.aplicarErroresValidacion(resultadoValidacion.errores)
                    }

                    root.mensajeValidacionResponsable = resultadoValidacion.mensaje || ""
                    root.registrarErroresValidacion("VALIDACIÓN RESPONSABLE", resultadoValidacion)
                    return
                }

                if (formResponsable.limpiarErroresValidacion) {
                    formResponsable.limpiarErroresValidacion()
                }

                root.mensajeValidacionResponsable = ""
                root.datosResponsableCapturados = datos

                var datosCompletos = {}

                for (var claveDestinatario in root.datosDestinatarioCapturados) {
                    datosCompletos[claveDestinatario] =
                            root.datosDestinatarioCapturados[claveDestinatario]
                }

                for (var claveResponsable in root.datosResponsableCapturados) {
                    datosCompletos[claveResponsable] =
                            root.datosResponsableCapturados[claveResponsable]
                }

                root.datosCompletosCapturados = datosCompletos

                Logger.bloque(
                    "SECTION TWO",
                    "datos completos capturados",
                    root.datosCompletosCapturados
                )

                root.datosSolicitudPreparada = controladorAltas.prepararDatosSolicitud(
                    root.datosCompletosCapturados
                )

                Logger.bloque(
                    "SECTION TWO",
                    "datos preparados para previsualización",
                    root.datosSolicitudPreparada
                )

                root.pasoAltaActual = root.pasoPrevisualizacion
            }
        }

        FormPrevisualizacion {
            id: formPrevisualizacion

            x: root.formContentX
            y: 0

            width: root.formContentWidth
            height: areaForm.height

            visible: root.pasoAltaActual === root.pasoPrevisualizacion

            datosSolicitud: root.datosSolicitudPreparada

            onVolverSolicitado: {
                root.pasoAltaActual = root.pasoResponsable
            }

            onGenerarSolicitado: {
                Logger.bloque(
                    "SECTION TWO",
                    "datos enviados para generar solicitud",
                    root.datosCompletosCapturados
                )

                let resultado = controladorAltas.generarSolicitud(
                    root.datosCompletosCapturados
                )

                Logger.simple("SECTION TWO", "resultado Python", resultado)
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

            visible: root.pasoAltaActual !== root.pasoDestinatario

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

            tipo: root.pasoAltaActual === root.pasoPrevisualizacion
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
                root.reiniciarSolicitudAlta()
            }
        }
    }
}
