// UI / Structures / HomeHeader.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Theme 1.0
import Layout 1.0


Rectangle {
    id: root

    width: 1000
    height: AppLayout.homeHeaderHeight

    color: AppTheme.colorSuperficieAlternativa
    border.color: AppTheme.cardBorde
    border.width: 1
    clip: true

    // ===============================
    // PROPIEDADES EXPORTABLES BASE
    // ===============================

    property string titulo: "Bienvenido"
    property string tituloResaltado: ""
    property string descripcion: "Seleccioná una acción para continuar."

    property int contenidoAnchoMaximo: AppLayout.homeHeaderTextMaxWidth

    // ===============================
    // MODO VISUAL
    // ===============================

    property string modoHeader: "home"

    readonly property bool esModoHome: root.modoHeader === "home"
    readonly property bool esModoFormulario: root.modoHeader === "formulario"

    // ===============================
    // IMAGEN DECORATIVA PRINCIPAL
    // ===============================

    property string formularioSource: ""
    property bool mostrarFormulario: formularioSource !== ""

    // ===============================
    // PROPIEDADES PARA MODO FORMULARIO
    // ===============================

    property string etiquetaSuperior: "DATOS PERSONALES"
    property string iconoPersonaSource: ""
    property bool mostrarIconoPersona: iconoPersonaSource !== ""

    property bool mostrarIndicadorPasos: true
    property bool mostrarPanelPaso: mostrarIndicadorPasos

    // Se mantienen por compatibilidad, aunque ya no se muestran en este header.
    property string pasoLabel: "PASO ACTUAL"
    property string pasoValor: "1 de 3"
    property string pasoDescripcion: "Completá los datos para continuar con el proceso."

    property int pasoActualFormulario: 1

    property var stepTitlesFormulario: [
        "Destinatario",
        "Responsable",
        "Previsualización"
    ]

    property int formularioHeaderLeftMargin: 160
    property int formularioHeaderRightMargin: 64

    // Ajustes específicos del indicador horizontal dentro del header
    property int headerStepsCircleSize: 34
    property int headerStepsStepWidth: 96
    property int headerStepsLineWidth: 24
    property int headerStepsHeight: 64

    // ===============================
    // ONDAS DECORATIVAS
    // ===============================

    Image {
        id: wavesImage

        visible: AppLayout.homeHeaderMostrarDecoracion
        source: AppLayout.homeHeaderWavesSource

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: parent.height * AppLayout.homeHeaderWavesHeightFactor

        fillMode: Image.PreserveAspectCrop
        smooth: true

        z: 1
    }

    // ===============================
    // IMAGEN DECORATIVA PRINCIPAL
    // Solo para modo HOME
    // ===============================

    Image {
        id: formularioImage

        visible: root.esModoHome && root.mostrarFormulario
        source: root.formularioSource

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        anchors.rightMargin: AppLayout.homeHeaderFormRightMargin
        anchors.verticalCenterOffset: AppLayout.homeHeaderFormVerticalOffset

        width: parent.width * AppLayout.homeHeaderFormWidthFactor
        height: parent.height * AppLayout.homeHeaderFormHeightFactor

        fillMode: Image.PreserveAspectFit
        smooth: true
        opacity: 1.0

        z: 4
    }

    // =====================================================
    // MODO HOME - CONTENIDO ORIGINAL
    // =====================================================

    Column {
        id: contenidoTextoHome

        visible: root.esModoHome

        width: Math.min(
            root.contenidoAnchoMaximo,
            parent.width - (AppLayout.homeHeaderTextLeftMargin * 2)
        )

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: AppLayout.homeHeaderTextLeftMargin
        anchors.verticalCenterOffset: AppLayout.homeHeaderTextVerticalOffset

        spacing: AppTheme.spacingLg
        z: 3

        Row {
            id: filaTituloHome

            spacing: AppTheme.spacingSm

            Text {
                text: root.titulo

                color: AppTheme.colorTextoPrincipal

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: AppLayout.homeHeaderTitleSize
                font.weight: AppTheme.pesoTituloHero
            }

            Text {
                visible: root.tituloResaltado !== ""
                text: root.tituloResaltado

                color: AppTheme.colorPrimario

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: AppLayout.homeHeaderTitleSize
                font.weight: AppTheme.pesoTituloHero
            }
        }

        Text {
            text: root.descripcion

            width: parent.width
            wrapMode: Text.WordWrap

            color: AppTheme.colorTextoSecundario

            font.family: AppTheme.fuenteCuerpo
            font.pixelSize: AppLayout.homeHeaderDescriptionSize
            font.weight: AppTheme.pesoTextoNormal
            lineHeight: 1.25
        }
    }

    // =====================================================
    // MODO FORMULARIO
    // =====================================================

    Row {
        id: contenidoFormulario

        visible: root.esModoFormulario

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        anchors.leftMargin: root.formularioHeaderLeftMargin
        anchors.rightMargin: root.formularioHeaderRightMargin
        anchors.verticalCenterOffset: -2

        height: parent.height * 0.62
        spacing: root.mostrarPanelPaso ? 26 : 0

        z: 5

        // ===============================
        // ÍCONO IZQUIERDO
        // ===============================

        Rectangle {
            id: iconoPersonaContainer

            visible: root.mostrarIconoPersona

            width: 82
            height: 82
            radius: width / 2

            anchors.verticalCenter: parent.verticalCenter

            color: "#FFFFFF"
            border.color: "#EEE8FF"
            border.width: 3

            Image {
                anchors.centerIn: parent

                source: root.iconoPersonaSource

                width: parent.width * 1.5
                height: parent.height * 1.5

                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        // ===============================
        // BLOQUE PRINCIPAL
        // ===============================

        Column {
            id: bloqueTextoFormulario

            width: root.mostrarPanelPaso
                   ? parent.width * 0.48
                   : parent.width * 0.82

            anchors.verticalCenter: parent.verticalCenter
            spacing: 7

            Text {
                text: root.etiquetaSuperior

                visible: root.etiquetaSuperior !== ""

                color: AppTheme.colorPrimario

                font.family: AppTheme.fuenteTitulo
                font.pixelSize: 13
                font.bold: true
            }

            Row {
                spacing: AppTheme.spacingSm

                Text {
                    text: root.titulo

                    color: AppTheme.colorTextoPrincipal

                    font.family: AppTheme.fuenteTitulo
                    font.pixelSize: AppLayout.homeHeaderTitleSize
                    font.weight: AppTheme.pesoTituloHero
                }

                Text {
                    visible: root.tituloResaltado !== ""
                    text: root.tituloResaltado

                    color: AppTheme.colorPrimario

                    font.family: AppTheme.fuenteTitulo
                    font.pixelSize: AppLayout.homeHeaderTitleSize
                    font.weight: AppTheme.pesoTituloHero
                }
            }

            Text {
                text: root.descripcion

                width: parent.width
                wrapMode: Text.WordWrap

                color: AppTheme.colorTextoSecundario

                font.family: AppTheme.fuenteCuerpo
                font.pixelSize: AppLayout.homeHeaderDescriptionSize
                font.weight: AppTheme.pesoTextoNormal
                lineHeight: 1.22
            }
        }

        // ===============================
        // DIVISOR VERTICAL
        // ===============================

        Rectangle {
            id: divisorFormulario

            visible: root.mostrarPanelPaso

            width: root.mostrarPanelPaso ? 1 : 0
            height: parent.height * 0.82

            anchors.verticalCenter: parent.verticalCenter

            color: "#E5E7EB"
        }

        // ===============================
        // INDICADOR HORIZONTAL DE PASOS
        // ===============================

        Item {
            id: panelPasoFormulario

            visible: root.mostrarPanelPaso

            width: root.mostrarPanelPaso ? parent.width * 0.32 : 0
            height: root.headerStepsHeight

            anchors.verticalCenter: parent.verticalCenter

            Steps {
                id: stepsHeader

                anchors.centerIn: parent

                orientation: "horizontal"
                currentStep: root.pasoActualFormulario

                stepTitles: root.stepTitlesFormulario

                horizontalCircleSize: root.headerStepsCircleSize
                horizontalStepWidth: root.headerStepsStepWidth
                horizontalLineWidth: root.headerStepsLineWidth
                horizontalStepHeight: root.headerStepsHeight

                margenIzquierdo: 0
                margenSuperior: 0
            }
        }
    }
}