# Ketip

Ketip is a systemd Service Manager.

![screenshot](data/screenshot.png?raw=true)

## Building and Installation

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install

To uninstall, use `ninja uninstall`

    sudo ninja uninstall