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

extern void gtk_button_box_set_child_non_homogeneous (ButtonBox container,
                                                      Widget    child,
                                                      bool      homogenous);

internal class MusicMate.PlayPauseButton : ToggleButton {
    public Image play_image;
    public Image pause_image;

    public PlayPauseButton () {
        Object ();

        play_image = new Image.from_stock (Stock.MEDIA_PLAY, IconSize.DIALOG);
        pause_image = new Image.from_stock (Stock.MEDIA_PAUSE,
                                            IconSize.DIALOG);
        this.set_image (play_image);
    }

    public override void toggled () {
        if (this.get_active ()) {
            this.set_image (pause_image);
        } else {
            this.set_image (play_image);
        }
    }
}

internal class MusicMate.AudioControls : Box {
    private Scale scale;
    private dynamic Gst.Element playbin;
    private ToggleButton play_button;
    private MusicMate.MediaKeys keys;
    private Label meta_data;

    public signal string? need_next ();
    public signal string? need_previous ();

    public string uri {
        set {
            var resume = false;

            if (playbin.current_state == Gst.State.PLAYING |
                playbin.current_state == Gst.State.PAUSED) {
                playbin.set_state (Gst.State.READY);
                resume = true;
            }
            playbin.uri = value;
            this.play_button.set_active (true);
            if (resume) {
                this.playbin.set_state (Gst.State.PLAYING);
            }
        }

        get {
            return playbin.uri;
        }
    }

    public void set_meta_data (uint duration,
                               string? artist,
                               string? album,
                               string? title) {
        string text;
        //this.scale.set_range (0.0, (double) (duration * Gst.SECOND));
        if (title != null) {
            text = "<i>%s</i>".printf (Markup.escape_text (title));
        } else {
            text = "<i>Unkown song</i>";
        }

        if (artist != null) {
            text += " by <i>%s</i>".printf (Markup.escape_text (artist));
        }

        if (album != null) {
            text += " from <i>%s</i>".printf (Markup.escape_text (album));
        }

        this.meta_data.set_markup (text);
    }

    public AudioControls () {
        Object ( orientation: Orientation.VERTICAL, spacing: 3);
        this.set_homogeneous (false);

        this.keys = new MusicMate.MediaKeys ();

        this.playbin = Gst.ElementFactory.make ("playbin2", null);
        this.playbin.about_to_finish.connect ( () => {
            // This event doesn't come from main-tread, and need_next triggers
            // UI updates, so let's lock the GDK Threads
            Gdk.threads_enter ();
            this.playbin.uri = need_next ();
            Gdk.threads_leave ();
        });

        this.meta_data = new Label (null);
        this.meta_data.show ();
        this.pack_end (this.meta_data);

        var adjustment = null as Adjustment;
        this.scale = new Scale (Orientation.HORIZONTAL, adjustment);
        this.scale.draw_value = false;
        this.scale.show ();
        this.pack_end (this.scale);

        var controls = new ButtonBox (Orientation.HORIZONTAL);
        this.set_homogeneous (false);
        controls.set_layout (ButtonBoxStyle.CENTER);
        controls.show ();

        var back_button = new Button ();
        var image = new Image.from_stock (Stock.MEDIA_PREVIOUS,
                                          IconSize.BUTTON);
        back_button.set_image (image);
        back_button.show ();
        controls.pack_start (back_button);
        gtk_button_box_set_child_non_homogeneous (controls, back_button, true);
        back_button.clicked.connect ( () => {
            this.uri = need_previous ();
        });

        play_button = new PlayPauseButton ();
        play_button.show ();
        controls.pack_start (play_button);
        play_button.toggled.connect ( (source) => {
            if (source.get_active ()) {
                if (this.playbin.uri == null) {
                    this.uri = this.need_next ();
                }
                playbin.set_state (Gst.State.PLAYING);
            } else {
                playbin.set_state (Gst.State.PAUSED);
            }
        });

        var next_button = new Button ();
        image = new Image.from_stock (Stock.MEDIA_NEXT,
                                      IconSize.BUTTON);
        next_button.set_image (image);
        next_button.show ();
        controls.pack_start (next_button);
        gtk_button_box_set_child_non_homogeneous (controls, next_button, true);
        next_button.clicked.connect ( () => {
            this.uri = need_next ();
        });

        this.pack_start (controls);

        this.keys.play.connect ( () => { play_button.set_active (true); } );
        this.keys.pause.connect ( () => { play_button.set_active (false); } );
        this.keys.stop.connect ( () => {
            play_button.set_active (false);
            this.playbin.set_state (Gst.State.READY);
        });
        this.keys.next.connect ( () => { next_button.clicked (); } );
        this.keys.previous.connect ( () => { back_button.clicked (); } );

/*        Timeout.add_seconds (1, () => {
            var format = Gst.Format.TIME;
            int64 duration = 0;

            this.playbin.query_position (ref format, out duration);
            this.scale.set_value ((double) duration);

            return true; 
        }); */
    }
}
