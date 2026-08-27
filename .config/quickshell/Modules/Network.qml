import Quickshell
import Quickshell.Networking
import QtQuick
import "../"

// Wired takes priority over Wi-Fi when both are present. If neither is
// connected this still shows the Wi-Fi glyph (as a fallback "offline"
// icon) but in Theme.error, rather than switching icon on disconnect.
Text {
    id: root

    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired)
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    readonly property bool wiredConnected: wiredDevice ? wiredDevice.connected : false
    readonly property bool wifiConnected: wifiDevice ? wifiDevice.connected : false
    readonly property bool connected: wiredConnected || wifiConnected

    visible: wiredDevice !== undefined || wifiDevice !== undefined

    text: wiredConnected ? "" : ""  // fa-sitemap (wired) / fa-wifi
    color: connected ? Theme.secondary : Theme.error
    font {
        family: "Maple Mono NF CN"
        pixelSize: 15
        weight: 400
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: Quickshell.execDetached(["nm-connection-editor"])
    }
}
