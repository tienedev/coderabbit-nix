{
  description = "Nix flake for CodeRabbit CLI — AI-powered code review from the command line";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wrap-buddy = {
      url = "github:Mic92/wrap-buddy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, wrap-buddy }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          wrapBuddy = if pkgs.stdenv.hostPlatform.isLinux
            then wrap-buddy.packages.${system}.wrapBuddy
            else null;
        in {
          coderabbit = pkgs.callPackage ./package.nix {
            inherit wrapBuddy;
          };
          default = self.packages.${system}.coderabbit;
        }
      );

      overlays.default = final: prev: {
        coderabbit = self.packages.${final.stdenv.hostPlatform.system}.default;
      };

      homeManagerModules.default = { pkgs, ... }: {
        home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      };
    };
}
