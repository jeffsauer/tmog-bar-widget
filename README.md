# tmog-bar-widget
Omarchy bar widget to show/hide TMOG on a scratchpad workspace.

To enable a keybinding to toggle visibility of TMOG, add the following to .config/hypr/bindings.lua:

o.bind("SUPER + ALT + T", "TMOG", "omarchy-shell -q com.darkhorse-studios.tmog-bar-widget toggle")

