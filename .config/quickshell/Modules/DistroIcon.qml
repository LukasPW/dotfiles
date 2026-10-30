import Quickshell
import Quickshell.Wayland
import QtQuick
import "../"

Text {
id: root
text: Distro.logo
color: Theme.secondary
  font {
    family: Theme.fontFamily
    pixelSize: Theme.fontSizeLarge
  }
}
