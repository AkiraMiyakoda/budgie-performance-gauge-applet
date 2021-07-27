// Copyright (c) 2021 Akira Miyakoda
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

namespace PerformanceGaugeApplet
{

internal const int MONITOR_TYPE_CPU     = 0;
internal const int MONITOR_TYPE_MEMORY  = 1;
internal const int MONITOR_TYPE_STORAGE = 2;

internal const int USAGE_UNIT_KIB = 0;
internal const int USAGE_UNIT_MIB = 1;
internal const int USAGE_UNIT_GIB = 2;

public class Plugin : Budgie.Plugin, Peas.ExtensionBase
{
    public Budgie.Applet get_panel_widget(string uuid)
    {
        return new PerformanceGaugeApplet.Applet(uuid);
    }
}

public class Applet : Budgie.Applet
{
    public string uuid { public set; public get; }

    private Gtk.EventBox applet_container;
    private GaugeWidget  gauge_widget;

    private uint timer_id = 0;

    private Settings settings;

    private AppletSettings settings_ui;
    private Budgie.Popover popover;
    private unowned Budgie.PopoverManager manager;

    public Applet(string uuid)
    {
        Object(uuid: uuid);

        // Setup settings
        this.settings_schema = "com.github.akiramiyakoda.budgie-performance-gauge-applet";
        this.settings_prefix = "/com/github/akiramiyakoda/budgie-performance-gauge-applet";

        this.settings = this.get_applet_settings(uuid);
        this.settings.changed.connect((key) => {
            update_all();
        });

        // Setup the applet
        this.gauge_widget = new GaugeWidget();

        this.applet_container = new Gtk.EventBox();
        this.applet_container.add(this.gauge_widget);

        this.add(this.applet_container);

        this.settings_ui = new AppletSettings(this.settings);

        this.popover = new Budgie.Popover(this.applet_container);
        this.popover.add(this.settings_ui);

        this.applet_container.button_press_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }

            if (this.popover.get_visible()) {
                this.popover.hide();
            } else {
                this.settings_ui.update_mount_points();
                this.manager.show_popover(this.applet_container);
            }

            return Gdk.EVENT_STOP;
        });

        this.update_all();
        this.show_all();
    }

    private void update_all()
    {
        if (timer_id != 0) {
            Source.remove(timer_id);
        }

        var interval = this.settings.get_int("update-interval");
        timer_id = Timeout.add_full(Priority.LOW, interval, update_gauge);

        update_gauge();
    }

    private bool update_gauge()
    {
        var monitor_type = this.settings.get_int("monitor-type");

        switch (monitor_type) {
        case MONITOR_TYPE_CPU:
            update_cpu_gauge();
            break;
        case MONITOR_TYPE_MEMORY:
            update_memory_gauge();
            break;
        case MONITOR_TYPE_STORAGE:
            update_storage_gauge();
            break;
        default:
            this.gauge_widget.set_percent(0.0);
            this.gauge_widget.set_tooltip_text(null);
            break;
        }

        return true;
    }

    private void update_cpu_gauge()
    {
        double usage;
        if (!Monitor.get_cpu_usage(out usage)) {
            this.gauge_widget.set_percent(0.0);
            this.gauge_widget.set_tooltip_text(null);
            return;
        }

        this.gauge_widget.set_percent(usage);
        this.gauge_widget.set_tooltip_text("%.1f %%".printf(usage));
    }

    private void update_memory_gauge()
    {
        uint64 total;
        uint64 used;
        if (!Monitor.get_memory_usage(out total, out used)) {
            this.gauge_widget.set_percent(0.0);
            this.gauge_widget.set_tooltip_text(null);
            return;
        }

        this.gauge_widget.set_percent(used * 100.0 / total);
        this.gauge_widget.set_tooltip_text(format_usage(used, total));
    }

    private void update_storage_gauge()
    {
        var mount_point = this.settings.get_string("mount-point");
        uint64 total;
        uint64 used;
        if (!Monitor.get_storage_usage(mount_point, out total, out used)) {
            this.gauge_widget.set_percent(0.0);
            this.gauge_widget.set_tooltip_text(null);
            return;
        }

        this.gauge_widget.set_percent(used * 100.0 / total);
        this.gauge_widget.set_tooltip_text(mount_point + "\n" + format_usage(used, total));
    }

    private string format_usage(uint64 used, uint64 total)
    {
        var usage_unit = this.settings.get_int("usage-unit");

        switch (usage_unit) {
        case USAGE_UNIT_KIB:
            return "%'llu / %'llu KiB (%.1f%%)".printf(used, total, used * 100.0 / total);
        case USAGE_UNIT_MIB:
            return "%'.1f / %'.1f MiB (%.1f%%)".printf(used / 1024.0, total / 1024.0, used * 100.0 / total);
        default:
            return "%'.1f / %'.1f GiB (%.1f%%)".printf(used / 1048576.0, total / 1048576.0, used * 100.0 / total);
        }
    }

    public override void update_popovers(Budgie.PopoverManager? manager)
    {
        this.manager = manager;
        this.manager.register_popover(this.applet_container, this.popover);
    }
}

}

[ModuleInit]
public void peas_register_types(TypeModule module)
{
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(PerformanceGaugeApplet.Plugin));
}
