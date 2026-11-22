#!/bin/sh
# Steam Deck: si el ventilador esta parado cuando deberia girar, reinicia
# jupiter-fan-control. Si no se puede recuperar (o fault=1), muestra una alerta.
MIN_RPM=300          # por debajo se considera parado
TEMP_MC=55000        # milligrados: por encima de esto debe girar
COOLDOWN=300         # segundos entre reinicios / entre alertas
USER_NAME=deck
STATE=/run/fan-watchdog.last
ALERT_STATE=/run/fan-watchdog.alert

find_hwmon() { for d in /sys/class/hwmon/hwmon*; do [ "$(cat "$d/name" 2>/dev/null)" = "$1" ] && echo "$d" && return; done; }

alert() {   # alert "mensaje" ; limitado por COOLDOWN
    logger -t fan-watchdog "ALERTA: $1"
    now=$(date +%s); last=$(cat "$ALERT_STATE" 2>/dev/null || echo 0)
    [ $((now - last)) -lt "$COOLDOWN" ] && return
    echo "$now" > "$ALERT_STATE"
    uid=$(id -u "$USER_NAME")
    runuser -u "$USER_NAME" -- env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        notify-send -u critical -i dialog-warning "Ventilador del Steam Deck" "$1" 2>/dev/null || true
}

read_fan() {
    fan=$(find_hwmon steamdeck_hwmon); cpu=$(find_hwmon k10temp)
    [ -n "$fan" ] && [ -n "$cpu" ] || return 1
    rpm=$(cat "$fan/fan1_input"); target=$(cat "$fan/fan1_target")
    fault=$(cat "$fan/fan1_fault"); temp=$(cat "$cpu/temp1_input")
}

read_fan || { logger -t fan-watchdog "hwmon no encontrado"; exit 0; }

[ "$rpm" -ge "$MIN_RPM" ] && exit 0

# fault=1 siempre alerta, aunque este frio (el firmware reporta el ventilador averiado)
if [ "$fault" = 1 ]; then
    alert "Fallo de hardware/firmware (fault=1, ${rpm} RPM, CPU $((temp/1000)) C). Reiniciar el servicio no ayuda: suspende y reanuda el Deck."
    exit 0
fi

[ "$temp" -lt "$TEMP_MC" ] && [ "$target" -lt 1000 ] && exit 0   # parado y frio: normal

now=$(date +%s); last=$(cat "$STATE" 2>/dev/null || echo 0)
[ $((now - last)) -lt "$COOLDOWN" ] && exit 0
echo "$now" > "$STATE"
logger -t fan-watchdog "ventilador parado (rpm=$rpm target=$target temp=$temp): reiniciando jupiter-fan-control"

if ! systemctl restart jupiter-fan-control.service; then
    alert "No se pudo reiniciar jupiter-fan-control. Ventilador parado, CPU $((temp/1000)) C."
    exit 0
fi

sleep 10
if read_fan; then
    if [ "$fault" = 1 ]; then
        alert "Tras reiniciar el controlador el ventilador marca fault=1. Suspende y reanuda el Deck."
    elif [ "$rpm" -lt "$MIN_RPM" ] && { [ "$temp" -ge "$TEMP_MC" ] || [ "$target" -ge 1000 ]; }; then
        alert "El ventilador sigue parado tras reiniciar el controlador (CPU $((temp/1000)) C)."
    else
        logger -t fan-watchdog "recuperado: rpm=$rpm target=$target"
    fi
else
    alert "No se pudo leer el ventilador tras reiniciar el controlador."
fi
