{
  description = "Terraform GitHub Constructor dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "terraform" ];
          };

          devPackages = with pkgs; [
            bashInteractive
            zsh
            zsh-completions
            zsh-autosuggestions
            zsh-syntax-highlighting
            coreutils
            gnugrep
            gnutar
            gzip
            gnused
            curl
            gitMinimal
            gh
            cacert
            ripgrep
            unzip
            checkov
            tflint
            terraform
          ];
        in
        {
          default = pkgs.dockerTools.buildLayeredImage {
            name = "repository-constructor";
            tag = "latest";
            contents = pkgs.buildEnv {
              name = "image-root";
              paths = devPackages;
              pathsToLink = [ "/bin" "/etc" "/lib" "/share" ];
            };
            fakeRootCommands = ''
              mkdir -p ./home/user ./workspaces ./tmp ./lib
              chmod 1777 ./tmp
              echo "user:x:1000:1000::/home/user:/bin/zsh" >> ./etc/passwd
              echo "user:x:1000:" >> ./etc/group
              chown 1000:1000 ./home/user
              chmod 755 ./home/user
              for f in ${pkgs.glibc}/lib/ld-linux*.so*; do
                ln -sf "$f" ./lib/$(basename "$f")
              done
            '';
            config = {
              Env = [
                "LANG=C.UTF-8"
                "LANGUAGE=C.UTF-8"
                "LC_ALL=C.UTF-8"
                "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
                "HOME=/home/user"
              ];
              User = "1000:1000";
              Cmd = [ "/bin/zsh" ];
            };
          };
        }
      );
    };
}
