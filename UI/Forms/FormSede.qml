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

    property var profesionales: ([])

    property string mensajeEstado: ""
    property bool hayErrorEstado: false

    // =====================================================
    // POSICIONAMIENTO INTERNO
    // =====================================================

    property real camposX: 24
    property real camposY: 24

    // =====================================================
    // MEDIDAS INTERNAS
    // =====================================================

    property real espacioCampos: 20
    property real altoCampo: 78
    property real altoCampoCombo: 78
    property real altoBotonera: 56
    property real altoBloqueProfesionales: root.modoCompacto ? 420 : 360
    property real altoBloqueCoordinadora: root.modoCompacto ? 300 : 210

    readonly property bool modoCompacto: root.width < 760

    readonly property real contenidoAncho: Math.max(
        0,
        panelSede.width - (root.camposX * 2)
    )

    readonly property real anchoCampo: root.modoCompacto
        ? root.contenidoAncho
        : (root.contenidoAncho - root.espacioCampos) / 2

    readonly property real anchoCampoProfesional: root.modoCompacto
        ? root.contenidoAncho - 32
        : (root.contenidoAncho - 32 - (root.espacioCampos * 2)) / 3

    // =====================================================
    // CATÁLOGO LOCAL DE ROLES
    // =====================================================

    property var rolesDisponibles: [
        {
            nombre: "Trabajadora social",
            siglas: "TS"
        },
        {
            nombre: "Psicóloga",
            siglas: "PSI"
        },
        {
            nombre: "Psicopedagoga",
            siglas: "PSP"
        },
        {
            nombre: "Profesor de educación física",
            siglas: "EFC"
        }
    ]

    property var nombresRolesDisponibles: [
        "Trabajadora social",
        "Psicóloga",
        "Psicopedagoga",
        "Profesor de educación física"
    ]

    // =====================================================
    // FUNCIONES - RESULTADOS
    // =====================================================

    function procesarResultado(resultado) {
        var texto = String(resultado || "")
        var partes = texto.split("|")
        var estado = partes.length > 0 ? partes[0] : ""
        var mensaje = partes.length > 1 ? partes.slice(1).join("|") : texto

        root.hayErrorEstado = estado === "ERROR"
        root.mensajeEstado = mensaje

        if (estado === "OK") {
            Logger.bloque(
                "FORM SEDE",
                "Resultado",
                "Datos enviados correctamente"
            )
        } else {
            Logger.bloque(
                "FORM SEDE",
                "Error",
                mensaje
            )
        }

        return estado === "OK"
    }

    function recargarConfiguracionDesdeControlador() {
        var datos = controladorConfiguracion.cargarConfiguracionSede()
        root.cargarConfiguracion(datos)
    }

    // =====================================================
    // FUNCIONES - ROLES
    // =====================================================

    function obtenerRol(nombreRol) {
        for (var i = 0; i < root.rolesDisponibles.length; i++) {
            if (root.rolesDisponibles[i].nombre === nombreRol) {
                return {
                    nombre: root.rolesDisponibles[i].nombre,
                    siglas: root.rolesDisponibles[i].siglas
                }
            }
        }

        return {
            nombre: "",
            siglas: ""
        }
    }

    function indiceRol(nombreRol) {
        for (var i = 0; i < root.nombresRolesDisponibles.length; i++) {
            if (root.nombresRolesDisponibles[i] === nombreRol) {
                return i
            }
        }

        return 0
    }

    // =====================================================
    // FUNCIONES - PROFESIONALES
    // =====================================================

    function textoProfesional(profesional) {
        if (!profesional) {
            return ""
        }

        var nombre = String(profesional.nombre || "").trim()
        var apellido = String(profesional.apellido || "").trim()
        var siglas = profesional.rol ? String(profesional.rol.siglas || "").trim() : ""

        if (siglas !== "") {
            return apellido + " " + nombre + " - " + siglas
        }

        return apellido + " " + nombre
    }

    function agregarProfesional() {
        var profesional = {
            nombre: inputNombreProfesional.text,
            apellido: inputApellidoProfesional.text,
            rol: root.obtenerRol(comboRolProfesional.currentText)
        }

        var resultado = controladorConfiguracion.agregarProfesional(profesional)

        if (root.procesarResultado(resultado)) {
            inputNombreProfesional.text = ""
            inputApellidoProfesional.text = ""
            comboRolProfesional.currentIndex = 0

            root.recargarConfiguracionDesdeControlador()
        }
    }

    function eliminarProfesional(indice) {
        var resultado = controladorConfiguracion.eliminarProfesional(indice)

        if (root.procesarResultado(resultado)) {
            root.recargarConfiguracionDesdeControlador()
        }
    }

    // =====================================================
    // FUNCIONES - GUARDADO POR SECCIÓN
    // =====================================================

    function guardarDatosSede() {
        var datos = {
            origen: inputOrigen.text,
            nombre_sede: inputNombreSede.text,
            ubicacion: {
                municipio: inputMunicipio.text,
                localidad: inputLocalidad.text,
                barrio: inputBarrio.text
            }
        }

        Logger.linea()
        Logger.bloque(
            "FORM SEDE",
            "Guardar datos de sede",
            "Datos enviados correctamente"
        )

        var resultado = controladorConfiguracion.guardarDatosSede(datos)

        if (root.procesarResultado(resultado)) {
            root.recargarConfiguracionDesdeControlador()
        }
    }

    function guardarCoordinador() {
        var coordinador = {
            nombre: inputNombreCoordinadora.text,
            apellido: inputApellidoCoordinadora.text,
            rol: root.obtenerRol(comboRolCoordinadora.currentText)
        }

        Logger.linea()
        Logger.bloque(
            "FORM SEDE",
            "Guardar coordinadora",
            "Datos enviados correctamente"
        )

        var resultado = controladorConfiguracion.guardarCoordinador(coordinador)

        if (root.procesarResultado(resultado)) {
            root.recargarConfiguracionDesdeControlador()
        }
    }

    // =====================================================
    // FUNCIONES - COMPATIBILIDAD / CARGA
    // =====================================================

    function capturarConfiguracionSede() {
        root.guardarDatosSede()
    }

    function cargarConfiguracion(datos) {
        inputNombreSede.text = datos.nombre_sede || ""
        inputOrigen.text = datos.origen || ""

        var ubicacion = datos.ubicacion || {}

        inputMunicipio.text = ubicacion.municipio || ""
        inputLocalidad.text = ubicacion.localidad || ""
        inputBarrio.text = ubicacion.barrio || ""

        var coordinador = datos.coordinador || {}
        var rolCoordinador = coordinador.rol || {}

        inputNombreCoordinadora.text = coordinador.nombre || ""
        inputApellidoCoordinadora.text = coordinador.apellido || ""
        comboRolCoordinadora.currentIndex = root.indiceRol(rolCoordinador.nombre || "")

        root.profesionales = datos.profesionales || []

        inputNombreProfesional.text = ""
        inputApellidoProfesional.text = ""
        comboRolProfesional.currentIndex = 0

        Logger.bloque(
            "FORM SEDE",
            "Configuración cargada",
            "Datos recibidos correctamente"
        )
    }

    function limpiarCampos() {
        inputNombreSede.text = ""
        inputOrigen.text = ""
        inputMunicipio.text = ""
        inputLocalidad.text = ""
        inputBarrio.text = ""

        inputNombreCoordinadora.text = ""
        inputApellidoCoordinadora.text = ""
        comboRolCoordinadora.currentIndex = 0

        inputNombreProfesional.text = ""
        inputApellidoProfesional.text = ""
        comboRolProfesional.currentIndex = 0

        root.profesionales = []
        root.mensajeEstado = ""
        root.hayErrorEstado = false
    }

    // =====================================================
    // PANEL PRINCIPAL
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
            contentHeight: contenido.implicitHeight + root.camposY + 24

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
                // MENSAJE DE ESTADO
                // =================================================

                // Rectangle {
                //     width: parent.width
                //     height: root.mensajeEstado === "" ? 0 : Math.max(44, mensajeEstadoTexto.implicitHeight + 20)

                //     visible: root.mensajeEstado !== ""

                //     radius: 10
                //     color: root.hayErrorEstado ? "#FEF2F2" : "#F0FDF4"
                //     border.color: root.hayErrorEstado ? "#FCA5A5" : "#86EFAC"
                //     border.width: 1

                //     Text {
                //         id: mensajeEstadoTexto

                //         anchors.fill: parent
                //         anchors.leftMargin: 12
                //         anchors.rightMargin: 12
                //         anchors.topMargin: 8
                //         anchors.bottomMargin: 8

                //         text: root.mensajeEstado

                //         wrapMode: Text.WordWrap
                //         verticalAlignment: Text.AlignVCenter

                //         color: root.hayErrorEstado ? "#991B1B" : "#166534"

                //         font.family: AppTheme.fuenteCuerpo
                //         font.pixelSize: 13
                //     }
                // }

                // =================================================
