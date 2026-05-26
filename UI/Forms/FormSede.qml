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
    property real altoBloqueProfesionales: root.modoCompacto ? 360 : 290
    property real altoBloqueCoordinadora: root.modoCompacto ? 300 : 210

    readonly property bool modoCompacto: root.width < 760

    readonly property real contenidoAncho: Math.max(
        0,
        panelSede.width - (root.camposX * 2)
    )

    // =====================================================
    // MEDIDAS PARA BLOQUE DATOS DE SEDE
    // =====================================================

    readonly property real anchoMaximoBloqueDatosSede: 980

    readonly property real anchoBloqueDatosSede: root.modoCompacto
        ? root.contenidoAncho
        : Math.min(root.contenidoAncho, root.anchoMaximoBloqueDatosSede)

    readonly property real anchoInternoBloqueDatosSede: Math.max(
        0,
        root.anchoBloqueDatosSede - 32
    )

    readonly property real anchoCampoSede: root.modoCompacto
        ? root.anchoInternoBloqueDatosSede
        : (root.anchoInternoBloqueDatosSede - root.espacioCampos) / 2

    // =====================================================
    // MEDIDAS PARA BLOQUES SECUNDARIOS
    // =====================================================

    readonly property real anchoMaximoBloquesSecundarios: 980

    readonly property real anchoBloqueSecundario: root.modoCompacto
        ? root.contenidoAncho
        : Math.min(root.contenidoAncho, root.anchoMaximoBloquesSecundarios)

    readonly property real anchoInternoBloqueSecundario: Math.max(
        0,
        root.anchoBloqueSecundario - 32
    )

    readonly property real anchoCampoProfesional: root.modoCompacto
        ? root.anchoInternoBloqueSecundario
        : (root.anchoInternoBloqueSecundario - (root.espacioCampos * 2)) / 3

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
                spacing: 70

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

                    width: root.anchoBloqueDatosSede
                    height: root.modoCompacto ? 560 : 330

                    radius: 0
                    color: "transparent"
                    border.width: 0

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

                                width: root.anchoCampoSede
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

                                width: root.anchoCampoSede
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

                                width: root.anchoCampoSede
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

                                width: root.anchoCampoSede
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

                                width: root.anchoCampoSede
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

                        Item {
                            id: itemBotonGuardarSede

                            width: parent.width
                            height: 60

                            CustonButton2 {
                                id: buttonGuardarDatosSede

                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.topMargin: 1

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
                }

                // =================================================
                // SECCIÓN 2 - PROFESIONALES INTERVINIENTES
                // =================================================

                Rectangle {
                    id: bloqueProfesionales

                    width: root.anchoBloqueSecundario
                    height: root.altoBloqueProfesionales

                    radius: 0
                    color: "transparent"
                    border.width: 0

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

                        Flow {
                            id: listaProfesionales

                            width: parent.width
                            height: root.profesionales.length === 0 ? 28 : implicitHeight

                            spacing: 8

                            Text {
                                visible: root.profesionales.length === 0

                                text: "No hay profesionales cargados."

                                color: AppTheme.colorTextoSecundario

                                font.family: AppTheme.fuenteCuerpo
                                font.pixelSize: 13
                            }

                            Repeater {
                                model: root.profesionales

                                delegate: Rectangle {
                                    height: 32
                                    width: textoProfesionalItem.implicitWidth + botonEliminar.width + 26

                                    radius: 8

                                    color: "#FFFFFF"
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 6

                                        spacing: 8

                                        Text {
                                            id: textoProfesionalItem

                                            height: parent.height

                                            verticalAlignment: Text.AlignVCenter

                                            text: root.textoProfesional(modelData)

                                            color: AppTheme.colorTextoPrincipal

                                            font.family: AppTheme.fuenteCuerpo
                                            font.pixelSize: 13
                                            font.bold: true
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

                    width: root.anchoBloqueSecundario
                    height: root.altoBloqueCoordinadora

                    radius: 0
                    color: "transparent"
                    border.width: 0

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