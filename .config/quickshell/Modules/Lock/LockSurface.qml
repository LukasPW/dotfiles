import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../"

WlSessionLockSurface {
    id: root
    color: Theme.background

    signal unlockRequested()

    // One-shot screenshot (live: false) of the screen at the moment of
    // locking, blurred behind the auth field below. Deliberately not a
    // live feed - that would keep compositing the real desktop every
    // frame while locked, which is both wasteful and a privacy leak.
    ScreencopyView {
        id: capture
        anchors.fill: parent
        captureSource: root.screen
        live: false
        paintCursor: false
        Component.onCompleted: captureFrame()
    }

    MultiEffect {
        anchors.fill: capture
        source: capture
        visible: capture.hasContent
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        saturation: -0.2
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 48

        DistroLogo {
            Layout.alignment: Qt.AlignHCenter
        }

        LockClock {
            Layout.alignment: Qt.AlignHCenter
        }

        AuthField {
            Layout.alignment: Qt.AlignHCenter
            onUnlocked: root.unlockRequested()
        }
    }
}
