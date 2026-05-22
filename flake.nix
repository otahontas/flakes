{
  description = "pi extensions packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          pi-mcp-adapter = pkgs.callPackage ./packages/pi-mcp-adapter/package.nix { };
          pi-web-access = pkgs.callPackage ./packages/pi-web-access/package.nix { };
          pi-subagents = pkgs.callPackage ./packages/pi-subagents/package.nix { };
          pi-ralph-loop = pkgs.callPackage ./packages/pi-ralph-loop/package.nix { };
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ nodejs jq ];
          };
        });
    };
}
