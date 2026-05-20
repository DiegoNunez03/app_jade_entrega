// UI / Structures / SectionListaDestinatarios.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Components 1.0
import Theme 1.0
import Layout 1.0
import Structures 1.0


Rectangle {
    id: root

    color: "#FFFFFF"

    property string filtroActual: "todos"
    property string mensajeEstado: ""

    property string turnoPendienteGeneracion: ""
    property string tipoListaSeleccionada: "semanal"

    property int destinatarioSeleccionadoId: -1
    property string destinatarioSeleccionadoNombre: ""
    property string destinatarioSeleccionadoApellido: ""

    readonly property bool modoCompacto: root.width < 1030

    function cargarDestinatarios() {
        destinatariosModel.clear()

        var destinatarios = []

        if (root.filtroActual === "mañana") {
            destinatarios = controladorDestinatarios.listarDestinatariosPorTurno("mañana")
        } else if (root.filtroActual === "tarde") {
            destinatarios = controladorDestinatarios.listarDestinatariosPorTurno("tarde")
        } else {
            destinatarios = controladorDestinatarios.listarDestinatarios()
        }

        for (var i = 0; i < destinatarios.length; i++) {
            destinatariosModel.append({
                idDestinatario: destinatarios[i].id,
                nombre: destinatarios[i].nombre,
                apellido: destinatarios[i].apellido,
                turno: destinatarios[i].turno
            })
        }

        if (destinatariosModel.count === 0) {
            root.mensajeEstado = "No hay destinatarios registrados para el filtro seleccionado."
        } else {
            root.mensajeEstado = "Destinatarios encontrados: " + destinatariosModel.count
        }
    }

    function aplicarFiltro(filtro) {
        root.filtroActual = filtro
        root.cargarDestinatarios()
    }

    function abrirDialogoGeneracion(turno) {
        root.turnoPendienteGeneracion = turno
        root.tipoListaSeleccionada = "semanal"
        radioSemanal.checked = true
        radioMensual.checked = false
        dialogoTipoLista.open()
    }

    function generarListaSeleccionada() {
        var resultado = ""

        if (root.turnoPendienteGeneracion === "") {
            root.mensajeEstado = "ERROR|No se indicó el turno para generar la lista."
            return
        }

        if (root.tipoListaSeleccionada === "mensual") {
            resultado = controladorDestinatarios.generarListaMensualPorTurno(
                root.turnoPendienteGeneracion
            )
        } else {
            resultado = controladorDestinatarios.generarListaSemanalPorTurno(
                root.turnoPendienteGeneracion
            )
        }

        console.log(
            "[SECTION LISTA DESTINATARIOS] generar",
            root.tipoListaSeleccionada,
            root.turnoPendienteGeneracion,
            resultado
        )

        root.mensajeEstado = resultado
        root.turnoPendienteGeneracion = ""
    }

    function prepararEliminacion(idDestinatario, nombre, apellido) {
        root.destinatarioSeleccionadoId = idDestinatario
        root.destinatarioSeleccionadoNombre = nombre
        root.destinatarioSeleccionadoApellido = apellido
        dialogoConfirmarEliminacion.open()
    }

    function eliminarDestinatarioSeleccionado() {
        if (root.destinatarioSeleccionadoId < 0) {
            root.mensajeEstado = "ERROR|No se seleccionó ningún destinatario para eliminar."
            return
        }

        let resultado = controladorDestinatarios.eliminarDestinatario(
            root.destinatarioSeleccionadoId
        )

        console.log(
            "[SECTION LISTA DESTINATARIOS] eliminar destinatario:",
            root.destinatarioSeleccionadoId,
            resultado
        )

        root.mensajeEstado = resultado

        root.destinatarioSeleccionadoId = -1
        root.destinatarioSeleccionadoNombre = ""
        root.destinatarioSeleccionadoApellido = ""

        root.cargarDestinatarios()
    }

    Component.onCompleted: {
        root.cargarDestinatarios()
    }

    onVisibleChanged: {
        if (visible) {
            root.cargarDestinatarios()
        }
    }

    ButtonGroup {
        id: grupoFiltro
    }

    ButtonGroup {
        id: grupoTipoLista
    }

    ListModel {
        id: destinatariosModel
    }

    // =====================================================
    // DIÁLOGO: TIPO DE LISTA
    // =====================================================

    Dialog {
        id: dialogoTipoLista

        modal: true
        title: ""
        padding: 0

        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)

        width: 440
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: 18
            color: "#FFFFFF"
            border.color: "#E5E7EB"
            border.width: 1
        }

        contentItem: Rectangle {
            // width: 440
            // height: 550
            width: 440
            height: 360
            implicitWidth: 440
            implicitHeight: 360
            radius: 18
            color: "#FFFFFF"
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 30

                Row {
                    width: parent.width
                    height: 52
                    spacing: 10

                    Column {
                        width: parent.width - 62
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Text {
                            text: "Generar lista de asistencia"
                            color: AppTheme.colorTextoPrincipal
                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "Turno " + root.turnoPendienteGeneracion
                            color: AppTheme.colorTextoSecundario
                            font.family: AppTheme.fuenteCuerpo
                            font.pixelSize: 13
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#E5E7EB"
                }

                Text {
                    text: "Seleccioná el tipo de lista que querés generar."
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: AppTheme.colorTextoSecundario
                    font.family: AppTheme.fuenteCuerpo
                    font.pixelSize: 13
                }

                Row {
                    width: parent.width
                    height: 86
                    spacing: 12

                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 86
                        radius: 14

                        color: radioSemanal.checked ? "#F0E7FF" : "#F9FAFB"
                        border.color: radioSemanal.checked ? AppTheme.colorPrimario : "#E5E7EB"
                        border.width: radioSemanal.checked ? 2 : 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                radioSemanal.checked = true
                                root.tipoListaSeleccionada = "semanal"
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            RadioButton {
                                id: radioSemanal
                                text: ""
                                checked: true
                                ButtonGroup.group: grupoTipoLista
                                anchors.horizontalCenter: parent.horizontalCenter

                                onClicked: {
                                    root.tipoListaSeleccionada = "semanal"
                                }
                            }

                            Text {
                                text: "Semanal"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 14
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Semana actual"
                                color: AppTheme.colorTextoSecundario
                                font.family: AppTheme.fuenteCuerpo
                                font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 86
                        radius: 14

                        color: radioMensual.checked ? "#F0E7FF" : "#F9FAFB"
                        border.color: radioMensual.checked ? AppTheme.colorPrimario : "#E5E7EB"
                        border.width: radioMensual.checked ? 2 : 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                radioMensual.checked = true
                                root.tipoListaSeleccionada = "mensual"
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            RadioButton {
                                id: radioMensual
                                text: ""
                                ButtonGroup.group: grupoTipoLista
                                anchors.horizontalCenter: parent.horizontalCenter

                                onClicked: {
                                    root.tipoListaSeleccionada = "mensual"
                                }
                            }

                            Text {
                                text: "Mensual"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 14
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Mes actual"
                                color: AppTheme.colorTextoSecundario
                                font.family: AppTheme.fuenteCuerpo
                                font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                // Text {
                //     text: root.tipoListaSeleccionada === "mensual"
                //           ? "Se generará la lista mensual del mes actual para el turno seleccionado."
                //           : "Se generará la lista semanal de la semana actual para el turno seleccionado."

                //     width: parent.width
                //     wrapMode: Text.WordWrap
                //     color: AppTheme.colorTextoSecundario
                //     font.family: AppTheme.fuenteCuerpo
                //     font.pixelSize: 12
                // }

                Row {
                    width: parent.width
                    height: 42
                    spacing: 12

                    Item {
                        width: parent.width - 252
                        height: 1
                    }

                    Button {
                        width: 120
                        height: 38
                        text: "Cancelar"

                        onClicked: {
                            root.turnoPendienteGeneracion = ""
                            dialogoTipoLista.close()
                        }
                    }

                    Button {
                        width: 120
                        height: 38
                        text: "Generar"

                        onClicked: {
                            dialogoTipoLista.close()
                            root.generarListaSeleccionada()
                        }
                    }
                }
            }
        }
    }

    // =====================================================
    // DIÁLOGO: CONFIRMAR ELIMINACIÓN
    // =====================================================

    Dialog {
        id: dialogoConfirmarEliminacion

        modal: true
        title: "Confirmar eliminación"

        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)

        width: 460
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        standardButtons: Dialog.NoButton

        Rectangle {
            width: parent.width
            height: 210
            color: "#FFFFFF"

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 18

                Text {
                    text: "¿Seguro que querés eliminar este destinatario?"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: AppTheme.colorTextoPrincipal
                    font.family: AppTheme.fuenteCuerpo
                    font.pixelSize: 15
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 58
                    radius: 10
                    color: "#FEF2F2"
                    border.color: "#FCA5A5"
                    border.width: 1

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter

                        text: root.destinatarioSeleccionadoApellido + ", " + root.destinatarioSeleccionadoNombre
                        color: "#991B1B"
                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                    }
                }

                Text {
                    text: "Esta acción eliminará el registro del archivo interno de destinatarios."
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: AppTheme.colorTextoSecundario
                    font.family: AppTheme.fuenteCuerpo
                    font.pixelSize: 12
                }

                Row {
                    width: parent.width
                    height: 46
                    spacing: 12

                    Item {
                        width: 1
                        height: 1
                        Layout.fillWidth: true
                    }

                    Button {
                        width: 120
                        height: 38
                        text: "Cancelar"

                        onClicked: {
                            root.destinatarioSeleccionadoId = -1
                            root.destinatarioSeleccionadoNombre = ""
                            root.destinatarioSeleccionadoApellido = ""
                            dialogoConfirmarEliminacion.close()
                        }
                    }

                    Button {
                        width: 120
                        height: 38
                        text: "Eliminar"

                        onClicked: {
                            dialogoConfirmarEliminacion.close()
                            root.eliminarDestinatarioSeleccionado()
                        }
                    }
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerContainer

            width: parent.width
            height: AppLayout.formHeaderHeight
            color: AppTheme.colorSuperficieAlternativa
            clip: true

            HomeHeader {
                anchors.fill: parent

                modoHeader: "formulario"
                titulo: "LISTA DE DESTINATARIOS"
                descripcion: "Consultá los destinatarios registrados y filtrá la lista por turno."

                etiquetaSuperior: ""
                iconoPersonaSource: ""
                formularioSource: ""

                mostrarIndicadorPasos: false
                formularioHeaderLeftMargin: root.modoCompacto ? 80 : 160
                formularioHeaderRightMargin: root.modoCompacto ? 40 : 64
            }
        }

        Rectangle {
            id: contenido

            width: parent.width
            height: parent.height - headerContainer.height
            color: "#FFFFFF"

            Column {
                id: columnaPrincipal

                anchors.fill: parent
                anchors.margins: 32
                spacing: 18

                Row {
                    id: filaTitulo

                    width: parent.width
                    height: 52
                    spacing: 12

                    Text {
                        text: "Destinatarios registrados"
                        color: AppTheme.colorTextoPrincipal
                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 24
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: 1
                        height: 1
                        Layout.fillWidth: true
                    }

                    CustonButton2 {
                        id: botonActualizar
                        tipo: "custom"
                        textoCustom: "Actualizar"
                        iconoCustom: ""
                        variante: "secondary"
                        width: 150
                        height: 42
                        anchors.verticalCenter: parent.verticalCenter

                        onClicked: {
                            root.cargarDestinatarios()
                        }
                    }
                }

                Rectangle {
                    id: filtrosContainer

                    width: parent.width
                    height: root.modoCompacto ? 124 : 78
                    radius: 12
                    color: "#F9FAFB"
                    border.color: "#E5E7EB"
                    border.width: 1

                    // =================================================
                    // MODO AMPLIO
                    // =================================================

                    Row {
                        visible: !root.modoCompacto

                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        spacing: 24

                        Text {
                            text: "Filtro:"
                            color: AppTheme.colorTextoPrincipal
                            font.family: AppTheme.fuenteCuerpo
                            font.pixelSize: 14
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        RadioButton {
                            text: "Sin filtro"
                            checked: root.filtroActual === "todos"
                            ButtonGroup.group: grupoFiltro
                            anchors.verticalCenter: parent.verticalCenter

                            onClicked: {
                                root.aplicarFiltro("todos")
                            }
                        }

                        RadioButton {
                            text: "Turno mañana"
                            checked: root.filtroActual === "mañana"
                            ButtonGroup.group: grupoFiltro
                            anchors.verticalCenter: parent.verticalCenter

                            onClicked: {
                                root.aplicarFiltro("mañana")
                            }
                        }

                        RadioButton {
                            text: "Turno tarde"
                            checked: root.filtroActual === "tarde"
                            ButtonGroup.group: grupoFiltro
                            anchors.verticalCenter: parent.verticalCenter

                            onClicked: {
                                root.aplicarFiltro("tarde")
                            }
                        }

                        Item {
                            width: 1
                            height: 1
                            Layout.fillWidth: true
                        }

                        CustonButton2 {
                            tipo: "custom"
                            textoCustom: "Generar mañana"
                            iconoCustom: ""
                            variante: "primary"
                            width: 170
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            onClicked: {
                                root.abrirDialogoGeneracion("mañana")
                            }
                        }

                        CustonButton2 {
                            tipo: "custom"
                            textoCustom: "Generar tarde"
                            iconoCustom: ""
                            variante: "primary"
                            width: 160
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            onClicked: {
                                root.abrirDialogoGeneracion("tarde")
                            }
                        }
                    }

                    // =================================================
                    // MODO COMPACTO
                    // =================================================

                    Column {
                        visible: root.modoCompacto

                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        spacing: 8

                        Row {
                            width: parent.width
                            height: 42
                            spacing: 18

                            Text {
                                text: "Filtro:"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteCuerpo
                                font.pixelSize: 14
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            RadioButton {
                                text: "Sin filtro"
                                checked: root.filtroActual === "todos"
                                ButtonGroup.group: grupoFiltro
                                anchors.verticalCenter: parent.verticalCenter

                                onClicked: {
                                    root.aplicarFiltro("todos")
                                }
                            }

                            RadioButton {
                                text: "Mañana"
                                checked: root.filtroActual === "mañana"
                                ButtonGroup.group: grupoFiltro
                                anchors.verticalCenter: parent.verticalCenter

                                onClicked: {
                                    root.aplicarFiltro("mañana")
                                }
                            }

                            RadioButton {
                                text: "Tarde"
                                checked: root.filtroActual === "tarde"
                                ButtonGroup.group: grupoFiltro
                                anchors.verticalCenter: parent.verticalCenter

                                onClicked: {
                                    root.aplicarFiltro("tarde")
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            height: 42
                            spacing: 12

                            Item {
                                width: 1
                                height: 1
                                Layout.fillWidth: true
                            }

                            CustonButton2 {
                                tipo: "custom"
                                textoCustom: "Generar mañana"
                                iconoCustom: ""
                                variante: "primary"
                                width: 170
                                height: 40

                                onClicked: {
                                    root.abrirDialogoGeneracion("mañana")
                                }
                            }

                            CustonButton2 {
                                tipo: "custom"
                                textoCustom: "Generar tarde"
                                iconoCustom: ""
                                variante: "primary"
                                width: 160
                                height: 40

                                onClicked: {
                                    root.abrirDialogoGeneracion("tarde")
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: tabla

                    width: parent.width
                    height: Math.max(
                        220,
                        columnaPrincipal.height
                        - filaTitulo.height
                        - filtrosContainer.height
                        - (columnaPrincipal.spacing * 2)
                    )

                    radius: 14
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1
                    clip: true

                    Rectangle {
                        id: encabezadoTabla

                        width: parent.width
                        height: 46
                        color: "#F3F4F6"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18
                            spacing: 12

                            Text {
                                width: parent.width * 0.40
                                text: "Apellido"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                width: parent.width * 0.40
                                text: "Nombre"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                width: parent.width * 0.16
                                text: "Turno"
                                color: AppTheme.colorTextoPrincipal
                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Text {
                        visible: destinatariosModel.count === 0
                        anchors.centerIn: parent
                        text: "No hay destinatarios para mostrar."
                        color: AppTheme.colorTextoSecundario
                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 15
                    }

                    ListView {
                        id: listaDestinatarios

                        anchors.top: encabezadoTabla.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        clip: true
                        model: destinatariosModel
                        visible: destinatariosModel.count > 0

                        ScrollBar.vertical: ScrollBar {}

                        delegate: Rectangle {
                            id: filaDestinatario

                            width: listaDestinatarios.width
                            height: 56
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9FAFB"
                            border.color: "#EEF2F7"
                            border.width: 1

                            Menu {
                                id: menuContextualDestinatario

                                MenuItem {
                                    text: "Eliminar destinatario"

                                    onTriggered: {
                                        root.prepararEliminacion(
                                            model.idDestinatario,
                                            model.nombre,
                                            model.apellido
                                        )
                                    }
                                }
                            }

                            MouseArea {
                                id: areaClickDerecho

                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton

                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        menuContextualDestinatario.popup()
                                    }
                                }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 12

                                Text {
                                    width: parent.width * 0.40
                                    text: model.apellido
                                    color: AppTheme.colorTextoPrincipal
                                    font.family: AppTheme.fuenteCuerpo
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: parent.width * 0.40
                                    text: model.nombre
                                    color: AppTheme.colorTextoPrincipal
                                    font.family: AppTheme.fuenteCuerpo
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: parent.width * 0.16
                                    text: model.turno
                                    color: AppTheme.colorTextoSecundario
                                    font.family: AppTheme.fuenteCuerpo
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
