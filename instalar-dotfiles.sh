#!/bin/bash

# Script de Restauración de Dotfiles para Omarchy / Arch Linux

echo ">>> Iniciando la restauración de las configuraciones del sistema (Dotfiles)..."

# Asegurar que Git está instalado
if ! command -v git &> /dev/null; then
    echo ">>> Git no está instalado. Instalándolo..."
    sudo pacman -Sy git --noconfirm
fi

# El repositorio se ubicará aquí
DOTFILES_DIR="$HOME/.dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    echo ">>> El directorio $DOTFILES_DIR ya existe. Omitiendo la clonación."
else
    echo ">>> Por favor, ingresa el enlace de tu repositorio en GitHub."
    echo ">>> [Presiona ENTER para usar por defecto: https://github.com/Alejol00/dotfiles.git]"
    read -r REPO_URL < /dev/tty
    if [ -z "$REPO_URL" ]; then
        REPO_URL="https://github.com/Alejol00/dotfiles.git"
    fi
    
    echo ">>> Clonando el repositorio..."
    git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

echo ">>> Instalando dependencias adicionales necesarias (SwayNC, jq, curl)..."
sudo pacman -S --needed --noconfirm swaync jq curl

# Usar una función en lugar de un alias para que funcione en el script
function dotfiles {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

# Respaldar archivos existentes que puedan generar conflictos
echo ">>> Respaldando configuraciones preexistentes para evitar conflictos..."
mkdir -p "$HOME/.dotfiles-backup"

# Intentar restaurar los archivos
if dotfiles checkout; then
    echo ">>> ¡Archivos restaurados correctamente!"
else
    echo ">>> Se detectaron archivos conflictivos. Moviéndolos a ~/.dotfiles-backup..."
    # Extraer los nombres de los archivos que fallaron y moverlos, creando las carpetas necesarias
    dotfiles checkout 2>&1 | awk '/^[[:space:]]+/ {print $1}' | while read -r file; do
        mkdir -p "$HOME/.dotfiles-backup/$(dirname "$file")"
        mv "$HOME/$file" "$HOME/.dotfiles-backup/$file"
    done
    
    # Reintentar la restauración
    echo ">>> Reintentando la restauración..."
    if dotfiles checkout; then
        echo ">>> ¡Archivos restaurados correctamente en el segundo intento!"
    else
        echo ">>> ERROR: No se pudo completar la restauración. Revisa los mensajes de error."
        exit 1
    fi
fi

# Configurar git para no mostrar archivos sin seguimiento
dotfiles config --local status.showUntrackedFiles no

# Asegurar que el script y el entorno tienen permisos
chmod +x "$HOME/instalar-dotfiles.sh"

# Agregar el alias permanentemente al bashrc si no existe
if ! grep -q "alias dotfiles=" "$HOME/.bashrc"; then
    echo ">>> Añadiendo alias 'dotfiles' a ~/.bashrc..."
    echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> "$HOME/.bashrc"
fi

echo ">>> ¡Restauración completada!"
echo ">>> Por favor, cierra esta terminal o ejecuta 'source ~/.bashrc' para poder usar el comando 'dotfiles'."
