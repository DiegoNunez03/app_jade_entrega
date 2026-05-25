// UI/Structures/SectionFive.qml
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
            }
        }

        Item {
            id: areaContenido

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: settingsNav.right
            anchors.right: parent.right

            clip: true

            FormSede {
                id: formFive

                anchors.fill: parent

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
                        "resultado al guardar configuración automática",
                        resultado
                    )
                }
            }

            FormDatosAutomaticos {
                id: formSix

                anchors.fill: parent

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

                    let configuracionGuardado = controladorConfiguracion.cargarConfiguracionGuardado()
                    formSix.cargarConfiguracionGuardado(configuracionGuardado)
                }
            }
        }
    }
}