// MENSAJE DE ESTADO
// =================================================

Rectangle {
    width: parent.width
    height: root.mensajeEstado === "" ? 0 : mensajeEstadoTexto.height + 20

    visible: root.mensajeEstado !== ""

    radius: 10
    color: root.hayErrorEstado ? "#FEF2F2" : "#F0FDF4"
    border.color: root.hayErrorEstado ? "#FCA5A5" : "#86EFAC"
    border.width: 1

    Text {
        id: mensajeEstadoTexto

        x: 12
        y: 8

        width: parent.width - 24
        height: implicitHeight

        text: root.mensajeEstado

        wrapMode: Text.WordWrap

        color: root.hayErrorEstado ? "#991B1B" : "#166534"

        font.family: AppTheme.fuenteCuerpo
        font.pixelSize: 13
    }
}

                // =================================================
                // SECCIÓN 1 - DATOS DE SEDE / UBICACIÓN
                // =================================================

                Rectangle {
                    id: bloqueDatosSede

                    width: parent.width
                    height: root.modoCompacto ? 560 : 330

                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E8E0FF"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        spacing: 14

                        Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "Datos de sede y ubicación"

                                color: AppTheme.colorPrimario

                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 16
                                font.bold: true
                            }

                            FieldHelpIcon {
                                anchors.verticalCenter: parent.verticalCenter

                                mensaje: "- Estos datos se usan en solicitudes de alta y baja\n- El barrio es opcional"
                            }
                        }

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

                                width: root.anchoCampo
                                height: root.altoCampo

                                campoObligatorio: false

                                InputText {
                                    id: inputBarrio

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldBarrio.labelConObligatorio("Barrio")
                                    placeholder: "Barrio"
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

                        CustonButton2 {
                            id: buttonGuardarDatosSede

                            tipo: "custom"
                            textoCustom: "Guardar cambios"
                            iconoCustom: ""
                            variante: "primary"

                            width: 190
                            height: 46

                            onClicked: {
                                root.guardarDatosSede()
                            }
                        }
                    }
                }

                // =================================================
                // SECCIÓN 2 - PROFESIONALES INTERVINIENTES
                // =================================================

                Rectangle {
                    id: bloqueProfesionales

                    width: parent.width
                    height: root.altoBloqueProfesionales

                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E8E0FF"
                    border.width: 1

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
                                text: "Profesionales intervinientes"

                                color: AppTheme.colorPrimario

                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 16
                                font.bold: true
                            }

                            FieldHelpIcon {
                                anchors.verticalCenter: parent.verticalCenter

                                mensaje: "- Cargá profesionales disponibles para bajas\n- Luego se seleccionarán desde el formulario de baja\n- Cada profesional puede eliminarse con la X"
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: root.espacioCampos

                            FieldBox {
                                id: fieldNombreProfesional

                                width: root.anchoCampoProfesional
                                height: root.altoCampo

                                campoObligatorio: true

                                InputText {
                                    id: inputNombreProfesional

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldNombreProfesional.labelConObligatorio("Nombre")
                                    placeholder: "Laura"
                                    width: parent.width
                                }
                            }

                            FieldBox {
                                id: fieldApellidoProfesional

                                width: root.anchoCampoProfesional
                                height: root.altoCampo

                                campoObligatorio: true

                                InputText {
                                    id: inputApellidoProfesional

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldApellidoProfesional.labelConObligatorio("Apellido")
                                    placeholder: "Gómez"
                                    width: parent.width
                                }
                            }

                            FieldBox {
                                id: fieldRolProfesional

                                width: root.anchoCampoProfesional
                                height: root.altoCampoCombo

                                campoObligatorio: true

                                Column {
                                    anchors.fill: parent
                                    spacing: 6

                                    Text {
                                        text: fieldRolProfesional.labelConObligatorio("Rol")
                                        color: AppTheme.colorTextoSecundario
                                        font.family: AppTheme.fuenteCuerpo
                                        font.pixelSize: 12
                                    }

                                    ComboBox {
                                        id: comboRolProfesional

                                        width: parent.width
                                        height: 36

                                        model: root.nombresRolesDisponibles
                                    }
                                }
                            }
                        }

                        Button {
                            id: buttonAgregarProfesional

                            width: 112
                            height: 40

                            text: "Agregar"

                            onClicked: {
                                root.agregarProfesional()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 110
                            radius: 8

                            color: "#FAFAFA"
                            border.color: "#E5E7EB"
                            border.width: 1

                            clip: true

                            Text {
                                anchors.centerIn: parent

                                visible: root.profesionales.length === 0

                                text: "No hay profesionales cargados."

                                color: AppTheme.colorTextoSecundario

                                font.family: AppTheme.fuenteCuerpo
                                font.pixelSize: 13
                            }

                            ListView {
                                id: listaProfesionales

                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                anchors.topMargin: 6
                                anchors.bottomMargin: 6

                                visible: root.profesionales.length > 0

                                model: root.profesionales
                                spacing: 6
                                clip: true

                                delegate: Rectangle {
                                    width: listaProfesionales.width
                                    height: 30
                                    radius: 6

                                    color: "#FFFFFF"
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 6

                                        spacing: 8

                                        Text {
                                            width: parent.width - botonEliminar.width - 18
                                            height: parent.height

                                            verticalAlignment: Text.AlignVCenter

                                            text: root.textoProfesional(modelData)

                                            color: AppTheme.colorTextoPrincipal

                                            font.family: AppTheme.fuenteCuerpo
                                            font.pixelSize: 13
                                            font.bold: true

                                            elide: Text.ElideRight
                                        }

                                        Button {
                                            id: botonEliminar

                                            width: 26
                                            height: 24

                                            anchors.verticalCenter: parent.verticalCenter

                                            text: "×"

                                            onClicked: {
                                                root.eliminarProfesional(index)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // =================================================
                // SECCIÓN 3 - COORDINADORA
                // =================================================

                Rectangle {
                    id: bloqueCoordinadora

                    width: parent.width
                    height: root.altoBloqueCoordinadora

                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E8E0FF"
                    border.width: 1

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
                                text: "Coordinadora"

                                color: AppTheme.colorPrimario

                                font.family: AppTheme.fuenteTitulo
                                font.pixelSize: 16
                                font.bold: true
                            }

                            FieldHelpIcon {
                                anchors.verticalCenter: parent.verticalCenter

                                mensaje: "- Cargá nombre, apellido y rol profesional\n- El rol usa las mismas opciones que profesionales"
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: root.espacioCampos

                            FieldBox {
                                id: fieldNombreCoordinadora

                                width: root.anchoCampoProfesional
                                height: root.altoCampo

                                campoObligatorio: true

                                InputText {
                                    id: inputNombreCoordinadora

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldNombreCoordinadora.labelConObligatorio("Nombre")
                                    placeholder: "Candela"
                                    width: parent.width
                                }
                            }

                            FieldBox {
                                id: fieldApellidoCoordinadora

                                width: root.anchoCampoProfesional
                                height: root.altoCampo

                                campoObligatorio: true

                                InputText {
                                    id: inputApellidoCoordinadora

                                    anchors.fill: parent
                                    anchors.rightMargin: 28

                                    label: fieldApellidoCoordinadora.labelConObligatorio("Apellido")
                                    placeholder: "Rossi"
                                    width: parent.width
                                }
                            }

                            FieldBox {
                                id: fieldRolCoordinadora

                                width: root.anchoCampoProfesional
                                height: root.altoCampoCombo

                                campoObligatorio: true

                                Column {
                                    anchors.fill: parent
                                    spacing: 6

                                    Text {
                                        text: fieldRolCoordinadora.labelConObligatorio("Rol")
                                        color: AppTheme.colorTextoSecundario
                                        font.family: AppTheme.fuenteCuerpo
                                        font.pixelSize: 12
                                    }

                                    ComboBox {
                                        id: comboRolCoordinadora

                                        width: parent.width
                                        height: 36

                                        model: root.nombresRolesDisponibles
                                    }
                                }
                            }
                        }

                        Button {
                            id: buttonGuardarCoordinadora

                            width: 180
                            height: 40

                            text: "Guardar coordinadora"

                            onClicked: {
                                root.guardarCoordinador()
                            }
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




// // UI / Forms / FormSede.qml

// import QtQuick
// import QtQuick.Controls

// import Components 1.0
// import Theme 1.0

// import "../Utils/Logger.js" as Logger


// Rectangle {
//     id: root

//     width: 600
//     height: 420
//     color: "transparent"
//     clip: true

//     signal configuracionSedeCapturada(var datos)

//     property var profesionales: ([])

//     // =====================================================
//     // POSICIONAMIENTO INTERNO
//     // =====================================================

//     property real camposX: 24
//     property real camposY: 24

//     // =====================================================
//     // MEDIDAS INTERNAS
//     // =====================================================

//     property real espacioCampos: 20
//     property real altoCampo: 78
//     property real altoCampoCombo: 78
//     property real altoBotonera: 56
//     property real altoBloqueProfesionales: root.modoCompacto ? 330 : 288

//     readonly property bool modoCompacto: root.width < 760

//     readonly property real contenidoAncho: Math.max(
//         0,
//         panelSede.width - (root.camposX * 2)
//     )

//     readonly property real anchoCampo: root.modoCompacto
//         ? root.contenidoAncho
//         : (root.contenidoAncho - root.espacioCampos) / 2

//     readonly property real anchoCampoProfesional: root.modoCompacto
//         ? root.contenidoAncho - 32
//         : (root.contenidoAncho - 32 - (root.espacioCampos * 2)) / 3

//     // =====================================================
//     // CATÁLOGO LOCAL DE ROLES
//     // =====================================================

//     property var rolesDisponibles: [
//         {
//             nombre: "Trabajadora social",
//             siglas: "TS"
//         },
//         {
//             nombre: "Psicóloga",
//             siglas: "PSI"
//         },
//         {
//             nombre: "Psicopedagoga",
//             siglas: "PSP"
//         },
//         {
//             nombre: "Profesor de educación física",
//             siglas: "EFC"
//         }
//     ]

//     property var nombresRolesDisponibles: [
//         "Trabajadora social",
//         "Psicóloga",
//         "Psicopedagoga",
//         "Profesor de educación física"
//     ]

//     // =====================================================
//     // FUNCIONES - ROLES
//     // =====================================================

//     function obtenerRol(nombreRol) {
//         for (var i = 0; i < root.rolesDisponibles.length; i++) {
//             if (root.rolesDisponibles[i].nombre === nombreRol) {
//                 return {
//                     nombre: root.rolesDisponibles[i].nombre,
//                     siglas: root.rolesDisponibles[i].siglas
//                 }
//             }
//         }

//         return {
//             nombre: "",
//             siglas: ""
//         }
//     }

//     function indiceRol(nombreRol) {
//         for (var i = 0; i < root.nombresRolesDisponibles.length; i++) {
//             if (root.nombresRolesDisponibles[i] === nombreRol) {
//                 return i
//             }
//         }

//         return 0
//     }

//     // =====================================================
//     // FUNCIONES - PROFESIONALES
//     // =====================================================

//     function claveProfesional(profesional) {
//         if (!profesional) {
//             return ""
//         }

//         return (
//             String(profesional.nombre || "").trim().toLowerCase()
//             + "|"
//             + String(profesional.apellido || "").trim().toLowerCase()
//             + "|"
//             + String(profesional.rol ? profesional.rol.nombre : "").trim().toLowerCase()
//         )
//     }

//     function textoProfesional(profesional) {
//         if (!profesional) {
//             return ""
//         }

//         var nombre = String(profesional.nombre || "").trim()
//         var apellido = String(profesional.apellido || "").trim()
//         var siglas = profesional.rol ? String(profesional.rol.siglas || "").trim() : ""

//         if (siglas !== "") {
//             return apellido + " " + nombre + " - " + siglas
//         }

//         return apellido + " " + nombre
//     }

//     function textoProfesionales() {
//         if (!root.profesionales || root.profesionales.length === 0) {
//             return ""
//         }

//         var textos = []

//         for (var i = 0; i < root.profesionales.length; i++) {
//             textos.push(root.textoProfesional(root.profesionales[i]))
//         }

//         return textos.join(" / ")
//     }

//     function agregarProfesional() {
//         var nombre = inputNombreProfesional.text.trim()
//         var apellido = inputApellidoProfesional.text.trim()
//         var rol = root.obtenerRol(comboRolProfesional.currentText)

//         if (nombre === "" && apellido === "") {
//             return
//         }

//         var profesional = {
//             nombre: nombre,
//             apellido: apellido,
//             rol: rol
//         }

//         var nuevaLista = []
//         var claveNueva = root.claveProfesional(profesional)
//         var existe = false

//         for (var i = 0; i < root.profesionales.length; i++) {
//             nuevaLista.push(root.profesionales[i])

//             if (root.claveProfesional(root.profesionales[i]) === claveNueva) {
//                 existe = true
//             }
//         }

//         if (!existe) {
//             nuevaLista.push(profesional)
//         }

//         root.profesionales = nuevaLista

//         inputNombreProfesional.text = ""
//         inputApellidoProfesional.text = ""
//         comboRolProfesional.currentIndex = 0

//         Logger.bloque(
//             "FORM SEDE",
//             "Profesional agregado",
//             "Datos recibidos correctamente"
//         )
//     }

//     function limpiarProfesionales() {
//         root.profesionales = []
//         inputNombreProfesional.text = ""
//         inputApellidoProfesional.text = ""
//         comboRolProfesional.currentIndex = 0
//     }

//     // =====================================================
//     // FUNCIONES - CAPTURA / CARGA
//     // =====================================================

//     function capturarConfiguracionSede() {
//         if (
//             inputNombreProfesional.text.trim() !== ""
//             || inputApellidoProfesional.text.trim() !== ""
//         ) {
//             root.agregarProfesional()
//         }

//         var datos = {
//             origen: inputOrigen.text,
//             nombre_sede: inputNombreSede.text,
//             ubicacion: {
//                 municipio: inputMunicipio.text,
//                 localidad: inputLocalidad.text,
//                 barrio: inputBarrio.text
//             },
//             coordinador: {
//                 nombre: inputNombreCoordinadora.text,
//                 apellido: inputApellidoCoordinadora.text,
//                 rol: root.obtenerRol(comboRolCoordinadora.currentText)
//             },
//             profesionales: root.profesionales
//         }

//         Logger.linea()
//         Logger.bloque(
//             "FORM SEDE",
//             "Configuración capturada",
//             "Datos enviados correctamente"
//         )

//         root.configuracionSedeCapturada(datos)
//     }

//     function cargarConfiguracion(datos) {
//         inputNombreSede.text = datos.nombre_sede || ""
//         inputOrigen.text = datos.origen || ""

//         var ubicacion = datos.ubicacion || {}

//         inputMunicipio.text = ubicacion.municipio || ""
//         inputLocalidad.text = ubicacion.localidad || ""
//         inputBarrio.text = ubicacion.barrio || ""

//         var coordinador = datos.coordinador || {}
//         var rolCoordinador = coordinador.rol || {}

//         inputNombreCoordinadora.text = coordinador.nombre || ""
//         inputApellidoCoordinadora.text = coordinador.apellido || ""
//         comboRolCoordinadora.currentIndex = root.indiceRol(rolCoordinador.nombre || "")

//         root.profesionales = datos.profesionales || []

//         inputNombreProfesional.text = ""
//         inputApellidoProfesional.text = ""
//         comboRolProfesional.currentIndex = 0

//         Logger.bloque(
//             "FORM SEDE",
//             "Configuración cargada",
//             "Datos recibidos correctamente"
//         )
//     }

//     function limpiarCampos() {
//         inputNombreSede.text = ""
//         inputOrigen.text = ""
//         inputMunicipio.text = ""
//         inputLocalidad.text = ""
//         inputBarrio.text = ""

//         inputNombreCoordinadora.text = ""
//         inputApellidoCoordinadora.text = ""
//         comboRolCoordinadora.currentIndex = 0

//         root.limpiarProfesionales()
//     }

//     // =====================================================
//     // PANEL PRINCIPAL
//     // =====================================================

//     Rectangle {
//         id: panelSede

//         anchors.fill: parent

//         color: "#FFFFFF"

//         Flickable {
//             id: scrollFormSede

//             anchors.fill: parent
//             clip: true

//             contentWidth: width
//             contentHeight: contenido.implicitHeight + root.camposY + 24

//             Column {
//                 id: contenido

//                 x: root.camposX
//                 y: root.camposY

//                 width: root.contenidoAncho
//                 spacing: 20

//                 // =================================================
//                 // TÍTULO
//                 // =================================================

//                 Column {
//                     width: parent.width
//                     spacing: 4

//                     Text {
//                         text: "Configuración de sede"

//                         color: AppTheme.colorTextoPrincipal

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 24
//                         font.bold: true
//                     }

//                     Text {
//                         text: "Definí los datos generales que se usarán al generar las solicitudes."

//                         width: parent.width
//                         wrapMode: Text.WordWrap

//                         color: AppTheme.colorTextoSecundario

//                         font.family: AppTheme.fuenteCuerpo
//                         font.pixelSize: 13
//                     }
//                 }

//                 // =================================================
//                 // DATOS GENERALES
//                 // =================================================

//                 Flow {
//                     id: camposFlow

//                     width: parent.width
//                     spacing: root.espacioCampos

//                     FieldBox {
//                         id: fieldNombreSede

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputNombreSede

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldNombreSede.labelConObligatorio("Nombre sede")
//                             placeholder: "Villa Arias"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldOrigen

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputOrigen

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldOrigen.labelConObligatorio("Origen")
//                             placeholder: "Envión"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldMunicipio

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputMunicipio

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldMunicipio.labelConObligatorio("Municipio")
//                             placeholder: "Coronel Rosales"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldLocalidad

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputLocalidad

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldLocalidad.labelConObligatorio("Localidad")
//                             placeholder: "Punta Alta"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldBarrio

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: false

//                         InputText {
//                             id: inputBarrio

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldBarrio.labelConObligatorio("Barrio")
//                             placeholder: "Barrio"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios\n- Campo opcional"
//                         }
//                     }
//                 }

//                 // =================================================
//                 // COORDINADORA
//                 // =================================================

//                 Rectangle {
//                     id: bloqueCoordinadora

//                     width: parent.width
//                     height: root.modoCompacto ? 300 : 150

//                     radius: 12
//                     color: "#FFFFFF"
//                     border.color: "#E8E0FF"
//                     border.width: 1

//                     Column {
//                         anchors.fill: parent
//                         anchors.leftMargin: 16
//                         anchors.rightMargin: 16
//                         anchors.topMargin: 10
//                         anchors.bottomMargin: 10

//                         spacing: 10

//                         Row {
//                             width: parent.width
//                             spacing: 10

//                             Text {
//                                 text: "Coordinadora"

//                                 color: AppTheme.colorPrimario

//                                 font.family: AppTheme.fuenteTitulo
//                                 font.pixelSize: 16
//                                 font.bold: true
//                             }

//                             FieldHelpIcon {
//                                 anchors.verticalCenter: parent.verticalCenter

//                                 mensaje: "- Cargá nombre, apellido y rol profesional\n- El rol usa las mismas opciones que profesionales"
//                             }
//                         }

//                         Flow {
//                             width: parent.width
//                             spacing: root.espacioCampos

//                             FieldBox {
//                                 id: fieldNombreCoordinadora

//                                 width: root.anchoCampoProfesional
//                                 height: root.altoCampo

//                                 campoObligatorio: true

//                                 InputText {
//                                     id: inputNombreCoordinadora

//                                     anchors.fill: parent
//                                     anchors.rightMargin: 28

//                                     label: fieldNombreCoordinadora.labelConObligatorio("Nombre")
//                                     placeholder: "Candela"
//                                     width: parent.width
//                                 }
//                             }

//                             FieldBox {
//                                 id: fieldApellidoCoordinadora

//                                 width: root.anchoCampoProfesional
//                                 height: root.altoCampo

//                                 campoObligatorio: true

//                                 InputText {
//                                     id: inputApellidoCoordinadora

//                                     anchors.fill: parent
//                                     anchors.rightMargin: 28

//                                     label: fieldApellidoCoordinadora.labelConObligatorio("Apellido")
//                                     placeholder: "Rossi"
//                                     width: parent.width
//                                 }
//                             }

//                             FieldBox {
//                                 id: fieldRolCoordinadora

//                                 width: root.anchoCampoProfesional
//                                 height: root.altoCampoCombo

//                                 campoObligatorio: true

//                                 Column {
//                                     anchors.fill: parent
//                                     spacing: 6

//                                     Text {
//                                         text: fieldRolCoordinadora.labelConObligatorio("Rol")
//                                         color: AppTheme.colorTextoSecundario
//                                         font.family: AppTheme.fuenteCuerpo
//                                         font.pixelSize: 12
//                                     }

//                                     ComboBox {
//                                         id: comboRolCoordinadora

//                                         width: parent.width
//                                         height: 36

//                                         model: root.nombresRolesDisponibles
//                                     }
//                                 }
//                             }
//                         }
//                     }
//                 }

//                 // =================================================
//                 // PROFESIONALES INTERVINIENTES
//                 // =================================================

//                 Rectangle {
//                     id: bloqueProfesionales

//                     width: parent.width
//                     height: root.altoBloqueProfesionales

//                     radius: 12
//                     color: "#FFFFFF"
//                     border.color: "#E8E0FF"
//                     border.width: 1

//                     Column {
//                         anchors.fill: parent
//                         anchors.leftMargin: 16
//                         anchors.rightMargin: 16
//                         anchors.topMargin: 10
//                         anchors.bottomMargin: 10

//                         spacing: 10

//                         Row {
//                             width: parent.width
//                             spacing: 10

//                             Text {
//                                 text: "Profesionales intervinientes"

//                                 color: AppTheme.colorPrimario

//                                 font.family: AppTheme.fuenteTitulo
//                                 font.pixelSize: 16
//                                 font.bold: true
//                             }

//                             FieldHelpIcon {
//                                 anchors.verticalCenter: parent.verticalCenter

//                                 mensaje: "- Cargá profesionales disponibles para bajas\n- Luego se seleccionarán desde el formulario de baja"
//                             }
//                         }

//                         Flow {
//                             width: parent.width
//                             spacing: root.espacioCampos

//                             FieldBox {
//                                 id: fieldNombreProfesional

//                                 width: root.anchoCampoProfesional
//                                 height: root.altoCampo

//                                 campoObligatorio: false

//                                 InputText {
//                                     id: inputNombreProfesional

//                                     anchors.fill: parent
//                                     anchors.rightMargin: 28

//                                     label: "Nombre"
//                                     placeholder: "Laura"
//                                     width: parent.width
//                                 }
//                             }

//                             FieldBox {
//                                 id: fieldApellidoProfesional

//                                 width: root.anchoCampoProfesional
//                                 height: root.altoCampo

//                                 campoObligatorio: false

//                                 InputText {
//                                     id: inputApellidoProfesional

//                                     anchors.fill: parent
//                                     anchors.rightMargin: 28

//                                     label: "Apellido"
//                                     placeholder: "Gómez"
//                                     width: parent.width
//                                 }
//                             }

//                             FieldBox {
//                                 id: fieldRolProfesional

//                                 width: root.anchoCampoProfesional
//                                 height: root.altoCampoCombo

//                                 campoObligatorio: false

//                                 Column {
//                                     anchors.fill: parent
//                                     spacing: 6

//                                     Text {
//                                         text: "Rol"
//                                         color: AppTheme.colorTextoSecundario
//                                         font.family: AppTheme.fuenteCuerpo
//                                         font.pixelSize: 12
//                                     }

//                                     ComboBox {
//                                         id: comboRolProfesional

//                                         width: parent.width
//                                         height: 36

//                                         model: root.nombresRolesDisponibles
//                                     }
//                                 }
//                             }
//                         }

//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Button {
//                                 id: buttonAgregarProfesional

//                                 width: 112
//                                 height: 40

//                                 text: "Agregar"

//                                 onClicked: {
//                                     root.agregarProfesional()
//                                 }
//                             }

//                             Button {
//                                 id: buttonLimpiarProfesionales

//                                 width: 112
//                                 height: 40

//                                 text: "Limpiar"

//                                 onClicked: {
//                                     root.limpiarProfesionales()
//                                 }
//                             }
//                         }

//                         Rectangle {
//                             width: parent.width
//                             height: 42
//                             radius: 8

//                             color: "#FAFAFA"
//                             border.color: "#E5E7EB"
//                             border.width: 1

//                             clip: true

//                             Text {
//                                 anchors.fill: parent
//                                 anchors.leftMargin: 12
//                                 anchors.rightMargin: 12

//                                 verticalAlignment: Text.AlignVCenter

//                                 text: root.profesionales.length === 0
//                                       ? "Todavía no se agregó ningún profesional."
//                                       : root.textoProfesionales()

//                                 color: root.profesionales.length === 0
//                                        ? AppTheme.colorTextoSecundario
//                                        : AppTheme.colorTextoPrincipal

//                                 font.family: AppTheme.fuenteCuerpo
//                                 font.pixelSize: 13
//                                 font.bold: root.profesionales.length > 0

//                                 elide: Text.ElideRight
//                             }
//                         }
//                     }
//                 }

//                 // =================================================
//                 // BOTÓN GUARDAR
//                 // =================================================

//                 Item {
//                     id: contenedorBotones

//                     width: parent.width
//                     height: root.altoBotonera

//                     CustonButton2 {
//                         id: buttonGuardarSede

//                         tipo: "custom"
//                         textoCustom: "Guardar cambios"
//                         iconoCustom: ""
//                         variante: "primary"

//                         width: 190
//                         height: 46

//                         anchors.left: parent.left
//                         anchors.verticalCenter: parent.verticalCenter

//                         onClicked: {
//                             root.capturarConfiguracionSede()
//                         }
//                     }
//                 }

//                 Item {
//                     width: parent.width
//                     height: 20
//                 }
//             }

//             ScrollBar.vertical: ScrollBar {}
//         }
//     }

//     // =====================================================
//     // COMPONENTE INTERNO: CONTENEDOR BLANCO DE CAMPO
//     // =====================================================

//     component FieldBox: Rectangle {
//         id: fieldBox

//         property bool campoObligatorio: true

//         function labelConObligatorio(texto) {
//             return fieldBox.campoObligatorio ? texto + " *" : texto
//         }

//         radius: 10
//         color: "#FFFFFF"
//         border.color: "#E5E7EB"
//         border.width: 1

//         default property alias content: contentHost.data

//         Item {
//             id: contentHost

//             anchors.fill: parent
//             anchors.leftMargin: 14
//             anchors.rightMargin: 14
//             anchors.topMargin: 8
//             anchors.bottomMargin: 8
//         }
//     }
// }




// // UI / Forms / FormSede.qml

// import QtQuick
// import QtQuick.Controls

// import Components 1.0
// import Theme 1.0

// import "../Utils/Logger.js" as Logger


// Rectangle {
//     id: root

//     width: 600
//     height: 420
//     color: "transparent"
//     clip: true

//     signal configuracionSedeCapturada(var datos)

//     property var profesionalesIntervinientes: ([])

//     // =====================================================
//     // POSICIONAMIENTO INTERNO
//     // Solo mueve los campos DENTRO del panel.
//     // No separa el formulario del HomeHeader ni de SettingsNav.
//     // =====================================================

//     property real camposX: 24
//     property real camposY: 24

//     // =====================================================
//     // MEDIDAS INTERNAS
//     // =====================================================

//     property real espacioCampos: 20
//     property real altoCampo: 78
//     property real altoBotonera: 56
//     property real altoBloqueProfesionales: root.modoCompacto ? 178 : 184

//     readonly property bool modoCompacto: root.width < 760

//     readonly property real contenidoAncho: Math.max(
//         0,
//         panelSede.width - (root.camposX * 2)
//     )

//     readonly property real anchoCampo: root.modoCompacto
//         ? root.contenidoAncho
//         : (root.contenidoAncho - root.espacioCampos) / 2

//     // =====================================================
//     // FUNCIONES
//     // =====================================================

//     function textoProfesionales() {
//         if (!root.profesionalesIntervinientes || root.profesionalesIntervinientes.length === 0) {
//             return ""
//         }

//         return root.profesionalesIntervinientes.join(" / ")
//     }

//     function agregarProfesional() {
//         var valor = inputProfesionalConfiguracion.text.trim()

//         if (valor === "") {
//             return
//         }

//         var nuevaLista = []

//         for (var i = 0; i < root.profesionalesIntervinientes.length; i++) {
//             nuevaLista.push(root.profesionalesIntervinientes[i])
//         }

//         if (nuevaLista.indexOf(valor) === -1) {
//             nuevaLista.push(valor)
//         }

//         root.profesionalesIntervinientes = nuevaLista
//         inputProfesionalConfiguracion.text = ""

//         Logger.bloque(
//             "FORM SEDE",
//             "profesionales configurados",
//             root.profesionalesIntervinientes
//         )
//     }

//     function limpiarProfesionales() {
//         root.profesionalesIntervinientes = []
//         inputProfesionalConfiguracion.text = ""
//     }

//     function capturarConfiguracionSede() {
//         if (inputProfesionalConfiguracion.text.trim() !== "") {
//             root.agregarProfesional()
//         }

//         var datos = {
//             nombreSede: inputNombreSede.text,
//             origen: inputOrigen.text,
//             municipio: inputMunicipio.text,
//             localidad: inputLocalidad.text,
//             barrio: inputBarrio.text,
//             coordinadora: inputCoordinadora.text,
//             profesionalesIntervinientes: root.profesionalesIntervinientes
//         }

//         Logger.linea()
//         Logger.bloque("FORM SEDE", "Configuración capturada:", JSON.stringify(datos))
//         root.configuracionSedeCapturada(datos)
//     }

//     function cargarConfiguracion(datos) {
//         inputNombreSede.text = datos.nombreSede || ""
//         inputOrigen.text = datos.origen || ""
//         inputMunicipio.text = datos.municipio || ""
//         inputLocalidad.text = datos.localidad || ""
//         inputBarrio.text = datos.barrio || ""
//         inputCoordinadora.text = datos.coordinadora || ""

//         root.profesionalesIntervinientes = datos.profesionalesIntervinientes || []
//         inputProfesionalConfiguracion.text = ""
//     }

//     function limpiarCampos() {
//         inputNombreSede.text = ""
//         inputOrigen.text = ""
//         inputMunicipio.text = ""
//         inputLocalidad.text = ""
//         inputBarrio.text = ""
//         inputCoordinadora.text = ""

//         root.limpiarProfesionales()
//     }

//     // =====================================================
//     // PANEL PRINCIPAL
//     // Ocupa todo el espacio recibido desde SectionFive.
//     // =====================================================

//     Rectangle {
//         id: panelSede

//         anchors.fill: parent

//         color: "#FFFFFF"

//         Flickable {
//             id: scrollFormSede

//             anchors.fill: parent
//             clip: true

//             contentWidth: width
//             contentHeight: contenido.implicitHeight + root.camposY + 24

//             Column {
//                 id: contenido

//                 x: root.camposX
//                 y: root.camposY

//                 width: root.contenidoAncho
//                 spacing: 20

//                 // =================================================
//                 // TÍTULO
//                 // =================================================

//                 Column {
//                     width: parent.width
//                     spacing: 4

//                     Text {
//                         text: "Configuración de sede"

//                         color: AppTheme.colorTextoPrincipal

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 24
//                         font.bold: true
//                     }

//                     Text {
//                         text: "Definí los datos generales que se usarán al generar las solicitudes."

//                         width: parent.width
//                         wrapMode: Text.WordWrap

//                         color: AppTheme.colorTextoSecundario

//                         font.family: AppTheme.fuenteCuerpo
//                         font.pixelSize: 13
//                     }
//                 }

//                 // =================================================
//                 // FORMULARIO RESPONSIVE
//                 // =================================================

//                 Flow {
//                     id: camposFlow

//                     width: parent.width
//                     spacing: root.espacioCampos

//                     FieldBox {
//                         id: fieldNombreSede

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputNombreSede

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldNombreSede.labelConObligatorio("Nombre sede")
//                             placeholder: "Villa Arias"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldOrigen

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputOrigen

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldOrigen.labelConObligatorio("Origen")
//                             placeholder: "Envión"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldMunicipio

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputMunicipio

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldMunicipio.labelConObligatorio("Municipio")
//                             placeholder: "Coronel Rosales"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldLocalidad

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputLocalidad

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldLocalidad.labelConObligatorio("Localidad")
//                             placeholder: "Punta Alta"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldBarrio

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: false

//                         InputText {
//                             id: inputBarrio

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldBarrio.labelConObligatorio("Barrio")
//                             placeholder: "Punta Alta"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios\n- Campo opcional"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldCoordinadora

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputCoordinadora

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldCoordinadora.labelConObligatorio("Coordinadora")
//                             placeholder: "Candela Rossi"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Nombre y apellido\n- Se usará automáticamente en las solicitudes de baja"
//                         }
//                     }
//                 }

//                 // =================================================
//                 // PROFESIONALES INTERVINIENTES
//                 // =================================================

//                 Rectangle {
//                     id: bloqueProfesionales

//                     width: parent.width
//                     height: root.altoBloqueProfesionales

//                     radius: 12
//                     color: "#FFFFFF"
//                     border.color: "#E8E0FF"
//                     border.width: 1

//                     Column {
//                         anchors.fill: parent
//                         anchors.leftMargin: 16
//                         anchors.rightMargin: 16
//                         anchors.topMargin: 10
//                         anchors.bottomMargin: 10

//                         spacing: 10

//                         Row {
//                             width: parent.width
//                             spacing: 10

//                             Text {
//                                 text: "Profesionales intervinientes"

//                                 color: AppTheme.colorPrimario

//                                 font.family: AppTheme.fuenteTitulo
//                                 font.pixelSize: 16
//                                 font.bold: true
//                             }

//                             FieldHelpIcon {
//                                 anchors.verticalCenter: parent.verticalCenter

//                                 mensaje: "- Cargá profesionales disponibles para bajas\n- Luego se seleccionarán desde el formulario de baja\n- Evita escribirlos manualmente cada vez"
//                             }
//                         }

//                         Row {
//                             width: parent.width
//                             spacing: root.espacioCampos

//                             FieldBox {
//                                 id: fieldProfesionalConfiguracion

//                                 width: parent.width
//                                        - buttonAgregarProfesional.width
//                                        - buttonLimpiarProfesionales.width
//                                        - (root.espacioCampos * 2)

//                                 height: root.altoCampo

//                                 campoObligatorio: false

//                                 InputText {
//                                     id: inputProfesionalConfiguracion

//                                     anchors.fill: parent
//                                     anchors.rightMargin: 28

//                                     label: "Profesional"
//                                     placeholder: "García Laura Fabiana - PSP"
//                                     width: parent.width
//                                 }

//                                 FieldHelpIcon {
//                                     anchors.top: parent.top
//                                     anchors.right: parent.right
//                                     anchors.topMargin: 2
//                                     anchors.rightMargin: 2

//                                     mensaje: "- Nombre y apellido\n- Rol opcional\n- Ejemplo: PSP / TS"
//                                 }
//                             }

//                             Button {
//                                 id: buttonAgregarProfesional

//                                 width: 112
//                                 height: root.altoCampo

//                                 text: "Agregar"

//                                 onClicked: {
//                                     root.agregarProfesional()
//                                 }
//                             }

//                             Button {
//                                 id: buttonLimpiarProfesionales

//                                 width: 112
//                                 height: root.altoCampo

//                                 text: "Limpiar"

//                                 onClicked: {
//                                     root.limpiarProfesionales()
//                                 }
//                             }
//                         }

//                         Rectangle {
//                             width: parent.width
//                             height: 42
//                             radius: 8

//                             color: "#FAFAFA"
//                             border.color: "#E5E7EB"
//                             border.width: 1

//                             clip: true

//                             Text {
//                                 anchors.fill: parent
//                                 anchors.leftMargin: 12
//                                 anchors.rightMargin: 12

//                                 verticalAlignment: Text.AlignVCenter

//                                 text: root.profesionalesIntervinientes.length === 0
//                                       ? "Todavía no se agregó ningún profesional."
//                                       : root.textoProfesionales()

//                                 color: root.profesionalesIntervinientes.length === 0
//                                        ? AppTheme.colorTextoSecundario
//                                        : AppTheme.colorTextoPrincipal

//                                 font.family: AppTheme.fuenteCuerpo
//                                 font.pixelSize: 13
//                                 font.bold: root.profesionalesIntervinientes.length > 0

//                                 elide: Text.ElideRight
//                             }
//                         }
//                     }
//                 }

//                 // =================================================
//                 // BOTÓN GUARDAR
//                 // =================================================

//                 Item {
//                     id: contenedorBotones

//                     width: parent.width
//                     height: root.altoBotonera

//                     CustonButton2 {
//                         id: buttonGuardarSede

//                         tipo: "custom"
//                         textoCustom: "Guardar cambios"
//                         iconoCustom: ""
//                         variante: "primary"

//                         width: 190
//                         height: 46

//                         anchors.left: parent.left
//                         anchors.verticalCenter: parent.verticalCenter

//                         onClicked: {
//                             root.capturarConfiguracionSede()
//                         }
//                     }
//                 }

//                 Item {
//                     width: parent.width
//                     height: 20
//                 }
//             }

//             ScrollBar.vertical: ScrollBar {}
//         }
//     }

//     // =====================================================
//     // COMPONENTE INTERNO: CONTENEDOR BLANCO DE CAMPO
//     // =====================================================

//     component FieldBox: Rectangle {
//         id: fieldBox

//         property bool campoObligatorio: true

//         function labelConObligatorio(texto) {
//             return fieldBox.campoObligatorio ? texto + " *" : texto
//         }

//         radius: 10
//         color: "#FFFFFF"
//         border.color: "#E5E7EB"
//         border.width: 1

//         default property alias content: contentHost.data

//         Item {
//             id: contentHost

//             anchors.fill: parent
//             anchors.leftMargin: 14
//             anchors.rightMargin: 14
//             anchors.topMargin: 8
//             anchors.bottomMargin: 8
//         }
//     }
// }


// // UI / Forms / FormSede.qml

// import QtQuick
// import QtQuick.Controls

// import Components 1.0
// import Theme 1.0

// import "../Utils/Logger.js" as Logger


// Rectangle {
//     id: root

//     width: 600
//     height: 420
//     color: "transparent"
//     clip: true

//     signal configuracionSedeCapturada(var datos)

//     // =====================================================
//     // POSICIONAMIENTO INTERNO
//     // Solo mueve los campos DENTRO del panel.
//     // No separa el formulario del HomeHeader ni de SettingsNav.
//     // =====================================================

//     property real camposX: 24
//     property real camposY: 24

//     // =====================================================
//     // MEDIDAS INTERNAS
//     // =====================================================

//     property real espacioCampos: 20
//     property real altoCampo: 78
//     property real altoBotonera: 56

//     readonly property bool modoCompacto: root.width < 760

//     readonly property real contenidoAncho: Math.max(
//         0,
//         panelSede.width - (root.camposX * 2)
//     )

//     readonly property real anchoCampo: root.modoCompacto
//         ? root.contenidoAncho
//         : (root.contenidoAncho - root.espacioCampos) / 2

//     // =====================================================
//     // FUNCIONES
//     // =====================================================

//     function capturarConfiguracionSede() {
//         var datos = {
//             nombreSede: inputNombreSede.text,
//             origen: inputOrigen.text,
//             municipio: inputMunicipio.text,
//             localidad: inputLocalidad.text,
//             barrio: inputBarrio.text,
//             coordinadora: inputCoordinadora.text
//         }

//         Logger.linea()
//         Logger.bloque("FORM SEDE", "Configuración capturada:", JSON.stringify(datos))
//         root.configuracionSedeCapturada(datos)
//     }

//     function cargarConfiguracion(datos) {
//         inputNombreSede.text = datos.nombreSede || ""
//         inputOrigen.text = datos.origen || ""
//         inputMunicipio.text = datos.municipio || ""
//         inputLocalidad.text = datos.localidad || ""
//         inputBarrio.text = datos.barrio || ""
//         inputCoordinadora.text = datos.coordinadora || ""
//     }

//     function limpiarCampos() {
//         inputNombreSede.text = ""
//         inputOrigen.text = ""
//         inputMunicipio.text = ""
//         inputLocalidad.text = ""
//         inputBarrio.text = ""
//         inputCoordinadora.text = ""
//     }

//     // =====================================================
//     // PANEL PRINCIPAL
//     // Ocupa todo el espacio recibido desde SectionFive.
//     // =====================================================

//     Rectangle {
//         id: panelSede

//         anchors.fill: parent

//         color: "#FFFFFF"

//         Flickable {
//             id: scrollFormSede

//             anchors.fill: parent
//             clip: true

//             contentWidth: width
//             contentHeight: contenido.implicitHeight + root.camposY

//             Column {
//                 id: contenido

//                 x: root.camposX
//                 y: root.camposY

//                 width: root.contenidoAncho
//                 spacing: 20

//                 // =================================================
//                 // TÍTULO
//                 // =================================================

//                 Column {
//                     width: parent.width
//                     spacing: 4

//                     Text {
//                         text: "Configuración de sede"

//                         color: AppTheme.colorTextoPrincipal

//                         font.family: AppTheme.fuenteTitulo
//                         font.pixelSize: 24
//                         font.bold: true
//                     }

//                     Text {
//                         text: "Definí los datos generales que se usarán al generar las solicitudes."

//                         width: parent.width
//                         wrapMode: Text.WordWrap

//                         color: AppTheme.colorTextoSecundario

//                         font.family: AppTheme.fuenteCuerpo
//                         font.pixelSize: 13
//                     }
//                 }

//                 // =================================================
//                 // FORMULARIO RESPONSIVE
//                 // =================================================

//                 Flow {
//                     id: camposFlow

//                     width: parent.width
//                     spacing: root.espacioCampos

//                     FieldBox {
//                         id: fieldNombreSede

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputNombreSede

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldNombreSede.labelConObligatorio("Nombre sede")
//                             placeholder: "Villa Arias"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldOrigen

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputOrigen

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldOrigen.labelConObligatorio("Origen")
//                             placeholder: "Envión"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldMunicipio

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputMunicipio

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldMunicipio.labelConObligatorio("Municipio")
//                             placeholder: "Coronel Rosales"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldLocalidad

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputLocalidad

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldLocalidad.labelConObligatorio("Localidad")
//                             placeholder: "Punta Alta"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Acentos\n- Espacios"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldBarrio

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: false

//                         InputText {
//                             id: inputBarrio

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldBarrio.labelConObligatorio("Barrio")
//                             placeholder: "Punta Alta"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Mayúsculas\n- Minúsculas\n- Números\n- Acentos\n- Espacios\n- Campo opcional"
//                         }
//                     }

//                     FieldBox {
//                         id: fieldCoordinadora

//                         width: root.anchoCampo
//                         height: root.altoCampo

//                         campoObligatorio: true

//                         InputText {
//                             id: inputCoordinadora

//                             anchors.fill: parent
//                             anchors.rightMargin: 28

//                             label: fieldCoordinadora.labelConObligatorio("Coordinadora")
//                             placeholder: "Candela Rossi"
//                             width: parent.width
//                         }

//                         FieldHelpIcon {
//                             anchors.top: parent.top
//                             anchors.right: parent.right
//                             anchors.topMargin: 2
//                             anchors.rightMargin: 2

//                             mensaje: "- Nombre y apellido\n- Se usará automáticamente en las solicitudes de baja"
//                         }
//                     }
//                 }

//                 // =================================================
//                 // BOTÓN GUARDAR
//                 // =================================================

//                 Item {
//                     id: contenedorBotones

//                     width: parent.width
//                     height: root.altoBotonera

//                     CustonButton2 {
//                         id: buttonGuardarSede

//                         tipo: "custom"
//                         textoCustom: "Guardar cambios"
//                         iconoCustom: ""
//                         variante: "primary"

//                         width: 190
//                         height: 46

//                         anchors.left: parent.left
//                         anchors.verticalCenter: parent.verticalCenter

//                         onClicked: {
//                             root.capturarConfiguracionSede()
//                         }
//                     }
//                 }

//                 Item {
//                     width: parent.width
//                     height: 20
//                 }
//             }

//             ScrollBar.vertical: ScrollBar {}
//         }
//     }

//     // =====================================================
//     // COMPONENTE INTERNO: CONTENEDOR BLANCO DE CAMPO
//     // =====================================================

//     component FieldBox: Rectangle {
//         id: fieldBox

//         property bool campoObligatorio: true

//         function labelConObligatorio(texto) {
//             return fieldBox.campoObligatorio ? texto + " *" : texto
//         }

//         radius: 10
//         color: "#FFFFFF"
//         border.color: "#E5E7EB"
//         border.width: 1

//         default property alias content: contentHost.data

//         Item {
//             id: contentHost

//             anchors.fill: parent
//             anchors.leftMargin: 14
//             anchors.rightMargin: 14
//             anchors.topMargin: 8
//             anchors.bottomMargin: 8
//         }
//     }
// }

