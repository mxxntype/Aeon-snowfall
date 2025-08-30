{ config, lib, pkgs, ... }:

{
    options.aeon.hardware.gpu = {
        core.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };

        intel = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
            };
            busID = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
            };
        };

        amd = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
            };
            busID = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
            };
        };

        nvidia = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
            };
            busID = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
            };
        };

        specialise = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.hardware.gpu)
            core
            intel
            amd
            nvidia
            specialise
            ;
        nvidiaConfig = {
            services.xserver.videoDrivers = lib.mkBefore [ "nvidia" ];
            hardware.nvidia = {
                open = false;
                package = config.boot.kernelPackages.nvidiaPackages.stable;
                modesetting.enable = true;
                powerManagement.enable = true;
                prime = {
                    intelBusId = (lib.mkIf intel.enable intel.busID);
                    amdgpuBusId = (lib.mkIf amd.enable amd.busID);
                    nvidiaBusId = nvidia.busID;
                    offload = {
                        enable = true;
                        enableOffloadCmd = true;
                    };
                };
            };
        };
    in lib.mkMerge [
        (lib.mkIf core.enable {
            environment.systemPackages = with pkgs; [ aeon.smart-offload ] ++
                # Exclude `nvtop` from minimal systems.
                (if !(builtins.elem config.networking.hostName [ "illusion" "virus" ])
                    then [ nvtopPackages.full ]
                    else [ ]);
        })

        (lib.mkIf intel.enable {
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

        (lib.mkIf amd.enable {
            services.xserver.videoDrivers = [ "amdgpu" ];
            hardware.graphics = {
                enable = true;
                enable32Bit = true;
            };
        })

        (lib.mkIf (nvidia.enable && !specialise) nvidiaConfig)

        (lib.mkIf (nvidia.enable && specialise)
            (lib.mkMerge [
                # Create a dGPU spec with the necessary drivers.
                {
                    specialisation."dGPU".configuration = lib.mkMerge [
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
                (lib.mkIf (config.specialisation != { }) {
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
            ]
        ))
    ];
}
