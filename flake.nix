{
  description = "Terraform GitHub Constructor dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            f (
              import nixpkgs {
                inherit system;
                config = {
                  allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "terraform" ];
                  # Required by checkov; ecdsa has an unfixed timing side-channel (CVE-2024-23342).
                  permittedInsecurePackages = [ "python3.14-ecdsa-0.19.2" ];
                };
                overlays = [
                  (_: prev: {
                    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                      (_: pyPrev: {
                        # checkov's closure is not in the binary cache, so this builds from
                        # source; its tests fail on Linux (unidiff parse errors).
                        bc-detect-secrets = pyPrev.bc-detect-secrets.overridePythonAttrs { doCheck = false; };
                      })
                    ];
                  })
                ];
              }
            )
          );
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            terraform
            tflint
            checkov
            nixfmt
            statix
            deadnix
            actionlint
          ];
        };
      });
    };
}
