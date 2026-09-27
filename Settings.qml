import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "keyboardLayoutOSD"

    SelectionSetting {
        settingKey: "position"
        label: "Position"
        options: [
            { label: "Top left", value: "topLeft" },
            { label: "Top center", value: "topCenter" },
            { label: "Top right", value: "topRight" },
            { label: "Middle left", value: "middleLeft" },
            { label: "Center", value: "center" },
            { label: "Middle right", value: "middleRight" },
            { label: "Bottom left", value: "bottomLeft" },
            { label: "Bottom center", value: "bottomCenter" },
            { label: "Bottom right", value: "bottomRight" }
        ]
        defaultValue: "center"
    }

    SliderSetting {
        settingKey: "xOffset"
        label: "Horizontal offset"
        defaultValue: 0
        minimum: -300
        maximum: 300
        unit: "px"
    }

    SliderSetting {
        settingKey: "yOffset"
        label: "Vertical offset"
        defaultValue: 0
        minimum: -300
        maximum: 300
        unit: "px"
    }

    SliderSetting {
        settingKey: "duration"
        label: "Display time"
        defaultValue: 700
        minimum: 200
        maximum: 3000
        unit: "ms"
    }

    ColorSetting {
        settingKey: "backgroundColor"
        label: "Background color"
        defaultValue: Theme.surfaceContainer
    }

    SliderSetting {
        settingKey: "backgroundOpacity"
        label: "Background opacity"
        defaultValue: 75
        minimum: 0
        maximum: 100
        unit: "%"
    }

    StringSetting {
        settingKey: "fontFamily"
        label: "Font family"
        description: "Leave empty to use the DMS font"
        defaultValue: ""
        placeholder: Theme.fontFamily
    }

    SliderSetting {
        settingKey: "fontSize"
        label: "Font size"
        defaultValue: 32
        minimum: 10
        maximum: 72
        unit: "px"
    }

    ColorSetting {
        settingKey: "textColor"
        label: "Text color"
        defaultValue: Theme.surfaceText
    }

    DankButton {
        width: parent.width
        text: "Preview layout popup"
        iconName: "visibility"
        onClicked: PluginService.pluginDaemonInstances[root.pluginId]?.preview()
    }
}
