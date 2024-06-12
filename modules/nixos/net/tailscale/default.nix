# INFO: DNCrypt-proxy2 NixOS module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.net.tailscale = {
        enable = mkOption {
            description = "Whether to connect the device to Tailscale";
            type = with types; bool;
            default = true;
        };

        useAuthKey = mkOption {
            description = "Whether to auto-authenticate using a key";
            type = with types; bool;
            default = true;
        };

        ACLtags = mkOption {
            description = "What ACL tags to request from the admin panel";
            type = with types; listOf str;
            default = [ ];
        };

        # INFO: https://tailscale.com/kb/1103/exit-nodes
        advertiseExitNode = mkOption {
            description = "Whether to make this device an exit node";
            type = with types; bool;
            default = false;
        };

        exitNode = mkOption {
            description = "What exit node to connect this device to. Leave empty to keep disabled";
            type = with types; str;
            default = "";
        };

        # TODO: Add subnet router configuration options.
        # INFO: https://tailscale.com/kb/1019/subnets
    };

    config = let
        inherit (config.aeon.net.tailscale)
            enable
            useAuthKey
            ACLtags
            advertiseExitNode
            exitNode
            ;
        tailnet = "raven-mixolydian.ts.net";
        exit_node = rec {
            server = advertiseExitNode;
            client = exitNode != "";
            hostname = if client then exitNode else null;
        };
    in mkIf enable {
        services.tailscale = mkMerge [
            {
                enable = true;
                openFirewall = true;

                # INFO: Enables settings required for features like subnet routers and exit nodes.
                # To use these these features, you will still need to call `sudo tailscale up`
                # with the relevant flags like `--advertise-exit-node` and `--exit-node`. (See below)
                #
                # When set to "client" or "both", reverse path filtering will be set to loose instead of strict.
                # When set to "server" or "both", IP forwarding will be enabled.
                useRoutingFeatures =
                    if exit_node.server && exit_node.client then "both"
                    else if exit_node.server then "server"
                    else if exit_node.client then "client"
                    else "none";

                extraUpFlags = [
                    "--operator=${lib.aeon.user}" # Allow me to manage `tailscaled` without `sudo`.
                    "--advertise-tags=${builtins.concatStringsSep "," (builtins.map (tag: "tag:${tag}") ACLtags)}"
                    "--exit-node=${if (exit_node.client) then "$(${pkgs.dig}/bin/dig ${exit_node.hostname}.${tailnet} A +short | head -n 1)" else ""}"
                    "--exit-node-allow-lan-access=${if exit_node.client then "true" else "false"}"
                    (mkIf exit_node.server "--advertise-exit-node")
                ];
            }

            (mkIf useAuthKey {
                authKeyFile = config.sops.secrets."keys/tailscale".path;
            })
        ];

        # Only make the auth key appear if it's used.
        sops.secrets = mkIf useAuthKey {
            "keys/tailscale" = { };
        };
    };
}
