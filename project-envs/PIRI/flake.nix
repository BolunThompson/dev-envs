{
  description = "Dev shell: project plus shared Python env";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    project.url = "git+ssh://git@github.com/Zarkino/PIRI?ref=ipyflow-benchmarks";
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
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        projShell   = project.devShells.${system}.default;
        sharedShell = devenv.devShells.${system}.default;

      in
      {
        devShells.default = pkgs.mkShell {
          name = "PIRI Dev Shell";

          inputsFrom  = [ sharedShell projShell];
          buildInputs = [];

          shellHook = ''
            # Doesn't work for some reason with mkdir -p only
            cd
            if [ ! -d programming ]; then
              mkdir programming
            fi
            cd programming
            if [ ! -d ./PIRI ]; then
              echo Cloning!
              git clone git@github.com:Zarkino/PIRI.git
            fi
            cd PIRI
          '';
        };
      });
}
