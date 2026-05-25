pragma Singleton

import QtQuick 

QtObject {
    id: layout

    // ============================================================
    // PERFIL BASE
    // ============================================================

    readonly property string perfil: "base"

    // ============================================================
    // VENTANA
    // ============================================================

    readonly property int ventanaAnchoBase: 1100
    readonly property int ventanaAltoBase: 920

    readonly property int ventanaAnchoMinimo: 1000
    readonly property int ventanaAltoMinimo: 720

    // ============================================================
    // SECCIONES
    // ============================================================

    readonly property int margenSeccionHorizontal: 48
    readonly property int margenSeccionVertical: 36


    // Margenes

    readonly property int margenContenidoDesdeSidebar: 100

}