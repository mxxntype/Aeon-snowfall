# INFO: NixOS GPU module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.hardware.gpu = {
        core.enable = mkOption {
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

        specialise = mkOption {
            description = "Whether to split iGPU/dGPU specialisations";
            type = with types; bool;
            default = false;
        };
    };

    config = let
        nvidiaConfig = {
            services.xserver.videoDrivers = mkBefore [ "nvidia" ];
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
        };
        inherit (config.aeon.hardware.gpu)
            core
            intel
            nvidia
            specialise
            ;
    in mkMerge [
        (mkIf core.enable {
            # Exclude `nvtop` from minimal systems.
            environment.systemPackages = with pkgs; [ aeon.smart-offload ] ++
                (if !(builtins.elem config.networking.hostName [
                    "illusion"
                    "virus"
                ])
                    then [ (nvtopPackages.intel.override { nvidia = true; }) ]
                    else [ ]);
        })

        (mkIf intel.enable {
            services.xserver.videoDrivers = [ "intel" ];
            hardware = {
                graphics = {
                    enable = true;
                    enable32Bit = true;
                    extraPackages = with pkgs; [
                        intel-media-driver
                        vaapiIntel
                        vaapiVdpau
                        libvdpau-va-gl
                    ];
                };
            };
        })

        (mkIf (nvidia.enable && !specialise) nvidiaConfig)

        (mkIf (nvidia.enable && specialise) (mkMerge [
            # Create a dGPU spec with the necessary drivers.
            {
                specialisation."dGPU".configuration = mkMerge [
                    {
                        system.nixos.label = "${config.networking.hostName}-dGPU";
                    }
                    nvidiaConfig
                ];
            }

            # Disable the NVIDIA dGPU in the default specialisation.
            #
            # NOTE: Stolen from https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/nvidia/disable.nix
            # Tried to use an import, but conditional imports are a f**king nightmare, so just hardcode for now (forever).
            (mkIf (config.specialisation != { }) {
                boot = {
                    blacklistedKernelModules = [
                        "nouveau"
                        "nvidia"
                        "nvidia_drm"
                        "nvidia_modeset"
                    ];

                    extraModprobeConfig = ''
                        blacklist nouveau
                        options nouveau modeset=0
                    '';
                };
    
                system.nixos.label = "${config.networking.hostName}-iGPU";
                services.udev.extraRules = /* python */ ''
                    # Remove NVIDIA USB xHCI Host Controller devices, if present.
                    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
                    # Remove NVIDIA USB Type-C UCSI devices, if present.
                    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
                    # Remove NVIDIA Audio devices, if present.
                    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
                    # Remove NVIDIA VGA/3D controller devices.
                    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
                '';
            })
        ]))
    ];
}
