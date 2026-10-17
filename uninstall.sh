#!/usr/bin/env bash
# Removes auto-update. Run:  sudo bash uninstall.sh
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run me with sudo:  sudo bash uninstall.sh"; exit 1; }
systemctl disable --now auto-update.timer 2>/dev/null || true
rm -f /etc/systemd/system/auto-update.{service,timer} /usr/local/bin/auto-update
rm -rf /usr/local/share/doc/auto-update /var/lib/auto-update
systemctl daemon-reload
echo "Removed. Kept /etc/auto-update.conf and /var/log/auto-update.log (delete them if you want)."
echo "paccache.timer is still enabled (it's useful on its own): sudo systemctl disable --now paccache.timer"
