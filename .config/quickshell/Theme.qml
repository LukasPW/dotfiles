pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#101418"

    readonly property color primary: "#9dcbfc"
    readonly property color secondary: "#bac8da"
    readonly property color tertiary: "#d4bee5"
    readonly property color error: "#ffb4ab"

    readonly property color outline: "#8c9199"

    readonly property color surfaceContainer: "#1d2024"
    readonly property color scrim: "#80000000"

    readonly property int radius: 12

    readonly property string fontFamily: "Maple Mono NF CN"
    readonly property int fontSizeSmall: 15
    readonly property int fontSizeLarge: 48
}
