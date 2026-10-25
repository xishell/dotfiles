import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray

ShellRoot {
    id: shell

    readonly property color bg:     "#0f111a"
    readonly property color fg:     "#c8d3f5"
    readonly property color muted:  "#565f89"
    readonly property color accent: "#7aa2f7"
    readonly property color crit:   "#f7768e"
    readonly property color border: "#2a2f42"
    readonly property string mono:  "FiraCode Nerd Font Mono"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property var defaultSink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: shell.defaultSink ? [shell.defaultSink] : [] }

    readonly property var mprisPlayers: Mpris.players.values.filter(p => p && p.canControl)
    readonly property var primaryPlayer: {
        const playing = mprisPlayers.find(p => p && p.isPlaying)
        if (playing) return playing
        return mprisPlayers[0] || null
    }

    function ipcCall(config, target, fn) {
        Quickshell.execDetached(["qs", "-c", config, "ipc", "call", target, fn])
    }

    function volumeIcon(sink) {
        if (!sink || !sink.audio) return "󰖁"
        if (sink.audio.muted) return "󰖁"
        const v = sink.audio.volume
        if (v < 0.01) return "󰕿"
        if (v < 0.34) return "󰕿"
        if (v < 0.67) return "󰖀"
        return "󰕾"
    }

    component Pill: Item {
        id: pill
        default property alias content: contentRow.children
        signal clicked()
        signal scrolled(int delta)
        property bool hoverable: true
        property real padding: 10

        implicitWidth: contentRow.implicitWidth + padding * 2
        implicitHeight: 24

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: pillArea.containsMouse && pill.hoverable
                ? Qt.rgba(0.48, 0.64, 0.97, 0.12) : "transparent"
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
        }

        MouseArea {
            id: pillArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: pill.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton
            onClicked: pill.clicked()
            onWheel: (e) => pill.scrolled(e.angleDelta.y > 0 ? 1 : -1)
        }
    }

    component WsButton: Item {
        id: ws
        property int wsId
        property var hMonitor
        readonly property var workspace: {
            const candidates = Hyprland.workspaces.values.filter(w =>
                w && w.id === ws.wsId
                && (!ws.hMonitor || !w.monitor || w.monitor === ws.hMonitor))
            return candidates[0] || null
        }
        readonly property bool focused: workspace ? workspace.focused : false
        readonly property bool occupied: workspace
            && workspace.toplevels && workspace.toplevels.values.length > 0
        readonly property bool urgent: workspace ? workspace.urgent : false

        implicitWidth: 26
        implicitHeight: 24

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: wsArea.containsMouse ? Qt.rgba(0.48, 0.64, 0.97, 0.12)
                : ws.focused ? Qt.rgba(0.48, 0.64, 0.97, 0.20)
                : ws.urgent ? Qt.rgba(0.97, 0.46, 0.55, 0.30)
                : "transparent"
        }

        Text {
            anchors.centerIn: parent
            text: ws.wsId
            color: ws.focused ? shell.fg : (ws.occupied ? shell.fg : shell.muted)
            font.family: shell.mono
            font.pixelSize: 12
            font.bold: ws.focused
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            width: 4; height: 3; radius: 1
            color: shell.accent
            visible: ws.occupied && !ws.focused
            opacity: 0.7
        }

        MouseArea {
            id: wsArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch(Hyprland.usingLua
                ? "hl.dsp.focus({ workspace = " + ws.wsId + " })"
                : "workspace " + ws.wsId)
        }
    }

    component TrayEntry: Item {
        id: tray
        property var item
        implicitWidth: 22
        implicitHeight: 22

        Image {
            anchors.centerIn: parent
            width: 16; height: 16
            source: tray.item ? tray.item.icon : ""
            smooth: true
            asynchronous: true
            onStatusChanged: if (status === Image.Error) console.log("tray icon failed:", source)
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (m) => {
                if (!tray.item) return
                if (m.button === Qt.LeftButton) tray.item.activate()
                else if (m.button === Qt.MiddleButton) tray.item.secondaryActivate()
                else if (m.button === Qt.RightButton && tray.item.hasMenu) {
                    tray.item.display(parent.QsWindow.window, parent.width / 2, parent.height)
                }
            }
            onWheel: (e) => tray.item && tray.item.scroll(e.angleDelta.y, false)
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            readonly property var hMonitor: Hyprland.monitorFor(modelData)

            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 34
            exclusiveZone: 34

            color: Qt.rgba(15/255, 17/255, 26/255, 0.7)

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Row {
                id: workspaces
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8
                spacing: 2
                Repeater {
                    model: 9
                    WsButton {
                        wsId: index + 1
                        hMonitor: bar.hMonitor
                    }
                }
            }

            Text {
                anchors.left: workspaces.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, Math.max(0, centerPill.x - x - 12))
                text: Hyprland.activeToplevel ? (Hyprland.activeToplevel.title || "") : ""
                color: shell.fg
                font.family: shell.mono
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
            }

            Pill {
                id: centerPill
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                hoverable: false

                Text {
                    text: Qt.formatDateTime(clock.date, "ddd MMM dd  HH:mm")
                    color: shell.accent
                    font.family: shell.mono
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: centerPill.right
                anchors.rightMargin: 8
                anchors.leftMargin: 12
                spacing: 6

                Item { Layout.fillWidth: true }

                Pill {
                    Layout.alignment: Qt.AlignVCenter
                    visible: shell.primaryPlayer !== null
                    onClicked: shell.ipcCall("media", "media", "toggle")

                    Text {
                        text: shell.primaryPlayer && shell.primaryPlayer.isPlaying ? "󰐊" : "󰏤"
                        color: shell.primaryPlayer && shell.primaryPlayer.isPlaying ? shell.accent : shell.muted
                        font.family: shell.mono
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: {
                            if (!shell.primaryPlayer) return ""
                            const title = shell.primaryPlayer.trackTitle || ""
                            return title.length > 30 ? title.slice(0, 28) + "…" : title
                        }
                        color: shell.fg
                        font.family: shell.mono
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Pill {
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: shell.ipcCall("mixer", "mixer", "toggle")
                    onScrolled: (d) => {
                        if (!shell.defaultSink || !shell.defaultSink.audio) return
                        const cur = shell.defaultSink.audio.volume
                        const next = Math.max(0, Math.min(1.5, cur + d * 0.05))
                        shell.defaultSink.audio.volume = next
                    }

                    Text {
                        text: shell.volumeIcon(shell.defaultSink)
                        color: shell.defaultSink && shell.defaultSink.audio && shell.defaultSink.audio.muted
                            ? shell.muted : "#9ece6a"
                        font.family: shell.mono
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: shell.defaultSink && shell.defaultSink.audio
                            ? Math.round(shell.defaultSink.audio.volume * 100) + "%"
                            : "—"
                        color: shell.fg
                        font.family: shell.mono
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4
                    Repeater {
                        model: SystemTray.items
                        TrayEntry { item: modelData }
                    }
                }
            }
        }
    }
}
