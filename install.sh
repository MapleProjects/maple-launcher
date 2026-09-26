#!/usr/bin/env bash
# Maple Launcher — dock/launcher de aplicaciones para Quickshell, extraido de Caelestia
# Instala el launcher independiente (sin el shell Caelestia completo).
#
# Requisitos:
#   - quickshell-git y caelestia-shell-git instalados (aportan el plugin nativo Caelestia
#     y los modulos QML de /etc/xdg/quickshell/caelestia de los que depende el launcher).
#   - Hyprland (usa WlrLayershell + Hyprland API).
set -euo pipefail

TARGET="$HOME/.config/quickshell/maple-launcher"
CAELESTIA="${CAELESTIA:-/etc/xdg/quickshell/caelestia}"

# Directorios del arbol de Caelestia que se enlazan (el launcher los consume via imports qs.*)
LINKDIRS=(assets components modules services utils)

mkdir -p "$TARGET"
cp shell.qml "$TARGET/shell.qml"

for d in "${LINKDIRS[@]}"; do
  if [ ! -d "$CAELESTIA/$d" ]; then
    echo "AVISO: falta $CAELESTIA/$d. Instala caelestia-shell-git." >&2
    continue
  fi
  ln -sfn "$CAELESTIA/$d" "$TARGET/$d"
done

# Unidad systemd de usuario (autoinicio en la sesion grafica)
UNIT="$HOME/.config/systemd/user/maple-launcher.service"
mkdir -p "$(dirname "$UNIT")"
cat > "$UNIT" <<'EOF'
[Unit]
Description=Maple Launcher (quickshell)
After=graphical-session.target
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/qs -c maple-launcher
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now maple-launcher.service 2>/dev/null || true

echo
echo "Instalado en $TARGET"
echo "  - Abrir:  qs -c maple-launcher ipc call launcher toggle"
echo "  - Bind en Hyprland (ejemplo en hyprland.lua):"
echo "      hl.bind(\"SUPER + D\", hl.dsp.exec_cmd(\"qs -c maple-launcher ipc call launcher toggle\"))"
