{ ... }:

{
    aeon = {
        desktop.hyprland = {
            enable = true;
            source = "nixpkgs";
        };
        style.codename = "evangelion";
    };

    # WARN: Changing this might break things. Just leave it.
    # The sole legit reason to change this is a reinstallation.
    home.stateVersion = "24.05";
}
