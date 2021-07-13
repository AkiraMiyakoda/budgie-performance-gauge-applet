// Copyright (c) 2021 Akira Miyakoda
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

namespace PerformanceGaugeApplet
{

internal class AppletSettings : Gtk.Box
{
    const int MARGIN = 12;
    const int HORIZONTAL_SPACING = 12;
    const int VERTICAL_SPACING   = 12;

    private Settings settings = null;

    private Gtk.ComboBoxText combobox_monitor;
    private Gtk.SpinButton   spinbutton_interval;
    private Gtk.ComboBoxText combobox_mount_point;
    private Gtk.Entry        entry_mount_point;
    private Gtk.ComboBoxText combobox_usage_unit;

    public AppletSettings(Settings settings)
    {
        this.settings = settings;

        this.orientation = Gtk.Orientation.VERTICAL;
        this.spacing     = VERTICAL_SPACING;
        this.margin      = MARGIN;

        {
            var label = new Gtk.Label(_ ("Monitor Type"));
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.CENTER;
            label.can_focus = false;

            this.combobox_monitor = new Gtk.ComboBoxText.with_entry();
            this.combobox_monitor.halign = Gtk.Align.END;
            this.combobox_monitor.valign = Gtk.Align.CENTER;
            this.combobox_monitor.can_focus = false;

            this.combobox_monitor.append_text(_ ("CPU"    ));
            this.combobox_monitor.append_text(_ ("Memory" ));
            this.combobox_monitor.append_text(_ ("Storage"));
            this.combobox_monitor.active = 0;

            var entry = (Gtk.Entry)this.combobox_monitor.get_child();
            entry.width_chars = 8;
            entry.can_focus = false;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, HORIZONTAL_SPACING);
            box.pack_start(label);
            box.pack_start(this.combobox_monitor);

            this.pack_start(box);
        }

        {
            var label = new Gtk.Label(_ ("Update Interval (ms)"));
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.CENTER;
            label.can_focus = false;

            var adjustment = new Gtk.Adjustment(1000, 100, 5000, 100, 500, 500);

            this.spinbutton_interval = new Gtk.SpinButton(adjustment, 100, 0);
            this.spinbutton_interval.halign = Gtk.Align.END;
            this.spinbutton_interval.valign = Gtk.Align.CENTER;
            this.spinbutton_interval.can_focus = true;
            this.spinbutton_interval.numeric = true;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, HORIZONTAL_SPACING);
            box.pack_start(label);
            box.pack_start(this.spinbutton_interval);

            this.pack_start(box);
        }

        {
            var label = new Gtk.Label(_ ("Mount Point"));
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.CENTER;
            label.can_focus = false;

            this.combobox_mount_point = new Gtk.ComboBoxText.with_entry();
            this.combobox_mount_point.halign = Gtk.Align.END;
            this.combobox_mount_point.valign = Gtk.Align.CENTER;
            this.combobox_mount_point.can_focus = false;
            this.combobox_mount_point.sensitive = false;

            this.entry_mount_point = (Gtk.Entry)this.combobox_mount_point.get_child();
            this.entry_mount_point.can_focus = false;
            this.update_mount_points();

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, HORIZONTAL_SPACING);
            box.pack_start(label);
            box.pack_start(this.combobox_mount_point);

            this.pack_start(box);
        }

        {
            var label = new Gtk.Label(_ ("Usage Unit"));
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.CENTER;
            label.can_focus = false;

            this.combobox_usage_unit = new Gtk.ComboBoxText.with_entry();
            this.combobox_usage_unit.halign = Gtk.Align.END;
            this.combobox_usage_unit.valign = Gtk.Align.CENTER;
            this.combobox_usage_unit.can_focus = false;
            this.combobox_usage_unit.sensitive = false;

            this.combobox_usage_unit.append_text(_ ("KiB"));
            this.combobox_usage_unit.append_text(_ ("MiB"));
            this.combobox_usage_unit.append_text(_ ("GiB"));
            this.combobox_usage_unit.active = 2;

            var entry = (Gtk.Entry)this.combobox_usage_unit.get_child();
            entry.width_chars = 4;
            entry.can_focus = false;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, HORIZONTAL_SPACING);
            box.pack_start(label);
            box.pack_start(this.combobox_usage_unit);

            this.pack_start(box);
        }

        this.settings.bind("monitor-type",    this.combobox_monitor,    "active", SettingsBindFlags.DEFAULT);
        this.settings.bind("update-interval", this.spinbutton_interval, "value",  SettingsBindFlags.DEFAULT);
        this.settings.bind("mount-point",     this.entry_mount_point,   "text",   SettingsBindFlags.DEFAULT);
        this.settings.bind("usage-unit",     this.combobox_usage_unit, "active", SettingsBindFlags.DEFAULT);

        this.settings.changed.connect(this.on_settings_change);
        this.on_settings_change("monitor-type");
    }

    public void update_mount_points()
    {
        this.combobox_mount_point.remove_all();

        Array<string> mount_points;
        if (!Monitor.get_mount_points(out mount_points)) {
            return;
        }

        this.combobox_mount_point.active = 0;

        var current_mount_point = this.settings.get_string("mount-point");
        int max_length = 0;
        for (int i = 0; i < mount_points.length; ++i) {
            this.combobox_mount_point.append_text(mount_points.index(i));
            max_length = int.max(max_length, mount_points.index(i).length);

            if (mount_points.index(i) == current_mount_point) {
                this.combobox_mount_point.active = i;
            }
        }

        this.entry_mount_point.width_chars = max_length + 1;
    }

    private void on_settings_change(string key)
    {
        if (key == "monitor-type") {
            var type = this.settings.get_int(key);
            this.combobox_mount_point.sensitive = (type == MONITOR_TYPE_STORAGE);
            this.combobox_usage_unit.sensitive  = (type == MONITOR_TYPE_MEMORY || type == MONITOR_TYPE_STORAGE);
        }
    }
}

}
