import QtQuick
import "../../"

// Purely decorative: the running distro's glyph on the lock screen, gently
// rocking and cycling color, tying together with LockClock below it. No
// interaction, and the only state is read-only - safe to delete or restyle
// without touching anything else. Which glyph to draw comes from Distro.qml.
Text {
    id: root

    text: Distro.logo
    color: Theme.primary
    font {
        // Distro.logo is a private-use codepoint, so it only draws if some
        // installed font is Nerd Font patched - whichever family is named
        // here, it's fontconfig's per-glyph fallback that actually finds it.
        // No family list to make that explicit, unfortunately: this Qt build
        // doesn't expose font.families to QML, only the single font.family.
        // Without a patched font anywhere on the system the logo comes out
        // as a tofu box.
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
