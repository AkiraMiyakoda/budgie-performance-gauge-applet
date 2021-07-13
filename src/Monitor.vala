// Copyright (c) 2021 Akira Miyakoda
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

namespace PerformanceGaugeApplet
{

internal class Monitor
{
    private static uint64 prev_cpu_busy = 0;
    private static uint64 prev_cpu_idle = 0;

    static construct
    {
        uint64 busy;
        uint64 idle;
        if (get_latest_cpu_usage(out busy, out idle)) {
            prev_cpu_busy = busy;
            prev_cpu_idle = idle;
        }
    }

    public static bool get_cpu_usage(out double usage)
    {
        usage = 0.0;

        uint64 latest_busy;
        uint64 latest_idle;
        if (!get_latest_cpu_usage(out latest_busy, out latest_idle)) {
            return false;
        }

        var busy = latest_busy - prev_cpu_busy;
        var idle = latest_idle - prev_cpu_idle;
        usage = busy * 100.0 / (busy + idle);

        prev_cpu_busy = latest_busy;
        prev_cpu_idle = latest_idle;

        return true;
    }

    private static bool get_latest_cpu_usage(out uint64 busy, out uint64 idle)
    {
        busy = 0;
        idle = 0;

        var stat = read_entire_file("/proc/stat");
        if (stat == "") {
            return false;
        }

        Regex regex;
        try {
            regex = new Regex("^cpu\\s+([0-9]+)\\s+([0-9]+)\\s+([0-9]+)\\s+([0-9]+)\\s+");
        }
        catch (RegexError e) {
            return false;
        }

        foreach (var line in stat.split("\n")) {
            MatchInfo m;
            if (!regex.match(line, 0, out m)) {
                continue;
            }

            busy = uint64.parse(m.fetch(1)) + uint64.parse(m.fetch(2)) + uint64.parse(m.fetch(3));
            idle = uint64.parse(m.fetch(4));
            break;
        }

        return (busy != 0);
    }

    public static bool get_memory_usage(out uint64 total, out uint64 used)
    {
        total = 0;
        used  = 0;

        var meminfo = read_entire_file("/proc/meminfo");
        if (meminfo == "") {
            return false;
        }

        Regex regex;
        try {
            regex = new Regex("^([A-Za-z]+)\\:\\s+([0-9]+)\\s+kB$");
        }
        catch (RegexError e) {
            return false;
        }

        uint64 mem_total = uint64.MAX;
        uint64 mem_free  = uint64.MAX;
        foreach (var line in meminfo.split("\n")) {
            MatchInfo m;
            if (!regex.match(line, 0, out m)) {
                continue;
            }

            if (m.fetch(1) == "MemTotal") {
                mem_total = uint64.parse(m.fetch(2));
            }
            else if (m.fetch(1) == "MemFree") {
                mem_free = uint64.parse(m.fetch(2));
            }

            if (mem_total != uint64.MAX && mem_free != uint64.MAX) {
                total = mem_total;
                used  = mem_total - mem_free;
                return true;
            }
        }

        return false;
    }

    public static bool get_mount_points(out Array<string> mount_points)
    {
        mount_points = new Array<string>();

        string stdout;
        string stderr;
        int status;

        try {
            Process.spawn_command_line_sync("df", out stdout, out stderr, out status);
        } catch (SpawnError e) {
            return false;
        }

        Regex regex;
        try {
            regex = new Regex("[0-9]+\\s+[0-9]+\\s+[0-9]+\\s+[0-9]+\\%\\s+(.+)$");
        }
        catch (RegexError e) {
            return false;
        }

        foreach (var line in stdout.split("\n")) {
            MatchInfo m;
            if (!regex.match(line, 0, out m)) {
                continue;
            }

            mount_points.append_val(m.fetch(1));
        }

        return (mount_points.length != 0);
    }

    public static bool get_storage_usage(string mount_point, out uint64 total, out uint64 used)
    {
        total = 0;
        used  = 0;

        Posix.statvfs stat;
        if (Posix.statvfs_exec(mount_point, out stat) != 0) {
            return false;
        }

        total = (uint64)stat.f_blocks * stat.f_bsize;
        used  = total - (uint64)stat.f_bfree * stat.f_bsize;

        total = (uint64)Math.round(total / 1024.0);
        used  = (uint64)Math.round(used  / 1024.0);

        return true;
    }

    private static string read_entire_file(string path)
    {
        var stream = FileStream.open(path, "r");
        if (stream == null) {
            return "";
        }

        var builder = new StringBuilder();
        char buffer[1024];
        while (stream.gets(buffer) != null) {
            builder.append((string)buffer);
        }

        return builder.str;
    }
}

}
