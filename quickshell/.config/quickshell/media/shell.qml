import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

ShellRoot {
    id: root

    property bool open: false
    property string pinnedId: ""

    readonly property color bg:     "#0f111a"
    readonly property color fg:     "#c8d3f5"
    readonly property color muted:  "#565f89"
    readonly property color accent: "#7aa2f7"
    readonly property color crit:   "#f7768e"
    readonly property color border: "#2a2f42"
    readonly property string mono:  "FiraCode Nerd Font Mono"

    readonly property var players: Mpris.players.values.filter(p => p && p.canControl)

    readonly property var preferredPlayer: {
        const playing = players.find(p => p.isPlaying)
        if (playing) return playing
        const paused = players.find(p => p.playbackState === MprisPlaybackState.Paused)
        if (paused) return paused
        return players[0] || null
    }

    readonly property var activePlayer: {
        if (pinnedId) {
            const p = players.find(p => p.uniqueId === pinnedId)
            if (p) return p
        }
        return preferredPlayer
    }

    readonly property var otherPlayers: players.filter(p => p && p !== activePlayer)

    onOpenChanged: if (!open) pinnedId = ""

    function fmtTime(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        const total = Math.floor(seconds)
        const m = Math.floor(total / 60)
        const s = total % 60
        return m + ":" + s.toString().padStart(2, "0")
    }

    IpcHandler {
        target: "media"
        function toggle(): void { root.open = !root.open }
        function show(): void   { root.open = true }
        function hide(): void   { root.open = false }
    }

    Timer {
        id: tick
        interval: 500
        running: root.open && root.activePlayer && root.activePlayer.isPlaying
        repeat: true
        onTriggered: scrubber.refresh()
    }

    component Label: Text {
        color: root.fg
        font.family: root.mono
        font.pixelSize: 12
        elide: Text.ElideRight
    }

    component SectionHeader: Text {
        color: root.muted
        font.family: root.mono
        font.pixelSize: 10
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1
    }

    component ControlButton: Rectangle {
        property string symbol
        property bool enabled: true
        property bool primary: false
        signal clicked()

        implicitWidth: primary ? 40 : 32
        implicitHeight: primary ? 40 : 32
        radius: width / 2
        color: btnArea.containsMouse && enabled
            ? Qt.rgba(0.48, 0.64, 0.97, 0.18)
            : (primary ? Qt.rgba(0.48, 0.64, 0.97, 0.10) : "transparent")
        opacity: enabled ? 1.0 : 0.35

        Text {
            anchors.centerIn: parent
            text: parent.symbol
            color: parent.primary ? root.accent : root.fg
            font.family: root.mono
            font.pixelSize: parent.primary ? 18 : 14
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (parent.enabled) parent.clicked()
        }
    }

    component Scrubber: Item {
        id: scrubber
        property var player
        property real displayPos: 0
        property real lengthSec: player ? player.length : 0
        property bool dragging: false

        function refresh() {
            if (!dragging && player) displayPos = player.position
        }

        Connections {
            target: scrubber.player
            function onPostTrackChanged() { scrubber.displayPos = 0 }
            function onPositionChanged() { if (!scrubber.dragging) scrubber.displayPos = scrubber.player.position }
        }

        onPlayerChanged: refresh()

        implicitHeight: 22

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 3
            radius: 2
            color: root.border

            Rectangle {
                width: parent.width * (scrubber.lengthSec > 0
                    ? Math.min(scrubber.displayPos / scrubber.lengthSec, 1) : 0)
                height: parent.height
                radius: 2
                color: root.accent
            }
        }

        Rectangle {
            visible: scrubber.lengthSec > 0
            x: (parent.width - width) * Math.min(scrubber.displayPos / Math.max(scrubber.lengthSec, 1), 1)
            anchors.verticalCenter: parent.verticalCenter
            width: 10; height: 10; radius: 5
            color: root.fg
            border.color: root.bg
            border.width: 2
        }

        MouseArea {
            anchors.fill: parent
            anchors.topMargin: -6
            anchors.bottomMargin: -6
            cursorShape: scrubber.player && scrubber.player.canSeek
                ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: scrubber.player && scrubber.player.canSeek && scrubber.lengthSec > 0
            function pick(mx) {
                const f = Math.max(0, Math.min(1, mx / width))
                scrubber.displayPos = f * scrubber.lengthSec
            }
            onPressed: (m) => { scrubber.dragging = true; pick(m.x) }
            onPositionChanged: (m) => { if (pressed) pick(m.x) }
            onReleased: {
                scrubber.dragging = false
                if (scrubber.player) scrubber.player.position = scrubber.displayPos
            }
        }
    }

    component PlayerRow: Rectangle {
        id: pr
        property var player
        Layout.fillWidth: true
        implicitHeight: 30
        radius: 6
        color: prArea.containsMouse ? Qt.rgba(0.48, 0.64, 0.97, 0.10) : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: pr.player && pr.player.isPlaying ? "󰐊" : "󰏤"
                color: pr.player && pr.player.isPlaying ? root.accent : root.muted
                font.family: root.mono
                font.pixelSize: 14
            }
            Label {
                Layout.fillWidth: true
                text: pr.player
                    ? (pr.player.identity || "Unknown")
                        + (pr.player.trackTitle ? " · " + pr.player.trackTitle : "")
                    : ""
                color: root.fg
            }
        }

        MouseArea {
            id: prArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (pr.player) root.pinnedId = pr.player.uniqueId
        }
    }

    PanelWindow {
        id: win
        visible: root.open
        screen: Quickshell.screens[0]

        anchors.top: true
        anchors.right: true
        anchors.bottom: true
        anchors.left: true

        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true

        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        Rectangle {
            id: card
            x: parent.width - width - 12
            y: 40
            width: 360
            height: column.implicitHeight + 28
            radius: 12
            color: Qt.rgba(15/255, 17/255, 26/255, 0.96)
            border.color: root.border
            border.width: 1

            MouseArea { anchors.fill: parent }

            Column {
                id: column
                x: 14; y: 14
                width: parent.width - 28
                spacing: 14

                RowLayout {
                    width: parent.width
                    Label {
                        Layout.fillWidth: true
                        text: "Now Playing"
                        color: root.fg
                        font.bold: true
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: closeArea
                        implicitWidth: 20; implicitHeight: 20
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.open = false
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: closeArea.containsMouse ? root.crit : root.muted
                            font.family: root.mono
                            font.pixelSize: 14
                        }
                    }
                }

                Label {
                    width: parent.width
                    visible: !root.activePlayer
                    text: "No active media players"
                    color: root.muted
                    font.italic: true
                    font.pixelSize: 11
                }

                Column {
                    width: parent.width
                    spacing: 10
                    visible: root.activePlayer !== null

                    RowLayout {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            implicitWidth: 64; implicitHeight: 64
                            radius: 6
                            color: root.border
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: root.activePlayer ? (root.activePlayer.trackArtUrl || "") : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 128
                                sourceSize.height: 128
                                asynchronous: true
                                cache: true
                            }

                            Text {
                                visible: !root.activePlayer || !root.activePlayer.trackArtUrl
                                anchors.centerIn: parent
                                text: "󰝚"
                                color: root.muted
                                font.family: root.mono
                                font.pixelSize: 28
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: root.activePlayer ? (root.activePlayer.trackTitle || "—") : ""
                                color: root.fg
                                font.bold: true
                                font.pixelSize: 13
                            }
                            Label {
                                Layout.fillWidth: true
                                text: root.activePlayer ? (root.activePlayer.trackArtist || "") : ""
                                color: root.muted
                                font.pixelSize: 11
                            }
                            Label {
                                Layout.fillWidth: true
                                visible: text.length > 0
                                text: root.activePlayer
                                    ? (root.activePlayer.identity || "")
                                    : ""
                                color: root.muted
                                font.pixelSize: 10
                                font.italic: true
                            }
                        }
                    }

                    Scrubber {
                        id: scrubber
                        width: parent.width
                        player: root.activePlayer
                    }

                    RowLayout {
                        width: parent.width

                        Label {
                            text: root.fmtTime(scrubber.displayPos)
                            color: root.muted
                            font.pixelSize: 10
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: root.fmtTime(scrubber.lengthSec)
                            color: root.muted
                            font.pixelSize: 10
                        }
                    }

                    RowLayout {
                        width: parent.width

                        Item { Layout.fillWidth: true }

                        ControlButton {
                            symbol: "󰒮"
                            enabled: root.activePlayer && root.activePlayer.canGoPrevious
                            onClicked: root.activePlayer.previous()
                        }
                        Item { implicitWidth: 6 }
                        ControlButton {
                            primary: true
                            symbol: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
                            enabled: root.activePlayer && root.activePlayer.canTogglePlaying
                            onClicked: root.activePlayer.togglePlaying()
                        }
                        Item { implicitWidth: 6 }
                        ControlButton {
                            symbol: "󰒭"
                            enabled: root.activePlayer && root.activePlayer.canGoNext
                            onClicked: root.activePlayer.next()
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 4
                    visible: root.otherPlayers.length > 0

                    SectionHeader { text: "Other players" }
                    Repeater {
                        model: root.otherPlayers
                        PlayerRow { player: modelData }
                    }
                }
            }
        }
    }
}
