import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// Everything non-visual: PAM authentication + the current user's info.
// Replaces SDDM's `sddm` object and `userModel`.
Scope {
    id: root

    signal unlocked()
    signal failed()

    // --- User info (what userModel used to provide) ---
    readonly property string userName: Quickshell.env("USER") || ""
    property string realName: ""
    readonly property url userIcon: "file://" + Quickshell.env("HOME") + "/.face"

    // GECOS field from passwd = the real name (first comma-separated entry)
    Process {
        running: true
        command: ["sh", "-c", "getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1"]
        stdout: StdioCollector {
            onStreamFinished: root.realName = this.text.trim()
        }
    }

    // --- Authentication ---
    property bool busy: false
    property string password: ""

    function tryUnlock(pw) {
        if (busy || pw === "") return
        password = pw
        busy = true
        pam.start()
    }

    PamContext {
        id: pam
        configDirectory: "pam"      // relative to the shell dir
        config: "password.conf"

        onPamMessage: {
            if (pam.responseRequired) pam.respond(root.password)
        }

        onCompleted: result => {
            root.password = ""
            root.busy = false
            if (result === PamResult.Success) root.unlocked()
            else root.failed()
        }
    }
}
