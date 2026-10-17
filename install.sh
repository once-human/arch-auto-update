#!/usr/bin/env bash
# One-time setup for background auto-updates. Run:  sudo bash install.sh
# Takes a few seconds. The actual updating happens in the background.
set -euo pipefail
cd "$(dirname "$0")"

[[ $EUID -eq 0 ]] || { echo "Run me with sudo:  sudo bash install.sh"; exit 1; }
[[ -f /etc/arch-release ]] || { echo "This is only for Arch Linux."; exit 1; }
USER_NAME=${SUDO_USER:-$(logname 2>/dev/null || true)}
[[ -n $USER_NAME && $USER_NAME != root ]] || { echo "Run via sudo from your normal user."; exit 1; }

install -Dm755 auto-update         /usr/local/bin/auto-update
install -Dm644 auto-update.service /etc/systemd/system/auto-update.service
install -Dm644 auto-update.timer   /etc/systemd/system/auto-update.timer
install -Dm644 README.md           /usr/local/share/doc/auto-update/README.md
if [[ ! -f /etc/auto-update.conf ]]; then
    sed "s/__USER__/$USER_NAME/" auto-update.conf >/etc/auto-update.conf
    chmod 644 /etc/auto-update.conf
fi
mkdir -p /var/lib/auto-update
touch /var/log/auto-update.log
rm -f /var/lib/auto-update/news-acked
/usr/local/bin/auto-update ack >/dev/null 2>&1 || true   # current Arch news = already read

systemctl daemon-reload
systemctl enable --now auto-update.timer >/dev/null 2>&1
# Kick off the first update right now, in the background.
systemctl start --no-block auto-update.service

echo "✓ Auto-updates are on. Updating in the background now, then daily."
echo "  You can close this terminal. Check anytime:  auto-update status"
