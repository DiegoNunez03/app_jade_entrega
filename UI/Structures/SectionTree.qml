// UI/Structures/SectionTree.qml
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
    property int pasoAltaTutorActual: 1

    property bool solicitudGenerada: false

    readonly property int pasoTutor: 1
    readonly property int pasoPrevisualizacion: 2

    property var datosTutorCapturados: ({})
    property var datosCompletosCapturados: ({})
    property var datosSolicitudPreparada: ({})

    property string mensajeValidacionTutor: ""

    //***********************************************************
    //  PROPIEDADES PARA TÍTULOS Y TEXTOS
    //***********************************************************

    readonly property string headerTitle: root.pasoAltaTutorActual === root.pasoTutor
                                           ? "Tutor"
                                           : "Previsualización"

    readonly property string headerDescription: root.pasoAltaTutorActual === root.pasoTutor
                                                ? "Completá la información personal del tutor para continuar con el proceso."
                                                : "Revisá los datos cargados antes de generar la solicitud."

    readonly property string altaHeaderIconoSource: "qrc:/qml/UI/Assets/icon_destinatario.png"

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
            root.pasoAltaTutorActual === root.pasoTutor
                ? formTutor.contenidoAltoFormulario
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

    function volverPasoAnterior() {
        if (root.pasoAltaTutorActual === root.pasoPrevisualizacion) {
            root.pasoAltaTutorActual = root.pasoTutor
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

    function completarResponsableVacio(datosBase) {
        datosBase.tipoSolicitud = "tutor"

        datosBase.responsableNombre = ""
        datosBase.responsableApellido = ""
        datosBase.responsableTelefono = ""
        datosBase.responsableDomicilio = ""
        datosBase.responsableDni = ""
        datosBase.responsableParentesco = ""
        datosBase.responsableFechaNacimiento = ""
        datosBase.responsableEdad = ""

        return datosBase
    }

    function prepararDatosTutor(datosTutor) {
        var datosCompletos = {}

        for (var claveTutor in datosTutor) {
            datosCompletos[claveTutor] = datosTutor[claveTutor]
        }

        datosCompletos = root.completarResponsableVacio(datosCompletos)

        return datosCompletos
    }

    function ejecutarAccionPrincipal() {
        if (root.pasoAltaTutorActual === root.pasoTutor) {
            formTutor.capturarDatos()
            return
        }

        if (root.pasoAltaTutorActual === root.pasoPrevisualizacion) {
            Logger.bloque(
                "SECTION TREE",
                "datos enviados para generar solicitud de tutor",
                root.datosCompletosCapturados
            )

            let resultado = controladorAltas.generarSolicitud(root.datosCompletosCapturados)

            Logger.simple("SECTION TREE", "resultado Python", resultado)

            if (String(resultado).startsWith("ERROR|")) {
                return
            }

            root.limpiarFormularioTutor()
            root.solicitudGenerada = true

            return
        }
    }

    function limpiarFormularioTutor() {
        formTutor.limpiarCampos()

        root.datosTutorCapturados = ({})
        root.datosCompletosCapturados = ({})
        root.mensajeValidacionTutor = ""
    }

    function reiniciarSolicitudTutor() {
        root.limpiarFormularioTutor()

        root.datosSolicitudPreparada = ({})
        root.pasoAltaTutorActual = root.pasoTutor
        root.solicitudGenerada = false
    }

    function abrirAltaTutorDesdeMenu() {
        root.pasoAltaTutorActual = root.pasoTutor
        root.solicitudGenerada = false
        root.mensajeValidacionTutor = ""
        formTutor.limpiarErroresValidacion()
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

        mostrarIndicadorPasos: false

        pasoLabel: "PASO ACTUAL"
        pasoValor: root.pasoAltaTutorActual + " de 2"
        pasoDescripcion: root.headerDescription

        formularioSource: ""

        pasoActualFormulario: root.pasoAltaTutorActual
    }

    StepsTutor {
        id: stepsTutorHeader

        visible: !root.modoCompacto

        orientation: "horizontal"
        currentStep: root.pasoAltaTutorActual

        anchors.right: parent.right
        anchors.rightMargin: 96
        anchors.verticalCenter: homeHeader.verticalCenter

        horizontalCircleSize: 34
        horizontalStepWidth: 106
        horizontalLineWidth: 30
        horizontalStepHeight: 64

        margenIzquierdo: 0
        margenSuperior: 0

        z: 20
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
            id: formTutor

            x: root.formContentX
            y: 0

            width: root.formContentWidth
            height: areaForm.height

            camposX: root.formInnerX
            camposY: root.formInnerY

            edadAutomatica: root.edadAutomatica
            visible: root.pasoAltaTutorActual === root.pasoTutor

            onDatosCapturados: function(datos) {
                Logger.linea()
                Logger.bloque(
                    "SECTION TREE",
                    "datos recibidos de FormDestinatario usado como Tutor",
                    JSON.stringify(datos)
                )

                let resultadoValidacion = controladorAltas.validarTutor(datos)

                if (!resultadoValidacion.valido) {
                    formTutor.aplicarErroresValidacion(resultadoValidacion.errores)

                    root.mensajeValidacionTutor = resultadoValidacion.mensaje || ""
                    root.registrarErroresValidacion("VALIDACIÓN TUTOR", resultadoValidacion)
                    return
                }

                formTutor.limpiarErroresValidacion()

                root.mensajeValidacionTutor = ""
                root.datosTutorCapturados = datos
                root.datosCompletosCapturados = root.prepararDatosTutor(datos)

                Logger.bloque(
                    "SECTION TREE",
                    "datos completos de tutor preparados",
                    root.datosCompletosCapturados
                )

                root.datosSolicitudPreparada = controladorAltas.prepararDatosSolicitud(
                    root.datosCompletosCapturados
                )

                Logger.bloque(
                    "SECTION TREE",
                    "datos preparados para previsualización tutor",
                    root.datosSolicitudPreparada
                )

                root.pasoAltaTutorActual = root.pasoPrevisualizacion
            }
        }

        FormPrevisualizacion {
            id: formPrevisualizacion

            x: root.formContentX
            y: 0

            width: root.formContentWidth
            height: areaForm.height

            visible: root.pasoAltaTutorActual === root.pasoPrevisualizacion

            datosSolicitud: root.datosSolicitudPreparada

            onVolverSolicitado: {
                root.pasoAltaTutorActual = root.pasoTutor
            }

            onGenerarSolicitado: {
                Logger.bloque(
                    "SECTION TREE",
                    "datos enviados para generar solicitud de tutor",
                    root.datosCompletosCapturados
                )

                let resultado = controladorAltas.generarSolicitud(
                    root.datosCompletosCapturados
                )

                Logger.simple("SECTION TREE", "resultado Python", resultado)
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

            visible: root.pasoAltaTutorActual !== root.pasoTutor

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

            tipo: root.pasoAltaTutorActual === root.pasoPrevisualizacion
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
                root.reiniciarSolicitudTutor()
            }
        }
    }
}