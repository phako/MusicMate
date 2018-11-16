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

public class MusicMate.Notifier : GLib.Object {
    private uint timeout_id;

    public void update (string? title, string? artist, string? album) {
        var notification = new GLib.Notification (title);

        var text = "";
        if (title != null) {
            text = "%s".printf (Markup.escape_text
                                (title ?? "Unknown Title"));
        }

        if (artist != null) {
            text += " by %s".printf (Markup.escape_text (artist));
        }

        if (album != null) {
            text += " from %s".printf (Markup.escape_text (album));
        }

        notification.set_body (text);

        var file = AlbumArtCache.lookup_file (artist, album);
        if (file != null) {
            var icon = new FileIcon (file);
            notification.set_icon (icon);
        }

        if (this.timeout_id != 0) {
            Source.remove (this.timeout_id);
            timeout_id = 0;
        }

        var app = GLib.Application.get_default ();
        app.send_notification ("musicmate-title-popup", notification);

        this.timeout_id = Timeout.add_seconds (10, () => {
            var app2 = GLib.Application.get_default ();
            app2.withdraw_notification ("musicmake-title-popup");

            this.timeout_id = 0;

            return false;
        });
    }

}
