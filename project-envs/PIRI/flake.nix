{
  description = "Dev shell: project plus shared Python env";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    project.url = "github:Zarkino/PIRI";
    project.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:BolunThompson/dev-envs?dir=lang-envs/python";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self
            , nixpkgs
            , flake-utils
            , project
            , devenv
            , ...
            }:
    flake-utils.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # fall back to an empty shell if an input does not define one yet
        projShell   = project.devShells.${system}.default or pkgs.mkShell { };
        sharedShell = devenv.devShells.${system}.default or pkks.mkShell { };

        lib = pkgs.lib;
        rawUrl = project.sourceInfo.url or "";                    # e.g. "github:owner/repo"
        ownerRepo = lib.removePrefix "github:" rawUrl;            # "owner/repo"
        ownerRepoOnly = lib.splitString "?" ownerRepo;            # drop ?dir=...
        ownerRepoClean = builtins.elemAt ownerRepoOnly 0;         # still "owner/repo"
        repoName = builtins.elemAt (lib.splitString "/" ownerRepoClean) 1;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "PIRI Dev Shell";

          # Merge inputs from both shells and add GitHub CLI
          inputsFrom  = [ projShell sharedShell ];
          buildInputs = [ pkgs.gh ];

          shellHook = ''
            if [ ! -d "./${repoName}" ]; then
              echo "[flake] cloning ${ownerRepoClean} into ./${repoName} ..."
              gh repo clone "${ownerRepoClean}" "./${repoName}"
            fi
          '';
        };
      });
}
