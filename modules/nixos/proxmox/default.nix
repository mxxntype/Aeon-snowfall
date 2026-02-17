{ inputs, config, pkgs, lib, ... }:

{
    options.aeon.proxmox = {
        enable = lib.mkEnableOption "Proxmox VE";
    };

    config = let cfg = config.aeon.proxmox;
    in lib.mkIf cfg.enable {
        services.proxmox-ve = {
            enable = true;
            ipAddress = "10.160.0.1";
        };

        nixpkgs.overlays = [ inputs.proxmox-nixos.overlays.${pkgs.stdenv.hostPlatform.system} ];
    };
}
