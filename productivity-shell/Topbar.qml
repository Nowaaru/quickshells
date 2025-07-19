import Quickshell // for PanelWindows
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes

// TODO: make draggable, maybe?
// TODO: on super, make this component fullscreen
// and then dynamically add the "SuperMenu" element

PanelWindow {
    id: topbar
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: implicitHeight
    implicitHeight: 16
    color: "black"


    anchors {
        top: true
        left: true
        right: true
    }
}
