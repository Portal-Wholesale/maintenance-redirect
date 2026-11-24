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

      checks = nixpkgs.lib.genAttrs systems (system: self.packages.${system} // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
        # Secret scan of the committed tree (no git history in the sandbox).
        gitleaks = let pkgs = nixpkgs.legacyPackages.${system}; in
          pkgs.runCommand "gitleaks" { nativeBuildInputs = [ pkgs.gitleaks ]; } ''
            export HOME="$TMPDIR" GOMAXPROCS="$NIX_BUILD_CORES"
            cd ${nixpkgs.lib.cleanSource ./.}
            gitleaks dir --no-banner --redact .
            touch $out
          '';
      });
    };
}
