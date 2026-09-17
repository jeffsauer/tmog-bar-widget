import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Task Manager TMOG bar toggle. Clicking launches the AppImage if it is not
// running and then shows the special:taskmgr scratchpad its window is parked
// on; click again to hide it.
BarWidget {
  id: root
  moduleName: "com.darkhorse-studios.tmog-bar-widget"

  readonly property string special: "taskmgr"
  readonly property string appTitle: "Task Manager TMOG"
  readonly property string appClass: "com.tmog.taskmanager"
  readonly property string appBinary: root.setting("binary", "~/Applications/TaskManagerOG-0.1.3-x86_64.AppImage")

  // Facts about the current state. hasClient = a TMOG window exists (3s
  // refresh poll); shown = the special:taskmgr scratchpad is the active
  // special workspace (tracked from Hyprland's `activespecial` event so it
  // cannot be fooled by focus: a window parked on a closed scratchpad still
  // reports as the active window). launching = a launch is in progress.
  // `shown` seeds false; the first activespecial corrects it.
  property bool hasClient: false
  property bool shown: false
  property bool launching: false

  readonly property bool running: root.hasClient || root.launching

  function isTmog(win) {
    if (!win) return false
    var cls = String(win.class || "")
    var title = String(win.title || "")
    return cls === root.appClass || title === root.appTitle
  }

  function hasTmogClient(clients) {
    for (var i = 0; i < clients.length; i++) {
      if (root.isTmog(clients[i])) return true
    }
    return false
  }

  // ------------- scratchpad visibility (source of truth for `shown`) -------------

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!event || String(event.name || "") !== "activespecial") return
      // data is "<specialName>,<monitor>" when a special workspace is active,
      // or ",<monitor>" when none is.
      var parts = String(event.data || "").split(",")
      root.shown = parts[0] === "special:" + root.special
    }
  }

  // ------------- hyprctl plumbing -------------

  property var pendingClients: null

  Process {
    id: clientsProcess
    command: ["hyprctl", "clients", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: function() {
        var clients = []
        try { clients = JSON.parse(String(text || "")) } catch (e) {}
        var cb = root.pendingClients
        root.pendingClients = null
        if (cb) cb(clients)
        else root.applyClients(clients)
      }
    }
  }

  Process {
    id: dispatchProcess
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.refreshState
    }
  }

  function queryClients(cb) {
    root.pendingClients = cb
    if (!clientsProcess.running) clientsProcess.running = true
  }

  function refreshState() {
    root.queryClients(null)
  }

  function toggleSpecial() {
    dispatchProcess.command = ["hyprctl", "dispatch", 'hl.dsp.workspace.toggle_special("' + root.special + '")']
    if (!dispatchProcess.running) dispatchProcess.running = true
  }

  function applyClients(clients) {
    root.hasClient = root.hasTmogClient(clients)
    if (root.hasClient) root.launching = false
  }

  // ------------- click: launch if needed, then flip the scratchpad -------------

  function onToggle() {
    if (root.launching) return
    root.queryClients(function(clients) {
      if (root.hasTmogClient(clients)) {
        // Window exists -> flip the special workspace. Toggling always flips,
        // and the activespecial event keeps `shown` in step with reality.
        root.toggleSpecial()
      } else {
        root.launchApp()
      }
    })
  }

  // ------------- launch -------------

  Timer {
    id: launchPoll
    interval: 350
    repeat: true
    running: false
    property int attempts: 0
    onTriggered: root.pollLaunch()
  }

  function launchApp() {
    root.launching = true
    launchPoll.attempts = 0
    launchPoll.running = true
    Util.execArgv([root.appBinary])
    root.pollLaunch()
  }

  function pollLaunch() {
    root.queryClients(function(clients) {
      if (root.hasTmogClient(clients)) {
        launchPoll.running = false
        launchPoll.attempts = 0
        root.launching = false
        // The window rule parks the app on special:taskmgr. A fresh launch
        // lands on the closed scratchpad (its window still steals focus), so
        // flip it open. If the scratchpad somehow was already showing, `shown`
        // is true and the toggle is skipped.
        if (!root.shown) root.toggleSpecial()
      } else if (++launchPoll.attempts >= 40) {
        // ~14s without a window: give up so the icon is not stuck "launching".
        launchPoll.running = false
        launchPoll.attempts = 0
        root.launching = false
      }
    })
  }

  Timer {
    id: stateRefresh
    interval: 3000
    repeat: true
    running: true
    onTriggered: root.refreshState()
  }

  Component.onCompleted: Qt.callLater(root.refreshState)

  // ------------- IPC (keybinding) -------------
  // `omarchy-shell com.darkhorse-studios.tmog-bar-widget toggle` (see
  // ~/.config/hypr/bindings.lua).

  IpcHandler {
    target: "com.darkhorse-studios.tmog-bar-widget"

    function toggle(): void { root.onToggle() }
    function show(): void { if (!root.shown) root.onToggle() }
    function hide(): void { if (root.shown) root.onToggle() }
  }

  // ------------- bar button -------------

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uDB81\uDFAF" // nf-md-chart_donut
    active: root.shown
    dimmed: !root.running
    tooltipText: root.shown ? "Hide TMOG" : "Open TMOG"
    onPressed: function(buttonId) {
      if (buttonId === Qt.LeftButton) root.onToggle()
    }
  }
}
