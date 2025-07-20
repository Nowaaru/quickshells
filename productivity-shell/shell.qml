//@ pragma UseQApplication

import Quickshell // for PanelWindows
import Quickshell.Widgets // for Wrappers
import QtQuick // for Texts
import QtQuick.Controls // for Buttons
import Quickshell.Hyprland // for Hyprland IPC

ShellRoot {
    id: root
    property var topbarHeight: 20
    property var outlineWidth: 1.5

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    // DONE: add the glow w/ the taskbarComplementColor
    // set underneath the main taskbar area
    // and it goes vertically to the taskbar area
    // (like that subaru osu skin i guess)
    // TODO: maybe add the glowing pulse?
    // TODO: make startup overlay
    // TODO: make shutdown overlay
    Tooltip {
        visible: menuButton.hovered
        id: tooltipMenu
        text: "Menu"

        border {
            width: 2
            color: "#202020"
        }

        anchor.adjustment: PopupAdjustment.None
        anchor.window: menuButtonPanel
        anchor.rect.x: menuButton.width + 2
        verticalAlignment: Text.AlignVCenter
        leftPadding: 0
        rightPadding: border.width + 0.5

        backgroundColor: "black"
        textColor: "white"
    }

    Tooltip {
        id: tooltipTime
        text: Qt.formatDateTime(clock.date, "hh:mm:ss - yyyy-MM-dd")

        border {
            width: 2
            color: "#202020"
        }

        verticalAlignment: Text.AlignVCenter
        visible: timeMouseController.containsMouse
        anchor.window: topbar
        anchor.rect.x: topbar.width / 2 - (tooltipTime.width / 2)
        anchor.rect.y: topbar.height
        backgroundColor: "black"
        textColor: "white"
        opacity: 0.85
    }

    Tooltip {
        visible: powerButton.hovered
        id: tooltipPower
        text: "Power"

        border {
            width: 2
            color: "#202020"
        }

        anchor.adjustment: PopupAdjustment.None
        anchor.window: powerButtonPanel
        anchor.rect.x: -powerButton.width * 2 - 2
        anchor.edges: Edges.Left

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHRight
        leftPadding: 0
        rightPadding: border.width

        backgroundColor: "black"
        textColor: "white"
    }

    PanelWindow {
        color: "transparent"
        mask: Region {}

        Topbar {
            id: topbar
            exclusiveZone: ((taskbar.implicitHeight - taskbar.exclusiveZone) / taskbar.implicitHeight) * root.topbarHeight
            implicitHeight: root.topbarHeight
            color: taskbar.taskbarColor

            WrapperItem {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                topMargin: 0.5 //: why?? bruh...

                Text {
                    MouseArea {
                        id: timeMouseController
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    text: Qt.formatDateTime(clock.date, "hh:mm:ss")

                    font {
                        weight: 600
                    }

                    color: "white"
                }
            }

            Text {
                visible: !tooltipMenu.visible
                width: 80
                height: 20
                x: 120 + tooltipMenu.border.width
                verticalAlignment: Text.AlignVCenter
                text: {
                    const currentToplevelName = Hyprland.activeToplevel?.lastIpcObject?.initialClass?.match(/^(\w+)/)?.[0] ?? ""
                    const capitalizedToplevelName = `${currentToplevelName.substring(0,1).toUpperCase()}${currentToplevelName.substring(1)}`;

                    return capitalizedToplevelName
                }
                font.weight: 600
                color: "white"
                anchors {
                    top: menuButtonPanel.top
                    left: menuButtonPanel.left
                }
            }
        }

        Outline {
            outlineColor: taskbar.taskbarComplimentColor
            outlineWidth: root.outlineWidth
            outlineTopPadding: root.topbarHeight
        }

        PanelWindow {
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            mask: Region {}

            anchors {
                top: true
                left: true
            }

            WaveyLine {
                id: waveyLineTopLeft
                primaryColor: taskbar.taskbarColor
                shadowColor: taskbar.taskbarComplimentColor

                height: taskbar.implicitHeight
                transform: Scale {
                    xScale: 1
                    yScale: -1
                    origin {
                        x: waveyLineTopLeft.width / 2
                        y: waveyLineTopLeft.height / 2
                    }
                }
            }
        }

        Taskbar {
            id: taskbar
            taskbarColor: "#0F0F0F"
            taskbarMidColor: "#282925"
            taskbarComplimentColor: "#444436"
            taskbarShadowColor: "#3C3C39"
            taskbarMarginBottom: 0
        }

        PanelWindow {
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            mask: Region {}
            anchors {
                top: true
                right: true
            }

            WaveyLine {
                id: waveyLineTopRight
                primaryColor: taskbar.taskbarColor
                shadowColor: taskbar.taskbarComplimentColor

                x: 4
                height: taskbar.implicitHeight
                transform: Scale {
                    xScale: -1
                    yScale: -1
                    origin {
                        x: waveyLineTopRight.width / 2
                        y: waveyLineTopRight.height / 2
                    }
                }
            }
        }

        PanelWindow {
            id: menuButtonPanel
            color: "transparent"
            implicitWidth: root.topbarHeight - 1
            implicitHeight: root.topbarHeight - 2
            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                left: true
            }

            margins {
                top: 1
                left: waveyLineTopLeft.width + (waveyLineTopLeft.width / 24) // 96 * 4 = 24; ideally /24 will give a nice ratio  across multiple ratios
            }

            Button {
                id: menuButton
                height: parent.height
                width: parent.width
                background: Rectangle {
                    id: menuBackground
                    color: menuButton.hovered ? "#44FFFFFF" : "transparent"
                    radius: 50
                    z: -1
                    anchors {
                        fill: parent
                        centerIn: parent
                        margins: 1
                    }
                }

                // TODO: use a loader for the anchors or something? maybe an objectmodel?
                anchors {
                    fill: menuBackground
                    centerIn: menuBackground
                }

                onClicked: {
                    menuContextWindow.visible = !menuContextWindow.visible
                }

                PSContextMenu {
                    id: menuContextWindow
                    mainBorderColor: taskbar.taskbarMidColor; // mid
                    backgroundColor: taskbar.taskbarColor //taskbar
                    baseDotColor: taskbar.taskbarComplimentColor // compliment
                    item: menuButton
                    anchor.edges: Edges.Bottom
                    anchor.rect.y: 20
                    anchor.gravity: Edges.Bottom | Edges.Right

                    property var genericTrigger: ((_this) => 
                    {
                        Quickshell.execDetached(`hyprctl notify 0 5000 rgb(${_this.color.toString().substring(_this.color.toString().length > 7 ? 3 : 1)}) ${_this.text} is not implemented yet.`.split(' '));
                    })

                    menuItems: ({
                            close: {
                                text: "Close",
                                color: menuContextWindow.baseDotColor,
                                onTriggered: function(mouse, [contextId, contextData])
                                {
                                    Hyprland.refreshToplevels();
                                    if (!Hyprland.activeToplevel?.lastIpcObject)

                                        return;

                                    Hyprland.dispatch(`closewindow address:${Hyprland.activeToplevel.lastIpcObject?.address}`)
                                    menuContextWindow.visible = false;
                                }
                            }
                    })
                }

                icon {
                    cache: false
                    color: "#FCFC4C"
                    name: "bars-solid"
                    source: "assets/icons/bars-solid.svg"
                    width: menuBackground.width - (menuBackground.width * 0.25)
                    height: menuBackground.height - (menuBackground.height * 0.25)
                }

                HoverHandler {
                    id: menuHoverHandler
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                    grabPermissions: PointerHandler.CanTakeOverFromAnything
                }
            }
        }

        PanelWindow {
            id: powerButtonPanel
            color: "transparent"
            implicitWidth: root.topbarHeight
            implicitHeight: root.topbarHeight
            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                right: true

            }

            margins {
                right: waveyLineTopRight.width + (waveyLineTopRight.width / 24) // 96 * 4 = 24; ideally /24 will give a nice ratio  across multiple ratios
            }

            Button {
                id: powerButton
                height: parent.height
                width: parent.width
                background: Rectangle {
                    id: powerBackground
                    color: powerButton.hovered ? "#44FFFFFF" : "transparent"
                    radius: 50
                    anchors {
                        fill: parent
                        centerIn: parent
                        margins: 2
                    }
                }

                anchors {
                    fill: powerBackground
                    centerIn: powerBackground
                }

                icon {
                    cache: false
                    color: "#DF2935"
                    name: "bars-solid"
                    source: "assets/icons/power-off-solid.svg"
                    width: powerBackground.width - (powerBackground.width * 0.50)
                    height: powerBackground.height - (powerBackground.height * 0.50)
                }

                PSContextMenu {
                    id: powerContextWindow
                    mainBorderColor: taskbar.taskbarMidColor; // mid
                    backgroundColor: taskbar.taskbarColor //taskbar
                    baseDotColor: taskbar.taskbarComplimentColor // compliment
                    item: powerButton
                    anchor.edges: Edges.Bottom
                    anchor.rect.y: 20
                    anchor.gravity: Edges.Bottom | Edges.Right

                    property var genericTrigger: ((_this) => 
                    {
                        Quickshell.execDetached(`hyprctl notify 0 5000 rgb(${_this.color.toString().substring(_this.color.toString().length > 7 ? 3 : 1)}) ${_this.text} is not implemented yet.`.split(' '));
                    })

                    menuItems: ({
                            close_window: {
                                text: "Shutdown",
                                color: "#AADF2935",
                                onTriggered: function()
                                {
                                    powerContextWindow.genericTrigger(this)
                                }
                            },
                            reboot: {
                                text: "Restart",
                                color: "#AAFCFC4C",
                                onTriggered: function(mouse, [contextId, contextData])
                                {
                                    powerContextWindow.genericTrigger(this)

                                }
                            },
                            logout: {
                                text: "Logout",
                                color: powerContextWindow.baseDotColor,
                                onTriggered: function(mouse, [contextId, contextData])
                                {
                                    powerContextWindow.genericTrigger(this)
                                }
                            }
                    })
                }

                HoverHandler {
                    id: powerHoverHandler
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }

                onClicked: {
                    powerContextWindow.visible = !powerContextWindow.visible
                }
            }
        }
    }
}
