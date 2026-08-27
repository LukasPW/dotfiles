pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "{{colors.background.default.hex}}"

    readonly property color primary: "{{colors.primary.default.hex}}"
    readonly property color secondary: "{{colors.secondary.default.hex}}"
    readonly property color tertiary: "{{colors.tertiary.default.hex}}"
    readonly property color error: "{{colors.error.default.hex}}"

    readonly property color outline: "{{colors.outline.default.hex}}"
    readonly property color surfaceContainer: "{{colors.surface_container.default.hex}}"

    readonly property int radius: 12
    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeSmall: 14
    readonly property int fontSizeLarge: 20
}
