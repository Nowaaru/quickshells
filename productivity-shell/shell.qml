import Quickshell // for PanelWindows
import Quickshell.Widgets // for Wrappers
import QtQuick // for Texts
import QtQuick.Controls // for Buttons

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
        id: tooltipMenu
        text: "Menu"

        border {
            width: 2
            color: "#202020"
        }

        anchor.window: menuButtonPanel
        anchor.rect.x: menuButton.width + menuButton.width / 4
        anchor.rect.y: -2
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

        visible: timeMouseController.containsMouse
        anchor.window: topbar
        anchor.rect.x: topbar.width / 2 - (tooltipTime.width / 2)
        anchor.rect.y: topbar.height
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
                }

                icon {
                    cache: false
                    color: "#FCFC4C"
                    name: "bars-solid"
                    source: "./assets/bars-solid.svg"
                    height: root.topbarHeight
                }
            }
        }

        PanelWindow {
            id: powerButtonPanel
            color: "transparent"
            implicitWidth: root.topbarHeight - 1
            implicitHeight: root.topbarHeight - 2
            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                right: true
            }

            margins {
                top: 1
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
                }

                icon {
                    cache: false
                    color: "#DF2935"
                    name: "bars-solid"
                    source: "./assets/power-off-solid.svg"
                    height: root.topbarHeight
                }
            }
        }
    }
}
