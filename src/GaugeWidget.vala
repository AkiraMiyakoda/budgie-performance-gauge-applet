// Copyright (c) 2021 Akira Miyakoda
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

namespace PerformanceGaugeApplet
{

internal class GaugeWidget : Gtk.DrawingArea
{
    private const uint   REDRAW_INTERVAL    = 50;
    private const double MAX_MOVEMENT       = 5.0;
    private const double FOREGROUND_OPACITY = 1.0;
    private const double BACKGROUND_OPACITY = 0.25;

    private double current_percent = 0.0;
    private double target_percent  = 0.0;

    public GaugeWidget()
    {
        this.set_size_request(20, 20);
        this.set_percent(0.0);

        Timeout.add_full(Priority.LOW, REDRAW_INTERVAL, redraw);
    }

    public void set_percent(double value)
    {
        value = double.min(value, 100.0);
        value = double.max(value,   0.0);
        this.target_percent = value;
    }

    public override bool draw(Cairo.Context cr)
    {
        const double RADIAN_START = 130.0 * Math.PI / 180.0;
        const double RADIAN_END   = 410.0 * Math.PI / 180.0;

        var delta = this.target_percent - this.current_percent;
        delta = double.min(delta,  MAX_MOVEMENT);
        delta = double.max(delta, -MAX_MOVEMENT);

        double radian_upper = RADIAN_START + (RADIAN_END - RADIAN_START) * this.current_percent / 100.0;
        this.current_percent += delta;

        double radian_lower;
        if (delta < 0.0) {
            radian_lower = RADIAN_START + (RADIAN_END - RADIAN_START) * this.current_percent / 100.0;
        }
        else {
            radian_lower = radian_upper;
        }

        var width  = this.get_allocated_width();
        var height = this.get_allocated_height();
        var center_x = width  / 2.0;
        var center_y = height / 2.0 * 1.05;
        var line_width = double.min(width, height) / 4.5;
        var radius = double.min(width, height) / 2.0 - line_width / 2.0 - 1;
        var line_color = this.get_style_context().get_color(Gtk.StateFlags.ACTIVE);

        if (radian_upper != RADIAN_END) {
            cr.set_source_rgba(
                line_color.red,
                line_color.green,
                line_color.blue,
                line_color.alpha * BACKGROUND_OPACITY
                );
            cr.set_line_width(line_width);
            cr.set_line_cap(Cairo.LineCap.BUTT);
            cr.arc(
                center_x,
                center_y,
                radius,
                radian_upper,
                RADIAN_END
                );
            cr.stroke();
        }

        if (radian_lower != radian_upper) {
            cr.set_source_rgba(
                line_color.red,
                line_color.green,
                line_color.blue,
                line_color.alpha * (BACKGROUND_OPACITY + FOREGROUND_OPACITY) / 2.0
                );
            cr.set_line_width(line_width);
            cr.set_line_cap(Cairo.LineCap.BUTT);
            cr.arc(
                center_x,
                center_y,
                radius,
                radian_lower,
                radian_upper
                );
            cr.stroke();
        }

        if (radian_lower != RADIAN_START) {
            cr.set_source_rgba(
                line_color.red,
                line_color.green,
                line_color.blue,
                line_color.alpha * FOREGROUND_OPACITY
                );
            cr.set_line_width(line_width);
            cr.set_line_cap(Cairo.LineCap.BUTT);
            cr.arc(
                center_x,
                center_y,
                radius,
                RADIAN_START,
                radian_lower
                );
            cr.stroke();
        }

        return false;
    }

    private bool redraw()
    {
        var window = this.get_window();
        if (window == null) {
            return true;
        }

        window.invalidate_region(window.get_clip_region(), true);

        return true;
    }
}

}
