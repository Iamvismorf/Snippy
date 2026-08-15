//@ pragma IconTheme Papirus-Dark
//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import qs.snippy

import qs.lib

ShellRoot {
    Process {
        running: true
        command: ["sh", "-c", `mkdir -p ${Lib.getSaveFolder()}`]
    }

    Variants {
        model: Quickshell.screens
        Overlay {}
    }
}
