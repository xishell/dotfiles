import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire

ShellRoot {
    id: root

    property bool open: false

    readonly property color bg:     "#0f111a"
    readonly property color fg:     "#c8d3f5"
    readonly property color muted:  "#565f89"
    readonly property color accent: "#7aa2f7"
    readonly property color crit:   "#f7768e"
    readonly property color border: "#2a2f42"
    readonly property string mono:  "FiraCode Nerd Font Mono"

    readonly property var sinks: Pipewire.nodes.values.filter(n =>
        n && n.isSink && !n.isStream)

    readonly property var streams: Pipewire.nodes.values.filter(n =>
        n && n.isStream && (n.type & PwNodeType.AudioOutStream) === PwNodeType.AudioOutStream)

    IpcHandler {
        target: "mixer"
        function toggle(): void { root.open = !root.open }
        function show(): void   { root.open = true }
        function hide(): void   { root.open = false }
    }

    PwObjectTracker {
        objects: {
            const a = []
            if (Pipewire.defaultAudioSink) a.push(Pipewire.defaultAudioSink)
            for (const n of root.sinks)   a.push(n)
            for (const n of root.streams) a.push(n)
            return a
        }
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

    component VolumeSlider: Item {
        id: slider
        property real value: 0
        property real maxValue: 1.5
        property bool muted: false
        signal moved(real v)

        implicitHeight: 18

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 4
            radius: 2
            color: root.border

            Rectangle {
                width: parent.width * Math.min(slider.value / slider.maxValue, 1)
                height: parent.height
                radius: 2
                color: slider.muted ? root.muted
                     : slider.value > 1.0 ? root.crit
                     : root.accent
                Behavior on width { NumberAnimation { duration: 80 } }
            }

            Rectangle {
                x: parent.width * Math.min(slider.value / slider.maxValue, 1) - width / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 12; height: 12; radius: 6
                color: root.fg
                border.color: root.bg
                border.width: 2
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.topMargin: -6
            anchors.bottomMargin: -6
            cursorShape: Qt.PointingHandCursor
            function emit(mx) {
                const v = Math.max(0, Math.min(slider.maxValue, mx / width * slider.maxValue))
                slider.moved(v)
            }
            onPressed: (m) => emit(m.x)
            onPositionChanged: (m) => { if (pressed) emit(m.x) }
        }
    }

    component NodeRow: ColumnLayout {
        id: row
        property var node
        readonly property var audio: node && node.ready ? node.audio : null
        readonly property string title: node ? (node.description || node.nickname || node.name || "Unknown") : ""

        spacing: 4
        visible: node !== null && node !== undefined

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: row.title
                opacity: row.audio && row.audio.muted ? 0.5 : 1.0
            }

            Label {
                text: row.audio ? Math.round(row.audio.volume * 100) + "%" : ""
                color: row.audio && row.audio.volume > 1.0 ? root.crit : root.muted
                font.pixelSize: 11
            }

            MouseArea {
                implicitWidth: 22; implicitHeight: 18
                cursorShape: Qt.PointingHandCursor
                onClicked: if (row.audio) row.audio.muted = !row.audio.muted
                Text {
                    anchors.centerIn: parent
                    text: row.audio && row.audio.muted ? "󰖁" : "󰕾"
                    color: row.audio && row.audio.muted ? root.muted : root.fg
                    font.family: root.mono
                    font.pixelSize: 14
                }
            }
        }

        VolumeSlider {
            Layout.fillWidth: true
            value: row.audio ? row.audio.volume : 0
            muted: row.audio ? row.audio.muted : false
            onMoved: (v) => { if (row.audio) row.audio.volume = v }
        }
    }

    component DeviceRow: Rectangle {
        id: dev
        property var node
        readonly property bool isDefault: node && Pipewire.defaultAudioSink === node

        Layout.fillWidth: true
        implicitHeight: 26
        radius: 6
        color: devArea.containsMouse ? Qt.rgba(0.48, 0.64, 0.97, 0.10) : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: dev.isDefault ? "󰐾" : "󰐽"
                color: dev.isDefault ? root.accent : root.muted
                font.family: root.mono
                font.pixelSize: 14
            }
            Label {
                Layout.fillWidth: true
                text: dev.node ? (dev.node.description || dev.node.name) : ""
                color: dev.isDefault ? root.fg : root.muted
            }
        }

        MouseArea {
            id: devArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (dev.node) Pipewire.preferredDefaultAudioSink = dev.node
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
                        text: "Audio Mixer"
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

                ColumnLayout {
                    width: parent.width
                    spacing: 6
                    SectionHeader { text: "Output" }
                    NodeRow {
                        Layout.fillWidth: true
                        node: Pipewire.defaultAudioSink
                    }
                }

                Flickable {
                    id: scroll
                    width: parent.width
                    contentWidth: width
                    contentHeight: scrollColumn.implicitHeight
                    implicitHeight: Math.min(scrollColumn.implicitHeight, 380)
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        policy: scroll.contentHeight > scroll.height
                            ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: root.muted
                            opacity: 0.6
                        }
                    }

                    Column {
                        id: scrollColumn
                        width: scroll.width - 10
                        spacing: 14

                        ColumnLayout {
                            width: parent.width
                            spacing: 2
                            visible: root.sinks.length > 1
                            SectionHeader { text: "Devices" }
                            Repeater {
                                model: root.sinks
                                DeviceRow { node: modelData }
                            }
                        }

                        ColumnLayout {
                            width: parent.width
                            spacing: 10
                            SectionHeader { text: "Apps" }
                            Repeater {
                                model: root.streams
                                NodeRow {
                                    Layout.fillWidth: true
                                    node: modelData
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                visible: root.streams.length === 0
                                text: "No apps playing audio"
                                color: root.muted
                                font.italic: true
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }
    }
}
