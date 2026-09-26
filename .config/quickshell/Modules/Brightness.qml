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

    // Backlight device name (e.g. "amdgpu_bl1", "intel_backlight") - varies
    // by GPU/driver, not by distro, so this is discovered at startup rather
    // than hardcoded. /sys/class/backlight is a kernel sysfs interface, laid
    // out identically regardless of how the distro packages anything, so
    // this needs no distro-specific handling. Picks whichever device sorts
    // first; fine for the common one-backlight-device case this module was
    // written for, but a machine with two (e.g. a hybrid-GPU laptop) would
    // need real disambiguation this doesn't attempt.
    property string device: ""

    // Set by the availability check below once brightnessctl is confirmed
    // on PATH. Separate from `available` because that also needs a
    // discovered `device` - see below.
    property bool _brightnessctlOk: false

    // Hidden until brightnessctl is on PATH *and* a backlight device was
    // actually found, so the module doesn't show on machines without either.
    readonly property bool available: root._brightnessctlOk && root.device.length > 0

    property int rawBrightness: 0
    property int maxBrightness: 1
    property real level: maxBrightness > 0 ? rawBrightness / maxBrightness : 0
    property bool popupHovered: false
    property bool dragging: false

    visible: root.available
    implicitWidth: root.available ? label.implicitWidth : 0
    implicitHeight: root.available ? label.implicitHeight : 0

    Component.onCompleted: availabilityCheck.exec(["sh", "-c", "command -v brightnessctl"])

    Process {
        id: availabilityCheck
        onExited: (exitCode) => root._brightnessctlOk = exitCode === 0
    }

    Process {
        id: deviceDetect
        command: ["sh", "-c", "ls /sys/class/backlight 2>/dev/null | head -n1"]
        stdout: SplitParser {
            onRead: line => {
                const name = line.trim();
                if (name.length)
                    root.device = name;
            }
        }
        Component.onCompleted: running = true
    }

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

    // Empty until deviceDetect resolves `root.device`; both paths re-bind
    // automatically once it does (plain reactive property, not blockLoading -
    // no need to force a reload by hand).
    FileView {
        id: brightnessFile
        path: root.device ? `/sys/class/backlight/${root.device}/brightness` : ""
        watchChanges: true
        onLoaded: root.rawBrightness = parseInt(text())
        onFileChanged: reload()
    }

    FileView {
        id: maxBrightnessFile
        path: root.device ? `/sys/class/backlight/${root.device}/max_brightness` : ""
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
