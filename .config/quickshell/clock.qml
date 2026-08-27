// Standalone scratch file - not imported by shell.qml and not part of the
// running shell. Kept around as an early experiment; run in isolation with
// `qs -p ~/.config/quickshell/clock.qml` if you want to poke at it. The
// real bar clock is Modules/Clock.qml.
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
