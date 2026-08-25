import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland // Hyprland IPC accsess
import QtQuick
import QtQuick.Layouts // For RowLayout
import Quickshell.Io

PanelWindow {
    id: root

    //Theme Properties
    property color colBg: "#1a1b26"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 18

    //System Data
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: "#1a1b26"

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]

        // Split Parser calls onRead for each line of output
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)));
                }
                lastCpuTotal = total;
                lastCpuIdle = idle;
            }
        }
        Component.onCompleted: running = true
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: cpuProc.running = true
    }
    // arranges children horizontaly
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        Repeater {
            model: 10

            Text {
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                text: index + 1
                color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
                font {
                    pixelSize: 14
                    bold: true
                }
                // Click to switch workspaces
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = ${index + 1}})`)
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }

        Text {
            text: "CPU: " + cpuUsage + "%"
            color: root.colYellow
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }
        Text {
            id: clock
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            color: root.colBlue

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            }
        }
    }
}
