// UI/Components/StepIndicator.qml

import QtQuick
import Theme 1.0


Item {
    id: root

    // =====================================================
    // PROPIEDADES EXPORTABLES
    // =====================================================

    property int stepNumber: 1
    property string titulo: "Destinatario"

    property bool actual: false
    property bool completado: false
    property bool ultimo: false

    property int tamanoCirculo: 48
    property int anchoTexto: 140
    property int altoPaso: 120

    property color colorActual: AppTheme.colorPrimario
    property color colorCompletado: AppTheme.colorAcento
    property color colorPendiente: "#FFFFFF"

    property color colorBordePendiente: "#D6D9E0"
    property color colorLineaActiva: AppTheme.colorAcento
    property color colorLineaPendiente: "#D6D9E0"

    property color colorTextoActual: AppTheme.colorTextoPrincipal
    property color colorTextoCompletado: AppTheme.colorTextoPrincipal
    property color colorTextoPendiente: AppTheme.colorTextoSecundario

    width: tamanoCirculo + 16 + anchoTexto
    height: altoPaso

    // =====================================================
    // LÍNEA VERTICAL
    // =====================================================

    Rectangle {
        id: lineaVertical

        visible: !root.ultimo

        width: 3
        radius: 2

        anchors.top: circulo.bottom
        anchors.topMargin: 6
        anchors.horizontalCenter: circulo.horizontalCenter
        anchors.bottom: parent.bottom

        color: root.completado ? root.colorLineaActiva : root.colorLineaPendiente
        opacity: root.completado ? 0.95 : 0.75

        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }
    }

    // =====================================================
    // HALO ANIMADO DEL PASO ACTUAL
    // =====================================================

    Rectangle {
        id: haloActual

        width: root.tamanoCirculo + 10
        height: root.tamanoCirculo + 10
        radius: width / 2

        anchors.centerIn: circulo

        visible: root.actual
        color: "transparent"
        border.color: root.colorActual
        border.width: 2
        opacity: 0.30

        z: 0

        SequentialAnimation on scale {
            running: root.actual
            loops: Animation.Infinite

            NumberAnimation {
                from: 1.0
                to: 1.22
                duration: 900
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                from: 1.22
                to: 1.0
                duration: 900
                easing.type: Easing.InOutQuad
            }
        }

        SequentialAnimation on opacity {
            running: root.actual
            loops: Animation.Infinite

            NumberAnimation {
                from: 0.34
                to: 0.08
                duration: 900
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                from: 0.08
                to: 0.34
                duration: 900
                easing.type: Easing.InOutQuad
            }
        }
    }

    // =====================================================
    // CÍRCULO PRINCIPAL
    // =====================================================

    Rectangle {
        id: circulo

        width: root.tamanoCirculo
        height: root.tamanoCirculo
        radius: width / 2

        anchors.left: parent.left
        anchors.top: parent.top

        color: root.completado
               ? root.colorCompletado
               : root.actual
                 ? root.colorActual
                 : root.colorPendiente

        border.width: root.actual ? 0 : 1
        border.color: root.completado
                      ? root.colorCompletado
                      : root.colorBordePendiente

        z: 2

        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 180
            }
        }

        Text {
            anchors.centerIn: parent

            text: root.completado ? "✓" : root.stepNumber.toString()

            color: root.completado || root.actual
                   ? "#FFFFFF"
                   : AppTheme.colorTextoSecundario

            font.family: AppTheme.fuenteTitulo
            font.pixelSize: root.completado ? 24 : 20
            font.bold: true

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // =====================================================
    // TEXTO DEL PASO
    // =====================================================

    Column {
        id: bloqueTexto

        anchors.left: circulo.right
        anchors.leftMargin: 16
        anchors.verticalCenter: circulo.verticalCenter

        width: root.anchoTexto
        spacing: 2

        Text {
            text: "Paso " + root.stepNumber

            visible: root.actual || root.completado

            color: root.completado
                   ? root.colorLineaActiva
                   : root.colorActual

            font.family: AppTheme.fuenteCuerpo
            font.pixelSize: 11
            font.bold: true
        }

        Text {
            text: root.titulo

            width: parent.width
            wrapMode: Text.WordWrap

            color: root.actual
                   ? root.colorTextoActual
                   : root.completado
                     ? root.colorTextoCompletado
                     : root.colorTextoPendiente

            font.family: AppTheme.fuenteTitulo
            font.pixelSize: root.actual ? 15 : 14
            font.bold: root.actual || root.completado
        }
    }
}
