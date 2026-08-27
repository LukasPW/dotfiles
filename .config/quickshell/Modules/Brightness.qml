import Quickshell
import Quickshell.Io
import QtQuick
import "../"

// Backlight brightness: label shows current %, hover reveals a
// click/drag-to-set slider popup. There's no reactive brightness service
// in Quickshell, so state comes from watching sysfs directly and `set` is
// shelled out to brightnessctl (which also handles the log-scale curve).
Item {
    id: root

    // Only backlight device present on this machine (see `brightnessctl -m`).
    readonly property string device: "amdgpu_bl1"

    property int rawBrightness: 0
    property int maxBrightness: 1
    property real level: maxBrightness > 0 ? rawBrightness / maxBrightness : 0
    property bool popupHovered: false
    property bool dragging: false

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    // Grace period so the popup survives the gap while the pointer travels
    // from the label down into the slider - without it, leaving the label's
    // tiny hitbox hides the popup before the pointer ever reaches it.
    Timer {
        id: hideTimer
        interval: 250
        onTriggered: root.popupHovered = false
    }

    function beginHover() {
        hideTimer.stop()
        root.popupHovered = true
    }

    function endHover() {
        hideTimer.restart()
    }

    function setLevel(newLevel) {
        const clamped = Math.max(0, Math.min(1, newLevel))
        root.level = clamped // optimistic update; FileView watcher reconciles with the real value
        setProc.exec(["brightnessctl", "set", Math.round(clamped * 100) + "%"])
    }

    FileView {
        id: brightnessFile
        path: `/sys/class/backlight/${root.device}/brightness`
        watchChanges: true
        onLoaded: root.rawBrightness = parseInt(text())
        onFileChanged: reload()
    }

    FileView {
        id: maxBrightnessFile
        path: `/sys/class/backlight/${root.device}/max_brightness`
        onLoaded: root.maxBrightness = parseInt(text())
    }

    Process {
        id: setProc
    }

    // U+E30D is nf-weather-day_sunny (a plain sun glyph); the classic FA
    // "fa-sun-o" codepoint (U+F185) renders as a gear in this font instead.
    Text {
        id: label
        text: " " + Math.round(root.level * 100) + "%"
        color: Theme.secondary
        font {
            family: "Maple Mono NF CN"
            pixelSize: 15
            weight: 400
        }
    }

    MouseArea {
        anchors.fill: label
        hoverEnabled: true
        onEntered: root.beginHover()
        onExited: root.endHover()

        // Scroll to adjust brightness
        onWheel: (wheel) => {
            const step = 0.05
            root.setLevel(root.level + (wheel.angleDelta.y > 0 ? step : -step))
        }
    }

    PopupWindow {
        id: popup
        visible: root.popupHovered || root.dragging
        color: Theme.surfaceContainer
        implicitWidth: 140
        implicitHeight: 32

        // Deliberately NOT setting anchor.window here. PopupAnchor derives
        // the window from `item` on its own once the item is actually
        // parented into one; setting `anchor.window: QsWindow.window`
        // explicitly races that resolution during startup and segfaults
        // in ProxyWindowBase::completeWindow() (Quickshell 0.3.0). Anchor
        // by item only.
        anchor {
            item: root
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom
            margins.top: 0
        }

        Rectangle {
            id: track
            anchors.fill: parent
            anchors.margins: 6
            radius: Theme.radius
            color: "transparent"
            border.color: Theme.outline
            border.width: 1

            Rectangle {
                id: fill
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Math.max(height, parent.width * root.level)
                radius: Theme.radius
                color: Theme.primary
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.beginHover()
                onExited: root.endHover()
                onPressed: (mouse) => {
                    root.dragging = true
                    root.setLevel(mouse.x / width)
                }
                onPositionChanged: (mouse) => {
                    if (root.dragging) root.setLevel(mouse.x / width)
                }
                onReleased: root.dragging = false
            }
        }
    }
}
