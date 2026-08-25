import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland // Hyprland IPC accsess
import QtQuick
import QtQuick.Layouts // For RowLayout
import Quickshell.Io
import Quickshell.Services.Pipewire

Text {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    function volumeIcon(vol, isMuted) {
        if (isMuted || vol === 0) return "\uf026"  // fa-volume-off
        if (vol < 0.5) return "\uf027"             // fa-volume-down
        return "\uf028"                             // fa-volume-up
    }

    text: volumeIcon(volume, muted) + " " + Math.round(volume * 100) + "%"
    color: muted ? "#f7768e" : "#81c7a4"
    font {
        family: "Maple Mono NF CN"
        pixelSize: 15
        weight: 400
    }

    // Keeps the sink bound so its properties actually update -
    // without this, .audio can stay stale/null on some setups.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (root.sink?.ready && root.sink?.audio)
                root.sink.audio.muted = !root.sink.audio.muted
        }

        // Scroll to adjust volume
        onWheel: (wheel) => {
            if (!root.sink?.ready || !root.sink?.audio) return
            const step = 0.05
            let newVol = root.volume + (wheel.angleDelta.y > 0 ? step : -step)
            newVol = Math.max(0, Math.min(1, newVol))
            root.sink.audio.muted = false
            root.sink.audio.volume = newVol
        }
    }
}
