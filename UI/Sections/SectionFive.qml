// UI/Sections/SectionFive.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import Components 1.0
import Forms 1.0
import Structures 1.0
import Theme 1.0
import Layout 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 800
    height: 300
    color: "#FFFFFF"

    //***********************************************************
    //  PROPIEDADES PARA LÓGICA DEL FORMULARIO
    //***********************************************************

    property bool edadAutomaticaActual: false
    property bool fechaAutomaticaActual: true
    property string fechaActualConfigurada: ""

    property int configuracionActual: 1

    property var erroresConfiguracion: []
    property string tituloErroresConfiguracion: "Corregí la configuración:"
    property string origenErrorConfiguracion: ""

    signal edadAutomaticaCambiada(bool valor)
    signal fechaAutomaticaCambiada(bool valor)
    signal fechaActualCambiada(string valor)

    readonly property bool modoCompacto: root.width < 1030

    readonly property int areaFormY: homeHeader.height
    readonly property int areaFormHeight: Math.max(
        0,
        root.height - homeHeader.height
    )

    readonly property int areaContenidoX: settingsNav.width
    readonly property int areaContenidoWidth: Math.max(
        0,
        areaForm.width - settingsNav.width
    )

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

    function erroresDesdeResultadoConfiguracion(resultado) {
        var mensaje = root.mensajeDesdeResultado(resultado)

        if (mensaje === "") {
            return []
        }

        var separador = mensaje.indexOf(":")

        if (separador > 0) {
            var campo = mensaje.substring(0, separador).trim()
            var texto = mensaje.substring(separador + 1).trim()

            return [{
                campo: campo,
                mensaje: texto
            }]
        }

        return [mensaje]
    }

    function mostrarErrorConfiguracion(titulo, resultado, origen) {
        var errores = root.erroresDesdeResultadoConfiguracion(resultado)

        root.tituloErroresConfiguracion = titulo
        root.erroresConfiguracion = errores.length > 0 ? errores : ["No se pudo guardar la configuración."]
        root.origenErrorConfiguracion = origen || ""
    }

    function limpiarErroresConfiguracion() {
        root.erroresConfiguracion = []
        root.origenErrorConfiguracion = ""
    }

    function limpiarErroresConfiguracionSiCorresponde(origen) {
        if (root.origenErrorConfiguracion === "" || root.origenErrorConfiguracion === origen) {
            root.limpiarErroresConfiguracion()
        }
    }

    function procesarResultadoConfiguracion(tituloError, resultado, origen) {
        if (String(resultado || "").startsWith("ERROR|")) {
            root.mostrarErrorConfiguracion(tituloError, resultado, origen)
            return false
        }

        root.limpiarErroresConfiguracionSiCorresponde(origen || "")
        return true
    }

    HomeHeader {
        id: homeHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: AppLayout.formHeaderHeight

        titulo: "CONFIGURACIÓN"
        descripcion: "Seleccioná una acción para continuar."

        modoHeader: "home"
        iconoPersonaSource: ""
        formularioSource: "qrc:/qml/UI/Assets/config.png"
    }

    Rectangle {
        id: areaForm

        anchors.top: homeHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: "#FFFFFF"
        z: 1

        SettingsNav {
            id: settingsNav

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            selectedOption: root.configuracionActual

            sedeDisponible: true
            textoDisponible: false
            generalDisponible: true

            onOpcionSeleccionada: function(opcion) {
                root.configuracionActual = opcion
                root.limpiarErroresConfiguracion()
            }
        }

        Item {
            id: areaContenido

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: settingsNav.right
            anchors.right: parent.right

            clip: true

            ValidationMessageBox {
                id: validationBoxConfiguracion

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: root.modoCompacto ? 24 : 36
                anchors.rightMargin: root.modoCompacto ? 24 : 36
                anchors.topMargin: 18

                errores: root.erroresConfiguracion
                titulo: root.tituloErroresConfiguracion

                z: 10
            }

            FormSede {
                id: formFive

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: validationBoxConfiguracion.visible
                             ? validationBoxConfiguracion.bottom
                             : parent.top
                anchors.topMargin: validationBoxConfiguracion.visible ? 12 : 0

                visible: root.configuracionActual === 1

                Component.onCompleted: {
                    let configuracion = controladorConfiguracion.cargarConfiguracionSede()

                    Logger.linea()
                    formFive.cargarConfiguracion(configuracion)
                    Logger.simple("SECTION FIVE", "configuración cargada")
                    Logger.bloque(JSON.stringify(configuracion))
                }

                onConfiguracionSedeCapturada: function(datos) {
                    let resultado = controladorConfiguracion.guardarConfiguracionSede(datos)

                    Logger.linea()
                    Logger.simple(
                        "SECTION FIVE",
                        "resultado al guardar configuración de sede",
                        resultado
                    )

                    root.procesarResultadoConfiguracion(
                        "Corregí los datos de sede:",
                        resultado,
                        "sede"
                    )
                }
            }

            FormDatosAutomaticos {
                id: formSix

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: validationBoxConfiguracion.visible
                             ? validationBoxConfiguracion.bottom
                             : parent.top
                anchors.topMargin: validationBoxConfiguracion.visible ? 12 : 0

                visible: root.configuracionActual === 3
                color: "#FFFFFF"

                Component.onCompleted: {
                    let configuracionAutomatica = controladorConfiguracion.cargarConfiguracionAutomatica()

                    Logger.linea()
                    Logger.bloque(
                        "SECTION SIX",
                        "configuración automática cargada",
                        JSON.stringify(configuracionAutomatica)
                    )

                    formSix.cargarConfiguracionAutomatica(configuracionAutomatica)

                    root.edadAutomaticaActual = configuracionAutomatica.edadAutomatica
                    root.fechaAutomaticaActual = configuracionAutomatica.fechaAutomatica
                    root.fechaActualConfigurada = configuracionAutomatica.fechaActual || ""

                    root.edadAutomaticaCambiada(configuracionAutomatica.edadAutomatica)
                    root.fechaAutomaticaCambiada(configuracionAutomatica.fechaAutomatica)
                    root.fechaActualCambiada(configuracionAutomatica.fechaActual || "")

                    let configuracionGuardado = controladorConfiguracion.cargarConfiguracionGuardado()

                    Logger.linea()
                    Logger.bloque(
                        "SECTION SIX",
                        "configuración de guardado cargada",
                        JSON.stringify(configuracionGuardado)
                    )

                    formSix.cargarConfiguracionGuardado(configuracionGuardado)
                }

                onConfiguracionAutomaticaCapturada: function(datos) {
                    Logger.linea()
                    Logger.bloque(
                        "SECTION SIX",
                        "datos recibidos desde FormDatosAutomaticos:",
                        JSON.stringify(datos)
                    )

                    let resultado = controladorConfiguracion.guardarConfiguracionAutomatica(datos)

                    Logger.simple(
                        "SECTION SIX",
                        "configuración automática",
                        resultado
                    )

                    if (!root.procesarResultadoConfiguracion(
                        "Corregí la configuración automática:",
                        resultado,
                        "automatica"
                    )) {
                        if (formSix.aplicarErroresValidacion) {
                            formSix.aplicarErroresValidacion(
                                root.erroresDesdeResultadoConfiguracion(resultado)
                            )
                        }

                        return
                    }

                    if (formSix.limpiarErroresValidacion) {
                        formSix.limpiarErroresValidacion()
                    }

                    root.edadAutomaticaActual = datos.edadAutomatica
                    root.fechaAutomaticaActual = datos.fechaAutomatica
                    root.fechaActualConfigurada = datos.fechaActual || ""

                    root.edadAutomaticaCambiada(datos.edadAutomatica)
                    root.fechaAutomaticaCambiada(datos.fechaAutomatica)
                    root.fechaActualCambiada(datos.fechaActual || "")
                }

                onCarpetaCopiaExternaCapturada: function(ruta) {
                    Logger.linea()
                    Logger.simple(
                        "SECTION SIX",
                        "ruta externa recibida",
                        ruta
                    )

                    let resultado = controladorConfiguracion.guardarCarpetaCopiaExternaSolicitudes(ruta)

                    Logger.simple(
                        "SECTION SIX",
                        "configuración de guardado",
                        resultado
                    )

                    if (!root.procesarResultadoConfiguracion(
                        "Corregí la carpeta externa de guardado:",
                        resultado,
                        "guardado"
                    )) {
                        if (formSix.aplicarErroresValidacion) {
                            formSix.aplicarErroresValidacion([
                                {
                                    campo: "carpetaCopiaExternaSolicitudes",
                                    mensaje: root.mensajeDesdeResultado(resultado)
                                }
                            ])
                        }

                        return
                    }

                    if (formSix.limpiarErroresValidacion) {
                        formSix.limpiarErroresValidacion()
                    }

                    let configuracionGuardado = controladorConfiguracion.cargarConfiguracionGuardado()
                    formSix.cargarConfiguracionGuardado(configuracionGuardado)
                }

                onCarpetaCopiaExternaRestablecida: function() {
                    Logger.linea()

                    let resultado = controladorConfiguracion.restablecerCarpetaCopiaExternaSolicitudes()

                    Logger.simple(
                        "SECTION SIX",
                        "restablecer carpeta externa",
                        resultado
                    )

                    if (!root.procesarResultadoConfiguracion(
                        "No se pudo restablecer la carpeta externa:",
                        resultado,
                        "guardado"
                    )) {
                        return
                    }

                    let configuracionGuardado = controladorConfiguracion.cargarConfiguracionGuardado()
                    formSix.cargarConfiguracionGuardado(configuracionGuardado)
                }
            }
        }
    }
}
