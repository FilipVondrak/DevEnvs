{
  description = "C# development environment";

  inputs = {
    # currently latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # reference to older specific commit containing dotnet 10.0.101 due to IDE compatibility
    nixpkgs-dotnet10.url = "github:NixOS/nixpkgs/f665af0cdb70ed27e1bd8f9fdfecaf451260fc55";
  };

  outputs = { self, nixpkgs, nixpkgs-dotnet10, ... } @ inputs:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system: let
        pkgs = import nixpkgs { inherit system; };
        pkgs10 = import nixpkgs-dotnet10 { inherit system; };

        combined-dotnet = pkgs.dotnetCorePackages.combinePackages [
          pkgs10.dotnet-sdk_10
          pkgs.dotnet-sdk_9
        ];

        in {
          default = pkgs.mkShell {
            name = "dotnet-mono-shell";

            packages = [
              combined-dotnet
              pkgs.mono
            ];

            shellHook = ''
              export DOTNET_ROOT=${combined-dotnet}
            '';
          };
        }
      );
    };
}
