# INFO: NixOS module for setting up VFIO (PCI/GPU passthrough).
#
# Most of this is stolen from https://astrid.tech/2022/09/22/0/nixos-gpu-vfio.

{
    config,
    lib,
    ...
}:

with lib;

{
    options.aeon.hardware.vfio = {
        enable = mkOption {
            type = with types; bool;
            default = false;
        };

        # NOTE: To figure what IDs you need, use the `iommugroups.sh` tool provided by this flake.
        # An IOMMU group is basically "the smallest set of devices that can be passed to a VM".
        # Find the group that contains your GPU, for example (take from https://astrid.tech/2022/09/22/0/nixos-gpu-vfio):
        #
        # IOMMU Group 2:
	    #     ...
	    #     07:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA104 [GeForce RTX 3070 Ti] [10de:2482] (rev a1)
	    #     07:00.1 Audio device [0403]: NVIDIA Corporation GA104 High Definition Audio Controller   [10de:228b] (rev a1)
        #                                                                                               ^^^^^^^^^
        #                                                                                          These are the PCI IDs.
        # You can also find the relevant PCI IDs by running `lspci -nn | grep -i nvidia`:
        #
        # 07:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA104 [GeForce RTX 3070 Ti] [10de:2482] (rev a1)
        # 07:00.1 Audio device [0403]: NVIDIA Corporation GA104 High Definition Audio Controller   [10de:228b] (rev a1)
        #                                                                                           ^^^^^^^^^
        #                                                                                           This stuff
        # By adding PCI IDs to this option, the system will isolate the devices with those
        # IDs, allowing them to be used in VMs but making them invisible to the host system.
        pciIDs = mkOption {
            type = with types; listOf str;
        };
    };

    config = let
        inherit (config.aeon.hardware.vfio)
            enable
            pciIDs
            ;
    in mkIf enable {
        # NOTE: Enable kernel support for IOMMU.
        # This is needed for PCI (GPU) passthrough.
        boot.kernelParams = [
            "intel_iommu=on"
            "vfio-pci.ids=${concatStringsSep "," pciIDs}"
        ];

        # WARN: It it important to have the VFIO modules before the Nvidia ones,
        # because otherwise the Nvidia modules are the first to claim the GPU.
        boot.initrd.kernelModules = [
            "vfio_pci"
            "vfio"
            "vfio_iommu_type1"
            "vfio_virqfd"

            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
        ];

        # NOTE: OpenGL is obvious, and SPICE redirection lets you essentially
        # hotplug USB keyboards, mice, storage, etc. from the host into VMs.
        hardware.opengl.enable = true;
        virtualisation.spiceUSBRedirection.enable = true;
     };
}
