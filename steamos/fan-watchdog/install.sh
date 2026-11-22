#!/bin/sh
# sudo ./install.sh            instala
# sudo ./install.sh --remove   desinstala
set -e
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }
if [ "$1" = "--remove" ]; then
    systemctl disable --now fan-watchdog.timer || true
    rm -rf /etc/fan-watchdog /etc/systemd/system/fan-watchdog.service /etc/systemd/system/fan-watchdog.timer
    systemctl daemon-reload; echo Eliminado; exit 0
fi
here=$(dirname "$(readlink -f "$0")")
install -d -m 755 /etc/fan-watchdog
install -m 755 -o root -g root "$here/fan-watchdog.sh" /etc/fan-watchdog/fan-watchdog.sh
cat > /etc/systemd/system/fan-watchdog.service <<'U'
[Unit]
Description=Vigila que el ventilador no quede parado
[Service]
Type=oneshot
ExecStart=/etc/fan-watchdog/fan-watchdog.sh
U
cat > /etc/systemd/system/fan-watchdog.timer <<'U'
[Unit]
Description=Vigilancia del ventilador cada 30 s
[Timer]
OnBootSec=60
OnUnitActiveSec=30
AccuracySec=1s
[Install]
WantedBy=timers.target
U
systemctl daemon-reload
systemctl enable --now fan-watchdog.timer
echo "Instalado. Logs: journalctl -t fan-watchdog"
