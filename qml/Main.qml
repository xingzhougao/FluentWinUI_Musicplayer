import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "pages"

ApplicationWindow {
    id: window

    width: 1480
    height: 900
    minimumWidth: 1180
    minimumHeight: 720
    visible: true
    title: "Fluent Music"
    color: "#0b1017"

    property int selectedNav: 0

    readonly property color panelColor: "#101721"
    readonly property color panelColor2: "#131c27"
    readonly property color borderColor: "#1f2b3a"
    readonly property color textPrimaryColor: "#f5f7fb"
    readonly property color textSecondaryColor: "#8c99aa"
    readonly property color accentColor: "#6ea8ff"

    //桌面歌词窗口
    DesktopLyricWindow{
        id: desktopLyric
    }

    Rectangle {
        anchors.fill: parent
        color: window.color

        Rectangle {
            width: 480
            height: 480
            radius: 240
            x: window.width - 280
            y: -280
            color: "#142b5d91"
            opacity: 0.24
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TopBar {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            borderColor: window.borderColor
            textPrimaryColor: window.textPrimaryColor
            textSecondaryColor: window.textSecondaryColor
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            SideBar {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                selectedIndex: window.selectedNav
                borderColor: window.borderColor
                textPrimaryColor: window.textPrimaryColor
                textSecondaryColor: window.textSecondaryColor

                onNavigationRequested: function(index) { window.selectedNav = index}
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: window.selectedNav

                DiscoverPage {
                    playerController: player
                    textPrimaryColor: window.textPrimaryColor
                    textSecondaryColor: window.textSecondaryColor
                }

                RecommendPage {}
                PlaylistPage {}
                LocalMusicPage {}
                RecentPage {}
            }
        }

        PlayerBar {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            playerController: player
            borderColor: window.borderColor
            textPrimaryColor: window.textPrimaryColor
            textSecondaryColor: window.textSecondaryColor

            onLyricRequested: {
                desktopLyric.visible = !desktopLyric.visible
            }
        }
    }
}
