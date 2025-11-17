{ config, lib, ... }:

{
    options.aeon.observability.nix = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };
    };

    config = lib.mkIf config.aeon.observability.nix.enable {
        environment.etc."nix/observability.json".text = let
            packageListToMetadata = packages:
                packages |> builtins.map (package: {
                    storePath = package;
                    pname = package.pname or package.name or null;
                    version = package.version or "unknown";
                });
        in builtins.toJSON {
            packages = rec {
                system = config.environment.systemPackages |> packageListToMetadata;
                user = config.home-manager.users."${lib.aeon.user}".home.packages |> packageListToMetadata;
                merged = system ++ user;
            };

            network.firewall = let
                inherit (config.networking.firewall)
                    allowedTCPPorts
                    allowedTCPPortRanges
                    allowedUDPPorts
                    allowedUDPPortRanges
                    ;
                rangesToList = ranges: ranges |> builtins.map (range: "${toString range.from}-${toString range.to}");
                tcpEntries = allowedTCPPorts ++ rangesToList allowedTCPPortRanges;
                udpEntries = allowedUDPPorts ++ rangesToList allowedUDPPortRanges;
            in
                (tcpEntries |> builtins.map (entry: { protocol = "tcp"; inherit entry; })) ++
                (udpEntries |> builtins.map (entry: { protocol = "udp"; inherit entry; }));
        };
    };
}
