import QtQuick
import qs.Common
import qs.Services
import qs.Modules.Plugins
import qs.Widgets

// Notification pill for the DankBar.
//   - Collapsed (no notification): plain bell, matching the native bell button.
//   - Active (notification arrives): avatar (image or purple bell) + app + summary.
//     Auto-collapses after a few seconds.
//   - Click on the body: opens the notification center anchored to this pill.
BasePill {
    id: root

    property bool showing: false
    property string appText: ""
    property string summaryText: ""
    property string avatarSource: ""

    // This pill is the ONLY notification surface: the native popup toast is muted
    // via a catch-all notificationRule (action "mute") in settings.json, which sets
    // popup=false, so NotificationService.popups stays empty. We therefore drive the
    // pill from the notification-center list ("notifications"), which still receives
    // every non-transient notification (transient ones are dropped by the mute rule).
    //
    // That list is mutated in place via .push() and emits NO change signal, so we
    // poll it. A genuine NEW arrival is detected as a growth in count; a shrink
    // (dismissal / clear-all) only updates the counter, so removing a notification
    // never re-pops the pill with an older one. _seenCount = -1 means "not yet
    // initialised": the first tick captures the baseline without popping, so
    // pre-existing notifications don't flash the pill on shell startup.
    property bool hasUnread: false
    property int _seenCount: -1

    Timer {
        interval: 300
        repeat: true
        running: true
        onTriggered: {
            const list = NotificationService.notifications;
            const count = list.length;
            root.hasUnread = count > 0;
            if (root._seenCount >= 0 && count > root._seenCount) {
                const latest = list[count - 1];
                if (latest) {
                    root.appText = (latest.notification && latest.notification.appName) || latest.appName || "";
                    root.summaryText = latest.summary || latest.body || "";
                    root.avatarSource = latest.image || latest.appIcon || "";
                    root.showing = true;
                    hideTimer.restart();
                }
            }
            root._seenCount = count;
        }
    }

    readonly property real pillH: root.widgetThickness
    readonly property real avatarSize: Math.max(16, pillH - 8)

    // Auto-hide: collapses the pill (the notification stays in the center).
    Timer {
        id: hideTimer
        interval: 6000
        repeat: false
        onTriggered: root.showing = false
    }

    // Opens the notification center anchored to THIS pill.
    function openNotificationCenter() {
        const loader = PopoutService.notificationCenterLoader;
        if (loader && !loader.active) {
            loader.active = true;
            Qt.callLater(root.openNotificationCenter);
            return;
        }
        const popout = PopoutService.notificationCenterPopout;
        if (!popout)
            return;
        const barPosition = root.axis?.edge === "left" ? 2 : (root.axis?.edge === "right" ? 3 : (root.axis?.edge === "top" ? 0 : 1));
        if (popout.setBarContext)
            popout.setBarContext(barPosition, root.barConfig?.bottomGap ?? 0);
        const globalPos = root.visualContent.mapToItem(null, 0, 0);
        const pos = SettingsData.getPopupTriggerPosition(globalPos, root.parentScreen, root.barThickness, root.visualWidth, root.barConfig?.spacing ?? 4, barPosition, root.barConfig);
        PopoutService.toggleNotificationCenter(pos.x, pos.y, pos.width, root.section, root.parentScreen);
    }

    onClicked: root.openNotificationCenter()

    content: Component {
        Item {
            id: body
            implicitHeight: root.pillH
            implicitWidth: root.showing ? Math.min(row.implicitWidth, 380) : collapsed.implicitWidth
            clip: true

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            // Collapsed: when there are unread notifications, the bell sits INSIDE a
            // filled purple circle (same as the avatar) so it clearly reads purple.
            // Otherwise, a plain grey bell (matching the native bell button).
            Item {
                id: collapsed
                visible: !root.showing
                anchors.centerIn: parent
                implicitWidth: root.hasUnread ? root.avatarSize : bellIcon.implicitWidth
                implicitHeight: root.pillH

                Rectangle {
                    visible: root.hasUnread
                    anchors.centerIn: parent
                    width: root.avatarSize
                    height: root.avatarSize
                    radius: width / 2
                    color: Theme.primary
                }

                DankIcon {
                    id: bellIcon
                    anchors.centerIn: parent
                    name: "notifications"
                    size: root.hasUnread ? Math.round(root.avatarSize * 0.6) : Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                    color: root.hasUnread ? (Theme.onPrimary ?? Theme.surface) : Theme.widgetIconColor
                }
            }

            // Active: avatar (image or purple bell) + app + summary.
            Row {
                id: row
                height: root.pillH
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showing
                spacing: Theme.spacingS

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.avatarSize
                    height: root.avatarSize
                    radius: width / 2
                    color: Theme.primary
                    clip: true

                    Image {
                        id: avatar
                        anchors.fill: parent
                        source: root.avatarSource
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                        asynchronous: true
                    }

                    DankIcon {
                        anchors.centerIn: parent
                        visible: avatar.status !== Image.Ready
                        name: "notifications"
                        size: root.avatarSize * 0.6
                        color: Theme.onPrimary ?? Theme.surface
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.appText
                    visible: text.length > 0
                    color: Theme.primary
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.summaryText
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeMedium
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    width: Math.min(implicitWidth, 240)
                }
            }
        }
    }
}
