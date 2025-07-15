import Quickshell // for PanelWindows
import QtQuick // for Texts
import Quickshell.Widgets // for Wrappers

PopupWindow {
    property alias backgroundColor: tooltipInner.color;
    property alias textColor: tooltipContent.color;
    property alias text: tooltipContent.text;
    property alias border: tooltipInner.border;
    property alias opacity: tooltipInner.opacity;
    property alias rightPadding: textWrapper.rightMargin
    property alias leftPadding: textWrapper.leftMargin
    property alias horizontalAlignment: tooltipContent.horizontalAlignment;
    property alias verticalAlignment: tooltipContent.verticalAlignment;
    
    
    readonly property var textObject: tooltipContent

    id: tooltip
    mask: Region {}
    color: "transparent"

    implicitWidth: metrics.width 
        + (textWrapper.leftMargin * 2) + (textWrapper.leftMargin * 0.75) 
        + (textWrapper.rightMargin * 2) + (textWrapper.rightMargin * 0.75) 
    implicitHeight: 18


    WrapperRectangle {
        id: tooltipInner
        implicitWidth: tooltip.implicitWidth
        implicitHeight: tooltip.implicitHeight

        radius: 2
        opacity: 0.5

        WrapperItem {
            id: textWrapper
            leftMargin: 4
            anchors {
                verticalCenter: parent.verticalCenter
            }

            TextMetrics {
                id: metrics
                font: tooltipContent.font
                text: tooltipContent.text
            }

            Text {
                id: tooltipContent
                text: "Tooltip"
                color: "white"
                font.weight: 600
            }
        }
    }
}
