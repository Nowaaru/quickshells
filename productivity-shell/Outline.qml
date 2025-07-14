import Quickshell// for PanelWindows
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes

PanelWindow {
    id: outline
    property var outlineColor;
    property var outlineTopPadding: 16;
    property var outlineWidth: 4;
    property var z: -4000;

    exclusionMode: ExclusionMode.Ignore
    mask: Region { }
    color: "transparent"

    
    implicitWidth: screen.width
    implicitHeight: screen.height - outlineTopPadding


    anchors {
        bottom: true
    }

    Rectangle {
        z: outline.z
        color: "transparent"

        border {
            width: outlineWidth
            color: outlineColor
        }
        width: parent.width
        height: parent.height
    }
}
