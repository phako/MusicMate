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

using Gtk;

internal class MusicMate.Application : Gtk.Application {
    public const string APPNAME = "org.jensge.MusicMate";

    public Application () {
        Object (application_id : APPNAME,
                flags: ApplicationFlags.FLAGS_NONE);
    }

    public override void activate () {
        unowned List<weak Window> windows = this.get_windows ();
        if (windows != null) {
            windows.data.present ();

            return;
        }

        var win = new MainWindow ();
        this.add_window (win);
    }
}
