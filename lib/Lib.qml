pragma Singleton
import Quickshell
import qs.singletons

Singleton {
    function clamp(val, min, max) {
        return Math.min(Math.max(val, min), max);
    }

    function isEmpty(obj) {
        for (const i in obj) {
            return false;
        }
        return true;
    }

    function getSaveFolder() {
        return Quickshell.env("HOME") + "/" + Config.saveFolder;
    }

    // https://stackoverflow.com/a/3943023/32940244
    // function used to choose which "opposite" color to use
    // caller should provide a light color if the function returns true
    function isDark(col) {
        return (col.r * 0.299 + col.g * 0.587 + col.b * 0.114) <= 0.58; // 149
    }
}
