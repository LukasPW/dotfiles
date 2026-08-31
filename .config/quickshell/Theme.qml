pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#131318"

    readonly property color primary: "#c4c0ff"
    readonly property color secondary: "#c7c4dc"
    readonly property color tertiary: "#ebb9d0"
    readonly property color error: "#ffb4ab"

    readonly property color outline: "#928f99"
    readonly property color surfaceContainer: "#201f25"

    readonly property int radius: 12
    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeSmall: 14
    readonly property int fontSizeLarge: 20
}
