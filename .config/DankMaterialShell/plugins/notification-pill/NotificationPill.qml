import QtQuick
import qs.Common
import qs.Services
import qs.Modules.Plugins
import qs.Widgets

// Pastilla de notificación para la DankBar: muestra la última notificación
// (avatar + app + summary) como una píldora en la topbar, con botones de
// "abrir" y "descartar". NO se auto-oculta: queda hasta que la descartás.
BasePill {
    id: root

    // Dispara cuando llega una notificación nueva (la usamos solo como gatillo;
    // el contenido mostrado se guarda en 'current' para que persista aunque el
    // popup nativo expire de su lado).
    readonly property var latest: NotificationService.popups.length > 0 ? NotificationService.popups[NotificationService.popups.length - 1] : null

    property var current: null
    property bool showing: false
    property string appText: ""
    property string summaryText: ""
    property string avatarSource: ""

    readonly property real pillH: root.widgetThickness
    readonly property real avatarSize: Math.max(16, pillH - 8)

    onLatestChanged: {
        if (latest) {
            current = latest;
            appText = (latest.notification && latest.notification.appName) || latest.appName || "";
            summaryText = latest.summary || latest.body || "";
            avatarSource = latest.image || latest.appIcon || "";
            showing = true;
        }
    }

    // Ir a donde lleva la notificación: invoca su acción por defecto y descarta.
    function activateNotification() {
        if (current && current.actions && current.actions.length > 0)
            current.actions[0].invoke();
        if (current)
            NotificationService.dismissNotification(current);
        _clear();
    }

    // Descartar sin abrir.
    function dismissNotification() {
        if (current)
            NotificationService.dismissNotification(current);
        _clear();
    }

    function _clear() {
        current = null;
        showing = false;
    }

    // Click en el cuerpo de la pastilla = ir a la notificación.
    onClicked: activateNotification()

    content: Component {
        Item {
            id: body
            implicitHeight: root.pillH
            implicitWidth: root.showing ? Math.min(row.implicitWidth, 460) : collapsed.implicitWidth
            clip: true

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            // Estado colapsado (sin notificación): campana idéntica a la del
            // botón de notificaciones de la derecha (mismo color y tamaño -4).
            DankIcon {
                id: collapsed
                anchors.centerIn: parent
                visible: !root.showing
                name: "notifications"
                size: Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: Theme.widgetIconColor
            }

            // Estado expandido: una línea -> avatar + app + summary + botones.
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

                // Botón: ir a la notificación (acción por defecto).
                DankActionButton {
                    anchors.verticalCenter: parent.verticalCenter
                    buttonSize: Math.round(root.pillH * 0.86)
                    iconName: "open_in_new"
                    iconSize: Math.round(root.pillH * 0.5)
                    iconColor: Theme.primary
                    tooltipText: "Abrir"
                    onClicked: root.activateNotification()
                }

                // Botón: descartar.
                DankActionButton {
                    anchors.verticalCenter: parent.verticalCenter
                    buttonSize: Math.round(root.pillH * 0.86)
                    iconName: "close"
                    iconSize: Math.round(root.pillH * 0.5)
                    iconColor: Theme.surfaceText
                    tooltipText: "Descartar"
                    onClicked: root.dismissNotification()
                }
            }
        }
    }
}
