{
  description = "Using Nix Flake apps to run scripts with uv2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    uv2nix,
    pyproject-nix,
    pyproject-build-systems,
    systems,
    ...
  }: let
    inherit (nixpkgs) lib;

    # Create attrset for each system
    forAllSystems = lib.genAttrs (import systems);

    # Workspace and package setup
    workspace = uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};

    overlay = workspace.mkPyprojectOverlay {
      sourcePreference = "wheel";
    };

    pythonSets = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python313;
        baseSet = pkgs.callPackage pyproject-nix.build.packages {
          inherit python;
        };
      in
        baseSet.overrideScope (
          lib.composeManyExtensions [
            pyproject-build-systems.overlays.default
            overlay
            (final: prev: {
              nixfastapi = prev.nixfastapi.overrideAttrs (old: {
                passthru =
                  (old.passthru or {})
                  // {
                    tests = let
                      virtualenv = final.mkVirtualEnv "nixfastapi-pytest" {
                        nixfastapi = ["dev"];
                      };
                    in
                      (old.tests or {})
                      // {
                        pytest = pkgs.stdenv.mkDerivation {
                          name = "${final.nixfastapi.name}-pytest";
                          inherit (final.nixfastapi) src;
                          nativeBuildInputs = [virtualenv];
                          dontConfigure = true;
                          buildPhase = ''
                            runHook preBuild
                            pytest --junit-xml=pytest.xml
                            runHook postBuild
                          '';
                          installPhase = ''
                            runHook preInstall
                            mv pytest.xml $out
                            runHook postInstall
                          '';
                        };
                      };
                  };
              });
            })
          ]
        )
    );
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pythonSet = pythonSets.${system};
      venv = pythonSet.mkVirtualEnv "nixfastapi-venv" workspace.deps.default;
      mainPy = pkgs.runCommand "main.py" {buildInputs = [venv];} ''
        mkdir -p $out
        cp ${./main.py} $out/main.py
        chmod +x $out/main.py
        patchShebangs $out/main.py
      '';
      staticDirectory = pkgs.runCommand "staticDirectory" {buildInputs = [pkgs.rsync];} ''
        mkdir -p $out/static
        rsync -a --exclude='output.css' ${./static}/ $out/static/
      '';
    in rec {
      # Create a docker image with nix-store paths as layers
      docker = pkgs.dockerTools.buildLayeredImage {
        name = "nixfastapi-container";
        created = "now";
        contents = [staticDirectory mainPy];
        extraCommands = ''
          ${pkgs.tailwindcss_4}/bin/tailwindcss -i ${./static/input.css} -o ./static/output.css --minify
        '';
        config = {
          Cmd = ["/main.py"];
          Volumes = {"/data" = {};};
        };
      };
      bundledApp = pkgs.symlinkJoin {
        name = "nixfastapi-bundle";
        paths = [staticDirectory mainPy];
      };
      default =
        if pkgs.stdenv.isLinux
        then docker
        else bundledApp;
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python313;
      pythonSet = pythonSets.${system};
      editableOverlay = workspace.mkEditablePyprojectOverlay {
        root = "$REPO_ROOT";
      };
      editablePythonSet = pythonSet.overrideScope (
        lib.composeManyExtensions [
          editableOverlay
          (final: prev: {
            nixfastapi = prev.nixfastapi.overrideAttrs (old: {
              src = lib.fileset.toSource {
                root = old.src;
                fileset = lib.fileset.unions [
                  (old.src + "/pyproject.toml")
                  (old.src + "/README.md")
                  (old.src + "/main.py")
                  (old.src + "/src/")
                  (old.src + "/tests/")
                  (old.src + "/static/")
                  (old.src + "/scripts/")
                ];
              };
              nativeBuildInputs =
                old.nativeBuildInputs
                ++ final.resolveBuildSystem {
                  editables = [];
                };
            });
          })
        ]
      );
      virtualenvDev = editablePythonSet.mkVirtualEnv "nixfastapi-dev" workspace.deps.all;
      #------------------------------------------------------------------------------#
      # tmux.conf file
      myTmuxConf = pkgs.writeText "tmux.conf" ''
        set -g mouse on
        set-option -g default-command "${pkgs.bash}/bin/bash -l"
      '';
      # wrapper script for tmux
      wrappedTmux = pkgs.writeShellScriptBin "tmux" ''
        exec ${pkgs.tmux}/bin/tmux -f ${myTmuxConf} "$@"
      '';
    in {
      # This devShell simply adds Python & uv and undoes the dependency leakage done by Nixpkgs Python infrastructure.
      impure = pkgs.mkShell {
        packages = [
          wrappedTmux
          python
          pkgs.uv
          pkgs.tailwindcss_4
          pkgs.watchman
        ];
        env =
          {
            UV_PYTHON_DOWNLOADS = "never";
            UV_PYTHON = python.interpreter;
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
          };
        shellHook = ''
          unset PYTHONPATH
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          uv sync
          source .venv/bin/activate
          $REPO_ROOT/scripts/tmux-startup.sh
        '';
      };
      # This devShell uses uv2nix to construct a virtual environment purely from Nix, using the same dependency specification as the application.
      default = pkgs.mkShell {
        packages = [
          wrappedTmux
          virtualenvDev
          pkgs.uv
          pkgs.tailwindcss_4
          pkgs.watchman
        ];
        env = {
          UV_NO_SYNC = "1";
          UV_PYTHON = python.interpreter;
          UV_PYTHON_DOWNLOADS = "never";
        };
        shellHook = ''
          unset PYTHONPATH
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          source ${virtualenvDev}/bin/activate
          $REPO_ROOT/scripts/tmux-startup.sh
        '';
      };
    });

    # Construct flake checks from Python set
    checks = forAllSystems (system: let
      pythonSet = pythonSets.${system};
    in {
      inherit (pythonSet.nixfastapi.passthru.tests) pytest;
    });
  };
}
