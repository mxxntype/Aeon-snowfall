{ pkgs, lib, ... }: let

recursiveDerivations = { maybe_drv, package_group ? null }:
    assert builtins.isAttrs maybe_drv;
    if maybe_drv ? "type" && maybe_drv.type == "derivation"
    then [ (maybe_drv // { group = null; }) ]
    else maybe_drv
        |> builtins.attrNames
        |> builtins.map (attr_name: rec {
            inherit ((builtins.tryEval maybe_drv.${attr_name})) success;
            package = if success then maybe_drv.${attr_name} else null;
        })
        |> builtins.filter (item: item.success)
        |> builtins.filter (item: builtins.isAttrs item.package)
        |> builtins.map (item: item.package // { group = package_group; })
        # |> builtins.map recursiveDerivations
        |> lib.flatten;

# HACK: Replace the declaration below for quick test runs.
# toplevelNames = [ "hyprland" "hyprlandPlugins" ];

toplevelNames = pkgs
    |> builtins.attrNames
    |> builtins.filter (name: name != "__splicedPackages" && name != "buildPackages" && ((builtins.substring 0 4 name) != "pkgs"))
    |> lib.unique;

evaluated = toplevelNames
    |> builtins.map (toplevelName: rec {
        inherit toplevelName;
        inherit ((builtins.tryEval pkgs.${toplevelName})) success;
        package = if success then pkgs.${toplevelName} else null;
    })
    |> builtins.filter (item: item.success)
    |> builtins.filter (item: builtins.isAttrs item.package)
    |> builtins.map (item: builtins.warn "Un-nesting `pkgs.${item.toplevelName}`" recursiveDerivations { maybe_drv = item.package; package_group = item.toplevelName; })
    |> lib.flatten;

with_src = evaluated
    |> builtins.filter (drv: drv ? "src" && (builtins.tryEval drv.src).success);

with_url = with_src
    |> builtins.filter (drv: let eval = builtins.tryEval (drv.src ? "url"); in eval.success && eval.value);

tryAccessField = set: field: set."${field}" or null;

in pkgs.writeTextFile {
    name = "nixpkgs-packages.json";
    text = builtins.toJSON {
        statistics = {
            evaluated = evaluated |> builtins.length;
            with_src = with_src |> builtins.length;
            with_url = with_url |> builtins.length;
        };

        packages = with_src |> builtins.map (package: let
            name = if package ? "pname" then package.pname else if package ? "name" then package.name else "unknown";
        in {
            name = if package.group == null then name else "${package.group}.${toString name}";

            version = tryAccessField package "version";
            url = tryAccessField package.src "url";
            git = tryAccessField package.src "gitRepoUrl";
        });
    };
}
