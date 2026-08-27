# Feature ideas

Ten additions that fit the current bar's vibe (flat `Text`-based modules,
`Theme.qml` tokens, hover-popup pattern established by `Brightness.qml`)
and need nothing beyond QML + shell one-liners - no custom C/Python
services to write or package.

Confirmed available in this Quickshell install
(`Quickshell/lib/qt-6/qml/Quickshell/Services/`): `Mpris`, `Notifications`,
`SystemTray`, `Polkit`, `Pipewire`, `UPower`, `Pam`, `Greetd`.

## 1. Media player widget (MPRIS)

`Quickshell.Services.Mpris` is a native QML service - no `playerctl`
needed. Show scrolling track/artist text with play/pause/skip, using the
same hover-popup pattern as `Brightness.qml` for a seek bar. `Mpris.players`
gives you every running player (Spotify, browsers, mpv); pick the first
`playbackState === Playing` one, falling back to the first available.

**Start here:** `import Quickshell.Services.Mpris` in a new
`Modules/Media.qml`, print `Mpris.players.values` to confirm you're
getting a player while some music is playing, then build the `Text`
around `player.trackTitle`/`player.trackArtist`.

## 2. System tray

`Quickshell.Services.SystemTray` implements the StatusNotifierItem
protocol natively. Apps like Discord, Steam, and syncthing that minimize
to tray currently have nowhere to go. A `RowLayout` of `Image { source:
trayItem.icon }` with click-to-activate/scroll-to-scroll would cover most
of it; menus need `trayItem.menu` opened via `QsMenuAnchor`.

**Start here:** `import Quickshell.Services.SystemTray` in a new
`Modules/Tray.qml`, add a `Repeater { model: SystemTray.items }` and just
log each item's `id`/`title` first - a tray-registering app (Discord,
syncthing) needs to be running to have anything to see.

## 3. Notification popups + history

`Quickshell.Services.Notifications` gives you a `NotificationServer` you
register as the DBus notification daemon (mutually exclusive with
mako/dunst/swaync - pick one). Toast popups as a `PopupWindow` styled like
`Brightness`'s slider card, plus a bell icon module showing unread count
that opens a scrollable history panel.

**Start here:** check nothing else already owns the notification DBus name
(`busctl --user status org.freedesktop.Notifications`, or just check
whether mako/dunst/swaync are enabled in `~/myNixOS/`) before wiring up
`NotificationServer`, since only one daemon can hold it at a time.

## 4. Polkit authentication agent

`Quickshell.Services.Polkit` lets Quickshell act as the polkit auth
agent - useful since a bare Hyprland setup often has no agent registered,
silently breaking GUI privilege prompts (e.g. NetworkManager Wi-Fi
password saves, some installers). The prompt UI can reuse
`Modules/Lock/AuthField.qml`'s dot-buffer/shake/PAM pattern almost
directly, just swapping the `PamContext` for the `PolkitAgent` request
object.

**Start here:** run `pkexec true` from a terminal first to see whether a
polkit agent is already registered (it'll either prompt or fail with "No
authentication agent found") - no point building this if e.g. GNOME's or
KDE's agent is already running system-wide.

## 5. Quick Settings popup

One "gear" icon on the bar that opens a panel combining toggles already
half-built as separate modules: Wi-Fi (`Networking`), volume slider
(`Pipewire`), brightness slider (reuse `Brightness.qml`'s track
`Rectangle`), and a Do Not Disturb switch (once #3 exists). Structurally
just a bigger `PopupWindow` with a `GridLayout` of the existing
sub-widgets - no new services required.

**Start here:** this is mostly a layout/refactor exercise, not new
plumbing - do it last, after #1-#3 exist, so there's more than
Wi-Fi/volume/brightness worth putting in the panel.

## 6. Power menu

A lock/logout/suspend/reboot/shutdown row in a `PopupWindow`, each button
running a `Process` one-liner: `loginctl lock-session` /
`hyprctl dispatch exit` / `systemctl suspend` / `reboot` / `poweroff`.
Pure bash dispatch, no service needed - the confirmation-on-click UX (e.g.
require a second click within 2s before actually shutting down) is the
only real design decision.

**Start here:** test each command by hand in a terminal first (especially
`hyprctl dispatch exit`, which closes the whole session) so you know what
each button actually does before wiring it to a click handler.

## 7. System resources module (CPU / RAM / disk)

`testShell.qml` already prototypes CPU% via `head -1 /proc/stat` parsed in
a `SplitParser` - promote that pattern into a real `Modules/Resources.qml`
polled by a `Timer`, and add RAM (`/proc/meminfo`, `MemAvailable` /
`MemTotal`) and disk (`df -h /` piped through `Process`). All plain-text
parsing, no new dependencies beyond coreutils that are already present.

**Start here:** copy `testShell.qml`'s `cpuProc`/`SplitParser`/`Timer`
block into a fresh `Modules/Resources.qml` as-is, get it running standalone
first (`qs -p Modules/Resources.qml` won't work since it needs a
PanelWindow - wrap it in one, or just watch the value via `console.log`),
then style it to match `Theme` and wire it into `shell.qml`.

## 8. Weather module

Shell out to `curl 'wttr.in/?format=%c+%t'` (or your city, `?format=j1`
for structured JSON) via `Process`, refreshed on a long `Timer` (30-60
min - be polite to the free API). Parse the one-line output directly, or
`JSON.parse` the `j1` response for a hover popup with more detail
(humidity, wind). Needs network egress but no API key for `wttr.in`.

**Start here:** run `curl 'wttr.in/?format=%c+%t'` from a terminal to see
the raw output before writing any QML, and confirm it works from this
machine's network (some networks/VPNs block it).

## 9. Calendar dropdown on the clock

Click `Modules/Clock.qml` to open a `PopupWindow` month grid - pure QML,
no service: a `GridLayout` of day numbers computed from
`Date.getDay()`/`Date.getDate()` for the first-of-month, highlighting
today via `Theme.primary`. Prev/next-month buttons just offset a `year`/
`month` property and recompute the grid.

**Start here:** reuse `Brightness.qml`'s `PopupWindow`/`beginHover`/
`endHover`/`hideTimer` block wholesale for the show/hide mechanics (or
switch it to click-to-toggle instead of hover, which suits a calendar
better since you'll want to linger on it) - the grid math is the only new
part.

## 10. Screenshot / screen-record launchers

`grim`, `slurp`, and `wl-copy` are already installed on this system
(confirmed via `which`); `wf-recorder` is not, so that half would need
adding to the flake first. One bar button running
`grim -g "$(slurp)" - | wl-copy` (region screenshot to clipboard) via
`Quickshell.execDetached` covers screenshots today, mirroring
`Network.qml`'s existing
`Quickshell.execDetached(["nm-connection-editor"])` pattern for launching
external tools. Screen recording can follow the same pattern once
`wf-recorder` (or `wl-screenrec`) is added as a system package.

**Start here:** test the pipeline by hand first -
`grim -g "$(slurp)" - | wl-copy` - then wrap it in
`Quickshell.execDetached(["sh", "-c", "grim -g \"$(slurp)\" - | wl-copy"])`
behind a new bar icon; `execDetached` (not `Process`) is the right call
here since the shell doesn't need the result back.
