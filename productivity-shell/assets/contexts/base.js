export const Context = {
    initialClasses: [ /.*/g ],
    contexts: [
        {
            text: "Close",
            onTriggered: function({
                Hyprland
            }) {
                Hyprland.refreshToplevels();
                if (!Hyprland.activeToplevel?.lastIpcObject)

                    return;

                Hyprland.dispatch(`closewindow address:${Hyprland.activeToplevel.lastIpcObject?.address}`)

            }
        },
    ]
}
