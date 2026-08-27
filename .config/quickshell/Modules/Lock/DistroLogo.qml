import QtQuick
import "../../"

// Purely decorative: a distro glyph on the lock screen that gently rocks
// and cycles color, tying together with LockClock below it. No state, no
// interaction - safe to delete or restyle without touching anything else.
Text {
    id: root

    text:""
    color: Theme.primary
    font {
        family: Theme.fontFamily
        pixelSize: 96
    }

    layer.enabled: true
    layer.smooth: true

    transform: Rotation {
        id: spin
        origin.x: root.width / 2
        origin.y: root.height / 2
        axis { x: 0; y: 1; z: 0 }
        angle: 0

        SequentialAnimation on angle {
            loops: Animation.Infinite
            NumberAnimation { to: 35; duration: 3000; easing.type: Easing.InOutSine }
            NumberAnimation { to: -35; duration: 6000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 3000; easing.type: Easing.InOutSine }
        }
    }

    SequentialAnimation on color {
        loops: Animation.Infinite
        ColorAnimation { to: Theme.tertiary; duration: 3000; easing.type: Easing.InOutSine }
        ColorAnimation { to: Theme.primary; duration: 3000; easing.type: Easing.InOutSine }
    }
}
