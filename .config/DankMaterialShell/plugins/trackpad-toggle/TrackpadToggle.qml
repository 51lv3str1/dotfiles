import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

// Bar button to enable/disable the mouse and trackpad (keyboard-first workflow).
//   - Runs toggle-trackpad.sh, which comments/uncomments the marked 'off' nodes
//     in the touchpad and mouse blocks of inputs.kdl; niri hot-reloads.
//   - Reads inputs.kdl via FileView (watchChanges) to reflect the real state, so
//     it also updates when toggled through the keybind (Mod+Shift+M).
//   - The icon is the actual cursor image (SVG of the selected cursor theme),
//     with a red "block" overlay when the pointer is disabled.
BasePill {
    id: root

    readonly property string home: Quickshell.env("HOME") || ""
    readonly property string inputsPath: home + "/.config/niri/inputs.kdl"
    readonly property string dmsCursorPath: home + "/.config/niri/dms/cursor.kdl"
    readonly property string scriptPath: home + "/.config/niri/scripts/toggle-trackpad.sh"
    readonly property string syncScript: home + "/.config/niri/scripts/sync-cursor.sh"

    // Currently selected cursor theme (live from DMS settings).
    readonly property string cursorTheme: {
        const cs = SettingsData.cursorSettings;
        if (!cs)
            return "";
        return cs.theme === "System Default" ? (SettingsData.systemDefaultCursorTheme || "") : (cs.theme || "");
    }
    // SVG source of that theme's default (arrow) cursor.
    readonly property string cursorSvg: cursorTheme ? ("file://" + home + "/.local/share/icons/" + cursorTheme + "/cursors_scalable/default/default.svg") : ""

    property bool pointerDisabled: false

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
        // Uncommented 'off' node + marker => pointer disabled.
        root.pointerDisabled = /(^|\n)[ \t]*off[ \t]+\/\/ dms-pointer-toggle/.test(t);
    }

    Process {
        id: toggleProc
        command: ["bash", root.scriptPath]
        // The inputs.kdl change is picked up by the FileView (watchChanges).
    }

    // Keep cursor.kdl's theme/size in sync with the DMS-managed dms/cursor.kdl:
    // whenever DMS rewrites it (the user changes the cursor theme), regenerate
    // cursor.kdl via sync-cursor.sh so niri picks up the new theme automatically.
    FileView {
        id: dmsCursorConf
        path: root.dmsCursorPath
        watchChanges: true
        onFileChanged: dmsCursorConf.reload()
        onLoaded: syncCursorProc.running = true
    }

    Process {
        id: syncCursorProc
        command: ["bash", root.syncScript]
    }

    onClicked: toggleProc.running = true

    content: Component {
        Item {
            implicitWidth: root.widgetThickness
            implicitHeight: root.widgetThickness

            readonly property real iconSize: Theme.barIconSize(root.barThickness, -2, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)

            // Actual cursor image (SVG of the selected theme's default cursor).
            Image {
                id: cursorImg
                anchors.centerIn: parent
                source: root.cursorSvg
                // The cursor SVG is a 32x32 canvas with the arrow pinned to the
                // top-left corner (the hotspot), so the rest is empty. Rasterize
                // at 64x64 and clip to the arrow's region so it sits centered and
                // sized like the other bar icons.
                sourceSize: Qt.size(64, 64)
                sourceClipRect: Qt.rect(0, 0, 38, 50)
                height: parent.iconSize
                width: parent.iconSize * 38 / 50
                smooth: true
                visible: status === Image.Ready
                opacity: root.pointerDisabled ? 0.45 : 1.0
            }

            // Fallback to a material icon if the cursor SVG can't be loaded.
            DankIcon {
                anchors.centerIn: parent
                visible: cursorImg.status !== Image.Ready
                name: "mouse"
                size: parent.iconSize
                color: root.pointerDisabled ? Theme.error : Theme.widgetIconColor
            }

            // "Block" overlay shown on top when the pointer is disabled.
            DankIcon {
                anchors.centerIn: parent
                visible: root.pointerDisabled
                name: "block"
                size: parent.iconSize
                color: Theme.error
            }
        }
    }
}
