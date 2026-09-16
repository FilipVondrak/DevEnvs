{
  description = "Python development environment";

  inputs = {
    # currently latest packages
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

        in {
          default = pkgs.mkShell {
            name = "Python venv shell";

            packages = [
              pkgs.python3
              pkgs.python3Packages.pip
              pkgs.python3Packages.virtualenv
            ];

            shellHook = ''
              echo "Python shell loaded!"

              # Create virtual environment if it doesn't exist
              if [ ! -d ".venv" ]; then
                echo "Creating new virtual environment..."
                python -m venv .venv
              fi

              # Activate the environment
              source .venv/bin/activate

              echo "Python is located at $(which python)"

              # Install packages if requirements.txt exists
              if [ -f "requirements.txt" ]; then
                echo "Installing requirements..."
                pip install -q -r requirements.txt
              else
                echo "Creating default requirements.txt..."
                touch requirements.txt
                echo "jupyter" >> requirements.txt
                echo "matplotlib" >> requirements.txt
                pip install -r requirements.txt
              fi
            '';
          };
        }
      );
    };
}
