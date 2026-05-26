// UI / Structures / SectionOne.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Theme 1.0
import Layout 1.0
import Structures 1.0


Rectangle {
    id: root

    color: "#f3f2f2"

    signal altaSolicitada()
    signal bajaSolicitada()
    signal configuracionSedeSolicitada()
    signal historialSolicitado()
    signal listaAsistenciaSolicitada()
    signal registrarDestinatarioSolicitado()

    Component.onCompleted: {
    console.log("[TEST JADELAYOUT] Card height:", JadeLayout.actionCardHeight)
    console.log("[TEST JADELAYOUT] Columnas:", JadeLayout.actionGridColumns)
}

    Flickable {
        id: scrollArea

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footerContainer.top

        clip: true

        contentWidth: width
        contentHeight: pagina.implicitHeight

        Column {
            id: pagina

            width: scrollArea.width
            spacing: 0

            // =====================================================
            // SECCIÓN 1 - HOME HEADER FULL WIDTH
            // =====================================================

            Rectangle {
                id: headerContainer

                width: parent.width
                height: AppLayout.homeHeaderHeight

                radius: 0
                color: AppTheme.colorSuperficieAlternativa
                border.width: 0
                clip: true

                HomeHeader {
                    id: homeHeader
                    anchors.fill: parent
                    modoHeader: "home"
                    titulo: "Bienvenido"
                    descripcion: "Desde aquí podés gestionar las solicitudes de destino de menores de forma simple y segura."
                    formularioSource: "qrc:/qml/UI/Assets/form.png"
                    z: 0
                }
            }

            Item {
                width: parent.width
                height: JadeLayout.homeToActionsSpacing
            }

            // =====================================================
            // SECCIÓN 2 - ACCIONES + NEX EN LA MISMA FILA
            // =====================================================

            Item {
                id: middleSection

                width: parent.width
                height: Math.max(acciones.implicitHeight, contenedorNex.height)

                Row {
                    id: filaAccionesRobot

                    anchors.left: parent.left
                    anchors.leftMargin: JadeLayout.margenContenidoDesdeSidebar
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 2

                    ActionCardsGrid {
                        id: acciones

                        onRegistrarDestinatarioClicked: root.registrarDestinatarioSolicitado()
                        onNuevaAltaClicked: root.altaSolicitada()
                        onNuevaBajaClicked: root.bajaSolicitada()
                        onConfiguracionSedeClicked: root.configuracionSedeSolicitada()
                        onHistorialClicked: root.historialSolicitado()
                        onListaAsistenciaClicked: root.listaAsistenciaSolicitada()
                    }

                    Item {
                        id: contenedorNex
                        visible: root.width >= JadeLayout.anchoMinimoMostrarRobotHome
                        width: 640
                        height: 600

                        anchors.verticalCenter: acciones.verticalCenter

                        // =====================================================
                        // CUADRO DE DIÁLOGO DE NEX
                        // =====================================================

                        Item {
                            id: contenedorDialogo

                            width: 380
                            height: 360

                            anchors.left: parent.left
                            anchors.leftMargin: -10
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            z: 2

                            Image {
                                id: imgCuadroDialogo

                                anchors.fill: parent
                                source: "qrc:/qml/UI/Assets/cuadro_dialogo.png"
                                fillMode: Image.Stretch
                                smooth: true
                            }
                        }

                        // =====================================================
                        // ROBOT NEX ANIMADO
                        // =====================================================

                        Item {
                            id: contenedorRobot

                            width: 430
                            height: 430

                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 22
                            

                            transform: Translate {
                                id: desplazamientoRobot
                                y: 0
                            }

                            Image {
                                id: imgNexJadeBase

                                anchors.fill: parent
                                source: "qrc:/qml/UI/Assets/robot.png"
                                fillMode: Image.PreserveAspectFit
                                opacity: 1.0
                                smooth: true
                                
                            }

                            Image {
                                id: imgNexJadeFlotando

                                anchors.fill: parent
                                source: "qrc:/qml/UI/Assets/robot2.png"
                                fillMode: Image.PreserveAspectFit
                                opacity: 0.0
                                smooth: true
                            }

                            SequentialAnimation {
                                running: true
                                loops: Animation.Infinite

                                // Sube
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: desplazamientoRobot
                                        property: "y"
                                        from: 0
                                        to: -18
                                        duration: 1700
                                        easing.type: Easing.InOutSine
                                    }

                                    NumberAnimation {
                                        target: imgNexJadeBase
                                        property: "opacity"
                                        from: 1.0
                                        to: 0.0
                                        duration: 1700
                                        easing.type: Easing.InOutSine
                                    }

                                    NumberAnimation {
                                        target: imgNexJadeFlotando
                                        property: "opacity"
                                        from: 0.0
                                        to: 1.0
                                        duration: 1700
                                        easing.type: Easing.InOutSine
                                    }
                                }

                                PauseAnimation {
                                    duration: 200
                                }

                                // Baja
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: desplazamientoRobot
                                        property: "y"
                                        from: -18
                                        to: 0
                                        duration: 1700
                                        easing.type: Easing.InOutSine
                                    }

                                    NumberAnimation {
                                        target: imgNexJadeBase
                                        property: "opacity"
                                        from: 0.0
                                        to: 1.0
                                        duration: 1700
                                        easing.type: Easing.InOutSine
                                    }

                                    NumberAnimation {
                                        target: imgNexJadeFlotando
                                        property: "opacity"
                                        from: 1.0
                                        to: 0.0
                                        duration: 1700
                                        easing.type: Easing.InOutSine
                                    }
                                }

                                PauseAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }
                }
            }

            // Espacio final para que el contenido no quede pegado al footer
            Item {
                width: parent.width
                height: AppTheme.spacingXl
            }
        }
    }

    // =====================================================
    // FOOTER FIJO ANCLADO ABAJO
    // =====================================================

    Rectangle {
        id: footerContainer

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 30

        color: "#ffffff"
        clip: true

        Text {
            anchors.centerIn: parent

            text: "SISTEMA JADE V1.0"
            color: "black"

            font.family: AppTheme.fuenteTitulo
            font.pixelSize: 16
            font.weight: AppTheme.fontWeightBold
        }
    }
}

