import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import "../"

Text {
    id: root
    property bool opened: false
    
    text: "\uf00b"
    color: Theme.secondary
    font {
        family: "Maple Mono NF CN"
        pixelSize: 15
        weight: 400
    }
    Process {
        id: proc
        command: ["rofi", "-show", "drun"]
    }
    MouseArea {
        anchors.fill:parent
        acceptedButtons: Qt.LeftButton
        onClicked: proc.running = true
    }
}
