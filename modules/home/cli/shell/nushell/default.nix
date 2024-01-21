# INFO: Nushell Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.cli.shell.nushell = {
        enable = mkOption {
            description = "Whether to enable Nushell, a new type of shell";
            type = types.bool;
            default = true;
        };
    };
    
    config = mkIf config.aeon.cli.shell.nushell.enable {
        programs = {
            nushell = {
                enable = true;
                package = pkgs.nushellFull;
                shellAliases = {
                    lsa = "ls -a";
                    cat = "${pkgs.bat}/bin/bat";
                    btm = "${pkgs.bottom}/bin/btm --battery";
                    ip = "ip --color=always";
                    duf = "${pkgs.duf}/bin/duf -theme ansi";
                    # tree = "erd --config tree";
                    # sz = "erd --config sz";
                };

                envFile.text = /* nu */ ''
                    $env.LS_COLORS = "${config.aeon.theme.cli.ls}"

                    # Autostart an SSH agent and don't start more than one of it.
                    let ssh_agent_env_path = $"/tmp/ssh-agent-($env.USER).nuon"
                    if ($ssh_agent_env_path | path exists) and ($"/proc/(open $ssh_agent_env_path | get SSH_AGENT_PID)" | path exists) {
                        load-env (open $ssh_agent_env_path)
                    } else {
                        ^ssh-agent -c
                            | lines
                            | first 2
                            | parse "setenv {name} {value};"
                            | transpose -r
                            | into record
                            | save --force $ssh_agent_env_path
                        load-env (open $ssh_agent_env_path)
                    }

                    # If no keys are added, prompt to add one ASAP.
                    let added_keys_count = ssh-add -l | lines | enumerate | where item =~ SHA | length
                    if $added_keys_count == 0 {
                        ssh-add
                    }
                '';
            };

            # TODO: Multi-shell multi-command argument completer.
            # carapace.enable = true;
        };
    };
}
