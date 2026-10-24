import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string outputName: ""
    property var _monitors: []

    readonly property var _mon: _monitors.find(m => m.name === outputName)
    readonly property int tagCount: _mon ? _mon.tag_num : 9
    readonly property var selectedNumbers: _mon ? _mon.active_tags : []
    readonly property var populatedNumbers: _mon ? _mon.tags.filter(t => t.client_count > 0).map(t => t.index) : []
    readonly property string layout: _mon ? _mon.layout_symbol : ""

    function activate(n) {
        Quickshell.execDetached(["mmsg", "dispatch", "view," + n]);
    }

    Process {
        id: proc
        running: true
        command: ["mmsg", "watch", "all-monitors"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    root._monitors = JSON.parse(line).monitors || [];
                } catch (e) {}
            }
        }
        onExited: retry.restart()
    }

    Timer {
        id: retry
        interval: 2000
        onTriggered: proc.running = true
    }
}
