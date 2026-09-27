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
    readonly property bool shortName: pluginData.shortName ?? false

    // DMS's own name -> ISO code table (what its bar widget uses). JS can't be imported via qs, so load it by path.
    readonly property QtObject layoutCodes: {
        try {
            return Qt.createQmlObject(`import QtQuick; import "file://${Quickshell.shellDir}/DankCommon/Common/LayoutCodes.js" as L; QtObject { function code(n) { return L.layoutCode(n) } }`, root);
        } catch (e) {
            return null;
        }
    }

    function displayName(name) {
        if (!shortName)
            return name;
        return layoutCodes?.code(name) ?? name.slice(0, 2).toUpperCase();
    }

    function showLayout(name) {
        if (!name)
            return;
        shownLayout = displayName(name);
        shownScreen = NiriService.currentOutput || Quickshell.screens[0]?.name || "";
        popupVisible = true;
        hideTimer.restart();
    }

    function preview() {
        showLayout(NiriService.getCurrentKeyboardLayoutName() || "English (US)");
    }

    Connections {
        target: NiriService
        function onCurrentKeyboardLayoutIndexChanged() {
            if (NiriService.hasInitialConnection)
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
            visible: bubble.opacity > 0 && modelData.name === root.shownScreen
            color: "transparent"

            WlrLayershell.namespace: "dms:keyboard-layout-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            // Fill only the usable area, so the bar's reserved space is never covered
            WlrLayershell.exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region {}
            anchors { top: true; bottom: true; left: true; right: true }

            Item {
                id: bubble

                readonly property int edgeGap: 24
                readonly property int column: root.place.endsWith("Left") ? 0 : root.place.endsWith("Right") ? 2 : 1
                readonly property int row: root.place.startsWith("top") ? 0 : root.place.startsWith("bottom") ? 2 : 1
                readonly property real baseX: column === 0 ? edgeGap : column === 2 ? parent.width - width - edgeGap : (parent.width - width) / 2
                readonly property real baseY: row === 0 ? edgeGap : row === 2 ? parent.height - height - edgeGap : (parent.height - height) / 2

                width: Math.min(parent.width - 32, Math.max(100, Math.ceil(label.implicitWidth) + 40))
                height: label.implicitHeight + 28
                x: Math.round(Math.max(0, Math.min(parent.width - width, baseX + root.xOffset)))
                y: Math.round(Math.max(0, Math.min(parent.height - height, baseY + root.yOffset)))

                opacity: root.popupVisible ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Easing.OutCubic
                    }
                }

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
}
