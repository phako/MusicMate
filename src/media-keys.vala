/*
    This file is part of MusicMate.

    MusicMate is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MusicMate is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MusicMate.  If not, see <http://www.gnu.org/licenses/>.
*/

[DBus (name = "org.gnome.SettingsDaemon.MediaKeys")]
internal interface Gnome.MediaKeys : Object {
    public abstract void grab_media_player_keys (string application,
                                                 uint   time) throws Error;
    public abstract void release_media_player_keys (string application)
                                                    throws Error;

    public signal void media_player_key_pressed (string application,
                                                 string key);
}

internal class MusicMate.MediaKeys : Object {
    private Gnome.MediaKeys keys;

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
