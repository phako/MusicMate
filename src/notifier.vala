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

using Notify;

public class MusicMate.Notifier : GLib.Object {
    private Notify.Notification notification;
    private uint timeout_id;

    public void update (string? title, string? artist, string? album) {
        var text = "";
        if (title != null) {
            text = "<i>%s</i>".printf (Markup.escape_text
                                        (title ?? "Unknown Title"));
        }

        if (artist != null) {
            text += " by <i>%s</i>".printf (Markup.escape_text (artist));
        }

        if (album != null) {
            text += " from <i>%s</i>".printf (Markup.escape_text (album));
        }

        try {
            if (this.timeout_id != 0) {
                Source.remove (this.timeout_id);
            }
            if (this.notification == null) {
                this.notification = new Notify.Notification (" ", text, null);
                this.notification.set_urgency (Urgency.LOW);
            } else {
                string? empty = null;
                this.notification.update (" ", text, empty);
            }

            var cache = AlbumArtCache.get_default ();
            this.notification.set_image_from_pixbuf (cache.lookup (artist,
                                                                   album));
            this.notification.show ();
            this.timeout_id = Timeout.add_seconds (10, () => {
                this.timeout_id = 0;
                try {
                    this.notification.close ();
                } catch (Error error) {}

                return false;
            });
        } catch (Error error) {
            warning ("Failed to show notification: %s", error.message);
        }
    }

}
