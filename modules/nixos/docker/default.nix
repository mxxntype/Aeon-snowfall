# INFO: Docker module for NixOS.

{
    pkgs,
    lib,
    config,
    ...
}:

with lib; {
    options.aeon = {
        docker = {
            enable = mkOption {
                type = with types; bool;
                default = false;
                description = "Whether to enable the Docker daemon";
            };

            implementation = mkOption {
                type = with types; enum [ "docker" "podman" "both" ];
                default = "docker";
                description = "Whether to use Docker or Podman";
            };
        };
    };

    config = let
        inherit (config.aeon.docker)
            enable
            implementation
            ;
    in mkIf enable (mkMerge [
        {
            virtualisation.containers.enable = true;
            environment.systemPackages = with pkgs; [
                dive # A tool for exploring each layer in a docker image.
            ];

            # INFO: Some large docker deployments, like Elastic or Wazuh, need this.
            #
            # NOTE: The NixOS LXD/LXC module also sets this, to the same value of 262144.
            # I'm not sure which of the two should take precedence, but since the value
            # is the same, I'll force it here and forget about it.
            boot.kernel.sysctl."vm.max_map_count" = lib.mkForce 262144;
        }

        (mkIf (implementation == "docker" || implementation == "both") {
            virtualisation.docker.enable = true;
            environment.systemPackages = with pkgs; [
                docker-compose # Docker CLI plugin to define and run multi-container applications with Docker.
            ];
        })

        (mkIf (implementation == "podman" || implementation == "both") {
            virtualisation.podman = {
                enable = true;

                # Create a `docker` alias for podman, to use it as a drop-in replacement.
                # dockerCompat = true;

                # Make the Podman socket available in place of the Docker socket, so Docker
                # tools can find the Podman socket (Podman implements the Docker API).
                # Users must be in the `podman` group in order to connect to the socket.
                # WARN: As with Docker, members of this group can gain root access.
                # dockerSocket.enable = true;

                # Required for containers under podman-compose to be able to talk to each other.
                defaultNetwork.settings.dns_enabled = true;
            };

            environment.systemPackages = with pkgs; [
                podman-compose # An implementation of docker-compose with podman backend.
                podman-tui     # Podman Terminal UI.
            ];
        })
    ]);
}
