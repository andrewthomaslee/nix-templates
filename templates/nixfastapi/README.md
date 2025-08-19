# nixfastapi
FastAPI managed with Nix and uv2nix

## Install Nix CLI
Determinate Nix Installer is the easiest and most reliable way to install Nix on your system. This will enable flakes by default.
1. Download [Determinate Systems Nix installer](https://github.com/DeterminateSystems/nix-installer) with one command:
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```

# Discover available flake options
```bash
nix flake show
```

# Usage
## Development Shell
The development shell is a Nix shell with all dependencies installed. You will be dropped into a tmux session with a `🌬️Tailwind` watcher, a uvicorn `🐍FastAPI` hot reload server, and a `🦁Brave` web browser.


tmux shortcuts:
- `Ctrl+b + d` → Detach from tmux session
- `Ctrl+b + c` → Create new window


To start development shell:
```bash
nix develop
```
or
```bash
nix develop .#impure
```

## Build
Build default package:
```bash
nix build
```

## Run
Launch fastapi dev server:
```bash
nix run
```
Launch docker compose:
```bash
nix run .#docker-compose
```

## Run tests
```bash
nix flake check
```
Build pytest results:
```bash
nix build .#checks.<system>.pytest
```

## Web Browsers
Included web browsers in the devShell:
- Brave ( Default )
- Firefox
- Chromium ( Linux only )