/*
 * maybe a bottom bar that curves into the side of the screen
 * and a top bar that curves out from the side with the same radius
 * as the bottom which has a centered time, active process name to the left,
 * system options to the right
 *
 * bottom bar is dedicated for apps and system tray things
 */

import Quickshell // for PanelWindows
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes

ShellRoot {
    id: taskbar
    /* properties */
    property alias exclusiveZone: taskbarOuter.exclusiveZone;
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

            // TODO: turn these into actual wavey lines that go from left and right of the taskbarInner
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
                    bottom: taskbarSmoother.bottom
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
                    bottom: taskbarSmoother.bottom
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
            implicitWidth: screen.width * 0.7
            exclusionMode: ExclusionMode.Ignore
            color: 'transparent'

            anchors {

                bottom: true
            }

            margins.bottom: taskbar.taskbarMarginBottom

            Text {
                text: "there was supposed to be something here but i got tired (sorry)"
                anchors.centerIn: parent
                color: taskbar.taskbarShadowColor
                font.bold: true
            }
        }
    }
    /*
     * probably going to have to get the pixel position of the element's top left and top right
     * and find the exponent and uneg it
     */
    // Text {
    //     // center the bar in its parent component (the window)
    //     anchors.centerIn: parent
    //
    //     text: "hello world!"
    // }
}
