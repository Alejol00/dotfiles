#!/bin/bash
set -e

echo "=== INSTALACIÓN DE DOTFILES ==="
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# 1. Stow
if ! command -v stow &>/dev/null; then
  echo "→ Instalando stow..."
  sudo pacman -S --noconfirm stow
fi

mkdir -p ~/.config ~/scripts

echo "→ Verificando conflictos..."
CONFLICTS=""
for f in "$DOTFILES/home/.config/hypr" "$DOTFILES/home/.bashrc" "$DOTFILES/home/scripts"; do
  target="$HOME/$(echo "$f" | sed "s|$DOTFILES/home/||")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  ⚠️  Conflicto: $target ya existe"
    CONFLICTS=1
  fi
done

if [ -n "$CONFLICTS" ]; then
  echo "→ Haciendo backup de archivos existentes..."
  BACKUP_DIR="$HOME/dotfiles-backup-$(date +%s)"
  mkdir -p "$BACKUP_DIR"
  for f in "$DOTFILES/home/.config/hypr" "$DOTFILES/home/.bashrc" "$DOTFILES/home/scripts"; do
    target="$HOME/$(echo "$f" | sed "s|$DOTFILES/home/||")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mv "$target" "$BACKUP_DIR/"
      echo "  → Movido $target → $BACKUP_DIR/"
    fi
  done
fi

echo "→ Instalando configuraciones con stow..."
cd "$DOTFILES"
stow home -t "$HOME"
echo "  ✅ Configuraciones instaladas"

# 2. Instalar paquetes
if [ -f "$DOTFILES/packages/official.txt" ]; then
  echo "→ Instalando paquetes oficiales..."
  sudo pacman -S --noconfirm --needed - < "$DOTFILES/packages/official.txt" 2>/dev/null || true
fi

if [ -f "$DOTFILES/packages/aur.txt" ]; then
  if command -v yay &>/dev/null; then
    echo "→ Instalando paquetes AUR..."
    yay -S --noconfirm --needed - < "$DOTFILES/packages/aur.txt" 2>/dev/null || true
  elif command -v paru &>/dev/null; then
    paru -S --noconfirm --needed - < "$DOTFILES/packages/aur.txt" 2>/dev/null || true
  fi
fi

# 3. Instalar temas de Omarchy
echo "→ Instalando temas de Omarchy..."
for theme in white blackmoney; do
  THEME_DIR="$DOTFILES/home/.config/omarchy/themes/$theme"
  if [ -d "$THEME_DIR" ]; then
    # El theme ya está en dotfiles, copiar a ~/.config/omarchy/themes/
    # (si el directorio existe como real, no como symlink, copiar igualmente)
    mkdir -p "$HOME/.config/omarchy/themes/$theme"
    cp -rn "$THEME_DIR/"* "$HOME/.config/omarchy/themes/$theme/" 2>/dev/null || true
    echo "  ✅ Tema $theme instalado"
  fi
done

# 4. Aplicar tema diurno (white)
if command -v omarchy &>/dev/null; then
  echo "→ Aplicando tema white..."
  omarchy theme apply white 2>/dev/null && echo "  ✅ Tema white aplicado" || echo "  ⚠️  No se pudo aplicar el tema (se puede hacer manual después)"
fi

# 5. Parchear hyprland.conf con source= adicionales
echo "→ Parcheando hyprland.conf..."
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPRLAND_CONF" ] && [ -f "$DOTFILES/packages/hyprland-patch.conf" ]; then
  while IFS= read -r line; do
    if ! grep -qF "$line" "$HYPRLAND_CONF" 2>/dev/null; then
      echo "$line" >> "$HYPRLAND_CONF"
      echo "  → Agregado: $line"
    fi
  done < "$DOTFILES/packages/hyprland-patch.conf"
  echo "  ✅ hyprland.conf parcheado"
fi

# 6. Configurar límite de batería al 80%
echo "→ Configurando límite de batería al 80%..."
UDEV_DIR="$DOTFILES/packages/udev"
if [ -f "$UDEV_DIR/99-battery-charge.rules" ]; then
  sudo cp "$UDEV_DIR/99-battery-charge.rules" /etc/udev/rules.d/
  echo "  ✅ Regla udev copiada"
fi
if [ -f "$UDEV_DIR/battery-charge-limit.service" ]; then
  sudo cp "$UDEV_DIR/battery-charge-limit.service" /etc/systemd/system/
  sudo systemctl daemon-reload 2>/dev/null || true
  sudo systemctl enable --now battery-charge-limit.service 2>/dev/null && echo "  ✅ Servicio de batería activado" || echo "  ⚠️  No se pudo activar el servicio de batería"
fi

# 7. Copiar configuración de opencode (sin secrets)
echo "→ Configurando opencode..."
OPCODE_DIR="$HOME/.config/opencode"
if [ -f "$DOTFILES/packages/opencode.json" ]; then
  mkdir -p "$OPCODE_DIR"
  if [ ! -f "$OPCODE_DIR/opencode.json" ]; then
    cp "$DOTFILES/packages/opencode.json" "$OPCODE_DIR/"
    echo "  ✅ opencode.json copiado (configurar API keys manualmente si es necesario)"
  else
    echo "  ⚠️  opencode.json ya existe, no se sobrescribe (contiene tus tokens)"
  fi
fi

# 8. Hacer scripts ejecutables
echo "→ Dando permisos de ejecución a scripts..."
chmod +x "$HOME/scripts/"* 2>/dev/null || true
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true
echo "  ✅ Scripts ejecutables"

# 9. Recargar Hyprland
if command -v hyprctl &>/dev/null; then
  echo "→ Recargando Hyprland..."
  hyprctl reload 2>/dev/null && echo "  ✅ Hyprland recargado" || echo "  ⚠️  No se pudo recargar Hyprland"
fi

echo ""
echo "=== INSTALACIÓN COMPLETADA ==="
echo "Para cambiar al tema nocturno: omarchy theme apply blackmoney"
