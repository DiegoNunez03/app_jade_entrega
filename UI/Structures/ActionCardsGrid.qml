// UI / Structures / ActionsCardsGrid.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Theme 1.0
import Components 1.0
import Layout 1.0


Item {
    id: root
    
    implicitWidth: JadeLayout.actionGridWidth
    implicitHeight: contenido.implicitHeight

    width: implicitWidth
    height: implicitHeight

    readonly property int columnasCalculadas: width < JadeLayout.actionGridBreakpointDosColumnas
                                               ? 2
                                               : JadeLayout.actionGridColumns

    signal registrarDestinatarioClicked()
    signal historialClicked()
    signal listaAsistenciaClicked()
    signal nuevaAltaClicked()
    signal nuevaBajaClicked()
    signal configuracionSedeClicked()

    Column {
        id: contenido

        anchors.left: parent.left
        anchors.right: parent.right

        spacing: AppTheme.spacingXl

        Text {
            text: "Acciones principales"

            color: AppTheme.colorTextoSecundario

            font.family: AppTheme.fuenteTitulo
            font.pixelSize: AppTheme.fontSizeSectionTitle
            font.weight: AppTheme.pesoTituloSeccion
        }

        GridLayout {
            id: grid

            width: parent.width
            columns: root.columnasCalculadas

            columnSpacing: JadeLayout.actionGridColumnSpacing
            rowSpacing: JadeLayout.actionGridRowSpacing

            ActionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: JadeLayout.actionCardHeight

                titulo: "Registrar destinatario"
                descripcion: "Completá los datos del destinatario para iniciar una nueva solicitud."
                iconoSource: "qrc:/qml/UI/Assets/icon/nuevo_destinatario_accion.png"
                iconoColor: AppTheme.colorAcento
                iconoFondo: AppTheme.colorAcentoSuave

                onClicked: root.registrarDestinatarioClicked()
            }

            ActionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: JadeLayout.actionCardHeight

                titulo: "Solicitudes generadas"
                descripcion: "Consultá y abrí las solicitudes de alta generadas por el sistema."
                iconoSource: "qrc:/qml/UI/Assets/icon/solicitud_generada_accion.png"
                iconoColor: AppTheme.colorAcento
                iconoFondo: AppTheme.colorAcentoSuave

                onClicked: root.historialClicked()
            }

            ActionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: JadeLayout.actionCardHeight

                titulo: "Lista de asistencia"
                descripcion: "Consultá o generá la lista de asistencia de la sede."
                iconoSource: "qrc:/qml/UI/Assets/icon/lista_accion.png"
                iconoColor: AppTheme.colorPrimario
                iconoFondo: AppTheme.colorPrimarioSuave

                onClicked: root.listaAsistenciaClicked()
            }

            ActionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: JadeLayout.actionCardHeight

                titulo: "Nueva alta"
                descripcion: "Iniciá una nueva solicitud de destino para un menor."
                iconoSource: "qrc:/qml/UI/Assets/icon/nueva_alta_accion.png"
                iconoColor: AppTheme.colorPrimario
                iconoFondo: AppTheme.colorPrimarioSuave

                onClicked: root.nuevaAltaClicked()
            }

            ActionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: JadeLayout.actionCardHeight

                titulo: "Nueva baja"
                descripcion: "Registrá la baja de una solicitud de destino existente."
                icono: "−"
                iconoColor: "#C02C8C"
                iconoFondo: "#FBEAF6"

                onClicked: root.nuevaBajaClicked()
            }

            ActionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: JadeLayout.actionCardHeight

                titulo: "Configuración de sede"
                descripcion: "Gestioná los datos y preferencias de tu sede."
                iconoSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"
                iconoColor: AppTheme.colorPrimario
                iconoFondo: AppTheme.colorPrimarioSuave

                onClicked: root.configuracionSedeClicked()
            }
        }
    }
}



// // UI / Structures / ActionsCardsGrid.qml
// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts

// import Theme 1.0
// import Components 1.0
// import Layout 1.0


// Item {
//     id: root

//     implicitWidth: 1000
//     implicitHeight: contenido.implicitHeight

//     height: implicitHeight
    
//     // readonly property int columnasCalculadas: width < 760 ? 2 : JadeLayout.actionGridColumns
//     // readonly property int columnasCalculadas: width < JadeLayout.actionGridBreakpointDosColumnas ? 2 : JadeLayout.actionGridColumns

