import Quickshell
import QtQuick

Text {
    color: "#81c7a4"
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
