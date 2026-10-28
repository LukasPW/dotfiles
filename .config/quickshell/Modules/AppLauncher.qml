import QtQuick
import Quickshell
import Quickshell.Io
import "../"

Text {
    id: root
    property bool opened: false
    
    text: "\uf00b"
    color: Theme.secondary
    font {
        family: Theme.fontFamily
        pixelSize: Theme.fontSizeSmall
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
