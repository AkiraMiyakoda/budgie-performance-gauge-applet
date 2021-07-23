// Copyright (c) 2021 Akira Miyakoda
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <cmath>
#include <cstring>
#include <string>
#include <mntent.h>
#include <sys/statvfs.h>
#include <glib.h>

extern "C" {

gboolean get_mount_points_native(gchar **buffer)
{
    // List all the mount points except for read-only or zero-capacity ones.
    std::string points;
    points.reserve(256);

    const auto file = ::setmntent("/etc/mtab", "r");
    if (!file) {
        return FALSE;
    }

    struct mntent *e;
    while ((e = ::getmntent(file)) != nullptr) {
        struct statvfs64 stat;
        if (::statvfs64(e->mnt_dir, &stat) != 0) {
            continue;
        }

        if (stat.f_blocks == 0 || (stat.f_flag & ST_RDONLY)) {
            continue;
        }

        points += e->mnt_dir;
        points += '\n';
    }
    ::endmntent(file);

    if (points.empty()) {
        return FALSE;
    }

    points.pop_back();

    *buffer = new gchar[ points.size() + 1 ];
    ::strcpy(*buffer, points.c_str());

    return TRUE;
}

void free_mount_points_native(gchar *buffer)
{
    delete [] buffer;
}

gboolean get_storage_usage_native(const gchar *mount_point, guint64 *total, guint64 *used)
{
    *total = 0;
    *used  = 0;

    struct statvfs64 stat;
    if (::statvfs64(mount_point, &stat) != 0) {
        return FALSE;
    }

    const auto total_bytes = stat.f_blocks * stat.f_bsize;
    const auto used_bytes  = total_bytes - stat.f_bfree * stat.f_bsize;

    *total = static_cast<guint64>(std::round(total_bytes / 1024.0));
    *used  = static_cast<guint64>(std::round(used_bytes  / 1024.0));

    return TRUE;
}

}
