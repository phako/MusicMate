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

internal class MusicMate.PlayPauseButton : ToggleButton {
    public Image play_image;
    public Image pause_image;

    public PlayPauseButton () {
        Object ();

        play_image = new Image.from_stock (Stock.MEDIA_PLAY, IconSize.BUTTON);
        pause_image = new Image.from_stock (Stock.MEDIA_PAUSE,
                                            IconSize.BUTTON);
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
    private uint position_update_timeout;

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

    public bool shuffle { get; set; }

    public void set_duration (uint duration) {
        this.scale.set_range (0.0, (double) (duration * Gst.SECOND));
        this.scale.set_value (0.0);
    }

    public AudioControls () {
        Object ( orientation: Orientation.HORIZONTAL, spacing: 3);

        this.set_homogeneous (false);
        this.keys = new MusicMate.MediaKeys ();
        this.position_update_timeout = 0;

        this.playbin = Gst.ElementFactory.make ("playbin2", null);
        var bus = this.playbin.get_bus ();
        bus.add_watch ( (bus, message) => {
            switch (message.type) {
            case Gst.MessageType.EOS:
                this.uri = this.need_next ();
                break;
            case Gst.MessageType.STATE_CHANGED:
                if (message.src == this.playbin) {
                    Gst.State old_state, new_state;
                    message.parse_state_changed (out old_state,
                                                 out new_state,
                                                 null);
                    if (old_state == Gst.State.PAUSED &&
                        new_state == Gst.State.PLAYING) {
                            this.update_position (true);
                    } else if (old_state == Gst.State.PLAYING &&
                               new_state == Gst.State.PAUSED) {
                        this.update_position (false);
                    }
                }
                break;
            default:
                break;
            }

            return true;
        });

        var shuffle = new CheckButton.with_mnemonic ("_Shuffle");
        this.pack_end (shuffle, false, false);
        shuffle.show ();
        shuffle.toggled.connect ( () => {
            this.shuffle = shuffle.get_active ();
        });

        var adjustment = null as Adjustment;
        this.scale = new Scale (Orientation.HORIZONTAL, adjustment);
        this.scale.draw_value = false;
        this.scale.show ();
        this.pack_end (this.scale);

        this.set_homogeneous (false);

        var back_button = new Button ();
        var image = new Image.from_stock (Stock.MEDIA_PREVIOUS,
                                          IconSize.BUTTON);
        back_button.set_image (image);
        back_button.show ();
        this.pack_start (back_button, false, false);
        back_button.clicked.connect ( () => {
            this.uri = need_previous ();
        });

        play_button = new PlayPauseButton ();
        play_button.show ();
        this.pack_start (play_button, false, false);
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
        this.pack_start (next_button, false, false);
        next_button.clicked.connect ( () => {
            this.uri = need_next ();
        });

        this.keys.play.connect ( () => { play_button.set_active (true); } );
        this.keys.pause.connect ( () => { play_button.set_active (false); } );
        this.keys.stop.connect ( () => {
            play_button.set_active (false);
            this.playbin.set_state (Gst.State.READY);
        });
        this.keys.next.connect ( () => { next_button.clicked (); } );
        this.keys.previous.connect ( () => { back_button.clicked (); } );
    }

    private void update_position (bool update) {
        if (update) {
            if (this.position_update_timeout == 0) {
                Timeout.add_seconds (1, this.update_position_cb);
            }
        } else {
            if (this.position_update_timeout != 0) {
                Source.remove (this.position_update_timeout);
                this.position_update_timeout = 0;
            }
        }
    }

    private bool update_position_cb () {
        var format = Gst.Format.TIME;
        int64 duration = 0;

        this.playbin.query_position (ref format, out duration);
        this.scale.set_value ((double) duration);

        return true;
    }
}
