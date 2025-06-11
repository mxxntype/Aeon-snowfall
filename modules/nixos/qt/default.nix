{ config, lib, ... }: with lib;

{
    config = mkIf (config.home-manager.users |> builtins.hasAttr "${aeon.user}") {
        # HACK: Every day we stray further from god.
        # Quickshell needs Qt (because its based on it), and I don't really want to mess
        # with Qt any extra time, so its enabled only if Quickshell is.
        # TODO: Maybe it should just stay enabled at all times.
        qt.enable = config.home-manager.users.${aeon.user}.aeon.desktop.quickshell.enable;
    };
}
