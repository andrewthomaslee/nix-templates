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
To start development shell:
```bash
nix develop
```
or
```bash
nix develop .#impure
```
To build default package ( docker image ):
```bash
nix build
```
To build app as file bundle:
```bash
nix build .#bundledApp
```