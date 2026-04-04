{
  description = "Coh Lean 4 Formalization";

  inputs = {
    lean.url = "github:leanprover/lean4";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, lean, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        leanPkgs = lean.packages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            leanPkgs.lean
            leanPkgs.lake
          ];
          shellHook = ''
            echo "Coh Lean Development Environment"
            export LEAN_PATH=$PWD
          '';
        };
      }
    );
}
