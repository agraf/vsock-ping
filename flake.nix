{
  description = "Vsock ping tool";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nitro-util.url = "github:/monzo/aws-nitro-util";
    nitro-util.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nitro-util }:
    let
      arch = "x86_64"; # stdenv.hostPlatform.uname.processor;
      system = "${arch}-linux";
      nitro = nitro-util.lib.${system};
      eifArch = "${arch}";
      pkgs = nixpkgs.legacyPackages."${system}";
      npkgs = import nixpkgs { inherit system; };

      vsock_ping =
        # with import nixpkgs { inherit system; };
        npkgs.stdenv.mkDerivation {
          name = "vsock_ping";
          src = self;
          buildInputs = [ npkgs.musl ];
          installPhase = ''
            mkdir -p $out/bin
            make CC=musl-gcc
            cp vsock_ping $out/bin
          '';
        };

      runSh = npkgs.writeShellScriptBin "run.sh" ''
        /bin/vsock_ping 3 8000 0 10 >/dev/null
      '';

      outputs = {
        packages.x86_64-linux.vsock_ping = vsock_ping;

        packages.x86_64-linux.vsock_ping_eif = nitro.buildEif {
          name = "vsock_ping_eif";

          # use AWS' nitro-cli binary blobs
          inherit (nitro.blobs.${eifArch}) kernel kernelConfig nsmKo;

          arch = eifArch;

          entrypoint = ''
            /bin/run.sh
          '';
          env = "";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ runSh vsock_ping npkgs.busybox ];
            pathsToLink = [ "/bin" ];
          };
        };

        packages.x86_64-linux.default = pkgs.symlinkJoin {
          name = "vsock-tools";
          paths = [
            outputs.packages.x86_64-linux.vsock_ping
            outputs.packages.x86_64-linux.vsock_ping_eif
          ];
        };
      };
    in
    outputs;
}
