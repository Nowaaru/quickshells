/*
 * maybe a bottom bar that curves into the side of the screen
 * and a top bar that curves out from the side with the same radius
 * as the bottom which has a centered time, active process name to the left,
 * system options to the right
 *
 * bottom bar is dedicated for apps and system tray things
 */

import Quickshell // for PanelWindows
import Quickshell.Widgets // for IconImages
import Quickshell.Hyprland // for Hyprland IPC
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes

ShellRoot {
    id: taskbar
    ScriptModel {
        id: uniqueHyprlandClients
        values: Hyprland.toplevels.values
            .filter((e,k,arr) => arr.findIndex((f) => f.lastIpcObject.class === e.lastIpcObject.class) === k)
            .filter((e) => e.lastIpcObject.address)
    }

    /* properties */
    property alias exclusiveZone: taskbarOuter.exclusiveZone
    property var taskbarColor: "#0F0F0F"
    property var taskbarMidColor: "#282925"
    property var taskbarComplimentColor: "#444436"
    property var taskbarShadowColor: "#3C3C39"
    property var taskbarMarginBottom: 0
    property var implicitHeight: 96
    /*------------*/

    PanelWindow {
        id: taskbarOuter
        implicitHeight: taskbar.implicitHeight
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: implicitHeight - 56
        surfaceFormat.opaque: false
        color: "transparent"

        anchors {
            left: true
            right: true
            bottom: true
        }

        margins {
            property var horizMargins: 0
            property var vertMargins: 16
        }

        /*
         * it'd be super cool if the curves were draggable and it would adjust the windows as well
         * :334:
         */
        mask: Region {}

        PanelWindow {
            id: taskbarInner
            color: 'transparent'
            mask: Region {}
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: taskbarInner.width
            implicitHeight: taskbar.implicitHeight

            anchors {
                left: true
                right: true
                bottom: true
            }

            Rectangle {
                z: 0
                anchors {
                    bottom: parent.bottom
                }

                color: taskbar.taskbarComplimentColor
                width: taskbarInner.width
                height: 4
            }

            Rectangle {
                id: taskbarLining

                z: -100
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                border {
                    width: 4
                    color: taskbar.taskbarMidColor
                }

                radius: 40
                color: taskbar.taskbarColor
                width: taskbarContainer.width
                height: taskbarContainer.height
            }

            Rectangle {
                z: -400
                rotation: 180
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop {
                        position: 0
                        color: "#55D0D080"
                    }
                    GradientStop {
                        position: 0.4
                        color: "#22D0D080"
                    }
                    GradientStop {
                        position: 1
                        color: "transparent"
                    }
                }

                height: parent.height * 0.5
                width: parent.width
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
            }

            Rectangle {
                id: taskbarSmoother
                z: -200
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                color: taskbar.taskbarColor
                width: taskbarContainer.width * 0.99
                height: taskbarContainer.height / 2
            }

            WaveyLine {
                id: waveyLineTaskbarLeft
                z: -400
                primaryColor: taskbar.taskbarColor
                shadowColor: taskbar.taskbarMidColor

                anchors {
                    right: taskbarSmoother.left
                    bottom: parent.bottom
                    rightMargin: 0
                }

                x: 400
                height: taskbarSmoother.height

                transform: Scale {
                    xScale: -1
                    yScale: 1
                    origin {
                        x: waveyLineTaskbarLeft.width / 2
                        y: waveyLineTaskbarLeft.height / 2
                    }
                }
            }

            WaveyLine {
                id: waveyLineTaskbarRight
                z: -400
                primaryColor: taskbar.taskbarColor
                shadowColor: taskbar.taskbarMidColor

                anchors {
                    left: taskbarSmoother.right
                    bottom: parent.bottom
                    rightMargin: 0
                }

                x: 400
                height: taskbarSmoother.height

                transform: Scale {
                    xScale: 1
                    yScale: 1
                    origin {
                        x: waveyLineTaskbarRight.width / 2
                        y: waveyLineTaskbarRight.height / 2
                    }
                }
            }
        }

        WaveyLine {
            id: waveyLineLeft
            primaryColor: taskbar.taskbarColor
            shadowColor: taskbar.taskbarComplimentColor

            height: taskbar.implicitHeight

            anchors {
                bottom: parent.bottom
                left: parent.left
            }
        }

        WaveyLine {
            id: waveyLineRight
            primaryColor: taskbar.taskbarColor
            shadowColor: taskbar.taskbarComplimentColor

            height: taskbar.implicitHeight

            anchors {
                bottom: parent.bottom
                right: parent.right
            }

            primaryTransform: Scale {
                xScale: -1
                yScale: 1
                origin {
                    x: waveyLineRight.width / 2
                    y: waveyLineRight.height / 2
                }
            }

            shadowTransform: Scale {
                xScale: -1
                yScale: 1
                origin {
                    x: waveyLineRight.width / 2
                    y: waveyLineRight.height / 2
                }
            }
        }

        PanelWindow {
            id: taskbarContainer
            implicitHeight: taskbar.implicitHeight - 44
            // i literally have zero clue how this math logic works but i got it to work somehow
            // thanks im so swag
            implicitWidth: (84 * (uniqueHyprlandClients.values.length)) - (84 * ((uniqueHyprlandClients.values.length - 1) / 2)) + applicationsListView.itemPadding

            exclusionMode: ExclusionMode.Ignore
            color: 'transparent'

            anchors {

                bottom: true
            }

            margins.bottom: taskbar.taskbarMarginBottom

            ListView {
                id: applicationsListView
                property int itemHeight: 32;
                property int itemPadding: 8;
                property int itemWidth: itemHeight;

                Component {
                    id: taskbarItemDelegate
                    Rectangle {
                        id: itemRect

                        required property var modelData
                        required property int index
                        property var baseImageSource: {
                            const { lastIpcObject } = modelData;
                            const possibleQueryItems = [
                                lastIpcObject.class ?? "",
                                lastIpcObject.initialClass,
                                lastIpcObject.title,
                                ...([lastIpcObject.class ?? "", lastIpcObject.initialClass].map((e) => e ? e.match(/^(\w+)/)[0] : undefined).filter((e) => e)),
                            ].filter((e) => e)

                            const lowercaseQueryItems = possibleQueryItems.map((e) => e.toLowerCase())
                            const outUrl = [
                                ...possibleQueryItems,
                                ...lowercaseQueryItems
                            ].map((e) => Quickshell.iconPath(e, true)).filter((e) => e.length > 0)[0]

                            console.log(`out url for ${lastIpcObject.initialClass} - '${modelData.title}' (${modelData.lastIpcObject.address}): ${outUrl} (${Quickshell.iconPath("kde.discover", true)})`)

                            return outUrl ?? ""
                        }

                        color: "transparent"
                        radius: 8
                        width: applicationsListView.itemWidth
                        height: applicationsListView.itemHeight

                        anchors {
                            verticalCenter: parent ? parent.verticalCenter : undefined
                        }


                        Component {
                            id: imageIfFound


                            Item {

                                WrapperMouseArea {
                                    id: hoverArea
                                    margin: applicationsListView.itemPadding / 2
                                    hoverEnabled: true

                                    ElapsedTimer {
                                        id: hoverElapsedTime
                                    }

                                    onEntered: {
                                        hoverElapsedTime.restart()
                                        itemRect.color = "#22FFFFFF"
                                    }

                                    onExited: {
                                        itemRect.color = "transparent"
                                    }


                                    IconImage {
                                        id: icon
                                        implicitSize: applicationsListView.itemHeight - applicationsListView.itemPadding

                                        mipmap: true
                                        source: baseImageSource
                                        asynchronous: true

                                        Tooltip {
                                            visible: hoverArea.containsMouse
                                            text: 
                                                (modelData.lastIpcObject.class.includes(".") ? modelData.lastIpcObject.title : modelData.lastIpcObject.class.match(/^\w+/)[0]).replace(/[^]/, (e) => e.toUpperCase())

                                            horizontalAlignment: Text.AlignHCenter
                                            leftPadding: 2
                                            rightPadding: 2

                                            anchor {
                                                item: icon
                                                rect.y: -icon.implicitSize
                                                rect.x: (icon.implicitSize / 2) - (this.width / 2)
                                            }

                                            opacity: 1
                                            backgroundColor: "#44FFFFFF"
                                        }
                                    }
                                }
                            }
                        }

                        // TODO: add rounded greyish-line underneath elements 
                        // when they are opened, and a 4px.-ish dot if they're unopened but hovered

                        Component {
                            id: imageIfNotFound


                            Item {

                                WrapperMouseArea {
                                    id: hoverArea2
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    hoverEnabled: true

                                    ElapsedTimer {
                                        id: hoverElapsedTime
                                    }

                                    Component.onCompleted: {
                                        itemRect.color = "#22FFFFFF"
                                    }

                                    onEntered: {
                                        hoverElapsedTime.restart()
                                        itemRect.color = "#FFFFFFFF"
                                    }

                                    onExited: {
                                        itemRect.color = "#22FFFFFF"
                                    }

                                    Tooltip {
                                        visible: hoverArea2.containsMouse
                                        text: 
                                            (modelData.lastIpcObject.class.includes(".") ? modelData.lastIpcObject.title : modelData.lastIpcObject.class.match(/^\w+/)[0]).replace(/[^]/, (e) => e.toUpperCase())

                                        horizontalAlignment: Text.AlignHCenter
                                        leftPadding: 2
                                        rightPadding: 2

                                        anchor {
                                            item: nfIconC
                                            rect.y: (-nfIcon.height * 2) + applicationsListView.itemPadding
                                            rect.x: (nfIconC.width / 2) - (this.width / 2) 
                                        }

                                        opacity: 1
                                        backgroundColor: "#44FFFFFF"
                                    }

                                    Rectangle {
                                        id: nfIconC
                                        width: 16
                                        height: 16
                                        color: "transparent"

                                        Image {
                                            id: nfIcon
                                            width: 16
                                            height: 16
                                            anchors {
                                                centerIn: parent
                                            }

                                            source: `${Quickshell.workingDirectory}/assets/question-solid.svg`

                                        }
                                    }
                                }
                            }
                        }

                        Loader {
                            id: imageLoader
                            sourceComponent: baseImageSource ? imageIfFound : imageIfNotFound
                        }
                    }
                }

                // remove duplicates, they will be restored 
                // via a panelmenu on hover
                model: uniqueHyprlandClients
                spacing: itemWidth/4
                orientation: Qt.Horizontal
                delegate: taskbarItemDelegate
                anchors {
                    fill: parent
                    leftMargin: itemWidth
                    rightMargin: itemHeight
                }

                Component.onCompleted: {
                    Hyprland.rawEvent.connect((rawEvent) =>
                    {
                        const { name, data } = rawEvent;
                        if (name == "openwindow")
                        {
                            console.log("window opened")
                            Hyprland.refreshToplevels()
                        }
                    })
                }
            }
        }
    }
}
