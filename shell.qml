// Maple Launcher — dock/launcher de aplicaciones extraido de Caelestia (independiente del shell caelestia)
// Solo UI: grid de apps + buscador + selector de wallpapers (accion "wallpaper " en el search).
// Config: ~/.config/caelestia/shell.json (secciones launcher / appearance via Caelestia.Config)
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

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: win.screen.height * 0.12

            implicitWidth: loader.implicitWidth
            implicitHeight: loader.implicitHeight

            Loader {
                id: loader

                active: screenState.launcher

                sourceComponent: Content {
                    screenState: root.screenState
                    panels: root.dummyPanels
                    maxHeight: win.screen.height * 0.65
                }
            }
        }
    }
}