# fan-watchdog (Steam Deck)

Cada 30 s comprueba el ventilador (hwmon `steamdeck_hwmon`). Si esta parado
(< 300 RPM) con la CPU > 55 C o con objetivo >= 1000 RPM, reinicia
`jupiter-fan-control`. Muestra una notificacion critica si:

- `fan1_fault=1` (fallo de firmware; ver ValveSoftware/SteamOS#2475, se arregla suspendiendo/reanudando),
- no se pudo reiniciar el servicio,
- el ventilador sigue parado 10 s despues del reinicio.

Instalar: `sudo ./install.sh` — desinstalar: `sudo ./install.sh --remove`.
Logs: `journalctl -t fan-watchdog`. Umbrales al inicio de `fan-watchdog.sh`.
