// AppTheme.qml
pragma Singleton

import QtQuick

QtObject {

    // =====================================================
    // TIPOGRAFÍA
    // =====================================================

    /*
        Estrategia tipográfica del sistema:

        La interfaz fue diseñada visualmente pensando en "Inter".
        Como no todos los sistemas tienen esa fuente instalada,
        Python podrá detectar la mejor fuente disponible y asignarla
        a la propiedad fuenteActiva.

        Orden recomendado de prioridad:

        1. Inter
        2. Segoe UI          // Windows
        3. Noto Sans         // Linux moderno
        4. DejaVu Sans       // Linux común
        5. Liberation Sans   // Linux / LibreOffice / entornos libres
        6. Arial             // Windows / compatibilidad
        7. Sans Serif        // fallback genérico de Qt
    */

    readonly property string fuentePrimaria: "Inter"
    readonly property string fuenteSecundariaWindows: "Segoe UI"
    readonly property string fuenteSecundariaLinux: "Noto Sans"
    readonly property string fuenteSecundariaLinuxAlternativa: "DejaVu Sans"
    readonly property string fuenteSecundariaLibre: "Liberation Sans"
    readonly property string fuenteSecundariaCompatibilidad: "Arial"
    readonly property string fuenteGenerica: "Sans Serif"

    /*
        Esta NO es readonly porque puede ser modificada desde QML
        después de que Python detecte la fuente disponible.

        Ejemplo:
        AppTheme.fuenteActiva = fuenteManager.fuenteActiva
    */
    property string fuenteActiva: fuentePrimaria

    // Fuentes por rol visual
    property string fuenteTitulo: fuenteActiva
    property string fuenteSubtitulo: fuenteActiva
    property string fuenteCuerpo: fuenteActiva
    property string fuenteEtiqueta: fuenteActiva
    property string fuenteInput: fuenteActiva
    property string fuenteBoton: fuenteActiva
    property string fuenteError: fuenteActiva
    property string fuenteNavegacion: fuenteActiva
    property string fuenteStepper: fuenteActiva
    property string fuenteBadge: fuenteActiva


    // =====================================================
    // TAMAÑOS DE FUENTE
    // =====================================================

    property int fontSizeHeroTitle: 40
    property int fontSizeScreenTitle: 32
    property int fontSizeFormTitle: 30
    property int fontSizeSectionTitle: 22
    property int fontSizeCardTitle: 18

    property int fontSizeBody: 16
    property int fontSizeBodySmall: 14

    property int fontSizeLabel: 15
    property int fontSizeInput: 15
    property int fontSizeButton: 16

    property int fontSizeHelper: 13
    property int fontSizeError: 13

    property int fontSizeNavigation: 15

    property int fontSizeStepperLabel: 13
    property int fontSizeStepperText: 14
    property int fontSizeStepperNumber: 20

    property int fontSizeBadge: 13


    // =====================================================
    // PESOS DE FUENTE
    // =====================================================

    readonly property int fontWeightLight: Font.Light
    readonly property int fontWeightRegular: Font.Normal
    readonly property int fontWeightMedium: Font.Medium
    readonly property int fontWeightSemiBold: Font.DemiBold
    readonly property int fontWeightBold: Font.Bold
    readonly property int fontWeightExtraBold: Font.ExtraBold

    // Pesos recomendados por uso visual
    property int pesoTituloHero: fontWeightExtraBold
    property int pesoTituloPantalla: fontWeightBold
    property int pesoTituloFormulario: fontWeightBold
    property int pesoTituloSeccion: fontWeightBold
    property int pesoTituloTarjeta: fontWeightSemiBold

    property int pesoTextoNormal: fontWeightRegular
    property int pesoTextoSecundario: fontWeightRegular

    property int pesoEtiqueta: fontWeightSemiBold
    property int pesoInput: fontWeightRegular
    property int pesoBoton: fontWeightSemiBold
    property int pesoError: fontWeightMedium

    property int pesoNavegacionActiva: fontWeightSemiBold
    property int pesoNavegacionInactiva: fontWeightMedium

    property int pesoStepperActivo: fontWeightSemiBold
    property int pesoStepperInactivo: fontWeightMedium

    property int pesoBadge: fontWeightMedium


    // =====================================================
    // COLORES BASE
    // =====================================================

    property color colorFondo: "#F3F3F4"
    property color colorSuperficie: "#FAFAFC"
    property color colorSuperficieAlternativa: "#FFFFFF"

    property color colorBorde: "#D8DAE0"
    property color colorBordeSuave: "#ECEEF3"
    property color colorSeparador: "#E3E5EA"


    // =====================================================
    // COLORES DE TEXTO
    // =====================================================

    property color colorTextoPrincipal: "#161F2E"
    property color colorTextoSecundario: "#62656F"
    property color colorTextoInactivo: "#9A9CA4"
    property color colorPlaceholder: "#8E95A8"
    property color colorTextoClaro: "#FFFFFF"


    // =====================================================
    // COLORES PRINCIPALES DEL SISTEMA
    // =====================================================

    property color colorPrimario: "#704ECC"
    property color colorPrimarioOscuro: "#5838B6"
    property color colorPrimarioSecundario: "#896FCC"
    property color colorPrimarioSuave: "#F0EBFF"
    property color colorLavanda: "#C7B8E2"


    // =====================================================
    // COLORES TURQUESA / CELESTE
    // =====================================================

    property color colorAcento: "#0BD3E9"
    property color colorAcentoClaro: "#58E0F0"
    property color colorCelesteDecorativo: "#B8CAEB"
    property color colorAcentoSuave: "#E6FBFD"


    // =====================================================
    // COLORES DE ESTADO
    // =====================================================

    property color colorExito: "#19C37D"
    property color colorExitoSuave: "#DDF8EA"

    property color colorAdvertencia: "#F59E0B"
    property color colorAdvertenciaSuave: "#FFF3D8"

    property color colorError: "#F55D5A"
    property color colorErrorLinea: "#F61A17"
    property color colorErrorSuave: "#FFE7E6"

    property color colorInfo: "#2D8CFF"
    property color colorInfoSuave: "#E5F1FF"


    // =====================================================
    // INPUTS / FORMULARIOS
    // =====================================================

    property color inputFondo: "#FFFFFF"
    property color inputBorde: "#D8DAE0"
    property color inputBordeFocus: colorPrimario
    property color inputBordeError: colorErrorLinea
    property color inputTexto: colorTextoPrincipal
    property color inputPlaceholder: colorPlaceholder
    property color inputLabel: colorPrimario
    property color inputDeshabilitadoFondo: "#F4F5F8"
    property color inputDeshabilitadoTexto: colorTextoInactivo

    property int inputHeight: 48
    property int inputRadius: 8
    property int inputBorderWidth: 1
    property int inputHorizontalPadding: 14
    property int inputVerticalPadding: 10


    // =====================================================
    // BOTONES
    // =====================================================

    property color botonPrimarioFondo: colorPrimario
    property color botonPrimarioFondoHover: colorPrimarioOscuro
    property color botonPrimarioTexto: "#FFFFFF"

    property color botonSecundarioFondo: "#FFFFFF"
    property color botonSecundarioBorde: "#D8CCFF"
    property color botonSecundarioTexto: colorPrimario

    property color botonDeshabilitadoFondo: "#E6E8EF"
    property color botonDeshabilitadoTexto: "#9A9CA4"

    property int botonHeight: 48
    property int botonRadius: 9
    property int botonMinWidth: 140
    property int botonHorizontalPadding: 22


    // =====================================================
    // TARJETAS / PANELES
    // =====================================================

    property color cardFondo: "#FFFFFF"
    property color cardBorde: "#ECEEF3"

    property int cardRadius: 16
    property int cardPadding: 24
    property int cardSpacing: 18

    property int bannerRadius: 18
    property int bannerPadding: 32
    property int bannerHeight: 260


    // =====================================================
    // STEPPER
    // =====================================================

    property color stepperActivoFondo: colorPrimario
    property color stepperCompletadoFondo: colorAcento
    property color stepperInactivoFondo: "#B8BEC9"

    property color stepperActivoTexto: "#FFFFFF"
    property color stepperInactivoTexto: colorTextoInactivo

    property color stepperLineaActiva: colorAcento
    property color stepperLineaInactiva: "#D8DAE0"

    property int stepperCircleSize: 34
    property int stepperLineWidth: 2
    property int stepperSpacing: 26


    // =====================================================
    // NAVBAR
    // =====================================================

    property color navFondo: "#FFFFFF"

    property color navTextoActivo: colorPrimario
    property color navTextoInactivo: colorTextoSecundario

    property color navIndicadorActivo: colorPrimario

    property color navIconoActivo: colorPrimario
    property color navIconoInactivo: colorTextoSecundario

    property int navHeight: 72
    property int navRadius: 16
    property int navItemSpacing: 28


    // =====================================================
    // SIDEBAR / CONFIGURACIÓN
    // =====================================================

    property color sidebarFondo: "#FFFFFF"
    property color sidebarItemActivoFondo: colorPrimarioSuave
    property color sidebarItemActivoTexto: colorPrimario
    property color sidebarItemInactivoTexto: colorTextoSecundario
    property color sidebarItemHoverFondo: "#F7F4FF"

    property int sidebarWidth: 260
    property int settingsSidebarWidth: 300
    property int sidebarRadius: 16
    property int sidebarItemHeight: 48
    property int sidebarItemRadius: 10


    // =====================================================
    // ESPACIADOS GENERALES
    // =====================================================

    property int spacingXs: 4
    property int spacingSm: 8
    property int spacingMd: 12
    property int spacingLg: 16
    property int spacingXl: 24
    property int spacing2xl: 32
    property int spacing3xl: 40
    property int spacing4xl: 56

    property int screenMargin: 24
    property int screenContentSpacing: 24


    // =====================================================
    // RADIOS
    // =====================================================

    property int radiusXs: 4
    property int radiusSm: 8
    property int radiusMd: 12
    property int radiusLg: 16
    property int radiusXl: 22
    property int radiusFull: 999


    // =====================================================
    // ICONOS
    // =====================================================

    property int iconSizeXs: 14
    property int iconSizeSm: 18
    property int iconSizeMd: 22
    property int iconSizeLg: 28
    property int iconSizeXl: 38

    property color iconoPrimario: colorPrimario
    property color iconoAcento: colorAcento
    property color iconoInactivo: colorTextoInactivo


    // =====================================================
    // BADGES / CHIPS
    // =====================================================

    property int badgeHeight: 28
    property int badgeRadius: 999
    property int badgeHorizontalPadding: 12

    property color badgeExitoFondo: colorExitoSuave
    property color badgeExitoTexto: "#148F5A"

    property color badgeAdvertenciaFondo: colorAdvertenciaSuave
    property color badgeAdvertenciaTexto: "#B76B00"

    property color badgeErrorFondo: colorErrorSuave
    property color badgeErrorTexto: "#C92A25"

    property color badgeInfoFondo: colorInfoSuave
    property color badgeInfoTexto: "#176BCC"


    // =====================================================
    // SOMBRAS
    // =====================================================

    /*
        QML no aplica sombras directamente con Rectangle.
        Para sombras se puede usar MultiEffect, DropShadow o
        componentes personalizados según la versión de Qt/PySide6.

        Estos valores quedan definidos como contrato visual.
    */

    property color shadowColor: "#22000000"
    property color shadowColorSoft: "#14000000"

    property int shadowBlurSmall: 12
    property int shadowBlurMedium: 24
    property int shadowBlurLarge: 36

    property int shadowOffsetYSmall: 2
    property int shadowOffsetYMedium: 6
    property int shadowOffsetYLarge: 12


    // =====================================================
    // DIMENSIONES DE LAYOUT
    // =====================================================

    property int maxContentWidth: 1180
    property int formMaxWidth: 980
    property int formColumnGap: 24
    property int formRowGap: 18

    property int headerHeight: 260
    property int footerInfoHeight: 48


    // =====================================================
    // TRANSICIONES / ANIMACIONES
    // =====================================================

    property int animationFast: 120
    property int animationNormal: 180
    property int animationSlow: 260

    property real opacityDisabled: 0.45
    property real opacityMuted: 0.65
    property real opacityHover: 0.88


    // =====================================================
    // FUNCIONES AUXILIARES
    // =====================================================

    function aplicarFuenteDetectada(nombreFuente) {
        if (nombreFuente !== undefined && nombreFuente !== null && nombreFuente !== "") {
            fuenteActiva = nombreFuente
        }
    }

    function restaurarFuentePrimaria() {
        fuenteActiva = fuentePrimaria
    }

    function restaurarFuenteGenerica() {
        fuenteActiva = fuenteGenerica
    }
}