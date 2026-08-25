pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "{{colors.background.default.hex}}"

    readonly property color primary: "{{colors.primary.default.hex}}"
    readonly property color secondary: "{{colors.secondary.default.hex}}"
    readonly property color tertiary: "{{colors.tertiary.default.hex}}"
    readonly property color error: "{{colors.error.default.hex}}"

    readonly property color outline: "{{colors.outline.default.hex}}"
}
