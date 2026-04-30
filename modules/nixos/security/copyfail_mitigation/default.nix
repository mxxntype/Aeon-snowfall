# Mitigation for CVE-2026-31431 ("CopyFail"), ensures the vulnerable kernel module isn't loaded.

_: {
    # SOURCE: https://copy.fail/#mitigation
    config.boot.blacklistedKernelModules = [ "algif_aead" ];
}
