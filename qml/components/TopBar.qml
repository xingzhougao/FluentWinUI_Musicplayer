import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle{
    id: root
    implicitHeight: 74
    border.color: root.borderColor
    border.width: 1

    property color borderColor: "#1f2b3a"           //蓝黑
    property color textPrimaryColor: "#f5f7fb"      //灰白
    property color textSecondaryColor: "#8c99aa"    //蓝灰

    //歌词模式标记与返回信号
    property bool isLyricMode: false
    signal backRequested()
    signal searchRequested(string keyword)
    signal searchItemClicked(int index, string title)

    function setSearchText(t) {
        searchField.text = t;
    }

    //歌词模式下与歌词页背景无缝融合
    color: root.isLyricMode ? "#0c131e" : "#0e141d"

    RowLayout{
        anchors.fill: parent
        anchors.leftMargin: 22
        anchors.rightMargin: 22
        spacing: 18

        //歌词界面返回按钮
        Button {
            id: backButton
            visible: root.isLyricMode
            Layout.preferredWidth: 92
            Layout.preferredHeight: 38

            background: Rectangle {
                radius: 19
                color: backButton.hovered ? "#24354c" : "#162232"
                border.color: backButton.hovered ? "#415f8a" : "#263952"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            contentItem: RowLayout {
                spacing: 6
                anchors.centerIn: parent

                Text {
                    text: "˅"
                    color: root.textPrimaryColor
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "返回"
                    color: root.textPrimaryColor
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }

            ToolTip.visible: hovered
            ToolTip.text: "收起歌词并返回主界面"
            ToolTip.delay: 400

            onClicked: {
                root.backRequested()
            }
        }

        Rectangle{
            width: 38
            height: 38
            color:root.color
            Image{
                anchors.centerIn: parent
                source: "../icons/menu_bar.svg"
                sourceSize.width: 20
                sourceSize.height: 20
                fillMode: Image.PreserveAspectFit
            }
        }

        Row{
            Layout.preferredWidth: 214
            spacing: 10

            Rectangle{
                width: 38
                height: 38
                radius: 12

                gradient: Gradient{     //默认从上到下的颜色
                    GradientStop { position: 0.0;color: "#7e69ff"}
                    GradientStop { position: 1.0;color: "#55b5ff"}
                }

                Text {
                    anchors.centerIn: parent
                    text: "♪"
                    color: "white"
                    font.pixelSize: 25
                    font.bold: true
                }
            }

            Column{
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text{
                    text: "Fluent Music"
                    color: root.textPrimaryColor
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Text{
                    text: "Your daily sound"
                    color: root.textSecondaryColor
                    font.pixelSize: 10
                }
            }
        }

        Item{
            Layout.fillWidth: true
        }

        Rectangle{
            id: searchBox
            visible: !root.isLyricMode
            Layout.preferredWidth: 460
            Layout.preferredHeight: 42
            radius: 19
            color: searchField.activeFocus ? "#182332" : "#141c27"
            border.color: searchField.activeFocus ? "#486b9a" : "#243143"
            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 8
                spacing: 8

                Image {
                    source: "../icons/search.svg"
                    sourceSize.width: 16
                    sourceSize.height: 16
                    opacity: 0.65
                }

                TextField{
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "搜索歌曲、歌手、专辑"
                    placeholderTextColor: "#657286"
                    color: "#e7edf5"
                    font.pixelSize: 13
                    background: null
                    selectByMouse: true

                    onTextChanged: {
                        var kw = searchField.text.trim();
                        if (kw.length > 0 && typeof suggestLibrary !== "undefined" && typeof musicLibrary !== "undefined") {
                            suggestLibrary.searchFromModel(musicLibrary, kw);
                            if (suggestLibrary.count > 0 && searchField.activeFocus) {
                                suggestPopup.open();
                            } else {
                                suggestPopup.close();
                            }
                        } else {
                            if (typeof suggestLibrary !== "undefined") {
                                suggestLibrary.clear();
                            }
                            suggestPopup.close();
                        }
                    }

                    onAccepted: {
                        var kw = searchField.text.trim();
                        if (kw.length > 0) {
                            suggestPopup.close();
                            searchField.focus = false;
                            root.searchRequested(kw);
                        }
                    }
                }

                // 清空按钮
                Button {
                    id: clearBtn
                    visible: searchField.text.length > 0
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    background: Rectangle {
                        radius: 12
                        color: clearBtn.hovered ? "#283b52" : "transparent"
                    }
                    contentItem: Text {
                        text: "✕"
                        color: clearBtn.hovered ? "#f5f7fb" : "#7f8ea2"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        searchField.text = "";
                        if (typeof suggestLibrary !== "undefined") {
                            suggestLibrary.clear();
                        }
                        suggestPopup.close();
                    }
                }

                // 右侧搜索图标按钮
                Button {
                    id: searchActionBtn
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 28
                    hoverEnabled: true

                    background: Rectangle {
                        radius: 8
                        color: searchActionBtn.pressed ? "#2e435e" : (searchActionBtn.hovered ? "#243449" : "#1c2736")
                        border.color: searchActionBtn.hovered ? "#4a6c96" : "#2a3c53"
                        border.width: 1
                        scale: searchActionBtn.pressed ? 0.94 : 1.0
                        Behavior on scale { NumberAnimation { duration: 80 } }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Image {
                        anchors.centerIn: parent
                        source: "../icons/search.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                        opacity: searchActionBtn.hovered ? 1.0 : 0.8
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "搜索 (Enter)"
                    ToolTip.delay: 350

                    onClicked: {
                        var kw = searchField.text.trim();
                        if (kw.length > 0) {
                            suggestPopup.close();
                            searchField.focus = false;
                            root.searchRequested(kw);
                        }
                    }
                }
            }

            // 下拉联想框
            Popup {
                id: suggestPopup
                y: searchBox.height + 6
                width: searchBox.width
                padding: 6
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                background: Rectangle {
                    radius: 12
                    color: "#111823"
                    border.color: "#2a394c"
                    border.width: 1

                    // 微阴影感发光边缘
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        radius: 13
                        color: "transparent"
                        border.color: "#3d577a"
                        border.width: 1
                        opacity: 0.25
                        z: -1
                    }
                }

                contentItem: ColumnLayout {
                    spacing: 4
                    width: parent.width

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.topMargin: 4
                        spacing: 6

                        Text {
                            text: "匹配到的本地音乐"
                            color: "#8c99aa"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: (typeof suggestLibrary !== "undefined" ? suggestLibrary.count : 0) + " 个结果"
                            color: "#5b6f88"
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#1c2736"
                    }

                    ListView {
                        id: suggestListView
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(contentHeight, 260)
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: typeof suggestLibrary !== "undefined" ? suggestLibrary : null

                        delegate: Rectangle {
                            id: itemRect
                            width: suggestListView.width
                            height: 44
                            radius: 6
                            color: itemMouse.containsMouse ? "#1c2a3d" : "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 5
                                    color: "#1a2535"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "♪"
                                        color: "#6ea8ff"
                                        font.pixelSize: 12
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        Layout.fillWidth: true
                                        text: model.title || "未知歌曲"
                                        color: "#f5f7fb"
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: (model.artist || "未知歌手") + (model.album ? (" · " + model.album) : "")
                                        color: "#7e8d9f"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: "进入"
                                    color: itemMouse.containsMouse ? "#6ea8ff" : "transparent"
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    suggestPopup.close();
                                    searchField.focus = false;
                                    root.searchItemClicked(index, model.title);
                                }
                            }
                        }
                    }
                }
            }
        }

        Item{ Layout.fillWidth: true}

        Button{
            id: settingButton
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38

            background: Rectangle{
                radius: 12
                color: settingButton.hovered ? "#1c2734" : "transparent"
            }

            contentItem: Image{
               source: "../icons/setting_button.svg"
               sourceSize.width: 18
               sourceSize.height: 18
               fillMode: Image.PreserveAspectFit        //保持长度适应宽比
            }
        }
    }
}
