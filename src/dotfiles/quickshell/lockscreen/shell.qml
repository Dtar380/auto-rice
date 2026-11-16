import QtQuick
import Quickshell
import Quickshell.Wayland

// Run with:  qs -c rice-lock
ShellRoot {
    LockContext {
        id: ctx
        onUnlocked: {
            lock.locked = false
            quitTimer.start()
        }
    }

    // Give the compositor a moment to receive the unlock request before exiting
    Timer {
        id: quitTimer
        interval: 200
        onTriggered: Qt.quit()
    }

    WlSessionLock {
        id: lock
        locked: true

        // Instantiated once per monitor
        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: ctx
            }
        }
    }
}
