using Gtk;

extern void gtk_button_box_set_child_non_homogeneous (ButtonBox container,
                                                      Widget    child,
                                                      bool      homogenous);

internal class PlayPauseButton : ToggleButton {
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

internal class AudioControls : Box {
    private Scale scale;
    private dynamic Gst.Element playbin;
    private ToggleButton play_button;
    private Playmate.MediaKeys keys;

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
        }

        get {
            return playbin.uri;
        }
    }

    public AudioControls () {
        Object ( orientation: Orientation.VERTICAL, spacing: 3);
        this.set_homogeneous (false);

        this.keys = new Playmate.MediaKeys ();

        this.playbin = Gst.ElementFactory.make ("playbin2", null);
        this.playbin.about_to_finish.connect ( () => {
            this.playbin.uri = need_next ();
        });

        var adjustment = null as Adjustment;
        this.scale = new Scale (Orientation.HORIZONTAL, adjustment);
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
        this.keys.next.connect ( () => { next_button.clicked (); } );
        this.keys.previous.connect ( () => { back_button.clicked (); } );
    }
}
