{
  description = "Nix package for Gemini CLI, tracking upstream releases";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f: lib.genAttrs (import systems) f;
      overlay = final: prev: {
        gemini-cli = final.callPackage ./package.nix { };
      };
      pkgsFor = system: import nixpkgs { inherit system; overlays = [ overlay ]; };
    in
    {
      overlays.default = overlay;

      packages = eachSystem (system: rec {
        gemini-cli = (pkgsFor system).gemini-cli;
        default = gemini-cli;
      });

      apps = eachSystem (system: rec {
        gemini-cli = {
          type = "app";
          program = "${(pkgsFor system).gemini-cli}/bin/gemini";
        };
        default = gemini-cli;
      });

      devShells = eachSystem (system: {
        default = (pkgsFor system).mkShell {
          packages = with (pkgsFor system); [ nixpkgs-fmt jq curl ];
        };
      });
    };
}
