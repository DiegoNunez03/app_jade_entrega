// AppLayout.qml
pragma Singleton

import QtQuick

QtObject {
    id: root

    // =====================================================
    // VIEWPORT ACTUAL
    // =====================================================

    property int viewportWidth: 1100
    property int viewportHeight: 920

    function actualizarViewport(ancho, alto) {
        viewportWidth = ancho
        viewportHeight = alto
    }

    // =====================================================
    // BREAKPOINTS DEL SISTEMA
    // =====================================================

    readonly property int breakpointInicial: 1000
    readonly property int breakpointAmplio: 1300
    readonly property int breakpointFullScreen: 1700

    readonly property bool esCompacto: viewportWidth < breakpointInicial

    readonly property bool esInicial: viewportWidth >= breakpointInicial
                                      && viewportWidth < breakpointAmplio

    readonly property bool esAmplio: viewportWidth >= breakpointAmplio
                                     && viewportWidth < breakpointFullScreen

    readonly property bool esFullScreen: viewportWidth >= breakpointFullScreen

    readonly property string modoActual: esCompacto
                                         ? "compacto"
                                         : esInicial
                                           ? "inicial"
                                           : esAmplio
                                             ? "amplio"
                                             : "full_screen"

    // =====================================================
    // MEDIDAS GENERALES DE CONTENIDO
    // =====================================================

    readonly property int margenHorizontal: esCompacto ? 32
                                        : esInicial ? 44
                                        : esAmplio ? 44
                                        : 64

    readonly property int contenidoMaxWidth: esCompacto ? 900
                                          : esInicial ? 1100
                                          : esAmplio ? 1280
                                          : 1500

    readonly property int contenidoTopMargin: esCompacto ? 28
                                           : esInicial ? 32
                                           : esAmplio ? 36
                                           : 42

    readonly property int seccionSpacing: esCompacto ? 26
                                      : esInicial ? 32
                                      : esAmplio ? 36
                                      : 40

    // =====================================================
    // SEPARACIONES ENTRE SECCIONES
    // =====================================================

    readonly property int homeToActionsSpacing: esCompacto ? 24
                                            : esInicial ? 50
                                            : esAmplio ? 32
                                            : 36

    readonly property int actionsToFooterSpacing: esCompacto ? 36
                                              : esInicial ? 179
                                              : esAmplio ? 56
                                              : 200

    // =====================================================
    // FOOTER
    // =====================================================

    readonly property int footerHeight: esCompacto ? 130
                                    : esInicial ? 50
                                    : esAmplio ? 160
                                    : 170

    // =====================================================
    // HOME HEADER - CONTENEDOR
    // =====================================================

    readonly property int homeHeaderHeight: esCompacto ? 210
                                        : esInicial ? 230
                                        : esAmplio ? 240
                                        : 250

    readonly property int homeHeaderTitleSize: esCompacto ? 32
                                           : esInicial ? 40
                                           : esAmplio ? 42
                                           : 44

    readonly property int homeHeaderDescriptionSize: esCompacto ? 14
                                                 : esInicial ? 16
                                                 : esAmplio ? 16
                                                 : 16

    readonly property int homeHeaderTextMaxWidth: esCompacto ? 430
                                             : esInicial ? 560
                                             : esAmplio ? 600
                                             : 640

    // =====================================================
    // HOME HEADER - TEXTO
    // =====================================================

    readonly property int homeHeaderTextLeftMargin: esCompacto ? 28
                                                : esInicial ? 54
                                                : esAmplio ? 70
                                                : 90

    readonly property int homeHeaderTextVerticalOffset: esCompacto ? -10
                                                    : esInicial ? -18
                                                    : esAmplio ? -22
                                                    : -24

    // =====================================================
    // HOME HEADER - ONDAS
    // =====================================================

    /*
        Las ondas ahora viven dentro de HomeHeader.qml.
        HomeHeader.qml debería usar:
        - AppLayout.homeHeaderWavesSource
        - AppLayout.homeHeaderWavesHeightFactor
        - AppLayout.homeHeaderWavesOpacity
    */

    readonly property bool homeHeaderMostrarDecoracion: viewportWidth >= breakpointInicial

    readonly property string homeHeaderWavesSource: esCompacto
                                                    ? "qrc:/qml/UI/Assets/waves_compacto.png"
                                                    : esFullScreen
                                                      ? "qrc:/qml/UI/Assets/waves_fullscreen.png"
                                                      : "qrc:/qml/UI/Assets/waves_inicial.png"

    readonly property real homeHeaderWavesHeightFactor: esCompacto ? 0.55
                                                     : esInicial ? 1.20
                                                     : esAmplio ? 0.78
                                                     : 1.70

    readonly property real homeHeaderWavesOpacity: esCompacto ? 0.45
                                                : esInicial ? 0.60
                                                : esAmplio ? 0.64
                                                : 0.68

    // =====================================================
    // HOME HEADER - IMAGEN FORMULARIO / ILUSTRACIÓN
    // =====================================================

    /*
        La imagen del formulario también vive dentro de HomeHeader.qml.

        HomeHeader.qml debería exponer:
        property string formularioSource: ""

        Y usar estas propiedades solo para posición/tamaño.
    */

    readonly property bool homeHeaderMostrarFormulario: viewportWidth >= breakpointInicial

    readonly property real homeHeaderFormWidthFactor: esCompacto ? 0.32
                                                   : esInicial ? 0.60
                                                   : esAmplio ? 0.30
                                                   : 0.26

    readonly property real homeHeaderFormHeightFactor: esCompacto ? 0.95
                                                    : esInicial ? 1.50
                                                    : esAmplio ? 1.00
                                                    : 0.95

    readonly property int homeHeaderFormRightMargin: esCompacto ? 30
                                                  : esInicial ? -80
                                                  : esAmplio ? 180
                                                  : 260

    readonly property int homeHeaderFormVerticalOffset: esCompacto ? 8
                                                     : esInicial ? 4
                                                     : esAmplio ? 2
                                                     : 0

    // =====================================================
    // ACTION CARDS GRID
    // =====================================================

    readonly property int actionGridColumns: esCompacto ? 2 : 3

    readonly property int actionCardHeight: esCompacto ? 180
                                        : esInicial ? 170
                                        : esAmplio ? 175
                                        : 180

    readonly property int actionGridColumnSpacing: esCompacto ? 20
                                               : esInicial ? 24
                                               : esAmplio ? 28
                                               : 32

    readonly property int actionGridRowSpacing: esCompacto ? 20
                                            : esInicial ? 24
                                            : esAmplio ? 28
                                            : 32

    // =====================================================
    // ACTION CARD
    // =====================================================

    readonly property int actionCardIconSize: esCompacto ? 70
                                          : esInicial ? 78
                                          : esAmplio ? 82
                                          : 86

    readonly property int actionCardIconFontSize: esCompacto ? 30
                                              : esInicial ? 36
                                              : esAmplio ? 38
                                              : 40

    readonly property int actionCardTitleSize: esCompacto ? 17
                                            : esInicial ? 18
                                            : esAmplio ? 19
                                            : 20

    readonly property int actionCardDescriptionSize: esCompacto ? 13
                                                  : esInicial ? 14
                                                  : esAmplio ? 14
                                                  : 15

    // Esta propiedad queda por compatibilidad si algún archivo viejo todavía la usa.
    // Si ya eliminaste definitivamente la flecha de ActionCard.qml, después la podemos borrar.
    readonly property int actionCardArrowSize: esCompacto ? 38
                                            : esInicial ? 42
                                            : esAmplio ? 44
                                            : 46



    // =====================================================
    // FORM HEADER
    // =====================================================

    readonly property int formHeaderHeight: esCompacto ? 170
                                    : esInicial ? 190
                                    : esAmplio ? 200
                                    : 210

    readonly property int formContentTopSpacing: esCompacto ? 24
                                         : esInicial ? 30
                                         : esAmplio ? 34
                                         : 38




    // =====================================================
// FORMULARIOS - ÁREA PRINCIPAL
// =====================================================

readonly property int formAreaTopSpacing: esCompacto ? 36
                                      : esInicial ? 42
                                      : esAmplio ? 46
                                      : 50

readonly property int formAreaHorizontalMargin: esCompacto ? 28
                                             : esInicial ? 44
                                             : esAmplio ? 56
                                             : 72

readonly property int formAreaPadding: esCompacto ? 22
                                    : esInicial ? 28
                                    : esAmplio ? 32
                                    : 36

readonly property int formStepsToContentSpacing: esCompacto ? 24
                                              : esInicial ? 32
                                              : esAmplio ? 36
                                              : 42

readonly property int formStepsWidth: esCompacto ? 120
                                   : esInicial ? 150
                                   : esAmplio ? 165
                                   : 180






    // =====================================================
    // DEBUG
    // =====================================================

    function imprimirDiagnostico() {
        console.log("====================================")
        console.log("APP LAYOUT")
        console.log("Viewport:", viewportWidth + "x" + viewportHeight)
        console.log("Modo actual:", modoActual)

        console.log("Compacto:", esCompacto)
        console.log("Inicial:", esInicial)
        console.log("Amplio:", esAmplio)
        console.log("Full screen:", esFullScreen)

        console.log("Margen horizontal:", margenHorizontal)
        console.log("Contenido max width:", contenidoMaxWidth)
        console.log("Contenido top margin:", contenidoTopMargin)
        console.log("Section spacing:", seccionSpacing)

        console.log("Header height:", homeHeaderHeight)
        console.log("Header title size:", homeHeaderTitleSize)
        console.log("Header description size:", homeHeaderDescriptionSize)
        console.log("Header text max width:", homeHeaderTextMaxWidth)
        console.log("Header text left margin:", homeHeaderTextLeftMargin)
        console.log("Header text vertical offset:", homeHeaderTextVerticalOffset)

        console.log("Waves source:", homeHeaderWavesSource)
        console.log("Waves height factor:", homeHeaderWavesHeightFactor)
        console.log("Waves opacity:", homeHeaderWavesOpacity)

        console.log("Formulario visible:", homeHeaderMostrarFormulario)
        console.log("Formulario width factor:", homeHeaderFormWidthFactor)
        console.log("Formulario height factor:", homeHeaderFormHeightFactor)
        console.log("Formulario right margin:", homeHeaderFormRightMargin)
        console.log("Formulario vertical offset:", homeHeaderFormVerticalOffset)

        console.log("Columnas acciones:", actionGridColumns)
        console.log("Action card height:", actionCardHeight)
        console.log("====================================")
    }
}