//     readonly property int columnasCalculadas: width < JadeLayout.actionGridBreakpointDosColumnas ? 2 : JadeLayout.actionGridColumns

//     signal registrarDestinatarioClicked()
//     signal historialClicked()
//     signal listaAsistenciaClicked()
//     signal nuevaAltaClicked()
//     signal nuevaBajaClicked()
//     signal configuracionSedeClicked()

//     Column {
//         id: contenido

//         anchors.left: parent.left
//         anchors.right: parent.right
//         spacing: AppTheme.spacingXl

//         Text {
//             text: "Acciones principales"

//             color: AppTheme.colorTextoSecundario

//             font.family: AppTheme.fuenteTitulo
//             font.pixelSize: AppTheme.fontSizeSectionTitle
//             font.weight: AppTheme.pesoTituloSeccion
//         }

//         GridLayout {
//             id: grid

//             width: parent.width
//             columns: root.columnasCalculadas

//             // columnSpacing: AppLayout.actionGridColumnSpacing
//             // rowSpacing: AppLayout.actionGridRowSpacing
//             columnSpacing: JadeLayout.actionGridColumnSpacing
// rowSpacing: JadeLayout.actionGridRowSpacing
//             // Layout.preferredHeight: JadeLayout.actionCardHeight

//             ActionCard {
//                 Layout.fillWidth: true
//                 // Layout.preferredHeight: AppLayout.actionCardHeight
//                 Layout.preferredHeight: JadeLayout.actionCardHeight

//                 titulo: "Registrar destinatario"
//                 descripcion: "Completá los datos del destinatario para iniciar una nueva solicitud."
//                 iconoSource: "qrc:/qml/UI/Assets/icon/nuevo_destinatario_accion.png"
//                 iconoColor: AppTheme.colorAcento
//                 iconoFondo: AppTheme.colorAcentoSuave

//                 onClicked: root.registrarDestinatarioClicked()
//             }

//             ActionCard {
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: AppLayout.actionCardHeight

//                 titulo: "Solicitudes generadas"
//                 descripcion: "Consultá y abrí las solicitudes de alta generadas por el sistema."
//                 iconoSource: "qrc:/qml/UI/Assets/icon/solicitud_generada_accion.png"
//                 iconoColor: AppTheme.colorAcento
//                 iconoFondo: AppTheme.colorAcentoSuave

//                 onClicked: root.historialClicked()
//             }

//             ActionCard {
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: AppLayout.actionCardHeight

//                 titulo: "Lista de asistencia"
//                 descripcion: "Consultá o generá la lista de asistencia de la sede."
//                 iconoSource: "qrc:/qml/UI/Assets/icon/lista_accion.png"
//                 iconoColor: AppTheme.colorPrimario
//                 iconoFondo: AppTheme.colorPrimarioSuave

//                 onClicked: root.listaAsistenciaClicked()
//             }

//             ActionCard {
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: AppLayout.actionCardHeight

//                 titulo: "Nueva alta"
//                 descripcion: "Iniciá una nueva solicitud de destino para un menor."
//                 iconoSource: "qrc:/qml/UI/Assets/icon/nueva_alta_accion.png"
//                 iconoColor: AppTheme.colorPrimario
//                 iconoFondo: AppTheme.colorPrimarioSuave

//                 onClicked: root.nuevaAltaClicked()
//             }

//             ActionCard {
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: AppLayout.actionCardHeight

//                 titulo: "Nueva baja"
//                 descripcion: "Registrá la baja de una solicitud de destino existente."
//                 icono: "−"
//                 iconoColor: "#C02C8C"
//                 iconoFondo: "#FBEAF6"

//                 onClicked: root.nuevaBajaClicked()
//             }

//             ActionCard {
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: AppLayout.actionCardHeight

//                 titulo: "Configuración de sede"
//                 descripcion: "Gestioná los datos y preferencias de tu sede."
//                 iconoSource: "qrc:/qml/UI/Assets/icon/icon_config.svg"
//                 iconoColor: AppTheme.colorPrimario
//                 iconoFondo: AppTheme.colorPrimarioSuave

//                 onClicked: root.configuracionSedeClicked()
//             }
//         }
//     }
// }