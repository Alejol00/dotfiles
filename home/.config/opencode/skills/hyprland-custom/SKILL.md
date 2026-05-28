---
name: hyprland-custom
description: Personalización de Hyprland en Omarchy. Use when editing Hyprland config, window rules, keybindings, animations, monitors, themes, wallpapers, or any Hyprland-related customization.
---

# Hyprland Customization (Omarchy)

## Config locations
| Archivo | Propósito |
|---------|-----------|
| `~/.config/hypr/hyprland.conf` | Config principal |
| `~/.config/hypr/bindings.conf` | Keybindings |
| `~/.config/hypr/monitors.conf` | Monitores |
| `~/.config/hypr/looknfeel.conf` | Apariencia (gaps, bordes, animaciones) |
| `~/.config/hypr/input.conf` | Teclado/mouse |
| `~/.config/hypr/hypridle.conf` | Idle/lock |
| `~/.config/hypr/hyprlock.conf` | Pantalla de bloqueo |

## Temas
```bash
omarchy theme list              # Listar temas
omarchy theme current           # Tema actual
omarchy theme set "Nombre"      # Aplicar tema
omarchy theme bg next           # Siguiente wallpaper
```

## Keybindings
- Editar `~/.config/hypr/bindings.conf`
- Formato: `bind = MOD, TECLA, comando`
- Usar `unbind = MOD, TECLA` antes de re-asignar
- Ver bindings actuales: `omarchy menu keybindings --print`

## Validación
- `hyprctl reload` - Recargar config
- `hyprctl configerrors` - Validar errores (siempre después de editar)

## Monitores
- `hyprctl monitors` - Listar monitores
- Editar `~/.config/hypr/monitors.conf`

## IMPORTANTE
- No editar archivos en `~/.local/share/omarchy/`
- Respaldar antes de cambios mayores: `cp archivo.conf archivo.conf.bak.$(date +%s)`
- Waybar requiere `omarchy restart waybar` después de editar (no auto-reload)
- Reglas de ventana: verificar sintaxis actual en wiki de Hyprland
