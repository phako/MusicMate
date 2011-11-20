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

internal class MusicMate.SongBrowser : TreeView {
    public SongBrowser () {
        Object (model : new FilteredSongList ());
        this.insert_column_with_attributes (-1,
                                                 "Disc",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.DISC);

        this.insert_column_with_attributes (-1,
                                                 "Track",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.TRACK);

        this.insert_column_with_attributes (-1,
                                                 "Title",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.TITLE);

        this.insert_column_with_attributes (-1,
                                                 "Album",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.ALBUM);
    }
}
