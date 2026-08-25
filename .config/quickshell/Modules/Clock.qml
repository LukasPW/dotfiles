import Quickshell
import QtQuick
import "../"

Text {
    color: Theme.secondary
    text: Qt.formatDateTime(clock.date, "ddd-MM/dd-HH:mm")
    font {
        family: "Maple Mono NF CN"
        letterSpacing: -1
        pixelSize: 15
        weight: 400
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
