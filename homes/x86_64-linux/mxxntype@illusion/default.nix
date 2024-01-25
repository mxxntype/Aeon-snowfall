{
    config,
    lib,
    ...
}:

{
    aeon = {
        style.codename = "overgrowth";
    };

    home = {
        homeDirectory = "/home/${config.home.username}";
        stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
    };
}

