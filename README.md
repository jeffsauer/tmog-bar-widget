<img width="1897" height="1220" alt="tmog-bar-widget" src="https://github.com/user-attachments/assets/d7436dcb-1612-493a-8df4-164cbd1af20d" />

# tmog-bar-widget
Omarchy bar widget to toggle (i.e. show/hide) [TMOG Task Manager](https://tmog.org/) visibility using a hyprland scratchpad workspace. 

This app is in no way affiliated with TMOG, just a helper widget to utilize it in Omarchy.

Assumes TMOG AppImage is located in ~/Applications and is named TaskManagerOG.AppImage

To install, use the following command:

```
omarchy plugin add https://github.com/jeffsauer/tmog-bar-widget --enable
```

Also, add a rule to your .config/hypr/looknfeel.lua, and then do ```hyprctl reload```
```
o.window("^com.tmog.taskmanager$", { workspace = "special:taskmgr silent" })
```

To enable a keybinding shortcut to toggle the visibility of TMOG (e.g. SUPER+ALT+T), simply add the following to .config/hypr/bindings.lua:

```
o.bind("SUPER + ALT + T", "TMOG", "omarchy-shell -q com.darkhorse-studios.tmog-bar-widget toggle")
```

Make sure you are not over-riding an existing key binding.


