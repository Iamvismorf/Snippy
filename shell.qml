//@ pragma IconTheme Papirus-Dark
//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Process {
        running: true
        command: ["sh", "-c", `mkdir -p ${Config.saveFolder}`]
    }

    Variants {
        model: Quickshell.screens
        Overlay {}
    }
}
