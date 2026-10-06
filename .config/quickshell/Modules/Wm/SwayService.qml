import QtQuick
import Quickshell.I3
// Sway workspaces backend for Modules/Workspaces.qml
// works similarly to how HyprlandService.qml does but ported to sway/I3 api instead

QtObject {
  id: root

  property string outputName: ""
  
  readonly property int focusedNumber: I3.focusedWorkspace ? I3.focusedWorkspace.number : -1
  readonly property var populatedNumbers: I3.workspaces.values.map(w=>w.number)
  
  function activate(n){
    I3.dispatch(`workspace number ${n}`)
  }
}
