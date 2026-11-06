pragma Singleton

import QtQuick

QtObject {
    // --- WRITABLE PROPERTIES ---
    property int currentUserIndex: 0
    property bool lockScreenDisplay: true

    // --- FONT ---
    readonly property string customFont: config.stringValue("fontFamily") || "JetBrainsMono NF"

    // --- BASE PALETTE ---
    readonly property color background: config.stringValue("background") || "#2e3440"
    readonly property color foreground: config.stringValue("foreground") || "#e5e9f0"
    readonly property color accent: config.stringValue("accent") || "#81a1c1"
    readonly property color selection: config.stringValue("selection") || "#88c0d0"
    readonly property color textColor: config.stringValue("textColor") || "#e5e9f0"
    readonly property color subtextColor: config.stringValue("subtextColor") || "#d8dee9"

    // --- ANSI REFERENCE MAPPING ---
    readonly property color black: config.stringValue("black") || "#2e3440"
    readonly property color red: config.stringValue("red") || "#bf616a"
    readonly property color green: config.stringValue("green") || "#a3be8c"
    readonly property color yellow: config.stringValue("yellow") || "#ebcb8b"
    readonly property color blue: config.stringValue("blue") || "#5e81ac"
    readonly property color magenta: config.stringValue("magenta") || "#b48ead"
    readonly property color cyan: config.stringValue("cyan") || "#88c0d0"
    readonly property color white: config.stringValue("white") || "#e5e9f0"
    readonly property color brightWhite: config.stringValue("brightWhite") || "#eceff4"
}
