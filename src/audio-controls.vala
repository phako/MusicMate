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

    public string uri {
        set {
            var resume = false;

            if (playbin.current_state == Gst.State.PLAYING |
                playbin.current_state == Gst.State.PAUSED) {
                playbin.set_state (Gst.State.READY);
                resume = true;
            }
            playbin.uri = value;
            if (resume) {
                playbin.set_state (Gst.State.PLAYING);
            }
        }

        get {
            return playbin.uri;
        }
    }

    public AudioControls () {
        Object ( orientation: Orientation.VERTICAL, spacing: 3);
        this.set_homogeneous (false);

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

        var play_button = new PlayPauseButton ();
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

        this.pack_start (controls);

        this.playbin = Gst.ElementFactory.make ("playbin2", null);
    }
}
