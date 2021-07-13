// Copyright (c) 2021 Akira Miyakoda
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>
#include <mntent.h>
#include <sys/statvfs.h>

extern "C" {

int get_mount_points_native(char *buffer, size_t length)
{
    // List all the mount points except for read-only or zero-capacity ones.
    std::string points;

    FILE* file = ::setmntent("/etc/mtab", "r");
    if (!file) {
        return 0;
    }

    struct mntent *e;
    while ((e = getmntent(file)) != NULL) {
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
        return 0;
    }

    points.pop_back();

    // snprintf always null-terminate the buffer unlike strncpy.
    ::snprintf(buffer, length, "%s", points.c_str());

    return 1;
}

int get_storage_usage_native(const char *mount_point, uint64_t *total, uint64_t *used)
{
    struct statvfs64 stat;
    if (::statvfs64(mount_point, &stat) != 0) {
        return 0;
    }

    auto total_bytes = stat.f_blocks * stat.f_bsize;
    auto used_bytes  = total_bytes - stat.f_bfree * stat.f_bsize;

    *total = static_cast<uint64_t>(std::round(total_bytes / 1024.0));
    *used  = static_cast<uint64_t>(std::round(used_bytes  / 1024.0));

    return 1;
}

}
