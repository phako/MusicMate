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

using Gee;
using Gdk;

[CCode (cname="ICON_DIR")]
extern const string ICON_DIR;

namespace MusicMate.AlbumArtCache {
    internal File? lookup_file (string? artist, string? album) {
        File? file = null;

        if (MediaArt.get_file (artist, album, "album", out file)) {
            return file;
        }

        return null;
    }

    internal Pixbuf? lookup (string? artist, string? album) {
        string? file = null;

        if (MediaArt.get_path (artist, album, "album", out file)) {
            try {
                return new Pixbuf.from_file_at_scale (file,
                                                      96,
                                                      96,
                                                      true);
            } catch (Error error) {
                debug ("Failed to create cover pixbuf: %s",
                        error.message);
            }
        }

        return null;
    }
}
