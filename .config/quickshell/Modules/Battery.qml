import Quickshell
import Quickshell.Services.UPower
import QtQuick

Text {
    id: root

    property var device: UPower.displayDevice
    property int pct: device ? Math.round(device.percentage * 100) : 0
    property bool charging: device && (device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge)
    property bool full: device && device.state === UPowerDeviceState.FullyCharged

    visible: device ? device.isPresent : false

    function levelGlyph(p) {
        if (p >= 90) return "\uf240"  // fa-battery-full
        if (p >= 65) return "\uf241"  // fa-battery-three-quarters
        if (p >= 40) return "\uf242"  // fa-battery-half
        if (p >= 15) return "\uf243"  // fa-battery-quarter
        return "\uf244"               // fa-battery-empty
    }

    text: {
        const glyph = full ? "\uf240" : levelGlyph(pct)
        const prefix = full ? "\uf1e6 " : (charging ? "\uf0e7 " : "")  // fa-plug / fa-bolt
        return prefix + glyph + " " + pct + "%"
    }

    color: {
        if (full || charging) return "#0db9d7"
        if (pct < 15) return "#f7768e"
        if (pct < 40) return "#e0af68"
        return "#81c7a4"
    }

    font {
        family: "Maple Mono NF CN"
        pixelSize: 15
        weight: 400
    }
}
