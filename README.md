# Mis Dotfiles (Configuraciones de Sistema)

Este repositorio contiene las configuraciones personales de mi sistema (Arch Linux / Omarchy / Hyprland).

## 🚀 Cómo instalar (En un equipo nuevo)

Para restaurar toda la configuración automáticamente en una computadora recién formateada, solo tienes que ejecutar este comando en tu terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/master/instalar-dotfiles.sh | bash
```

*(Recuerda cambiar `TU_USUARIO` y `TU_REPO` por los datos reales de tu GitHub una vez subas este repositorio).*

---

### Código fuente del script de instalación
Si prefieres hacerlo manualmente o quieres ver qué hace el script por debajo, aquí tienes el código exacto:

```bash
#!/bin/bash
echo ">>> Iniciando la restauración de las configuraciones del sistema (Dotfiles)..."

# Asegurar que Git está instalado
if ! command -v git &> /dev/null; then
    echo ">>> Git no está instalado. Instalándolo..."
    sudo pacman -Sy git --noconfirm
fi

DOTFILES_DIR="$HOME/.dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    echo ">>> El directorio ya existe."
else
    echo ">>> Ingresa el enlace de tu repositorio (ejemplo: https://github.com/USUARIO/REPO.git):"
    read -r REPO_URL
    git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

function dotfiles {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}
mkdir -p "$HOME/.dotfiles-backup"

if dotfiles checkout; then
    echo ">>> ¡Archivos restaurados correctamente!"
else
    echo ">>> Resolviendo conflictos..."
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
    dotfiles checkout
fi

dotfiles config --local status.showUntrackedFiles no
chmod +x "$HOME/instalar-dotfiles.sh"

if ! grep -q "alias dotfiles=" "$HOME/.bashrc"; then
    echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> "$HOME/.bashrc"
fi

echo ">>> ¡Restauración completada!"
```
