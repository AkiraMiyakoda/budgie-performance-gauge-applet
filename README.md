## Budige Performance Gauge Applet

This applet shows a CPU, Memory or Storage gauge on your budgie panel.

![Panel1](https://github.com/AkiraMiyakoda/budgie-performance-gauge-applet/raw/master/assets/panel1.png)

## Dependencies

```
meson
valac
libgtk-3-dev >= 3.24.0
libpeas-dev >= 1.26.0
budgie-core-dev >= 1.0
```

## Installation

**From source**
```
meson build --buildtype=release --prefix /usr --libdir lib
cd build/
ninja
sudo ninja install
```

**From PPA (Ubuntu Budgie 20.04, 21.04 & 21.10)**
```
sudo add-apt-repository ppa:ubuntubudgie/backports
sudo apt install budgie-performance-gauge-applet
```
