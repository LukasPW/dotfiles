import Quickshell
import QtQuick

ShellRoot {
    Text {
        text: Qt.formatDateTime(clock.date, "ddd, MMM dd - HH:mm")
        font {
            family: "JetBrainsMono Nerd Font"
            letterSpacing: -1
            pixelSize: 15
            weight: 400
        }
    }
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
