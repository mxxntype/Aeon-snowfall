# INFO: Hyprland Home-manager module.

{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:

with lib; {
    # HACK: Here, because importing in flake.nix does not work.
    imports = with inputs; [ hyprland.homeManagerModules.default ];

    options.aeon.desktop.hyprland = {
        enable = mkOption {
            description = "Whether to enable and configure Hyprland";
            type = with types; bool;
            default = false;
        };

        # NOTE: Using `"nixpkgs"` will make Nix use the Nixpkgs-provided version of Hyprland.
        # Otherwise, Hyprland will come from flake's inputs (see flake.nix). That might cause
        # some extra building from source, however gives more control over versions of stuff.
        source = mkOption {
            type = with types; enum [ "nixpkgs" "git" ];
            default = "git";
        };
    };

    config = let
        inherit (config.aeon.desktop.hyprland)
            enable
            source
            ;
    in mkIf enable {
        wayland.windowManager.hyprland = {
            enable = true;
            package = if (source == "nixpkgs")
                      then pkgs.hyprland
                      else inputs.hyprland.packages.${pkgs.system}.default;

            settings = let
                MOD = "SUPER";
            in {
                bind = builtins.concatLists [
                    # General binds.
                    [
                        "${MOD} CTRL SHIFT, E, exit"
                    ]

                    # Generate bindings for switching or moving active window to a workspace.
                    (builtins.concatLists (builtins.genList (_ws: 
                        let ws = toString (_ws + 1); in [
                            "${MOD},       ${ws}, workspace,       ${ws}"
                            "${MOD} SHIFT, ${ws}, movetoworkspace, ${ws}"
                        ])
                        /* WORKSPACE_COUNT: */ 10))
                ];

                exec-once = [
                    "${pkgs.kitty}/bin/kitty"
                ];
            };

            plugins = if (source == "nixpkgs") then [
                pkgs.hyprlandPlugins.hy3
                pkgs.hyprlandPlugins.borders-plus-plus
            ] else [
                inputs.hyprland-hy3.packages.${pkgs.system}.hy3
                inputs.hyprland-plugins.packages.${pkgs.system}.borders-plus-plus
            ];
        };
    };
}
