[DBus (name = "org.gnome.SettingsDaemon.MediaKeys")]
internal interface GnomeMediaKeys : Object {
    public abstract void grab_media_player_keys (string application,
                                                 uint   time) throws Error;
    public abstract void release_media_player_keys (string application)
                                                    throws Error;

    public signal void media_player_key_pressed (string application,
                                                 string key);
}

internal class Playmate.MediaKeys : Object {
    private GnomeMediaKeys keys;

    public signal void play ();
    public signal void pause ();
    public signal void stop ();
    public signal void next ();
    public signal void previous ();

    public MediaKeys () {
        try {
            this.keys = Bus.get_proxy_sync (BusType.SESSION,
                                            "org.gnome.SettingsDaemon",
                                            "/org/gnome/SettingsDaemon/MediaKeys");
            this.keys.grab_media_player_keys (Application.APPNAME, 0);
            this.keys.media_player_key_pressed.connect (this.on_key_pressed);
        } catch (Error error) {
            message ("Failed to connect to media keys: %s", error.message);
        }
    }

    ~MediaKeys () {
        if (this.keys != null) {
            try {
                this.keys.release_media_player_keys (Application.APPNAME);
            } catch (Error error) { };
        }
    }

    private void on_key_pressed (string application, string key) {
        if (application != Application.APPNAME) {
            return;
        }

        switch (key) {
            case "Play":
                this.play ();
                break;
            case "Pause":
                this.pause ();
                break;
            case "Stop":
                this.stop ();
                break;
            case "Next":
                this.next ();
                break;
            case "Previous":
                this.previous ();
                break;
            default:
                break;
        }
    }
}
