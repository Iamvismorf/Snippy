pragma Singleton
import Quickshell

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
}
