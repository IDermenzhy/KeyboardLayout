import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import qs.Modules.Settings.Widgets

PluginSettings {
    id: root
    pluginId: "keyboardLayoutOSD"

    function resetToDefaults() {
        // Stop the color pickers from saving the theme's current color back as a fixed override
        backgroundColorSetting.isInitialized = false;
        textColorSetting.isInitialized = false;
        fontRow.currentValue = "Default"; // the dropdown drops its binding once a font is picked
        const all = JSON.parse(JSON.stringify(SettingsData.pluginSettings));
        all[root.pluginId] = { enabled: all[root.pluginId]?.enabled ?? true };
        SettingsData.pluginSettings = all;
        SettingsData.savePluginSettings();
        PluginService.pluginDataChanged(root.pluginId);
    }

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

    ToggleSetting {
        settingKey: "shortName"
        label: "Short layout code"
        description: "Show RU instead of Russian"
        defaultValue: false
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
        id: backgroundColorSetting
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

    // No settingKey here: on this row it would register in DMS's own settings search
    SettingsFontDropdownRow {
        id: fontRow
        width: parent.width
        text: "Font family"
        description: "Default follows the DMS font"
        currentFont: SettingsData.getPluginSetting(root.pluginId, "fontFamily", "")
        onFontSelected: family => root.saveValue("fontFamily", family)
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
        id: textColorSetting
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

    DankButton {
        width: parent.width
        text: "Reset to defaults"
        iconName: "restart_alt"
        onClicked: root.resetToDefaults()
    }
}
