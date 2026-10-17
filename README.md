# arch-auto-update

Hands-off, careful automatic updates for an Arch Linux laptop.

Once it's installed, your system updates itself about once a day in the background, at idle priority, and only when you're plugged in. While it runs, one notification keeps you in the loop: it says when the update starts, shows a progress bar through downloading and installing (with the package it's on), and ends with a summary of how many packages were updated, how much was downloaded and how long it took. If nothing needs updating, you won't hear from it at all. To turn the progress notifications off, set `SHOW_PROGRESS=0` in `/etc/auto-update.conf`.

## Install (once)

```bash
cd ~/Projects/arch-auto-update
sudo bash install.sh
```

It takes a few seconds and asks nothing. It sets up the background service and starts the first update right away. You can close the terminal and keep working.

## What it does on its own

Every hour it does a quick check. Once at least 24 hours have passed since the last upgrade, it runs a real one:

1. **Reads the Arch news feed.** Arch announces updates that need manual steps on archlinux.org/news. If there's a post you haven't acknowledged yet, auto-updates pause and you get one notification.
2. **Checks what's pending** against a throwaway copy of the package database, so the real one is never left half-synced.
3. **Skips the whole upgrade if a "held" package is in it.** By default those are Hyprland and its libraries, Quickshell, NVIDIA and GRUB, because those are the updates that tend to break a riced desktop or the boot process. It never upgrades just part of the system: on Arch, partial upgrades are what actually break things.
4. **Takes a snapshot** if Timeshift or Snapper is installed.
5. **Runs the upgrade** (`archlinux-keyring` first, then `pacman -Su`). While it runs, sleep, shutdown and lid-close are blocked so the upgrade can't be cut off halfway.
6. **Checks afterwards** whether the kernel changed (you need to reboot) or whether new `.pacnew` config files showed up (you need to merge them).
7. **Updates Flatpak apps**, if you use Flatpak.

The `paccache.timer` is also turned on. It keeps the last 3 versions of every package and clears out the rest, so the cache doesn't fill your disk and you can still downgrade if you need to.

## What it will never do

| Never | Why |
|---|---|
| Update AUR packages | AUR packages are scripts built from source. Running them unattended means running code nobody has looked at. Update them with `yay`/`paru` whenever you want. |
| Merge config files | `.pacnew` merges need a human. It tells you when there are new ones. |
| Reboot | It tells you when a reboot is needed and leaves the timing to you. |
| Run on battery | If the battery dies mid-upgrade, the system can end up unbootable. |
| Fight you | If you're already running pacman or yay yourself, it backs off. |

## When it pings you

| Notification | What to do |
|---|---|
| **Arch news — auto-updates paused** | Read the post. Do whatever it says, if it applies to you. Then run `sudo auto-update ack`. |
| **Update needs you** (held package) | Run `sudo pacman -Syu` yourself and check your desktop afterwards. |
| **Auto-update failed** | Usually a package conflict pacman wants you to answer. Run `sudo pacman -Syu` and read what it asks. |
| **Kernel updated — reboot when convenient** | Reboot sometime. Until you do, plugging in new USB devices may not work. |
| **New config files to merge** | `sudo pacdiff` |

## Commands

```bash
auto-update status        # what happened last and what needs you
auto-update log           # recent log (full log: /var/log/auto-update.log)
sudo auto-update run      # update right now
sudo auto-update ack      # after reading Arch news
sudo auto-update pause    # stop automatic upgrades (e.g. before a demo)
sudo auto-update resume
```

## Settings

Everything is in `/etc/auto-update.conf` and is commented: how often it upgrades, the held packages, notifications on success, Flatpak, snapshots and the minimum free disk space. Changes apply on the next check.

To let Hyprland update automatically too, remove it from `HOLD_PKGS`.

## Strongly recommended: snapshots

Without snapshots, a bad update means fixing things from a live USB. With them, you pick yesterday's snapshot and you're back in about a minute.

```bash
sudo pacman -S timeshift
```

Open Timeshift once and set it up (BTRFS mode if your root partition is btrfs, RSYNC otherwise). After that, auto-update takes a snapshot before every upgrade.

## Uninstall

```bash
sudo bash uninstall.sh
```
