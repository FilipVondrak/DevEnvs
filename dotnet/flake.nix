{
  description = "C# development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
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

        combined-dotnet = pkgs.dotnetCorePackages.combinePackages [
          pkgs.dotnet-sdk_10
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
