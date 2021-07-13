LIB_INSTALL_DIR = join_paths(prefix, libdir, 'budgie-desktop', 'plugins', 'budgie-performance-gauge')

install_data(
    'BudgiePerformanceGaugeApplet.plugin',
    install_dir : LIB_INSTALL_DIR
)

applet_cputemp_sources = [
    'Applet.vala',
    'AppletSettings.vala',
    'GaugeWidget.vala',
    'Monitor.vala',
]

applet_cputemp_deps = [
    dependency('gtk+-3.0', version: '>= 3.24.0'),
    dependency('libpeas-1.0', version: '>= 1.26.0'),
    dependency('budgie-1.0', version: '>=2'),
]

shared_library(
    'performancegaugeapplet',
    applet_cputemp_sources,
    dependencies: applet_cputemp_deps,
    vala_args: [
        '--pkg', 'libpeas-1.0',
        '--pkg', 'gtk+-3.0',
        '--pkg', 'posix',
    ],
    link_args: [
        '-lm',
    ],
    install: true,
    install_dir: LIB_INSTALL_DIR,
)

install_data(
    'com.github.akiramiyakoda.budgie-performance-gauge-applet.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas'),
)

PIXMAPS_DIR = join_paths(datadir, 'pixmaps')

install_data(
    'performance-gauge-applet-symbolic.svg',
    install_dir: PIXMAPS_DIR
)
