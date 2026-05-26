pragma Singleton

import QtQuick

QtObject {
    id: root

    // =====================================================
    // VIEWPORT ACTUAL
    // =====================================================

    property int viewportWidth: 1400
    property int viewportHeight: 920

    function actualizarViewport(ancho, alto) {
        viewportWidth = ancho
        viewportHeight = alto
    }

    // =====================================================
    // BREAKPOINTS DEL SISTEMA
    // =====================================================

    readonly property int breakpointCompacto: 1000
    readonly property int breakpointAmplio: 1300
    readonly property int breakpointMaximizado: 1700

    readonly property bool esCompacto: viewportWidth < breakpointCompacto

    readonly property bool esBase: viewportWidth >= breakpointCompacto
                                   && viewportWidth < breakpointAmplio

    readonly property bool esAmplio: viewportWidth >= breakpointAmplio
                                     && viewportWidth < breakpointMaximizado

    readonly property bool esMaximizado: viewportWidth >= breakpointMaximizado

    readonly property string modoActual: esCompacto
                                         ? "compacto"
                                         : esBase
                                           ? "base"
                                           : esAmplio
                                             ? "amplio"
                                             : "maximizado"

    // =====================================================
    // MEDIDAS HOME / SECTION ONE
    // =====================================================

    readonly property int margenContenidoDesdeSidebar: esMaximizado ? 48 : 44

    readonly property int anchoMinimoMostrarRobotHome: 1500

    readonly property int actionGridColumns: esCompacto ? 2 : 3

    readonly property int homeToActionsSpacing: esCompacto ? 24
                                      : esBase ? - 20
                                      : esAmplio ? 24
                                      : 36

    readonly property int actionGridColumnSpacing: esCompacto ? 20
                                               : esBase ? 24
                                               : esAmplio ? 28
                                               : 32

    readonly property int actionGridRowSpacing: esCompacto ? 20
                                            : esBase ? 24
                                            : esAmplio ? 28
                                            : 32

    readonly property int actionCardHeight: esCompacto ? 160
                                        : esBase ? 170
                                        : esAmplio ? 175
                                        : 190

    readonly property int actionGridBreakpointDosColumnas: 760

    readonly property int actionGridWidth: esCompacto
                                        ? Math.max(620, viewportWidth - margenContenidoDesdeSidebar * 2)
                                        : esMaximizado
                                         ? 1000
                                         : 1000

    readonly property int actionCardIconSize: esCompacto ? 70
                                      : esBase ? 78
                                      : esAmplio ? 82
                                      : 86

    readonly property int actionCardIconFontSize: esCompacto ? 30
                                          : esBase ? 36
                                          : esAmplio ? 38
                                          : 40

    readonly property int actionCardTitleSize: esCompacto ? 17
                                        : esBase ? 18
                                        : esAmplio ? 19
                                        : 20

    readonly property int actionCardDescriptionSize: esCompacto ? 13
                                              : esBase ? 14
                                              : esAmplio ? 14
                                              : 15

    // =====================================================
    // DEBUG
    // =====================================================

    function imprimirDiagnostico() {
        console.log("====================================")
        console.log("LAYOUT JADE")
        console.log("Viewport:", viewportWidth + "x" + viewportHeight)
        console.log("Modo actual:", modoActual)
        console.log("Compacto:", esCompacto)
        console.log("Base:", esBase)
        console.log("Amplio:", esAmplio)
        console.log("Maximizado:", esMaximizado)
        console.log("Margen sidebar:", margenContenidoDesdeSidebar)
        console.log("Columnas acciones:", actionGridColumns)
        console.log("Action card height:", actionCardHeight)
        console.log("====================================")
    }
}

