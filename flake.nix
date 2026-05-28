{
  description = "Mini SWE Agent - A simple AI software engineering agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        python = pkgs.python312;

        mini-swe-agent = python.pkgs.buildPythonPackage rec {
          pname = "mini-swe-agent";
          version = "2.3.0";
          pyproject = true;

          src = ./.;

          build-system = [ python.pkgs.setuptools ];

          dependencies = with python.pkgs; [
            pyyaml
            requests
            jinja2
            pydantic
            litellm
            tenacity
            rich
            python-dotenv
            typer
            platformdirs
            textual
            prompt-toolkit
            datasets
            openai
          ];

          # No tests in the build environment (network access, etc.)
          doCheck = false;

          meta = {
            description = "Mini SWE Agent - A simple AI software engineering agent";
            homepage = "https://github.com/SWE-agent/mini-swe-agent";
            license = pkgs.lib.licenses.mit;
            mainProgram = "mini";
          };
        };
      in
      {
        packages = {
          default = mini-swe-agent;
          mini-swe-agent = mini-swe-agent;
        };

        apps = {
          default = {
            type = "app";
            program = "${mini-swe-agent}/bin/mini";
          };
          mini = {
            type = "app";
            program = "${mini-swe-agent}/bin/mini";
          };
          mini-swe-agent = {
            type = "app";
            program = "${mini-swe-agent}/bin/mini-swe-agent";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python
            uv
          ];

          shellHook = ''
            echo "🛠️  mini-swe-agent dev shell"
            echo "   Run 'mini' or 'mini-swe-agent' after installing with: uv pip install -e ."
          '';
        };
      }
    );
}
