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
                height: AppLayout.homeToActionsSpacing
            }

            // =====================================================
            // SECCIÓN 2 - ACCIONES PRINCIPALES CON MARGEN
            // =====================================================

            Item {
                id: middleSection

                width: parent.width
                height: acciones.implicitHeight

                ActionCardsGrid {
                    id: acciones

                    width: Math.min(
                        parent.width - (AppLayout.margenHorizontal * 2),
                        AppLayout.contenidoMaxWidth
                    )

                    anchors.horizontalCenter: parent.horizontalCenter

                    onRegistrarDestinatarioClicked: root.registrarDestinatarioSolicitado()
                    onNuevaAltaClicked: root.altaSolicitada()
                    onNuevaBajaClicked: root.bajaSolicitada()
                    onConfiguracionSedeClicked: root.configuracionSedeSolicitada()
                    onHistorialClicked: root.historialSolicitado()
                    onListaAsistenciaClicked: root.listaAsistenciaSolicitada()
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