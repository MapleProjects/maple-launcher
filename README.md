# Maple Launcher

Dock / launcher de aplicaciones para [Quickshell](https://github.com/Quickshell/Quickshell), adaptado como componente independiente para Hyprland (sin depender del entorno ni paquete `caelestia-shell-git`).

## Características

- Grid de aplicaciones con buscador integrado.
- Selector dinámico de fondos de pantalla (escribir `wallpaper` en el buscador).
- Acciones, conversiones y cálculo matemático integrados.
- Despliegue centrado en el monitor activo enfocado (`Hyprland.focusedMonitor`).
- Hereda dinámicamente el esquema de colores Material 3 y la transparencia del escritorio activo.

## Requisitos

- **Hyprland** (requiere soporte Wayland LayerShell).
- **quickshell** (`quickshell-git`).
- Soporte para componentes QML Caelestia en `/usr/lib/qt6/qml/Caelestia`.

## Instalación

```bash
git clone https://github.com/MapleProjects/maple-launcher
cd maple-launcher
chmod +x install.sh
./install.sh
```

El script copia los módulos autónomos a `~/.config/quickshell/maple-launcher/` y registra la unidad systemd de usuario `maple-launcher.service`.

## Uso

```bash
qs -c maple-launcher ipc call launcher toggle
```

En la configuración de Hyprland (`custom/keybinds.lua`):

```lua
hl.bind("SUPER + D", hl.dsp.exec_cmd("systemctl --user start maple-launcher.service; qs -c maple-launcher ipc call launcher toggle"))
```
