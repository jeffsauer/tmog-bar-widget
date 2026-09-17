# tmog-bar-widget
Omarchy bar widget to toggle (i.e. show/hide) TMOG visibility using a hyprland scratchpad workspace.

Assumes TMOG AppImage is located in ~/Applications and is named TaskManagerOG.AppImage

To install, use the following command:

```
omarchy plugin add https://github.com/jeffsauer/tmog-bar-widget --enable
```

And then add the following rule to ~/.config/hypr/looknfeel.lua followed by a ```hyprctl reload``` command to let hyprland know about the new rule.

```
o.window("^com.tmog.taskmanager$", { workspace = "special:taskmgr silent" })
```


To enable a keybinding shortcut to toggle the visibility of TMOG (e.g. SUPER+ALT+T), simply add the following to .config/hypr/bindings.lua:

```
o.bind("SUPER + ALT + T", "TMOG", "omarchy-shell -q com.darkhorse-studios.tmog-bar-widget toggle")
```

Make sure you are not over-riding an existing key binding.


