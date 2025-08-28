# INFO: "Unstable" nixpkgs overlay.
#
# This overlay replaces certain packages with their versions from nixpkgs/nixos-unstable,
# which allows us to have a "stable" system with only select stuff pulled in from the
# bleeding-edge `nixos-unstable` branch of nixpkgs. All in one overlay, because why not.
#
# NOTE: Channels are named after nixpkgs instances in your flake inputs. For example, with
# the input `nixpkgs` there will be a channel available at `channels.nixpkgs`. These
# channels are system-specific instances of nixpkgs that can be used to quickly pull
# packages into your overlay. All other arguments for this function are flake inputs.

{
    channels,
    ...
}:

_final: _prev: {
    inherit (channels.unstable)
        # atuin # BUG: Nix store collision...
        OVMF
        OVMFFull
        alacritty
        anytype
        binsider
        cargo-unfmt
        cargo-wizard
        direnv
        dua
        gitoxide
        glab
        helix
        helix-gpt
        hyprland
        hyprlandPlugins
        jujutsu
        kitty
        marksman
        matugen
        nh
        nix-direnv
        nushell
        pastel
        prettypst
        prismlauncher
        qemu
        rust-motd
        rustscan
        tailscale
        tailscaled
        tracy
        uv
        vesktop
        wezterm
        ytdownloader
        zellij
        ;
}
