const initialClasses = [ /.*/g ];
const contexts = {
    close_window: {
        text: "Close",
        onTriggered: function({Hyprland, modelData}) {
            Hyprland.refreshToplevels();
            if (!modelData[1].ipcObject)

                return;

            Hyprland.dispatch(`closewindow address:${modelData[1].ipcObject.address}`)

        }
    },
};

export { 
    initialClasses,
    contexts
}
