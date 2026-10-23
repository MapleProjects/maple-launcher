#!/usr/bin/env bash
# Maple Launcher — dock/launcher de aplicaciones para Quickshell
# Instalación autónoma e independiente (sin requerir el paquete caelestia-shell-git).
#
# Requisitos:
#   - quickshell (quickshell-git)
#   - Hyprland (usa WlrLayershell + Hyprland API)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/quickshell/maple-launcher"

# Directorios empaquetados autónomos (el launcher los consume mediante imports qs.*)
DIRS=(assets components modules services utils)

mkdir -p "$TARGET"
cp -f "$SCRIPT_DIR/shell.qml" "$TARGET/shell.qml"

for d in "${DIRS[@]}"; do
  if [ -d "$SCRIPT_DIR/$d" ]; then
    rm -rf "$TARGET/$d"
    cp -r "$SCRIPT_DIR/$d" "$TARGET/$d"
  fi
done

# Unidad systemd de usuario (autoinicio en la sesión gráfica)
UNIT="$HOME/.config/systemd/user/maple-launcher.service"
mkdir -p "$(dirname "$UNIT")"

EXEC_PREFIX=""
if [ -x "$HOME/.local/bin/intel-run" ]; then
  EXEC_PREFIX="$HOME/.local/bin/intel-run "
elif command -v intel-run &>/dev/null; then
  EXEC_PREFIX="intel-run "
fi

cat > "$UNIT" <<EOF
[Unit]
Description=Maple Launcher (quickshell, independiente)
After=graphical-session.target
PartOf=graphical-session.target

[Service]
ExecStart=${EXEC_PREFIX}/usr/bin/qs -c maple-launcher
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now maple-launcher.service 2>/dev/null || true

echo
echo "Instalado con éxito en $TARGET (independiente de Caelestia Shell)"
echo "  - Abrir/Alternar: qs -c maple-launcher ipc call launcher toggle"
echo "  - Atajo en Hyprland (ejemplo en custom/keybinds.lua):"
echo "      hl.bind(\"SUPER + D\", hl.dsp.exec_cmd(\"systemctl --user start maple-launcher.service; qs -c maple-launcher ipc call launcher toggle\"))"
