# INFO: NixOS GPU module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.gpu = {
        core = mkOption {
            description = "Whether to add common GPU-related modules";
            type = with types; bool;
            default = true;
        };

        intel = {
            enable = mkOption {
                description = "Whether to support Intel graphics";
                type = with types; bool;
                default = true;
            };
            busID = mkOption {
                description = "Intel iGPU PCI bus ID";
                type = with types; nullOr str;
                default = null;
            };
        };

        nvidia = {
            enable = mkOption {
                description = "Whether to support NVIDIA graphics";
                type = with types; bool;
                default = false;
            };
            busID = mkOption {
                description = "NVIDIA dGPU PCI bus ID";
                type = with types; nullOr str;
                default = null;
            };
        };
    };

    config = let
        inherit (config.aeon.gpu)
            core
            intel
            nvidia
            ;
    in mkMerge [
        (mkIf core {
            # Exclude `nvtop` from minimal systems.
            environment.systemPackages = with pkgs; [ aeon.smart-offload ] ++
                (if (config.networking.hostName != "illusion")
                    then [ nvtop ]
                    else [ ]);
        })

        (mkIf intel.enable {
            services.xserver.videoDrivers = [ "intel" ];
            hardware = {
                opengl = {
                    enable = true;
                    driSupport = true;
                    driSupport32Bit = true;
                    extraPackages = with pkgs; [
                        intel-media-driver
                        vaapiIntel
                        vaapiVdpau
                        libvdpau-va-gl
                    ];
                };
            };
        })

        (mkIf nvidia.enable {
            services.xserver.videoDrivers = [ "nvidia" ];
            hardware.nvidia = {
                package = config.boot.kernelPackages.nvidiaPackages.stable;
                modesetting.enable = true;
                powerManagement.enable = true;
                prime = {
                    intelBusId = intel.busID;
                    nvidiaBusId = nvidia.busID;
                    offload = {
                        enable = true;
                        enableOffloadCmd = true;
                    };
                };
            };
        })
    ];
}
