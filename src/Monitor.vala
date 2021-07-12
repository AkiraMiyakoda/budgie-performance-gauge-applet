namespace PerformanceGaugeApplet
{

internal class Monitor
{
    private static uint prev_cpu_busy = 0;
    private static uint prev_cpu_idle = 0;

    static construct
    {
        uint busy, idle;
        if (get_latest_cpu_usage(out busy, out idle)) {
            prev_cpu_busy = busy;
            prev_cpu_idle = idle;
        }
    }

    public static bool get_cpu_usage(out double usage)
    {
        usage = 0.0;

        uint latest_busy;
        uint latest_idle;
        if (!get_latest_cpu_usage(out latest_busy, out latest_idle)) {
            return false;
        }

        uint busy = latest_busy - prev_cpu_busy;
        uint idle = latest_idle - prev_cpu_idle;
        usage = busy * 100.0 / (busy + idle);

        prev_cpu_busy = latest_busy;
        prev_cpu_idle = latest_idle;

        return true;
    }

    private static bool get_latest_cpu_usage(out uint busy, out uint idle)
    {
        busy = 0;
        idle = 0;

        var stat = read_entire_file("/proc/stat");
        if (stat == "") {
            return false;
        }

        var index = find_digit(stat);
        if (index < 0) {
            return false;
        }

        var values = stat.substring(index, 50).split(" ", 4);
        if (values.length < 4) {
            return false;
        }

        busy = uint.parse(values[0]) + uint.parse(values[1]) + uint.parse(values[2]);
        idle = uint.parse(values[3]);

        return true;
    }

    public static bool get_memory_usage(out uint total, out uint used)
    {
        total = 0;
        used  = 0;

        var meminfo = read_entire_file("/proc/meminfo");
        if (meminfo == "") {
            return false;
        }

        {
            var index = meminfo.index_of("MemTotal:");
            if (index < 0) {
                return false;
            }

            index = find_digit(meminfo, index + 9);
            if (index < 0) {
                return false;
            }

            total = uint.parse(meminfo.substring(index, 10));
        }

        {
            var index = meminfo.index_of("MemFree:");
            if (index < 0) {
                return false;
            }

            index = find_digit(meminfo, index + 8);
            if (index < 0) {
                return false;
            }

            used = total - uint.parse(meminfo.substring(index, 10));
        }

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

    private static int find_digit(string haystack, int start_index = 0)
    {
        for (int i = start_index; i < haystack.length; ++i) {
            if (haystack[i] >= '0' && haystack[i] <= '9') {
                return i;
            }
        }

        return -1;
    }

}

}
