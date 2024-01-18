{
    config,
    lib,
    ...
}:

let
    # Only add these groups if they are present to avoid clutter.
    ifPresent = with builtins;
        groups: filter (G: hasAttr G config.users.groups) groups;
in

with lib; {
    config = {
        users.users = mkIf (builtins.hasAttr "${aeon.user}" config.home-manager.users) {
            ${aeon.user} = {
                hashedPasswordFile = config.sops.secrets."passwords/user".path;
                openssh.authorizedKeys.keys = aeon.pubKeys;
                extraGroups = [
                    "wheel"
                    "video"
                    "audio"
                    "input"
                ] ++ ifPresent [
                    "networkmanager"
                    "docker"
                    "git"
                    "libvirtd"
                ];
            };
        };

        sops.secrets."passwords/user" = {
            sopsFile = ../../../lib/secrets.yaml;
            neededForUsers = true;
        };
    };
}
