{
    config,
    ...
}:

{
    aeon = {
        style.codename = "overgrowth";
        desktop.hyprland.enable = true;
    };

    home = {
        homeDirectory = "/home/${config.home.username}";
        stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
    };
}

