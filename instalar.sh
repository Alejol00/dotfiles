#!/bin/bash
set -e

echo "=== INSTALACIÓN DE DOTFILES ==="

# 0. Obtener el directorio donde está este script
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# 1. Verificar stow
if ! command -v stow &>/dev/null; then
  echo "→ Instalando stow..."
  sudo pacman -S --noconfirm stow
fi

# 2. Crear directorios necesarios
mkdir -p ~/.config
mkdir -p ~/scripts

# 3. Verificar paquetes no conflictivos
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

# 4. Crear symlinks con stow
echo "→ Instalando dotfiles con stow..."
cd "$DOTFILES"
stow home -t "$HOME"
echo "  ✅ Configuraciones instaladas"

# 5. Instalar paquetes
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

echo ""
echo "=== INSTALACIÓN COMPLETADA ==="
echo "Reinicia sesión o recarga Hyprland para aplicar todos los cambios."
