// UI/Structures/Steps.qml

import QtQuick
import QtQuick.Controls

import Components 1.0
import Theme 1.0
import Layout 1.0


Rectangle {
    id: root

    color: "transparent"

    // Paso actual: 1, 2, 3...
    property int currentStep: 1

    property var stepTitles: [
        "Destinatario",
        "Responsable",
        "Previsualización"
    ]

    /*
        orientation:
        - "vertical"
        - "horizontal"
    */
    property string orientation: "vertical"

    readonly property bool esVertical: root.orientation === "vertical"
    readonly property bool esHorizontal: root.orientation === "horizontal"

    // =====================================================
    // MEDIDAS EXPORTABLES
    // =====================================================

    property int margenIzquierdo: 0
    property int margenSuperior: 0

    // Modo vertical
    property int stepCircleSize: root.esHorizontal ? 34 : 48
    property int stepHeight: root.esHorizontal ? 64 : 112
    property int stepTextWidth: root.esHorizontal ? 92 : 150

    // Modo horizontal
    property int horizontalCircleSize: 34
    property int horizontalStepWidth: 96
    property int horizontalStepHeight: 64
    property int horizontalLineWidth: 26
    property int horizontalLineHeight: 3
    property int horizontalSpacing: 4

    // Vertical
    width: root.esHorizontal
           ? pasosRow.implicitWidth + root.margenIzquierdo
           : 260

    implicitHeight: root.esHorizontal
                    ? pasosRow.implicitHeight + root.margenSuperior
                    : pasosColumn.implicitHeight + root.margenSuperior

    height: implicitHeight

    // =====================================================
    // MODO VERTICAL
    // =====================================================

    Column {
        id: pasosColumn

        visible: root.esVertical

        x: root.margenIzquierdo
        y: root.margenSuperior

        width: root.width
        spacing: 0

        Repeater {
            model: root.stepTitles.length

            delegate: StepIndicator {
                id: stepItemVertical

                stepNumber: index + 1
                titulo: root.stepTitles[index]

                actual: stepNumber === root.currentStep
                completado: stepNumber < root.currentStep
                ultimo: stepNumber === root.stepTitles.length

                tamanoCirculo: root.stepCircleSize
                altoPaso: root.stepHeight
                anchoTexto: root.stepTextWidth
            }
        }
    }

    // =====================================================
    // MODO HORIZONTAL
    // Diseño tipo modelo D:
    // completado = check celeste
    // actual = círculo violeta con halo
    // pendiente = blanco/gris
    // texto debajo del círculo
    // línea corta entre círculos
    // =====================================================

    Row {
        id: pasosRow

        visible: root.esHorizontal

        x: root.margenIzquierdo
        y: root.margenSuperior

        spacing: root.horizontalSpacing

        Repeater {
            model: root.stepTitles.length

            delegate: Row {
                id: stepWrapper

                spacing: root.horizontalSpacing
                height: root.horizontalStepHeight

                readonly property int stepNumber: index + 1
                readonly property bool esActual: stepNumber === root.currentStep
                readonly property bool esCompletado: stepNumber < root.currentStep
                readonly property bool esUltimo: stepNumber === root.stepTitles.length

                Item {
                    id: horizontalStep

                    width: root.horizontalStepWidth
                    height: root.horizontalStepHeight

                    // ===============================
                    // HALO DEL PASO ACTUAL
                    // ===============================

                    Rectangle {
                        id: haloActual

                        width: root.horizontalCircleSize + 9
                        height: root.horizontalCircleSize + 9
                        radius: width / 2

                        anchors.horizontalCenter: circulo.horizontalCenter
                        anchors.verticalCenter: circulo.verticalCenter

                        visible: stepWrapper.esActual

                        color: "transparent"
                        border.color: AppTheme.colorPrimario
                        border.width: 2
                        opacity: 0.30

                        z: 0

                        SequentialAnimation on scale {
                            running: stepWrapper.esActual
                            loops: Animation.Infinite

                            NumberAnimation {
                                from: 1.0
                                to: 1.18
                                duration: 900
                                easing.type: Easing.InOutQuad
                            }

                            NumberAnimation {
                                from: 1.18
                                to: 1.0
                                duration: 900
                                easing.type: Easing.InOutQuad
                            }
                        }

                        SequentialAnimation on opacity {
                            running: stepWrapper.esActual
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

                    // ===============================
                    // CÍRCULO
                    // ===============================

                    Rectangle {
                        id: circulo

                        width: root.horizontalCircleSize
                        height: root.horizontalCircleSize
                        radius: width / 2

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top

                        color: stepWrapper.esCompletado
                               ? AppTheme.colorAcento
                               : stepWrapper.esActual
                                 ? AppTheme.colorPrimario
                                 : "#FFFFFF"

                        border.width: stepWrapper.esActual ? 0 : 1
                        border.color: stepWrapper.esCompletado
                                      ? AppTheme.colorAcento
                                      : "#D6D9E0"

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

                            text: stepWrapper.esCompletado
                                  ? "✓"
                                  : stepWrapper.stepNumber.toString()

                            color: stepWrapper.esCompletado || stepWrapper.esActual
                                   ? "#FFFFFF"
                                   : AppTheme.colorTextoSecundario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: stepWrapper.esCompletado ? 18 : 15
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // ===============================
                    // TEXTO DEBAJO DEL CÍRCULO
                    // ===============================

                    Column {
                        id: textoPaso

                        anchors.top: circulo.bottom
                        anchors.topMargin: 6
                        anchors.horizontalCenter: circulo.horizontalCenter

                        width: parent.width
                        spacing: 0

                        Text {
                            text: "Paso " + stepWrapper.stepNumber

                            width: parent.width

                            visible: stepWrapper.esActual || stepWrapper.esCompletado

                            color: stepWrapper.esCompletado
                                   ? AppTheme.colorAcento
                                   : AppTheme.colorPrimario

                            font.family: AppTheme.fuenteCuerpo
                            font.pixelSize: 9
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        Text {
                            text: root.stepTitles[index]

                            width: parent.width

                            color: stepWrapper.esActual
                                   ? AppTheme.colorTextoPrincipal
                                   : stepWrapper.esCompletado
                                     ? AppTheme.colorTextoPrincipal
                                     : AppTheme.colorTextoSecundario

                            font.family: AppTheme.fuenteTitulo
                            font.pixelSize: stepWrapper.esActual ? 11 : 10
                            font.bold: stepWrapper.esActual || stepWrapper.esCompletado

                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }

                // ===============================
                // LÍNEA CORTA ENTRE CÍRCULOS
                // ===============================

                Rectangle {
                    id: lineaHorizontal

                    visible: !stepWrapper.esUltimo

                    width: root.horizontalLineWidth
                    height: root.horizontalLineHeight
                    radius: height / 2

                    anchors.top: parent.top
                    anchors.topMargin: (root.horizontalCircleSize - height) / 2

                    color: stepWrapper.esCompletado
                           ? AppTheme.colorAcento
                           : "#D6D9E0"

                    opacity: stepWrapper.esCompletado ? 0.95 : 0.75

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }
                }
            }
        }
    }
}