pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root
    pluginId: "keyboardLayoutOSD"
    pluginService: PluginService

    property bool ready: false
    property bool popupVisible: false
    property string shownLayout: ""
    property string shownScreen: ""

    readonly property string place: pluginData.position ?? "center"
    readonly property int xOffset: Number(pluginData.xOffset ?? 0)
    readonly property int yOffset: Number(pluginData.yOffset ?? 0)
    readonly property int duration: Number(pluginData.duration ?? 700)
    readonly property int fontSize: Number(pluginData.fontSize ?? 32)
    readonly property string fontFamily: pluginData.fontFamily || Theme.fontFamily
    readonly property color backgroundColor: pluginData.backgroundColor || Theme.surfaceContainer
    readonly property color textColor: pluginData.textColor || Theme.surfaceText
    readonly property real backgroundOpacity: Number(pluginData.backgroundOpacity ?? 75) / 100

    function showLayout(name) {
        if (!name)
            return;
        shownLayout = name;
        shownScreen = NiriService.currentOutput || Quickshell.screens[0]?.name || "";
        popupVisible = true;
        hideTimer.restart();
    }

    function preview() {
        showLayout(NiriService.getCurrentKeyboardLayoutName() || "English (US)");
    }

    Component.onCompleted: ready = true

    Connections {
        target: NiriService
        function onCurrentKeyboardLayoutIndexChanged() {
            if (root.ready && NiriService.hasInitialConnection)
                root.showLayout(NiriService.getCurrentKeyboardLayoutName());
        }
    }

    Timer {
        id: hideTimer
        interval: Math.max(100, root.duration)
        onTriggered: root.popupVisible = false
    }

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: popup
            required property var modelData
            screen: modelData
            visible: root.popupVisible && modelData.name === root.shownScreen
            color: "transparent"

            WlrLayershell.namespace: "dms:keyboard-layout-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: -1
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region {}

            readonly property int edgeGap: 24
            readonly property int column: root.place.endsWith("Left") ? 0 : root.place.endsWith("Right") ? 2 : 1
            readonly property int row: root.place.startsWith("top") ? 0 : root.place.startsWith("bottom") ? 2 : 1
            readonly property int horizontal: column === 0 ? edgeGap : column === 2 ? modelData.width - width - edgeGap : (modelData.width - width) / 2
            readonly property int vertical: row === 0 ? edgeGap : row === 2 ? modelData.height - height - edgeGap : (modelData.height - height) / 2

            anchors { top: true; left: true }
            WlrLayershell.margins {
                left: Math.round(Math.max(0, Math.min(modelData.width - popup.width, popup.horizontal + root.xOffset)))
                top: Math.round(Math.max(0, Math.min(modelData.height - popup.height, popup.vertical + root.yOffset)))
            }

            implicitWidth: Math.min(modelData.width - 32, Math.max(100, label.implicitWidth + 40))
            implicitHeight: label.implicitHeight + 28

            Rectangle {
                anchors.fill: parent
                radius: Math.min(16, height / 2)
                color: root.backgroundColor
                opacity: Math.max(0, Math.min(1, root.backgroundOpacity))
            }

            Text {
                id: label
                anchors.centerIn: parent
                width: parent.width - 40
                text: root.shownLayout
                color: root.textColor
                font.family: root.fontFamily
                font.pixelSize: Math.max(10, root.fontSize)
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                renderType: Text.QtRendering
            }
        }
    }
}
