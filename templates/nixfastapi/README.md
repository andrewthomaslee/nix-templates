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
To start development shell:
```bash
nix develop
```
or
```bash
nix develop .#impure
```

## Build
Build default package ( docker image ):
```bash
nix build
```
Build app as file bundle:
```bash
nix build .#bundledApp
```

## Run
Build -> Load -> Run ( docker image ):
```bash
nix run
```
Build -> Run ( bundled app ):
```bash
nix run .#bundledApp
```

## Run tests
```bash
nix flake check
```
Build pytest results:
```bash
nix build .#checks.<system>.pytest
```

###### Firefox & datastar issue ...
Firefox browser fights `datastar`. Makings styles not work. To fix this, use a different browser or disable datastar.