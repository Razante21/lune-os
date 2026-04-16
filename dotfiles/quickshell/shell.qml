import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "qml"
import "qml/components"

ShellRoot {
    id: root

    // Global Style
    Style {
        id: style
    }

    PanelWindow {
        id: rootPanel
        exclusionMode: ExclusionMode.Ignore
        implicitHeight: screen.height
        implicitWidth: screen.width
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        focusable: true

        // --- Top Hover Trigger ---
        MouseArea {
            id: topHoverTrigger
            width: parent.width
            height: 10
            anchors.top: parent.top
            hoverEnabled: true
        }

        // --- Left Hover Trigger ---
        MouseArea {
            id: leftHoverTrigger
            width: 10
            height: parent.height
            anchors.left: parent.left
            hoverEnabled: true
        }

        // --- Top Drawer (Hidden Panel) ---
        Loader {
            id: drawerLoader
            active: true
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: TopDrawer {
                id: topDrawer
                visible: topHoverTrigger.containsMouse
                opacity: topHoverTrigger.containsMouse ? 1 : 0
            }
        }

        // --- Side Drawer (Navigation) ---
        Loader {
            id: sideDrawerLoader
            active: true
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            sourceComponent: SideDrawer {
                id: sideDrawer
                isOpen: leftHoverTrigger.containsMouse
            }
        }

        // --- Top Bar ---
        Loader {
            id: topBarLoader
            active: true // Always active
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: TopBar {
                id: topBar
            }
        }

        // --- App Launcher (Skewed) ---
        Loader {
            id: launcherLoader
            active: false
            anchors.centerIn: parent
            sourceComponent: AppLauncher {
                id: appLauncher
            }
        }

        // --- Media Hub (Manga/Anime/Novel) ---
        Loader {
            id: hubLoader
            active: false
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            sourceComponent: MediaHub {
                id: mediaHub
            }
        }

        // --- Wallpaper Picker (Skewed) ---
        Loader {
            id: wallpaperLoader
            active: false
            anchors.centerIn: parent
            sourceComponent: WallpaperPicker {
                id: wallpaperPicker
            }
        }

        // Masking for interactivity
        mask: Region {
            Region {
                item: topBarLoader.item
            }
            Region {
                item: drawerLoader.item
            }
            Region {
                item: sideDrawerLoader.item
            }
            Region {
                item: launcherLoader.item
            }
            Region {
                item: hubLoader.item
            }
            Region {
                item: wallpaperLoader.item
            }
        }
    }

    // --- IPC Handlers for Toggling ---

    IpcHandler {
        target: "lune-launcher"
        function toggle() {
            launcherLoader.active = !launcherLoader.active;
            if (launcherLoader.active) {
                launcherLoader.item.opened = true;
            }
        }
    }

    IpcHandler {
        target: "lune-hub"
        function toggle() {
            hubLoader.active = !hubLoader.active;
            if (hubLoader.active) {
                hubLoader.item.opened = true;
            }
        }
    }

    IpcHandler {
        target: "lune-wallpaper"
        function toggle() {
            wallpaperLoader.active = !wallpaperLoader.active;
            if (wallpaperLoader.active) {
                wallpaperLoader.item.opened = true;
            }
        }
    }

    IpcHandler {
        target: "lune-side-drawer"
        function toggle() {
            if (sideDrawerLoader.item) {
                sideDrawerLoader.item.isOpen = !sideDrawerLoader.item.isOpen;
            }
        }
    }

    // Cleanup timers to unload components when closed
    Timer {
        id: cleanupTimer
        interval: 600
        onTriggered: {
            if (launcherLoader.item && !launcherLoader.item.opened) launcherLoader.active = false;
            if (hubLoader.item && !hubLoader.item.opened) hubLoader.active = false;
            if (wallpaperLoader.item && !wallpaperLoader.item.opened) wallpaperLoader.active = false;
        }
    }

    Connections {
        target: launcherLoader.item
        function onOpenedChanged() { if (!launcherLoader.item.opened) cleanupTimer.start(); }
    }
    Connections {
        target: hubLoader.item
        function onOpenedChanged() { if (!hubLoader.item.opened) cleanupTimer.start(); }
    }
    Connections {
        target: wallpaperLoader.item
        function onOpenedChanged() { if (!wallpaperLoader.item.opened) cleanupTimer.start(); }
    }
}
