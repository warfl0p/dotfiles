import QtQuick
import Quickshell.Hyprland

// Custom replacement for the built-in omarchy.workspaces widget, which always
// shows workspaces 1-5 regardless of whether they're occupied. This only
// shows workspaces that have a window, plus whichever workspace is currently
// focused (so switching to an empty workspace doesn't make the indicator
// disappear entirely).
Item {
  id: root
  property var bar
  property string moduleName
  property var settings: ({})

  function workspaceIds() {
    var ids = []
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var ws = values[i]
      if (ws.id > 0 && ws.toplevels.values.length > 0) ids.push(ws.id)
    }

    var focused = Hyprland.focusedWorkspace
    if (focused && focused.id > 0 && ids.indexOf(focused.id) === -1) ids.push(focused.id)

    ids.sort(function(a, b) { return a - b })
    return ids
  }

  implicitWidth: row.implicitWidth
  implicitHeight: bar ? bar.barSize : 26

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    spacing: 8

    Repeater {
      model: root.workspaceIds()

      Item {
        required property int modelData
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        width: label.implicitWidth + 8
        height: bar ? bar.barSize : 26

        Text {
          id: label
          anchors.centerIn: parent
          text: focused ? "󱓻" : (modelData === 10 ? "0" : String(modelData))
          color: bar ? bar.barForeground : "white"
          font.family: bar ? bar.fontFamily : "monospace"
          font.pixelSize: 12
        }

        MouseArea {
          anchors.fill: parent
          onClicked: if (bar) bar.run("hyprctl dispatch 'hl.dsp.focus({ workspace = \"" + modelData + "\" })'")
        }
      }
    }
  }
}
