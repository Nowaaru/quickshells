/*
 * TODO: add mechanism that swaps back to your original special/normal
 * workspace by checking the Hyprland.activeToplevel.workspace?.name
 * and then checking if it contains the 'special' regex. if it does,
 * then 'togglespecialwindow' back to the primary. otherwise, use
 * 'moveworkspacetomonitor'
 */

import Quickshell // for PanelWindows
import Quickshell.Widgets // for IconImages
import Quickshell.Services.SystemTray // for SysTray Support
import Quickshell.Hyprland // for Hyprland IPC
import Quickshell.Wayland // for Hyprland IPC
import QtQuick // for Texts
import QtQuick.Shapes // for Shapes
import QtQuick.Controls // for Shapes
import QtQuick.Effects

ShellRoot {
    id: taskbar


    ScriptModel {
        id: uniqueHyprlandClients
        values: {
            return Hyprland.toplevels.values
                .filter((e,k,arr) => arr.findIndex((f) => f.lastIpcObject.class === e.lastIpcObject.class) === k)
                .filter((e) => e.lastIpcObject.address)
                .filter((e) => e.lastIpcObject.initialClass && e.lastIpcObject.class && e.lastIpcObject.address)
        }
    }

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
            id: taskbarDecoration
            color: 'transparent'
            mask: Region {}
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: taskbarDecoration.width
            implicitHeight: taskbar.implicitHeight

            anchors {
                left: true
                right: true
                bottom: true
            }

            TaskbarLining {
                id: taskbarLining
                borderWidth: 4
                borderColor: taskbar.taskbarMidColor

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

        // TODO:: implement upwards-facing chevron that appears only after
        // 'maxItems' is achieved or 'hiddenItems' is populated and matches
        // against the target tray entry.
        PanelWindow {
            id: sysTrayContainer
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: 256
            implicitHeight: taskbarContainer.implicitHeight

            color: "transparent"

            anchors {
                bottom: true
                right: true
            }

            margins {
                right: waveyLineRight.width
            }


            Rectangle {
                id: traySmoother
                z: -200
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                color: taskbar.taskbarColor
                width: trayLining.width * 0.75
                height: parent.height / 2
            }



            ListView {
                id: lView
                property int itemWidth: 32
                property int imagePadding: 8;
                implicitWidth: SystemTray.items.values.length * itemWidth
                implicitHeight: 32

                spacing: 2
                orientation: Qt.Horizontal

                
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }



                Component {
                    id: delegate
                    Rectangle {
                        z: 4000
                        width: lView.itemWidth
                        height: lView.itemWidth


                        required property var modelData
                        required property int index

                        color: mouseArea.containsMouse ? "#22FFFFFF" : "transparent"
                        radius: 8

                        QsMenuAnchor {
                            id: menuAnchor
                            menu: modelData.menu
                            anchor {
                                item: icon
                                rect {
                                    y: -icon.height - (icon.height / 4)
                                    x: -(icon.width * 2) - (lView.spacing)
                                }
                            }
                        }

                        WrapperMouseArea {
                            id: mouseArea
                            hoverEnabled: true
                            implicitWidth: lView.itemWidth - lView.imagePadding
                            implicitHeight: lView.itemWidth - lView.imagePadding
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: {
                                menuAnchor.visible ? menuAnchor.close() : menuAnchor.open()
                            }

                            anchors {
                                centerIn: parent
                            }

                            Image {

                                id: icon
                                width: parent.width
                                height: parent.height
                                sourceSize.width: width
                                sourceSize.height: height

                                mipmap: true
                                source: { 
                                    
                                    return modelData.icon
                                }


                                asynchronous: true


                                Tooltip {
                                    visible: !!this.text && mouseArea.containsMouse // remove visibility if empty, for now.
                                    text: modelData.tooltipTitle || modelData.tooltipDescription || modelData.title

                                    horizontalAlignment: Text.AlignHCenter
                                    leftPadding: 2
                                    rightPadding: 2

                                    anchor {
                                        item: icon
                                        rect.y: -icon.height
                                        rect.x: (icon.width / 2) - (this.width / 2)
                                    }

                                    opacity: 1
                                    backgroundColor: "#44FFFFFF"
                                }
                            }
                        }
                    }
                }

                TaskbarLining {
                    id: trayLining
                    borderWidth: 4
                    borderColor: taskbar.taskbarMidColor

                    color: taskbar.taskbarColor

                    width: lView.width + (lView.spacing * lView.model.values.length) + lView.itemWidth / (lView.model.values.length > 1 ? 2 : 1)
                    height: taskbarContainer.height

                    anchors {
                        centerIn: parent
                    }


                    WaveyLine {
                        z: -400
                        id: waveyTrayLineLeft
                        primaryColor: taskbar.taskbarColor
                        shadowColor: taskbar.taskbarMidColor

                        height: parent.height / 2

                        anchors {
                            bottom: parent.bottom
                            right: parent.left
                            rightMargin: -16
                        }

                        primaryTransform: Scale {
                            xScale: -1
                            yScale: 1
                            origin {
                                x: waveyTrayLineLeft.width / 2
                                y: waveyTrayLineLeft.height / 2
                            }
                        }

                        shadowTransform: Scale {
                            xScale: -1
                            yScale: 1
                            origin {
                                x: waveyTrayLineLeft.width / 2
                                y: waveyTrayLineLeft.height / 2
                            }
                        }
                    }


                    WaveyLine {
                        z: -400
                        id: waveyTrayLineRight
                        primaryColor: taskbar.taskbarColor
                        shadowColor: taskbar.taskbarMidColor

                        height: parent.height / 2

                        anchors {
                            bottom: parent.bottom
                            left: parent.right
                            leftMargin: -16
                        }

                        primaryTransform: Scale {
                            xScale: 1
                            yScale: 1
                            origin {
                                x: waveyTrayLineRight.width / 2
                                y: waveyTrayLineRight.height / 2
                            }
                        }

                        shadowTransform: Scale {
                            xScale: 1
                            yScale: 1
                            origin {
                                x: waveyTrayLineRight.width / 2
                                y: waveyTrayLineRight.height / 2
                            }
                        }
                    }
                }


                model: {
                    const trayItems = SystemTray.items.values;
                    return trayItems
                }

                delegate: delegate
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
                                ...([lastIpcObject.class ?? "", lastIpcObject.initialClass].map((e) => e ? e.match(/^(\w+)/)?.[0] : undefined).filter((e) => e)),
                            ].filter((e) => e)

                            const lowercaseQueryItems = possibleQueryItems.map((e) => e.toLowerCase())
                            const outUrl = [
                                ...possibleQueryItems,
                                ...lowercaseQueryItems
                            ].map((e) => Quickshell.iconPath(e, true)).filter((e) => e.length > 0)[0]

                            // console.log(`out url for ${lastIpcObject.initialClass} - '${modelData.title}' (${modelData.lastIpcObject.address}): ${outUrl} (${Quickshell.iconPath("kde.discover", true)})`)

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
                                Timer {
                                    property var isDisappearing: false
                                    property var appearInterval: 500
                                    property var disappearInterval: 100

                                    id: hoverTimer
                                    interval: appearInterval
                                    running: false
                                    repeat: false

                                    onTriggered: {
                                        console.log("ok i got you dawg")
                                        duplicateClassesPopupWindow.visible = !this.isDisappearing
                                        this.isDisappearing = !this.isDisappearing;
                                        Hyprland.refreshToplevels();
                                        Hyprland.refreshWorkspaces();
                                    }
                                }

                                WrapperMouseArea {
                                    id: hoverArea
                                    margin: applicationsListView.itemPadding / 2
                                    hoverEnabled: true
                                    acceptedButtons: Qt.RightButton

                                    onEntered: {
                                        hoverTimer.isDisappearing = false;
                                        hoverTimer.interval = hoverTimer.appearInterval
                                        hoverTimer.restart();
                                        itemRect.color = "#22FFFFFF"
                                    }

                                    onExited: {
                                        hoverTimer.isDisappearing = true;
                                        hoverTimer.interval = hoverTimer.disappearInterval
                                        hoverTimer.restart();
                                        itemRect.color = "transparent"
                                    }


                                    Component.onCompleted: {
                                    }

                                    onClicked: {

                                        menuWindow.visible = !menuWindow.visible
                                    }


                                    child: IconImage {
                                        id: icon
                                        implicitSize: applicationsListView.itemHeight - applicationsListView.itemPadding

                                        mipmap: true
                                        source: baseImageSource
                                        asynchronous: true

                                        PopupWindow {
                                            id: duplicateClassesPopupWindow
                                            property double aspectRatio: 16/9
                                            property double containerRectSize: 240
                                            property double containerRectBorderSize: 3
                                            visible: false
                                            color: "transparent" // "#2200FF00"
                                            /*
                                             * I DON'T KNOW WHAT ANY OF THIS MEANS
                                             * BUT YOU KNOW WHAT I'M TAKING IT
                                             */
                                            implicitWidth: 
                                                ((containerRectSize) * (valuesModel.values.length))
                                                + (duplicateListView.spacing * valuesModel.values.length - 1)
                                                + (containerRectBorderSize * valuesModel.values.length)
                                                + (backgroundRect.anchors.margins * 2)
                                                - (3 * (Math.max(0, valuesModel.values.length - 2)))
                                                + (valuesModel.values.length > 1 ? 0 : (duplicateListView.spacing / 2))

                                            implicitHeight: {

                                                return 150
                                            }

                                            HoverHandler {
                                                id: hoverHandler
                                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                                onHoveredChanged: {
                                                    if (this.hovered)
                                                    {
                                                        hoverTimer.isDisappearing = false;
                                                        hoverTimer.stop()

                                                        return;
                                                    } 

                                                    hoverTimer.isDisappearing = true;
                                                    hoverTimer.restart()
                                                }
                                            }

                                            Rectangle {
                                                id: backgroundRect
                                                color: taskbar.taskbarColor
                                                border { 
                                                    width: 2
                                                    color: taskbar.taskbarComplimentColor
                                                }
                                                radius: 4
                                                anchors {
                                                    top: parent.top
                                                    margins: 8
                                                    bottom: parent.bottom
                                                    left: parent.left
                                                    right: parent.right
                                                    leftMargin: 8 
                                                }

                                                ListView {
                                                    id: duplicateListView
                                                    width: duplicateClassesPopupWindow.implicitWidth 
                                                    height: parent.height - parent.anchors.margins
                                                    x: parent.anchors.leftMargin / 2 
                                                    y: parent.anchors.margins / 2
                                                    anchors {
                                                    }

                                                    orientation: Qt.Horizontal
                                                    delegate: screenViewItemDelegate                                           
                                                    spacing: 4
                                                    model: valuesModel

                                                    ScriptModel {
                                                        id: valuesModel
                                                        values: {
                                                            const reducedValues = 
                                                                Hyprland.toplevels.values
                                                                    .filter(({lastIpcObject}) => lastIpcObject.class === modelData.lastIpcObject.class)
                                                                    .reduce((acc, {lastIpcObject}, k) => {
                                                                        const {class: ipcClass, address} = lastIpcObject;
                                                                        const stringifiedObject = JSON.stringify(lastIpcObject);
                                                                        if (acc[ipcClass]) 

                                                                            acc[ipcClass].push(stringifiedObject)

                                                                        else {
                                                                            if (address)

                                                                                acc[ipcClass] = [stringifiedObject];
                                                                        }

                                                                        return acc;
                                                                    }, {})

                                                            const all = reducedValues[modelData.lastIpcObject.class]
                                                            const single = [all[0]];
                                                            return all
                                                        }
                                                    }
                                                }

                                                Component {
                                                    id: screenViewItemDelegate
                                                    WrapperMouseArea {
                                                        id: mouseArea
                                                        hoverEnabled: true
                                                        required property var modelData
                                                        required property int index
                                                        width: duplicateClassesPopupWindow.containerRectSize

                                                        Timer {
                                                            id: showElementTimer
                                                            interval: 250
                                                            running: false
                                                            repeat: false

                                                            property var modifiedAddresses: []
                                                            property var workspaceSpecial: undefined
                                                            property var workspace: undefined
                                                            onTriggered: {
                                                                Hyprland.refreshWorkspaces()
                                                                if (this.workspace)

                                                                    return;

                                                                const activeWorkspace = Hyprland.focusedWorkspace;
                                                                const currentWorkspace = JSON.parse(modelData).workspace;
                                                                const currentSpecialWorkspaceName = 
                                                                    currentWorkspace.name.match(/special:(.+)/)?.[1]

                                                                Hyprland.toplevels.values.forEach(({lastIpcObject: e}) =>
                                                                {
                                                                    if (e.address != JSON.parse(modelData).address)
                                                                    {
                                                                        modifiedAddresses.push(e.address);
                                                                        ["", "inactive", "fullscreen"].forEach((alphaItem) =>
                                                                        {
                                                                            Hyprland.dispatch(`setprop address:${e.address} alpha${alphaItem}override 1`)
                                                                            Hyprland.dispatch(`setprop address:${e.address} alpha${alphaItem} 0`)
                                                                        })
                                                                    }


                                                                })

                                                                const mainToplevel = Hyprland.workspaces.values.find((e) => e.name === Hyprland.activeToplevel?.workspace?.name)
                                                                if (currentSpecialWorkspaceName)
                                                                {
                                                                    if (mainToplevel.name !== currentWorkspace.name)
                                                                    {
                                                                        this.workspaceSpecial = currentSpecialWorkspaceName;
                                                                        Hyprland.dispatch(`togglespecialworkspace ${currentSpecialWorkspaceName}`)
                                                                    }
                                                                } 
                                                                else if (activeWorkspace)
                                                                {
                                                                    // check to see if the target
                                                                    // workspace is on the current 
                                                                    // face monitors...
                                                                    const targetWorkspace = Hyprland.workspaces.values.find((e) => 
                                                                    {
                                                                        return e.name.toString() === currentWorkspace.name.toString()
                                                                    })

                                                                    if (targetWorkspace && !targetWorkspace.active)
                                                                    {
                                                                        this.workspace = activeWorkspace.name
                                                                        targetWorkspace.activate()
                                                                    }
                                                                }



                                                                // console.log(`hovered for over ${(this.interval / 1000).toString().substring(0, 4)} seconds`)
                                                            }

                                                            onRunningChanged: {
                                                            }
                                                        }

                                                        property var didClick: false
                                                        onClicked: {
                                                            this.didClick = true;

                                                            const parsedModelData = JSON.parse(modelData);
                                                            const currentWorkspace = parsedModelData.workspace;
                                                            const foundMatchingWorkspace = Hyprland.workspaces.values.find((e) => e.name === currentWorkspace?.name);
                                                            Hyprland.dispatch(`movetoworkspace ${Hyprland.focusedMonitor.activeWorkspace.name},address:${parsedModelData.address}`)
                                                            Hyprland.dispatch(`focuswindow address:${parsedModelData.address}`)
                                                            Hyprland.refreshToplevels();
                                                            Hyprland.refreshWorkspaces();
                                                            showElementTimer.stop();
                                                        }

                                                        onContainsMouseChanged: {
                                                            if (this.containsMouse)
                                                            {
                                                                showElementTimer.restart()
                                                            } 
                                                            else 
                                                            {

                                                                ["", "inactive", "fullscreen"].forEach((alphaItem) =>
                                                                {
                                                                    Hyprland.toplevels.values.filter((e) => e?.lastIpcObject?.address).forEach(({lastIpcObject: e}) =>
                                                                    {
                                                                        Hyprland.dispatch(`setprop address:${e.address} alpha${alphaItem}override 1`)
                                                                        Hyprland.dispatch(`setprop address:${e.address} alpha${alphaItem} 1`)
                                                                        Hyprland.dispatch(`setprop address:${e.address} alpha${alphaItem}override 0`)
                                                                    })
                                                                })

                                                                if (showElementTimer.running)

                                                                    showElementTimer.stop()

                                                                if (showElementTimer.workspaceSpecial && !this.didClick)
                                                                {
                                                                    Hyprland.dispatch(`togglespecialworkspace ${showElementTimer.workspaceSpecial}`)
                                                                } 
                                                                else if (showElementTimer.workspace)
                                                                {
                                                                    const previousWorkspace = Hyprland.workspaces.values.find((e) => e.name == showElementTimer.workspace)
                                                                    if (previousWorkspace)

                                                                        previousWorkspace.activate()
                                                                }



                                                                // clear old arr
                                                                showElementTimer.modifiedAddresses = []
                                                                showElementTimer.workspaceSpecial = undefined;
                                                                showElementTimer.workspace = undefined;
                                                                this.didClick = false;
                                                            }
                                                            console.log(this.containsMouse)
                                                        }

                                                        anchors {
                                                            top: parent ? parent.top : undefined
                                                            bottom: parent ? parent.bottom : undefined
                                                        }
                                                        Rectangle {
                                                            id: containerRect
                                                            color: "transparent"
                                                            clip: {
                                                                // console.log(modelData)
                                                                return true;
                                                            }

                                                            border {
                                                                width: duplicateClassesPopupWindow.containerRectBorderSize
                                                                color: taskbar.taskbarComplimentColor
                                                            }

                                                            radius: 2

                                                            width: parent.width

                                                            anchors {
                                                                top: parent ? parent.top : undefined
                                                                bottom: parent ? parent.bottom : undefined
                                                            }

                                                            /**
                                                             * i had to do some weird bullhonkey
                                                             * because some windows have different
                                                             * ratios (for some reason?) 
                                                             *
                                                             * so, i opted to just tuck the screencopy
                                                             * underneath the rectangle overlay. this also
                                                             * allows me to comfortably have a border
                                                             * radius as a result! this is cool.
                                                             */
                                                            ScreencopyView {
                                                                id: sourceItem
                                                                z: -1
                                                                visible: true
                                                                live: true
                                                                captureSource: {
                                                                    const E = Hyprland.toplevels.values.find((e) => e.lastIpcObject.address === JSON.parse(modelData).address)
                                                                    return E?.wayland ?? null
                                                                }

                                                                paintCursor: false


                                                                width: duplicateClassesPopupWindow.containerRectSize - containerRect.border.width
                                                                height: parent.height - containerRect.border.width
                                                                constraintSize {
                                                                    width: duplicateClassesPopupWindow.containerRectSize
                                                                    height: parent.height
                                                                }

                                                                anchors {
                                                                    top: parent.top
                                                                    bottom: parent.bottom
                                                                    left: parent.left
                                                                    right: parent.right
                                                                    // divide by 2 because... duh?
                                                                    // its essentially positioned halfway 
                                                                    // in the inside border
                                                                    centerIn: parent
                                                                }
                                                            }

                                                            Rectangle {
                                                                width: parent.width
                                                                height: 32
                                                                color: `#${mouseArea.containsMouse ? "99" : "00"}${taskbar.taskbarComplimentColor.substring(1)}`
                                                                anchors {
                                                                    top: parent.top
                                                                    bottom: parent.bottom
                                                                    horizontalCenter: parent.horizontalCenter
                                                                }

                                                                Rectangle {
                                                                    id: coverBorder
                                                                    width: nameText.contentWidth + 12
                                                                    color: taskbar.taskbarMidColor
                                                                    height: nameText.contentHeight
                                                                    radius: 4
                                                                    opacity: 0.7

                                                                    anchors {
                                                                        bottom: parent.bottom
                                                                        horizontalCenter: parent.horizontalCenter
                                                                        bottomMargin: 8
                                                                    }

                                                                    border {
                                                                        width: 2
                                                                        color: taskbar.taskbarComplimentColor
                                                                    }


                                                                    Text {
                                                                        color: "white"
                                                                        id: nameText
                                                                        width: sourceItem.width - 24
                                                                        wrapMode: Text.Wrap;
                                                                        horizontalAlignment: Text.AlignHCenter
                                                                        verticalAlignment: Text.AlignVCenter
                                                                        text: {
                                                                            return JSON.parse(modelData).title
                                                                        }

                                                                        anchors {
                                                                            centerIn: parent
                                                                        }

                                                                        font {
                                                                            weight: 600
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            anchor {
                                                item: icon
                                                edges: Edges.Top
                                                rect {
                                                    y: -height
                                                    x: -(width - (lView.spacing * 2 )) / 2 + (icon.width / 2) - lView.spacing
                                                }
                                            }
                                        }

                                        PopupWindow {
                                            id: menuWindow
                                            visible: false
                                            color: "transparent"
                                            implicitWidth: 160
                                            implicitHeight: 32 * contextModel.values.length



                                            anchor {
                                                item: icon
                                                edges: Edges.Top
                                                rect {
                                                    y: -height
                                                    x: -(width - (lView.spacing * 2 )) / 2 + (icon.width / 2) - lView.spacing
                                                }
                                            }

                                            Rectangle {
                                                id: containerItem
                                                width: menuWindow.width
                                                color: taskbar.taskbarColor
                                                height: menuWindow.height
                                                radius: 8

                                                border {
                                                    color: taskbar.taskbarMidColor
                                                    width: 2
                                                }

                                                Component {
                                                    id: menuItemDelegate
                                                    WrapperMouseArea {
                                                        hoverEnabled: true
                                                        required property var modelData
                                                        required property int index
                                                        implicitWidth: parent.width
                                                        implicitHeight: 32 - (containerItem.border.width * 2)
                                                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        anchors.verticalCenter: parent.verticalCenter

                                                        onClicked: function(mouse) {
                                                            if (mouse.button & Qt.LeftButton)

                                                                modelData[1]/*contextData*/.onTriggered(mouse, modelData)

                                                            else menuWindow.visible = false;
                                                        }

                                                        onContainsMouseChanged: function(mouseChangedStatus) {
                                                            listItemDetails.color = this.containsMouse ?  "#66FFFFFF" : "transparent"
                                                        }


                                                        Rectangle {
                                                            id: listItemDetails
                                                            color: "#00FFFFFF"
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
                                                                id: dotContainer
                                                                implicitWidth: 8
                                                                height: implicitWidth - containerItem.border.width
                                                                radius: 40
                                                                color: Object.keys(modelData[1]).includes("color") ? modelData[1].color : taskbar.taskbarComplimentColor
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

                                                ScriptModel {
                                                    id: contextModel
                                                    property var baseMenuContexts: ({
                                                            close_window: {
                                                                text: "Close",
                                                                onTriggered: function(mouse, [contextId, contextData])
                                                                {
                                                                    Hyprland.dispatch(`closewindow address:${modelData.lastIpcObject.address}`)
                                                                }
                                                            }
                                                    })
                                                    values: {
                                                        return Object.entries(baseMenuContexts)
                                                    }
                                                }

                                                ListView {
                                                    id: contextMenuListView
                                                    width: parent.width - (parent.border.width * 2) - 8
                                                    height: parent.height - (parent.border.width * 2) - 2
                                                    anchors { 
                                                        centerIn: parent
                                                    }
                                                    delegate: menuItemDelegate
                                                    model: contextModel.values
                                                }
                                            }
                                        }

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
                                            (modelData.lastIpcObject.class.includes(".") ? modelData.lastIpcObject.title : modelData.lastIpcObject.class.match(/^(\w|\s)+/)[0]).replace(/[^]/, (e) => e.toUpperCase())

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
                                            sourceSize.width: width
                                            sourceSize.height: height
                                            anchors {
                                                centerIn: parent
                                            }

                                            source: `./assets/question-solid.svg`

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
                            Hyprland.refreshToplevels()
                        }
                    })
                }
            }
        }
    }

    PanelWindow {
        id: bottomHalfDecoration
        mask: Region { }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors {
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            anchors {
                bottom: parent.bottom
            }

            color: taskbar.taskbarComplimentColor
            width: taskbarDecoration.width
            height: 4
            z: -100
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
    }

}
