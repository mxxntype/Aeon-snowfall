# INFO: A script to get the current charge level of the system.

{ pkgs, ... }:

pkgs.nuenv.writeScriptBin {
    name = "battery-charge-level";
    script = /* nu */ ''
        const bat: string = "/sys/class/power_supply/BAT0"
        if ($bat | path exists) {
            let current: int = (open $"($bat)/charge_now"  | into int)
            let full: int = (open $"($bat)/charge_full" | into int)
            let charge_percent = $current / $full * 100
            $charge_percent | into int
        } else { "N/A" }
    '';
}
