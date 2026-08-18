{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = {nixpkgs, ...}: let
    forAllSystems = fn:
      nixpkgs.lib.genAttrs nixpkgs.lib.platforms.linux (
        system: fn system nixpkgs.legacyPackages.${system}
      );
  in {
    packages = forAllSystems (_: pkgs: rec {
      snippy = pkgs.callPackage ./nix {};
      default = snippy;
    });

    devShells = forAllSystems (_: pkgs: {
      default = import ./shell.nix {
        inherit pkgs;
      };
    });
  };
}
