# Maple Launcher

Dock / launcher de aplicaciones para [Quickshell](https://github.com/Quickshell/Quickshell),
extraido de [Caelestia Shell](https://github.com/caelestia-dots/shell) para funcionar de forma
**independiente**, sin levantar el shell Caelestia completo (barra, fondos, drawers, lock, etc.).

Aporta:
- Grid de aplicaciones con buscador.
- Selector de **wallpapers** en vivo (escribe `wallpaper ` en el buscador).
- Acciones y calculo integrados (prefijo de accion configurable).
- Aparece en el monitor con foco (`Hyprland.focusedMonitor`).

## Requisitos

- Hyprland
- `quickshell-git` y `caelestia-shell-git` (AUR)
  - El launcher depende del plugin nativo `Caelestia` y de los modulos QML de
    `/etc/xdg/quickshell/caelestia`, que aporta `caelestia-shell-git`.
  - No se reempaqueta ese codigo aqui; solo se enlaza (`ln -s`) su arbol.

## Instalacion

```bash
git clone https://github.com/MapleProjects/maple-launcher
cd maple-launcher
./install.sh
```

El instalador crea `~/.config/quickshell/maple-launcher/`, enlaza los directorios
compartidos de Caelestia y registra la unidad systemd de usuario `maple-launcher.service`
(autoinicio con la sesion grafica).

## Uso

```bash
qs -c maple-launcher ipc call launcher toggle   # abrir/cerrar
```

En Hyprland (config Lua):

```lua
hl.bind("SUPER + D", hl.dsp.exec_cmd("qs -c maple-launcher ipc call launcher toggle"))
```

## Configuracion

El launcher lee `~/.config/caelestia/shell.json` (secciones `launcher` y `appearance`)
a traves de `Caelestia.Config`, igual que el shell original.
