import Quickshell // for PanelWindows
import Quickshell.Widgets // for IconImages
import Quickshell.Services.SystemTray // for SysTray Support
import Quickshell.Hyprland // for Hyprland IPC
import Quickshell.Wayland // for Hyprland IPC
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes
import QtQuick.Controls // for Shapes
import QtQuick.Effects

PopupWindow {
    property alias mainBorderColor: containerItem.border.color;
    property alias backgroundColor: containerItem.color
    property alias item: anchors.item
    property color baseDotColor: dotContainer.color
    property int spacingCompensation: 0
    required property var menuItems;

    id: menuWindow
    visible: false
    color: "transparent"
    implicitWidth: 160
    implicitHeight: 32 * contextModel.values.length

    anchor {
        id: anchors
        edges: Edges.Top
        rect {
            y: -height
            x: -(menuWindow.width - (spacingCompensation * 2 )) / 2 + (menuWindow.item.width / 2) - spacingCompensation
        }
    }

    Rectangle {
        id: containerItem
        width: menuWindow.width
        height: menuWindow.height
        radius: 8

        border {
            width: 2
        }

        Component {
            id: menuItemDelegate
            WrapperMouseArea {
                hoverEnabled: true
                required property var modelData
                required property int index
                implicitWidth: parent.width
                implicitHeight: 32 - (containerItem.border.width * (contextModel.values.length > 1 ? 0.5 : 2))
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                anchors.horizontalCenter: parent.horizontalCenter

                onClicked: function(mouse) {
                    if (mouse.button & Qt.LeftButton)

                        modelData[1]/*contextData*/.onTriggered(mouse, modelData)

                    menuWindow.visible = false;
                }

                onContainsMouseChanged: function(mouseChangedStatus) {
                    listItemDetails.color = this.containsMouse ?  "#66FFFFFF" : "transparent"
                }

                Rectangle {
                    id: listItemDetails
                    color: "transparent"
                    radius: containerItem.radius / 1.25


                    Component {
                        id: potentialImage
                        Image {
                        }
                    }

                    Loader {
                        property var itemContainsImage: Object.keys(modelData[1]/*contextData */).includes("image")
                        source: itemContainsImage ? modelData[1].image : ""
                        sourceComponent: itemContainsImage ? potentialImage : undefined
                    }

                    Rectangle {
                        color: "transparent"
                        anchors {
                            fill: parent
                            centerIn: parent
                            leftMargin: 4
                        }

                        Rectangle {
                            id: dotContainer
                            implicitWidth: 8
                            height: implicitWidth - containerItem.border.width
                            radius: 40
                            color: Object.keys(modelData[1]).includes("color") ? modelData[1].color : baseDotColor
                            anchors {
                                leftMargin: containerItem.border.width
                                left: parent.left
                                right: text.left
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            id: text
                            width: parent.width - dotContainer.implicitWidth
                            height: parent.height
                            anchors {
                                right: parent.right
                            }

                            verticalAlignment:Text.AlignVCenter
                            leftPadding: dotContainer.implicitWidth / 2
                            color: "white"

                            font {
                                pointSize: 10
                                weight: 600
                                family: "VictorMonoNFM-Semibold"
                            }
                            text: {
                                const [contextId, contextData] = modelData;
                                return contextData.text
                            }
                        }
                    }
                }
            }
        }

        ScriptModel {
            id: contextModel
            property var baseMenuContexts: menuWindow.menuItems
            values: {
                return Object.entries(baseMenuContexts)
            }
        }

        ListView {
            id: contextMenuListView
            width: parent.width - (parent.border.width * 2)
            height: parent.height - (parent.border.width * 2)
            anchors { 
                centerIn: parent
            }
            orientation: ListView.Vertical
            delegate: menuItemDelegate
            model: contextModel.values
        }
    }
}
