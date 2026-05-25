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
    echo ">>> Por favor, ingresa el enlace de tu repositorio en GitHub (ejemplo: git@github.com:USUARIO/REPO.git o https://github.com/USUARIO/REPO.git):"
    read -r REPO_URL
    
    echo ">>> Clonando el repositorio..."
    git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

# Configurar alias temporal para la ejecución
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Respaldar archivos existentes que puedan generar conflictos
echo ">>> Respaldando configuraciones preexistentes para evitar conflictos..."
mkdir -p "$HOME/.dotfiles-backup"

# Intentar restaurar los archivos
if dotfiles checkout; then
    echo ">>> ¡Archivos restaurados correctamente!"
else
    echo ">>> Se detectaron archivos conflictivos. Moviéndolos a ~/.dotfiles-backup..."
    # Extraer los nombres de los archivos que fallaron y moverlos
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
    
    # Reintentar la restauración
    echo ">>> Reintentando la restauración..."
    dotfiles checkout
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
