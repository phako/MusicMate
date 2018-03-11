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
using Tracker;
using Gdk;

internal enum MusicMate.AlbumListStoreColumn {
    ALBUM_ART,
    TITLE,
    ID
}

internal class MusicMate.AlbumListStore : Gtk.ListStore {
    private const string ALBUM_QUERY =
"""

SELECT
    nie:title(?album)
    tracker:coalesce(
        (SELECT GROUP_CONCAT(nmm:artistName(?artist), ",")
         WHERE { ?album nmm:albumArtist ?artist }),
        (SELECT GROUP_CONCAT((SELECT nmm:artistName(nmm:performer(?_12)) as ?perf
                              WHERE { ?_12 nmm:musicAlbum ?album }
                              GROUP BY ?perf), ",") as ?album_performer
         WHERE { })
    ) as ?album_artist

    tracker:coalesce(nmm:albumTrackCount(?album),
                     (SELECT COUNT(?_1)
                      WHERE { ?_1 nmm:musicAlbum ?album;
                                  tracker:available "true" }))
    tracker:id(?album)
    (SELECT GROUP_CONCAT(fn:year-from-dateTime(?c), ",")
     WHERE { ?_2 nmm:musicAlbum ?album;
                 nie:contentCreated ?c;
                 tracker:available "true" }) as ?albumyear
{
    ?album a nmm:MusicAlbum
    FILTER (EXISTS {
                { ?_3 nmm:musicAlbum ?album; tracker:available "true" }
                FILTER(fn:starts-with(nie:url(?_3), '%s'))
            })
}
ORDER BY ?album_artist ?albumyear nie:title(?album)
""";

    public AlbumListStore () {
        Object ();

        Type[] types = { typeof (Pixbuf),
                         typeof (string),
                         typeof (uint64) };

        this.set_column_types (types);
        this.fill_list_store.begin ();
    }

    private async void fill_list_store () {
        try {
            var connection = yield Sparql.Connection.get_async ();
            unowned string music_path = Environment.get_user_special_dir
                                        (UserDirectory.MUSIC);
            var uri = File.new_for_path (music_path).get_uri ();
            var query = ALBUM_QUERY.printf (uri);
            var cursor = yield connection.query_async (query);
            debug ("Running SPARQL query %s", query);
            var cache = AlbumArtCache.get_default ();
            while (cursor.next ()) {
                TreeIter iter;
                this.append (out iter);
                this.set (iter,
                          AlbumListStoreColumn.ALBUM_ART,
                              cache.lookup (cursor.get_string (1),
                                            cursor.get_string (0)),
                          AlbumListStoreColumn.TITLE,
                              "%s (%d)".printf (cursor.get_string (0),
                                                (int) cursor.get_integer (2)),
                          AlbumListStoreColumn.ID,
                              cursor.get_integer (3),
                          -1);
            }
        } catch (Error error) {
            critical ("Something bad happened: %s", error.message);
        }
    }
}
