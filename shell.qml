//@ pragma IconTheme Papirus-Dark
//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import Snippy as Snippy

ShellRoot {
    Variants {
        model: Quickshell.screens
        Overlay {}
    }
}
