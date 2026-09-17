# tmog-bar-widget
Omarchy bar widget to show/hide TMOG on a scratchpad workspace.

Assumes TMOG AppImage is located in ~/Applications and is named TaskManagerOG.AppImage

To enable a keybinding to toggle the visibility of TMOG, add the following to .config/hypr/bindings.lua:

```
o.bind("SUPER + ALT + T", "TMOG", "omarchy-shell -q com.darkhorse-studios.tmog-bar-widget toggle")
```

