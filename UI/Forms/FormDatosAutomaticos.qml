// UI / Forms / FormDatosAutomaticos.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import Components 1.0
import Theme 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 600
    height: 200
    color: "#FFFFFF"
    clip: true

    property bool edadAutomaticaActiva: false
    property bool fechaAutomaticaActiva: false

    property real camposX: 24
    property real camposY: 24

    property real espacioCampos: 20
    property real altoCampo: 78
    property real altoBotonera: 56

    readonly property bool modoCompacto: root.width < 760

    readonly property real contenidoAncho: Math.max(
        0,
        root.width - (root.camposX * 2)
    )

    readonly property real anchoCampoPrincipal: root.modoCompacto
        ? root.contenidoAncho
        : Math.min(380, root.contenidoAncho * 0.62)

    readonly property real anchoOpciones: root.modoCompacto
        ? root.contenidoAncho
        : Math.max(160, root.contenidoAncho - anchoCampoPrincipal - root.espacioCampos)

    signal configuracionAutomaticaCapturada(var datos)
    signal carpetaCopiaExternaCapturada(string ruta)
    signal carpetaCopiaExternaRestablecida()

    function obtenerFechaActual() {
        var fecha = new Date()
        var dia = fecha.getDate()
        var mes = fecha.getMonth() + 1
        var anio = fecha.getFullYear()

        if (dia < 10) {
            dia = "0" + dia
        }

        if (mes < 10) {
            mes = "0" + mes
        }

        return dia + "/" + mes + "/" + anio
    }

    function capturarConfiguracionAutomatica() {
        var datos = {
            fechaActual: inputFechaAutomatica.text,
            fechaAutomatica: fechaAutomaticaSi.checked,
            edadAutomatica: edadAutomaticaSi.checked
        }

        Logger.bloque(
            "FORM DATOS AUTOMÁTICOS",
            "configuración automática capturada",
            datos
        )

        root.configuracionAutomaticaCapturada(datos)
    }

    function cargarConfiguracionAutomatica(datos) {
        root.fechaAutomaticaActiva = datos.fechaAutomatica === true

        if (root.fechaAutomaticaActiva) {
            inputFechaAutomatica.text = root.obtenerFechaActual()
        } else {
            inputFechaAutomatica.text = datos.fechaActual || root.obtenerFechaActual()
        }

        fechaAutomaticaSi.checked = root.fechaAutomaticaActiva
        fechaAutomaticaNo.checked = !root.fechaAutomaticaActiva

        root.edadAutomaticaActiva = datos.edadAutomatica === true
        edadAutomaticaSi.checked = root.edadAutomaticaActiva
        edadAutomaticaNo.checked = !root.edadAutomaticaActiva
    }

    function cargarConfiguracionGuardado(datos) {
        var ruta = datos.carpetaCopiaExternaSolicitudes || ""

        inputUbicacionGuardado.text = ruta

        if (ruta === "") {
            textoEstadoGuardado.text = "No hay carpeta externa configurada. Las solicitudes se guardan solo dentro del sistema."
        } else {
            textoEstadoGuardado.text = "Carpeta externa configurada correctamente."
        }
    }

    function capturarCarpetaCopiaExterna() {
        var ruta = inputUbicacionGuardado.text.trim()

        if (ruta === "") {
            textoEstadoGuardado.text = "No se indicó ninguna carpeta externa."
            return
        }

        root.carpetaCopiaExternaCapturada(ruta)
    }

    ButtonGroup {
        id: grupoFechaAutomatica
    }

    ButtonGroup {
        id: grupoEdadAutomatica
    }

    FolderDialog {
        id: selectorCarpetaGuardado
        title: "Seleccionar carpeta externa para copia de solicitudes"

        onAccepted: {
            inputUbicacionGuardado.text = String(selectedFolder)
            root.carpetaCopiaExternaCapturada(String(selectedFolder))
        }
    }

    Flickable {
        id: scrollForm

        anchors.fill: parent
        clip: true

        contentWidth: width
        contentHeight: columFields.implicitHeight + root.camposY + 24

        Column {
            id: columFields

            width: root.contenidoAncho
            x: root.camposX
            y: root.camposY

            spacing: 14

            Text {
                text: "Configuración general"
                color: AppTheme.colorTextoPrincipal
                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 24
                font.bold: true
            }

            Text {
                text: "Definí los ajustes automáticos y la ubicación adicional de copia de las solicitudes."
                width: parent.width
                wrapMode: Text.WordWrap
                color: AppTheme.colorTextoSecundario
                font.family: AppTheme.fuenteCuerpo
                font.pixelSize: 13
            }

            // =====================================================
            // FECHA AUTOMÁTICA
            // =====================================================

            Flow {
                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldFecha

                    width: root.anchoCampoPrincipal
                    height: root.altoCampo

                    campoObligatorio: true

                    InputText {
                        id: inputFechaAutomatica

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        enabled: !root.fechaAutomaticaActiva
                        label: fieldFecha.labelConObligatorio("Fecha automática")
                        placeholder: "dd/mm/aaaa"
                        width: parent.width
                        opacity: root.fechaAutomaticaActiva ? 0.55 : 1.0
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Si está activa, usa la fecha actual\n- Si está desactivada, permite cargar una fecha manual"
                    }
                }

                Rectangle {
                    width: root.anchoOpciones
                    height: root.altoCampo
                    color: "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 18

                        RadioButton {
                            id: fechaAutomaticaSi
                            text: "Sí"
                            ButtonGroup.group: grupoFechaAutomatica

                            onClicked: {
                                root.fechaAutomaticaActiva = true
                                inputFechaAutomatica.text = root.obtenerFechaActual()
                            }
                        }

                        RadioButton {
                            id: fechaAutomaticaNo
                            text: "No"
                            ButtonGroup.group: grupoFechaAutomatica

                            onClicked: {
                                root.fechaAutomaticaActiva = false
                            }
                        }
                    }
                }
            }

            // =====================================================
            // EDAD AUTOMÁTICA
            // =====================================================

            Flow {
                width: parent.width
                spacing: root.espacioCampos

                FieldBox {
                    id: fieldEdad

                    width: root.anchoCampoPrincipal
                    height: root.altoCampo

                    campoObligatorio: true

                    InputText {
                        id: inputEdadAutomatica

                        anchors.fill: parent
                        anchors.rightMargin: 28

                        label: fieldEdad.labelConObligatorio("Edad automática")
                        placeholder: ""
                        width: parent.width
                        enabled: !root.edadAutomaticaActiva
                        opacity: root.edadAutomaticaActiva ? 0.55 : 1.0
                    }

                    FieldHelpIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        anchors.rightMargin: 2

                        mensaje: "- Si está activa, calcula la edad automáticamente\n- Si está desactivada, permite cargarla manualmente"
                    }
                }

                Rectangle {
                    width: root.anchoOpciones
                    height: root.altoCampo
                    color: "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 18

                        RadioButton {
                            id: edadAutomaticaSi
                            text: "Sí"
                            checked: true
                            ButtonGroup.group: grupoEdadAutomatica

                            onClicked: {
                                root.edadAutomaticaActiva = true
                            }
                        }

                        RadioButton {
                            id: edadAutomaticaNo
                            text: "No"
                            ButtonGroup.group: grupoEdadAutomatica

                            onClicked: {
                                root.edadAutomaticaActiva = false
                            }
                        }
                    }
                }
            }

            // =====================================================
            // CARPETA ADICIONAL DE GUARDADO
            // =====================================================

            Rectangle {
                id: bloqueGuardado

                width: parent.width
                height: root.modoCompacto ? 278 : 220

                radius: 12
                color: "#F9FAFB"
                border.color: "#E5E7EB"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        text: "Carpeta adicional de guardado"
                        color: AppTheme.colorTextoPrincipal
                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 17
                        font.bold: true
                    }

                    Text {
                        text: "Las solicitudes siempre se guardan dentro del sistema. Si seleccionás una carpeta adicional, también se guardará una copia allí."
                        width: parent.width
                        wrapMode: Text.WordWrap
                        color: AppTheme.colorTextoSecundario
                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 12
                    }

                    Flow {
                        width: parent.width
                        spacing: 10

                        FieldBox {
                            id: fieldUbicacionGuardado

                            width: root.modoCompacto
                                ? parent.width
                                : Math.max(320, parent.width - 200)

                            height: root.altoCampo
                            campoObligatorio: false

                            InputText {
                                id: inputUbicacionGuardado

                                anchors.fill: parent
                                anchors.rightMargin: 28

                                label: fieldUbicacionGuardado.labelConObligatorio("Ruta externa de copia")
                                placeholder: "Sin carpeta externa configurada"
                                width: parent.width
                            }

                            FieldHelpIcon {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 2
                                anchors.rightMargin: 2

                                mensaje: "- Carpeta opcional\n- Ejemplo: /home/usuario/Documentos\n- También podés seleccionarla con el botón"
                            }
                        }

                        Column {
                            width: root.modoCompacto ? parent.width : 180
                            spacing: 8

                            CustonButton2 {
                                id: buttonSeleccionarCarpeta

                                tipo: "custom"
                                textoCustom: "Seleccionar"
                                iconoCustom: ""
                                variante: "primary"

                                width: root.modoCompacto ? parent.width : 170
                                height: 34

                                onClicked: {
                                    selectorCarpetaGuardado.open()
                                }
                            }

                            CustonButton2 {
                                id: buttonRestablecerCarpeta

                                tipo: "custom"
                                textoCustom: "Restablecer"
                                iconoCustom: ""
                                variante: "secondary"

                                width: root.modoCompacto ? parent.width : 170
                                height: 34

                                onClicked: {
                                    inputUbicacionGuardado.text = ""
                                    textoEstadoGuardado.text = "No hay carpeta externa configurada. Las solicitudes se guardan solo dentro del sistema."
                                    root.carpetaCopiaExternaRestablecida()
                                }
                            }
                        }
                    }

                    Text {
                        id: textoEstadoGuardado

                        text: "No hay carpeta externa configurada. Las solicitudes se guardan solo dentro del sistema."
                        width: parent.width
                        wrapMode: Text.WordWrap
                        color: AppTheme.colorTextoSecundario
                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 12
                    }
                }
            }

            // =====================================================
            // BOTÓN GUARDAR
            // =====================================================

            Item {
                id: contenedorBotones

                width: parent.width
                height: root.altoBotonera

                CustonButton2 {
                    id: buttonGuardar

                    tipo: "custom"
                    textoCustom: "Guardar cambios"
                    iconoCustom: ""
                    variante: "primary"

                    width: 190
                    height: 46

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    onClicked: {
                        root.capturarConfiguracionAutomatica()
                        root.capturarCarpetaCopiaExterna()
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

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
