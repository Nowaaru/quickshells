import Quickshell // for PanelWindows
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes

Item {
    /*------------*/

    id: waveyLine
    /* properties */
    property var primaryColor
    property var shadowColor

    property var shadowHeight: 10
    property var shadowWidth: 10

    property var usableHeight: waveyLine.height - shadowHeight
    property var usableWidth: waveyLine.width - shadowWidth

    property var primaryTransform: Scale {}
    property var shadowTransform: primaryTransform

    width: height

    Shape {
        id: waveyLineShape
        width: waveyLine.usableWidth
        height: waveyLine.usableHeight
        transform: primaryTransform

        ShapePath {
            strokeWidth: 0
            fillColor: primaryColor

            strokeStyle: ShapePath.DashLine
            dashPattern: [1, 4]
            startX: 0
            startY: waveyLine.height - waveyLine.usableHeight

            // TODO: make these WAVE!!! (WITH MORE WAVING COLORS BEHIND IT...!!!!!)
            // (when the user is away, make it eventually go fullscreen)
            // which then hyprlock will blur the screen and so the colors
            // are like rave lights with the blur, and then once activity
            // is detected it'll tween back to normal
            PathCubic {
                x: waveyLine.usableWidth
                y: waveyLine.height
                control1X: x / 18
                control1Y: y / 2
                control2X: x / 2
                control2Y: y / 4
            }

            PathLine {
                x: 0
                y: waveyLine.height
            }

            PathLine {
                x: 0
                y: waveyLine.height - waveyLine.usableHeight
            }
        }
    }

    Shape {
        id: waveyLineShapeShadow
        width: waveyLineShape.width + waveyLine.shadowWidth
        height: waveyLineShape.height + waveyLine.shadowHeight
        transform: shadowTransform
        z: -4

        ShapePath {
            strokeWidth: 0
            fillColor: shadowColor

            strokeStyle: ShapePath.DashLine
            dashPattern: [1, 4]
            startX: 0
            startY: 0

            // TODO: make these WAVE!!! (WITH MORE WAVING COLORS BEHIND IT...!!!!!)
            // (when the user is away, make it eventually go fullscreen)
            // which then hyprlock will blur the screen and so the colors
            // are like rave lights with the blur, and then once activity
            // is detected it'll tween back to normal
            PathCubic {
                x: waveyLine.width
                y: waveyLine.height
                control1X: x / 18
                control1Y: y / 2
                control2X: x / 2
                control2Y: y / 4
            }

            PathLine {
                x: 0
                y: waveyLine.height
            }

            PathLine {
                x: 0
                y: waveyLine.height
            }
        }
    }
}
