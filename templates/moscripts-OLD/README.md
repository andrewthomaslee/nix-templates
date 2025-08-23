# moscripts
A collection of Python scripts


## Determinate Systems Nix installer
Determinate Nix Installer is the easiest and most reliable way to install Nix on your system. This will enable flakes by default.
1. Download [Determinate Systems Nix installer](https://github.com/DeterminateSystems/nix-installer) with one command:
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```


## Discover flake options
```bash
nix flake show github:andrewthomaslee/moscripts
```

## Usage
To run apps:
```bash
nix run github:andrewthomaslee/moscripts#greet
```
To build package:
```bash
nix build github:andrewthomaslee/moscripts
```
To build docker image:
```bash
nix build github:andrewthomaslee/moscripts#packages.x86_64-linux.greet-container
```