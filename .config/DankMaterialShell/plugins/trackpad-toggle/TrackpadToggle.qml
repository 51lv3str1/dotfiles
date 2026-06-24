import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

// Bar button to enable/disable the trackpad.
//   - Runs toggle-trackpad.sh (comments/uncomments the 'off' node in inputs.kdl;
//     niri hot-reloads the config).
//   - Reads inputs.kdl via FileView (watchChanges) to reflect the real state, so
//     it also updates when toggled through the keybind (Mod+Shift+M).
//   - Base icon plus a red "block" overlay when the trackpad is disabled.
BasePill {
    id: root

    readonly property string home: Quickshell.env("HOME") || ""
    readonly property string inputsPath: home + "/.config/niri/inputs.kdl"
    readonly property string scriptPath: home + "/.config/niri/scripts/toggle-trackpad.sh"

    property bool trackpadDisabled: false

    FileView {
        id: conf
        path: root.inputsPath
        watchChanges: true
        // watchChanges does NOT auto-reload: call reload() on onFileChanged so
        // onLoaded fires again and the icon state is recomputed.
        onFileChanged: conf.reload()
        onLoaded: root._recompute()
    }

    function _recompute() {
        const t = conf.text() || "";
        // Uncommented 'off' node + marker => trackpad disabled.
        root.trackpadDisabled = /(^|\n)[ \t]*off[ \t]+\/\/ dms-trackpad-toggle/.test(t);
    }

    Process {
        id: toggleProc
        command: ["bash", root.scriptPath]
        // The inputs.kdl change is picked up by the FileView (watchChanges),
        // which recomputes the icon.
    }

    onClicked: toggleProc.running = true

    content: Component {
        Item {
            implicitWidth: baseIcon.implicitWidth
            implicitHeight: root.widgetThickness

            // Base trackpad icon (always the same glyph).
            DankIcon {
                id: baseIcon
                anchors.centerIn: parent
                name: "touch_app"
                size: Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.trackpadDisabled ? Theme.error : Theme.widgetIconColor
            }

            // "Block" overlay shown on top when the trackpad is disabled.
            DankIcon {
                anchors.centerIn: parent
                visible: root.trackpadDisabled
                name: "block"
                size: baseIcon.size
                color: Theme.error
            }
        }
    }
}
