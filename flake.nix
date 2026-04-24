{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    kiorg = {
      url = "github:scottmckendry/kiorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, niri, kiorg, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        niri = niri.packages.${system}.niri;
        kiorg = kiorg.packages.${system}.default;
        # TODO: add more packages here
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ ];
      };
    };
}
