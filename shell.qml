// Maple Launcher — dock/launcher de aplicaciones extraido de Caelestia (independiente del shell caelestia)
// Tema: hereda la paleta Material y la transparencia del shell end4-pC instalado
//   - paleta: ~/.local/state/quickshell/user/generated/material_colors.scss (regenerada por switchwall.sh)
//   - transparencia: ~/.config/illogical-impulse/config.json -> appearance.transparency
// Config del launcher en si: ~/.config/caelestia/shell.json (seccion launcher)
// Uso: qs -c maple-launcher  →  qs -c maple-launcher ipc call launcher toggle

//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.launcher

ShellRoot {
    id: root

    // ---- Tema heredado de end4-pC ----
    readonly property string scssPath: "/home/maple/.local/state/quickshell/user/generated/material_colors.scss"
    readonly property string end4ConfigPath: "/home/maple/.config/illogical-impulse/config.json"

    property color mtSurface: "#201f20"   // fallback material surfaceContainer
    property color mtPrimary: "#cbc4cb"   // fallback across end4 default
    property color mtOnSurface: "#e6e1e1"
    property real mtBackgroundAlpha: 0.7   // 1 - backgroundTransparency

    FileView {
        id: scss
        path: Qt.resolvedUrl(root.scssPath)
        watchChanges: true
        onLoadedChanged: {
            const t = scss.text();
            const s = t.match(/\$surfaceContainer: ?(#[0-9a-fA-F]{6})/);
            const p = t.match(/\$primary: ?(#[0-9a-fA-F]{6})/);
            const o = t.match(/\$onSurface: ?(#[0-9a-fA-F]{6})/);
            if (s) root.mtSurface = s[1];
            if (p) root.mtPrimary = p[1];
            if (o) root.mtOnSurface = o[1];
        }
    }

    FileView {
        id: cfg
        path: Qt.resolvedUrl(root.end4ConfigPath)
        onLoadedChanged: {
            try {
                const j = JSON.parse(cfg.text());
                const tr = j.appearance?.transparency;
                if (tr?.backgroundTransparency != null)
                    root.mtBackgroundAlpha = 1 - tr.backgroundTransparency;
            } catch (e) { /* config ausente o invalida: usar fallback */ }
        }
    }

    // ---- Estado ----
    IpcHandler {
        id: launcher
        target: "launcher"

        function toggle(): void {
            screenState.launcher = !screenState.launcher;
        }

        function open(): void {
            screenState.launcher = true;
        }

        function close(): void {
            screenState.launcher = false;
        }
    }

    readonly property ShellScreen activeScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]

    property ScreenState screenState: ScreenState {
        modelData: root.activeScreen
        launcher: false
        dashboard: false
        utilities: false
        sidebar: false
    }

    // Panels ficticios: Content/WallpaperList solo los usan para calcular margenes de drawers que aqui no existen
    property QtObject dummyPanels: QtObject {

        readonly property QtObject dashboard: QtObject { readonly property real nonAnimHeight: 0 }
        readonly property QtObject bar: QtObject { readonly property real implicitWidth: 0 }
        readonly property QtObject popouts: QtObject {
            readonly property bool hasCurrent: false
            readonly property real currentCenter: 0
            readonly property real nonAnimHeight: 0
            readonly property real nonAnimWidth: 0
        }
        readonly property QtObject utilities: QtObject { readonly property real implicitWidth: 0 }
    }

    PanelWindow {
        id: win

        screen: screenState.modelData
        visible: screenState.launcher
        color: "transparent"

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: screenState.launcher ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        // Scrim: pulsar fuera del launcher lo cierra
        MouseArea {
            anchors.fill: parent
            onClicked: screenState.launcher = false
        }

        Item {
            id: contentHost

            focus: true
            Keys.onEscapePressed: screenState.launcher = false

            // Dock anclado al borde inferior, centrado
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 16

            width: Math.min(900, win.screen.width * 0.75)
            implicitHeight: loader.implicitHeight

            // Panel: fondo heredado de end4 (surfaceContainer + transparencia del theme end4)
            Rectangle {
                id: panel
                anchors.fill: parent
                color: root.mtSurface
                opacity: root.mtBackgroundAlpha
                radius: 18
                border.color: Qt.alpha(root.mtPrimary, 0.25)
                border.width: 1

                Behavior on color { ColorAnimation { duration: 250 } }
            }

            Loader {
                id: loader

                anchors.fill: parent
                active: screenState.launcher

                sourceComponent: Content {
                    screenState: root.screenState
                    panels: root.dummyPanels
                    maxHeight: win.screen.height * 0.5
                }
            }
        }
    }
}