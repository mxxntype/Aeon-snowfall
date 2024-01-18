{
    config,
    lib,
    ...
}:

with lib; {
    config = {
        # Add the main user's SSH key if the user is present on the system.
        users.users = mkIf (builtins.hasAttr "${aeon.user}" config.home-manager.users) {
            ${aeon.user}.openssh = {
                authorizedKeys.keys = aeon.pubKeys;
            };
        };
    };
}
