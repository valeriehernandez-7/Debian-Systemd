#!/bin/bash
# Verifica si hay cambios en la rama main de GitHub y actualiza la instancia local.

REPO="/home/velysian/Documents/GitHub/Debian-Systemd"
REMOTE_URL="git@github.com:valeriehernandez-7/Debian-Systemd.git"
BRANCH="main"
APP_USER="velysian"
SERVICE="hello-express"

# Ejecuta comandos como el dueño del repo (no como root)
as_user() { runuser -u "$APP_USER" -- env HOME="/home/$APP_USER" "$@"; }

cd "$REPO" || { echo "No existe $REPO"; exit 1; }

# Fetch por HTTPS: repo público, no necesita credenciales
if ! as_user git fetch --quiet "$REMOTE_URL" "$BRANCH"; then
    echo "Error al consultar GitHub"
    exit 1
fi

LOCAL=$(as_user git rev-parse HEAD)
REMOTE=$(as_user git rev-parse FETCH_HEAD)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Sin cambios ($LOCAL)"
    exit 0
fi

echo "Cambios detectados: ${LOCAL:0:7} -> ${REMOTE:0:7}"

if ! as_user git merge --ff-only FETCH_HEAD; then
    echo "No se pudo actualizar (hay cambios locales o historial divergente)"
    exit 1
fi

# Reinstalar dependencias solo si cambiaron
if as_user git diff --name-only "$LOCAL" "$REMOTE" | grep -q '^express/package'; then
    echo "Dependencias cambiaron, ejecutando npm ci"
    (cd express && as_user npm ci --omit=dev)
fi

systemctl restart "$SERVICE"
echo "Servicio $SERVICE reiniciado con la versión ${REMOTE:0:7}"
