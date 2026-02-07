# INFO: A script to get the current wattage of the system.

{ pkgs, ... }:

pkgs.nuenv.writeScriptBin {
    name = "powerdrain";
    script = /* nu */ ''
        const bat: string = "/sys/class/power_supply/BAT0"
        const K: int = 1000000000000

        if ($bat | path exists) {
            let current: int = (open $"($bat)/current_now" | into int)
            let voltage: int = (open $"($bat)/voltage_now" | into int)
            let power = ($current * $voltage / $K)
            $power | into int
        } else { "N/A" }
    '';
}
