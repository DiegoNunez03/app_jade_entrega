// UI / Forms / FormSede.qml

import QtQuick
import QtQuick.Controls

import Components 1.0
import Theme 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 600
    height: 420
    color: "transparent"
    clip: true

    signal configuracionSedeCapturada(var datos)

    // =====================================================
    // POSICIONAMIENTO INTERNO
    // Solo mueve los campos DENTRO del panel.
    // No separa el formulario del HomeHeader ni de SettingsNav.
    // =====================================================

    property real camposX: 24
    property real camposY: 24

    // =====================================================
    // MEDIDAS INTERNAS
    // =====================================================

    property real espacioCampos: 20
    property real altoCampo: 78
    property real altoBotonera: 56

    readonly property bool modoCompacto: root.width < 760

    readonly property real contenidoAncho: Math.max(
        0,
        panelSede.width - (root.camposX * 2)
    )

    readonly property real anchoCampo: root.modoCompacto
        ? root.contenidoAncho
        : (root.contenidoAncho - root.espacioCampos) / 2

    // =====================================================
    // FUNCIONES
    // =====================================================

    function capturarConfiguracionSede() {
        var datos = {
            nombreSede: inputNombreSede.text,
            origen: inputOrigen.text,
            municipio: inputMunicipio.text,
            localidad: inputLocalidad.text,
            barrio: inputBarrio.text
        }

        Logger.linea()
        Logger.bloque("FORM SEDE", "Configuración capturada:", JSON.stringify(datos))
        root.configuracionSedeCapturada(datos)
    }

    function cargarConfiguracion(datos) {
        inputNombreSede.text = datos.nombreSede || ""
        inputOrigen.text = datos.origen || ""
        inputMunicipio.text = datos.municipio || ""
        inputLocalidad.text = datos.localidad || ""
        inputBarrio.text = datos.barrio || ""
    }

    function limpiarCampos() {
        inputNombreSede.text = ""
        inputOrigen.text = ""
        inputMunicipio.text = ""
        inputLocalidad.text = ""
        inputBarrio.text = ""
    }

    // =====================================================
    // PANEL PRINCIPAL
    // Ocupa todo el espacio recibido desde SectionFive.
    // =====================================================

    Rectangle {
        id: panelSede

        anchors.fill: parent

        color: "#FFFFFF"

        Flickable {
            id: scrollFormSede

            anchors.fill: parent
            clip: true

            contentWidth: width
            contentHeight: contenido.implicitHeight + root.camposY

            Column {
                id: contenido

                x: root.camposX
                y: root.camposY

                width: root.contenidoAncho
                spacing: 20

                // =================================================
                // TÍTULO
                // =================================================

                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "Configuración de sede"

                        color: AppTheme.colorTextoPrincipal

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Text {
                        text: "Definí los datos generales que se usarán al generar las solicitudes."

                        width: parent.width
                        wrapMode: Text.WordWrap

                        color: AppTheme.colorTextoSecundario

                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 13
                    }
                }

                // =================================================
                // FORMULARIO RESPONSIVE
                // =================================================

                Flow {
                    id: camposFlow

                    width: parent.width
                    spacing: root.espacioCampos

                    FieldBox {
                        id: fieldNombreSede

                        width: root.anchoCampo
                        height: root.altoCampo

                        campoObligatorio: true

                        InputText {
                            id: inputNombreSede

                            anchors.fill: parent
                            anchors.rightMargin: 28

                            label: fieldNombreSede.labelConObligatorio("Nombre sede")
                            placeholder: "Villa Arias"
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
                        id: fieldOrigen

                        width: root.anchoCampo
                        height: root.altoCampo

                        campoObligatorio: true

                        InputText {
                            id: inputOrigen

                            anchors.fill: parent
                            anchors.rightMargin: 28

                            label: fieldOrigen.labelConObligatorio("Origen")
                            placeholder: "Envión"
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
                        id: fieldMunicipio

                        width: root.anchoCampo
                        height: root.altoCampo

                        campoObligatorio: true

                        InputText {
                            id: inputMunicipio

                            anchors.fill: parent
                            anchors.rightMargin: 28

                            label: fieldMunicipio.labelConObligatorio("Municipio")
                            placeholder: "Coronel Rosales"
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
                        id: fieldLocalidad

                        width: root.anchoCampo
                        height: root.altoCampo

                        campoObligatorio: true

                        InputText {
                            id: inputLocalidad

                            anchors.fill: parent
                            anchors.rightMargin: 28

                            label: fieldLocalidad.labelConObligatorio("Localidad")
                            placeholder: "Punta Alta"
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
                        id: fieldBarrio

                        width: root.modoCompacto ? root.anchoCampo : root.anchoCampo
                        height: root.altoCampo

                        campoObligatorio: false

                        InputText {
                            id: inputBarrio

                            anchors.fill: parent
                            anchors.rightMargin: 28

                            label: fieldBarrio.labelConObligatorio("Barrio")
                            placeholder: "Punta Alta"
                            width: parent.width
                        }

                        FieldHelpIcon {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 2
                            anchors.rightMargin: 2

                            mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios\n- Campo opcional"
                        }
                    }
                }

                // =================================================
                // BOTÓN GUARDAR
                // =================================================

                Item {
                    id: contenedorBotones

                    width: parent.width
                    height: root.altoBotonera

                    CustonButton2 {
                        id: buttonGuardarSede

                        tipo: "custom"
                        textoCustom: "Guardar cambios"
                        iconoCustom: ""
                        variante: "primary"

                        width: 190
                        height: 46

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        onClicked: {
                            root.capturarConfiguracionSede()
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 20
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }
    }

    // =====================================================
    // COMPONENTE INTERNO: CONTENEDOR BLANCO DE CAMPO
    // =====================================================

    component FieldBox: Rectangle {
        id: fieldBox

        property bool campoObligatorio: true

        function labelConObligatorio(texto) {
            return fieldBox.campoObligatorio ? texto + " *" : texto
        }

        radius: 10
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1

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

