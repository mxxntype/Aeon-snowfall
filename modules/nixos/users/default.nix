{
    config,
    lib,
    ...
}:

with lib; {
    config = mkIf (config.home-manager.users |> builtins.hasAttr "${aeon.user}") {
        users.users = {
            ${aeon.user} = {
                hashedPasswordFile = config.sops.secrets."passwords/user".path;
                openssh.authorizedKeys.keys = aeon.pubKeys;
                extraGroups = [
                    "wheel"
                    "video"
                    "audio"
                    "input"
                ] ++ ([
                    "networkmanager"
                    "docker"
                    "podman"
                    "git"
                    "libvirtd"
                ] |> builtins.filter (G: builtins.hasAttr G config.users.groups));

                # INFO: systemd user units will start at boot, rather than starting
                # at login and stopping at logout. This is the declarative equivalent
                # of running loginctl enable-linger for this user.
                linger = true;
            };
        };

        sops.secrets."passwords/user".neededForUsers = true;
    };
}
