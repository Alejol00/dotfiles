#!/bin/bash

# Umbrales de batería
LOW_BATTERY_THRESHOLD=20
CRITICAL_BATTERY_THRESHOLD=10
POLL_INTERVAL=3

PREV_AC_STATUS=-1
PREV_CAPACITY=-1

while true; do
    if [ -f "/sys/class/power_supply/AC0/online" ] && [ -f "/sys/class/power_supply/BAT0/capacity" ]; then
        AC_STATUS=$(cat /sys/class/power_supply/AC0/online)
        CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)

        # Notificación inicial (solo para registrar el estado inicial)
        if [ "$PREV_AC_STATUS" = "-1" ]; then
            PREV_AC_STATUS="$AC_STATUS"
            PREV_CAPACITY="$CAPACITY"
            notify-send -a "Energía" -u normal -i battery "Monitor de Batería" "Actualizado. Cargador conectado: $AC_STATUS, Nivel: ${CAPACITY}%"
        fi

        # Si el estado de conexión AC cambia
        if [ "$AC_STATUS" != "$PREV_AC_STATUS" ]; then
            if [ "$AC_STATUS" -eq 1 ]; then
                notify-send -a "Energía" -u normal -i battery-charging "Batería Cargando" "Nivel de batería: ${CAPACITY}%"
            else
                notify-send -a "Energía" -u normal -i battery "Batería Desconectada" "Nivel de batería: ${CAPACITY}%"
            fi
            PREV_AC_STATUS="$AC_STATUS"
        fi

        # Notificaciones de batería baja (sólo avisar cuando se descarga y cruza el umbral)
        if [ "$AC_STATUS" -eq 0 ]; then
            if [ "$CAPACITY" -le "$CRITICAL_BATTERY_THRESHOLD" ] && [ "$PREV_CAPACITY" -gt "$CRITICAL_BATTERY_THRESHOLD" ]; then
                notify-send -a "Energía" -u critical -i battery-empty "Batería Crítica" "¡Conecta el cargador! Nivel: ${CAPACITY}%"
            elif [ "$CAPACITY" -le "$LOW_BATTERY_THRESHOLD" ] && [ "$PREV_CAPACITY" -gt "$LOW_BATTERY_THRESHOLD" ]; then
                notify-send -a "Energía" -u critical -i battery-low "Batería Baja" "Nivel de batería: ${CAPACITY}%"
            fi
        fi
        
        # Notificar batería llena al llegar al 100% mientras está conectado
        if [ "$AC_STATUS" -eq 1 ]; then
            if [ "$CAPACITY" -eq 100 ] && [ "$PREV_CAPACITY" -lt 100 ]; then
                notify-send -a "Energía" -u normal -i battery-full "Batería Llena" "La batería está al 100%"
            fi
        fi

        PREV_CAPACITY="$CAPACITY"
    fi

    sleep $POLL_INTERVAL
done
