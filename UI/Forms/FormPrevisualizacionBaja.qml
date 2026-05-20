// UI/Forms/FormPrevisualizacionBaja.qml

import QtQuick
import QtQuick.Controls

import Components 1.0
import Theme 1.0

import "../Utils/Logger.js" as Logger


Rectangle {
    id: root

    width: 600
    height: 400
    color: "transparent"
    clip: true

    property var datosSolicitud: ({})

    // Se mantienen por compatibilidad.
    // SectionFour va a controlar los botones globales.
    signal volverSolicitado()
    signal generarSolicitado()

    // =====================================================
    // POSICIONAMIENTO INTERNO
    // =====================================================

    property real camposX: 20
    property real camposY: 20

    property real contenidoWidth: root.width - root.camposX - 40

    // =====================================================
    // ESTADO DE SECCIONES
    // Por defecto arrancan cerradas
    // =====================================================

    property bool institucionalExpandido: false
    property bool beneficiarioExpandido: false
    property bool responsableExpandido: false

    // =====================================================
    // MEDIDAS VISUALES
    // =====================================================

    property real sectionSpacing: 12
    property real fieldSpacing: 8

    property real fieldHeight: 38
    property real fieldLabelWidth: 160

    property real sectionHeaderHeight: 52

    // =====================================================
    // HELPERS
    // =====================================================

    function valorSeguro(valor) {
        return valor === undefined || valor === null || valor === "" ? "-" : valor
    }

    function nombreCompletoBeneficiario() {
        var nombre = datosSolicitud.bajaNombre || ""
        var apellido = datosSolicitud.bajaApellido || ""
        return (nombre + " " + apellido).trim()
    }

    function nombreCompletoResponsable() {
        var nombre = datosSolicitud.bajaResponsableNombre || ""
        var apellido = datosSolicitud.bajaResponsableApellido || ""
        return (nombre + " " + apellido).trim()
    }

    function textoProfesionales() {
        if (datosSolicitud.profesionalesIntervinientesTexto !== undefined
                && datosSolicitud.profesionalesIntervinientesTexto !== null
                && datosSolicitud.profesionalesIntervinientesTexto !== "") {
            return datosSolicitud.profesionalesIntervinientesTexto
        }

        if (!datosSolicitud.profesionalesIntervinientes
                || datosSolicitud.profesionalesIntervinientes.length === 0) {
            return "-"
        }

        return datosSolicitud.profesionalesIntervinientes.join(" / ")
    }

    // =====================================================
    // CONTENIDO CON SCROLL
    // =====================================================

    Flickable {
        id: flick

        anchors.fill: parent

        clip: true
        contentWidth: width
        contentHeight: columFields.implicitHeight + root.camposY + 24

        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        Column {
            id: columFields

            x: root.camposX
            y: root.camposY

            width: root.contenidoWidth
            spacing: root.sectionSpacing

            // =================================================
            // SECCIÓN INSTITUCIONAL
            // =================================================

            PreviewAccordionSection {
                id: sectionInstitucional

                width: parent.width

                titulo: "DATOS INSTITUCIONALES"
                iconText: "▣"
                expanded: root.institucionalExpandido

                accentColor: AppTheme.colorPrimario
                headerBackgroundColor: "#F3EDFF"
                borderColor: "#DCCBFF"
                lineColor: "#BFA8FF"

                onToggleSolicitado: {
                    root.institucionalExpandido = !root.institucionalExpandido
                }

                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: 24
                    rowSpacing: root.fieldSpacing

                    PreviewField {
                        width: (sectionInstitucional.contentWidth - 24) / 2
                        label: "Centro Envión"
                        value: root.valorSeguro(root.datosSolicitud.centroEnvion)
                        labelColor: AppTheme.colorPrimario
                    }

                    PreviewField {
                        width: (sectionInstitucional.contentWidth - 24) / 2
                        label: "Sede"
                        value: root.valorSeguro(root.datosSolicitud.sede)
                        labelColor: AppTheme.colorPrimario
                    }

                    PreviewField {
                        width: (sectionInstitucional.contentWidth - 24) / 2
                        label: "Modalidad"
                        value: root.valorSeguro(root.datosSolicitud.modalidad)
                        labelColor: AppTheme.colorPrimario
                    }

                    PreviewField {
                        width: (sectionInstitucional.contentWidth - 24) / 2
                        label: "Fecha de baja"
                        value: root.valorSeguro(root.datosSolicitud.fechaBaja)
                        labelColor: AppTheme.colorPrimario
                    }

                    PreviewField {
                        width: (sectionInstitucional.contentWidth - 24) / 2
                        label: "Coordinadora"
                        value: root.valorSeguro(root.datosSolicitud.coordinadora)
                        labelColor: AppTheme.colorPrimario
                    }

                    PreviewField {
                        width: (sectionInstitucional.contentWidth - 24) / 2
                        label: "Profesionales"
                        value: root.valorSeguro(root.textoProfesionales())
                        labelColor: AppTheme.colorPrimario
                    }
                }
            }

            // =================================================
            // SECCIÓN BENEFICIARIO Y MOTIVO
            // =================================================

            PreviewAccordionSection {
                id: sectionBeneficiario

                width: parent.width

                titulo: "BENEFICIARIO Y MOTIVO"
                iconText: "♙"
                expanded: root.beneficiarioExpandido

                accentColor: "#2E7CF6"
                headerBackgroundColor: "#EAF3FF"
                borderColor: "#C9E0FF"
                lineColor: "#6DA8FF"

                onToggleSolicitado: {
                    root.beneficiarioExpandido = !root.beneficiarioExpandido
                }

                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: 24
                    rowSpacing: root.fieldSpacing

                    PreviewField {
                        width: (sectionBeneficiario.contentWidth - 24) / 2
                        label: "Tipo"
                        value: root.valorSeguro(root.datosSolicitud.bajaTipoBeneficiario)
                        labelColor: "#2E7CF6"
                    }

                    PreviewField {
                        width: (sectionBeneficiario.contentWidth - 24) / 2
                        label: "Nombre"
                        value: root.valorSeguro(root.nombreCompletoBeneficiario())
                        labelColor: "#2E7CF6"
                    }

                    PreviewField {
                        width: (sectionBeneficiario.contentWidth - 24) / 2
                        label: "Tipo doc."
                        value: root.valorSeguro(root.datosSolicitud.bajaTipoDni)
                        labelColor: "#2E7CF6"
                    }

                    PreviewField {
                        width: (sectionBeneficiario.contentWidth - 24) / 2
                        label: "DNI"
                        value: root.valorSeguro(root.datosSolicitud.bajaDni)
                        labelColor: "#2E7CF6"
                    }

                    PreviewField {
                        width: (sectionBeneficiario.contentWidth - 24) / 2
                        label: "Fecha ingreso"
                        value: root.valorSeguro(root.datosSolicitud.bajaFechaIngreso)
                        labelColor: "#2E7CF6"
                    }

                    PreviewField {
                        width: (sectionBeneficiario.contentWidth - 24) / 2
                        label: "Motivo"
                        value: root.valorSeguro(root.datosSolicitud.bajaMotivo)
                        labelColor: "#2E7CF6"
                    }
                }
            }

            // =================================================
            // SECCIÓN RESPONSABLE ADULTO
            // =================================================

            PreviewAccordionSection {
                id: sectionResponsable

                width: parent.width

                titulo: "RESPONSABLE ADULTO"
                iconText: "♙"
                expanded: root.responsableExpandido

                accentColor: "#0E9AA5"
                headerBackgroundColor: "#E7FAFC"
                borderColor: "#BDEFF4"
                lineColor: "#42D5DE"

                onToggleSolicitado: {
                    root.responsableExpandido = !root.responsableExpandido
                }

                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: 24
                    rowSpacing: root.fieldSpacing

                    PreviewField {
                        width: (sectionResponsable.contentWidth - 24) / 2
                        label: "Nombre"
                        value: root.valorSeguro(root.nombreCompletoResponsable())
                        labelColor: "#0E9AA5"
                    }

                    PreviewField {
                        width: (sectionResponsable.contentWidth - 24) / 2
                        label: "Relación"
                        value: root.valorSeguro(root.datosSolicitud.bajaResponsableRelacion)
                        labelColor: "#0E9AA5"
                    }

                    PreviewField {
                        width: (sectionResponsable.contentWidth - 24) / 2
                        label: "Informado"
                        value: root.valorSeguro(root.datosSolicitud.bajaResponsableInformado)
                        labelColor: "#0E9AA5"
                    }
                }
            }

            // =================================================
            // NOTA INFORMATIVA
            // =================================================

            Rectangle {
                id: nota

                width: parent.width
                height: 46
                radius: 0

                color: "#F4EFFF"
                border.color: "#E5D8FF"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    spacing: 12

                    Text {
                        text: "ⓘ"

                        anchors.verticalCenter: parent.verticalCenter

                        color: AppTheme.colorPrimario

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {
                        text: "Si detectás algún error, volvé atrás para corregir los datos antes de generar la baja."

                        anchors.verticalCenter: parent.verticalCenter

                        color: AppTheme.colorTextoSecundario

                        font.family: AppTheme.fuenteCuerpo
                        font.pixelSize: 13

                        elide: Text.ElideRight
                        width: parent.width - 54
                    }
                }
            }
        }
    }

    // =====================================================
    // COMPONENTE INTERNO: SECCIÓN DESPLEGABLE
    // =====================================================

    component PreviewAccordionSection: Rectangle {
        id: section

        property string titulo: "SECCIÓN"
        property string iconText: "▣"

        property bool expanded: false

        property color accentColor: AppTheme.colorPrimario
        property color headerBackgroundColor: "#F3EDFF"
        property color borderColor: "#DDE2EA"
        property color lineColor: AppTheme.colorPrimario

        readonly property real contentWidth: contentColumn.width

        signal toggleSolicitado()

        width: parent ? parent.width : 600
        height: root.sectionHeaderHeight + (section.expanded ? contentArea.implicitHeight : 0)

        radius: 0
        color: "#FFFFFF"

        border.color: section.borderColor
        border.width: 1

        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutQuad
            }
        }

        Column {
            anchors.fill: parent

            Rectangle {
                id: sectionHeader

                width: parent.width
                height: root.sectionHeaderHeight

                radius: 0
                color: section.headerBackgroundColor

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    spacing: 12

                    Rectangle {
                        width: 34
                        height: 34
                        radius: width / 2

                        anchors.verticalCenter: parent.verticalCenter

                        color: Qt.rgba(
                            section.accentColor.r,
                            section.accentColor.g,
                            section.accentColor.b,
                            0.16
                        )

                        Text {
                            anchors.centerIn: parent

                            text: section.iconText
                            color: section.accentColor

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    Text {
                        text: section.titulo

                        anchors.verticalCenter: parent.verticalCenter

                        color: section.accentColor

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 15
                        font.bold: true
                    }

                    Item {
                        width: 1
                        height: 1
                    }

                    Text {
                        text: section.expanded ? "⌃" : "⌄"

                        anchors.verticalCenter: parent.verticalCenter

                        color: section.accentColor

                        font.family: AppTheme.fuenteTitulo
                        font.pixelSize: 20
                        font.bold: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        section.toggleSolicitado()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 2
                color: section.lineColor
                opacity: section.expanded ? 0.75 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }

            Item {
                id: contentArea

                visible: section.expanded

                width: parent.width
                implicitHeight: section.expanded ? contentColumn.implicitHeight + 20 : 0

                Column {
                    id: contentColumn

                    x: 16
                    y: 10

                    width: parent.width - 32
                    spacing: root.fieldSpacing
                }
            }
        }

        default property alias contenido: contentColumn.data
    }

    // =====================================================
    // COMPONENTE INTERNO: CAMPO DE PREVISUALIZACIÓN
    // =====================================================

    component PreviewField: Rectangle {
        id: field

        property string label: ""
        property string value: ""
        property color labelColor: AppTheme.colorPrimario

        height: root.fieldHeight
        radius: 0

        color: "#FFFFFF"
        border.color: "#DDE5EE"
        border.width: 1

        Row {
            anchors.fill: parent

            Rectangle {
                id: labelBox

                width: root.fieldLabelWidth
                height: parent.height

                radius: 0

                color: Qt.rgba(
                    field.labelColor.r,
                    field.labelColor.g,
                    field.labelColor.b,
                    0.08
                )

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 14

                    text: field.label

                    color: field.labelColor

                    font.family: AppTheme.fuenteCuerpo
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            Rectangle {
                width: 1
                height: parent.height
                color: "#E1E7EF"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16

                width: parent.width - root.fieldLabelWidth - 28

                text: field.value
                elide: Text.ElideRight

                color: AppTheme.colorTextoPrincipal

                font.family: AppTheme.fuenteCuerpo
                font.pixelSize: 13
                font.bold: true
            }
        }
    }
}