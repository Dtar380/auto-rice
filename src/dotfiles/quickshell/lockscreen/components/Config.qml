pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Quickshell replacement for the SDDM Config.qml.
// Same property names, so every shared component works untouched.
// Instead of SDDM's `config` object, it parses colors.conf (symlinked into the shell dir).
Singleton {
    id: root

    // --- WRITABLE PROPERTIES ---
    property int currentUserIndex: 0
    property bool lockScreenDisplay: true

    // --- colors.conf loading ---
    FileView {
        id: file
        path: Quickshell.shellPath("colors.conf")
        blockLoading: true      // values are ready before the UI is built
        watchChanges: true      // edit colors.conf -> lockscreen updates live
        onFileChanged: reload()
    }

    function parse(text) {
        var out = {}
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i].trim()
            if (l === "" || l[0] === "#" || l[0] === ";" || l[0] === "[") continue
            var eq = l.indexOf("=")
            if (eq < 1) continue
            var k = l.slice(0, eq).trim()
            var v = l.slice(eq + 1).trim().replace(/^"(.*)"$/, "$1")   // strip the quotes
            out[k] = v
        }
        return out
    }

    readonly property var values: parse(file.text())

    // --- FONT ---
    readonly property string customFont: values.fontFamily || "JetBrainsMono NF"

    // --- BASE PALETTE ---
    readonly property color background: values.background || "#2e3440"
    readonly property color foreground: values.foreground || "#e5e9f0"
    readonly property color accent: values.accent || "#81a1c1"
    readonly property color selection: values.selection || "#88c0d0"
    readonly property color textColor: values.textColor || "#e5e9f0"
    readonly property color subtextColor: values.subtextColor || "#d8dee9"

    // --- ANSI REFERENCE MAPPING ---
    readonly property color black: values.black || "#2e3440"
    readonly property color red: values.red || "#bf616a"
    readonly property color green: values.green || "#a3be8c"
    readonly property color yellow: values.yellow || "#ebcb8b"
    readonly property color blue: values.blue || "#5e81ac"
    readonly property color magenta: values.magenta || "#b48ead"
    readonly property color cyan: values.cyan || "#88c0d0"
    readonly property color white: values.white || "#e5e9f0"
    readonly property color brightWhite: values.brightWhite || "#eceff4"
}
