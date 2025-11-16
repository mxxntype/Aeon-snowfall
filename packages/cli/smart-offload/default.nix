# INFO: A script to Run commands on the NVIDIA GPU if possible.

{ pkgs, ... }:

pkgs.nuenv.writeScriptBin {
    name = "smart-offload";
    script = /* nu */ ''
        # Run commands on the NVIDIA GPU if possible.
        def main --wrapped [
            ...rest # The command to try to offload.
        ]: nothing -> nothing {
            let prefix: string = match (which nvidia-offload | is-empty) {
                false => "nvidia-offload ",
                true => ""
            }
            let command: string = $"($prefix)($rest | str join (char space))"
            print $"(ansi magenta)smart-offload:(ansi reset) Running (ansi {fg: cyan, bg: dark_gray}) ($command) (ansi reset)"
            exec ${pkgs.bash}/bin/bash -c $command
        }
    '';
}
