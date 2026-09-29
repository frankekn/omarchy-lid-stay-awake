# omarchy-lid-stay-awake

An [Omarchy](https://omarchy.org) bar plugin that toggles what your laptop does when you close the lid:

- **OFF** (default): closing the lid locks the session and suspends.
- **ON**: closing the lid turns the screen off but keeps the system running — music, builds, SSH sessions, and downloads keep going. Opening the lid brings the screen back.


## How it works

- A bar widget (`io.github.frankekn.lid`) shows a laptop icon — lit when active, dimmed when off — with a dropdown showing the current state and a switch.
- ON holds a user-level `systemd-inhibit --what=handle-lid-switch` lock (a transient `systemd-run --user` unit, no root needed), the same mechanism desktop environments use for "do nothing on lid close".
- Hyprland `switch:on/off:Lid Switch` bindings call the helper script, which powers the internal panel down/up via `hyprctl dispatch dpms off/on`. DPMS keeps the Wayland output alive, so the lock screen is never racing a destroyed monitor.

Stock Omarchy behavior is untouched: the lid still locks the session on close (so opening it asks for your password), and docked/clamshell mode with external monitors keeps working.

## Install

```bash
omarchy plugin add https://github.com/frankekn/omarchy-lid-stay-awake --enable
bash ~/.config/omarchy/plugins/io.github.frankekn.lid/install.sh
```

The installer:

1. copies `bin/omarchy-lid-stay-awake` to `~/.local/bin/`
2. appends two `switch:` bindings to `~/.config/hypr/bindings.lua` (backs up first, skips if present)
3. enables the widget in the right section of the bar

## Uninstall

```bash
bash ~/.config/omarchy/plugins/io.github.frankekn.lid/uninstall.sh
omarchy plugin remove io.github.frankekn.lid
```

## CLI

The widget is a thin front-end over a script, so it also works from a terminal:

```bash
omarchy-lid-stay-awake toggle   # or: on / off / status
```

## Caveats

- While ON, a closed laptop keeps drawing power and generating heat — don't leave it running in a bag.
- Closing the lid still locks the session (intentional). Open and unlock as usual.

## License

MIT
