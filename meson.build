# Copyright (c) 2021 Akira Miyakoda
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

project('budgie-performance-gauge-applet',
    [
        'vala',
        'c',
        'cpp'
    ],
    default_options: [
        'warning_level=3',
        'werror=true',
        'cpp_std=c++17',
    ],
    version: '1.0.0',
    meson_version: '>= 0.40.0'
)

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

meson.add_install_script('meson_post_install.py')

# Global path variable
prefix  = get_option('prefix')
libdir  = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))

subdir('src')
