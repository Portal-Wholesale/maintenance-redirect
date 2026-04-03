{
  description = "Portal maintenance redirect page";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenvNoCC.mkDerivation {
          pname = "portal-maintenance-redirect";
          version = "0.1.0";
          src = ./.;
          installPhase = ''
            mkdir -p $out
            cp index.html $out/
          '';
        };
      });
    };
}
