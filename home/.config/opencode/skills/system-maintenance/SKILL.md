---
name: system-maintenance
description: Usa este skill para tareas de mantenimiento del sistema Omarchy/Arch Linux. Incluye limpieza de paquetes huérfanos, snapshots, actualizaciones, diagnóstico del sistema, y gestión de logs.
---

# System Maintenance

Guía de mantenimiento para Omarchy Linux.

## Actualización completa
```bash
omarchy update -y
```

## Limpiar paquetes huérfanos
```bash
omarchy update orphan pkgs
```

## Snapshots del sistema
```bash
omarchy snapshot create        # Crear snapshot
omarchy snapshot restore       # Restaurar snapshot
```

## Diagnóstico
```bash
omarchy debug --no-sudo --print
```

## Errores del sistema
```bash
journalctl -p 3 -b --no-pager  # Errores del boot actual
journalctl --disk-usage        # Espacio usado por logs
sudo journalctl --rotate --vacuum-time=2weeks  # Limpiar logs viejos
```

## Espacio en disco
```bash
df -h /
du -sh ~/.cache/*
```
