namespace PerformanceGaugeApplet
{

internal class AppletSettings : Gtk.Box
{
    const int MARGIN = 12;
    const int HORIZONTAL_SPACING = 12;
    const int VERTICAL_SPACING   = 12;

    private GLib.Settings? settings = null;

    private Gtk.ComboBoxText? combobox_monitor;
    private Gtk.SpinButton?   spinbutton_interval;
    private Gtk.ComboBoxText? combobox_memory_unit;

    public AppletSettings(Settings? settings)
    {
        this.settings = settings;

        this.orientation = Gtk.Orientation.VERTICAL;
        this.spacing     = VERTICAL_SPACING;
        this.margin      = MARGIN;

        {
            var label = new Gtk.Label(_ ("Monitor Type"));
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.CENTER;

            this.combobox_monitor = new Gtk.ComboBoxText.with_entry();
            this.combobox_monitor.halign = Gtk.Align.END;
            this.combobox_monitor.valign = Gtk.Align.CENTER;

            this.combobox_monitor.append_text(_ ("CPU Usage"   ));
            this.combobox_monitor.append_text(_ ("Memory Usage"));

            var sensor_entry = (Gtk.Entry)this.combobox_monitor.get_child();
            sensor_entry.width_chars = 13;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, HORIZONTAL_SPACING);
            box.pack_start(label);
            box.pack_start(this.combobox_monitor);

            this.pack_start(box);
        }

        {
            var label = new Gtk.Label(_ ("Update Interval (ms)"));
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.CENTER;

            var adjustment = new Gtk.Adjustment(1000, 100, 5000, 100, 500, 500);

            this.spinbutton_interval = new Gtk.SpinButton(adjustment, 100, 0);
            this.spinbutton_interval.halign = Gtk.Align.END;
            this.spinbutton_interval.valign = Gtk.Align.CENTER;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, HORIZONTAL_SPACING);
            box.pack_start(label);
            box.pack_start(this.spinbutton_interval);

            this.pack_start(box);
        }

        {
            var label = new Gtk.Label(_ ("Memory Unit"));
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.CENTER;

            this.combobox_memory_unit = new Gtk.ComboBoxText.with_entry();
            this.combobox_memory_unit.halign = Gtk.Align.END;
            this.combobox_memory_unit.valign = Gtk.Align.CENTER;

            this.combobox_memory_unit.append_text(_ ("KiB"));
            this.combobox_memory_unit.append_text(_ ("MiB"));
            this.combobox_memory_unit.append_text(_ ("GiB"));

            var sensor_entry = (Gtk.Entry)this.combobox_memory_unit.get_child();
            sensor_entry.width_chars = 4;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, HORIZONTAL_SPACING);
            box.pack_start(label);
            box.pack_start(this.combobox_memory_unit);

            this.pack_start(box);
        }

        this.settings.bind("monitor-type",    this.combobox_monitor,     "active", SettingsBindFlags.DEFAULT);
        this.settings.bind("update-interval", this.spinbutton_interval,  "value",  SettingsBindFlags.DEFAULT);
        this.settings.bind("memory-unit",     this.combobox_memory_unit, "active", SettingsBindFlags.DEFAULT);

        this.settings.changed.connect((key) => {
            if (key == "monitor-type") {
                this.combobox_memory_unit.sensitive = ( this.settings.get_int(key) == MONITOR_TYPE_MEMORY);
            }
        });
    }
}

}
