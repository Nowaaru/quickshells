import Quickshell // for PanelWindows
import Quickshell.Widgets // for IconImages
import Quickshell.Hyprland // for Hyprland IPC
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes

Rectangle {
    property alias borderWidth: _border.width;
    property alias borderColor: _border.color;
    

    id: taskbarLining

    z: -150
    anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
    }

    border {
        id: _border
        width: 4
        color: taskbar.taskbarMidColor
    }

    radius: 40
    // color: taskbar.taskbarColor
    // width: taskbarContainer.width
    // height: taskbarContainer.height
}
