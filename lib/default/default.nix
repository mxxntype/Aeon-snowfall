{
    inputs,
    ...
}: let
    nix-std = builtins.attrValues inputs.nix-std.lib;
in rec {
    inherit nix-std;

    # I change my username from time to time, An because some NixOS
    # options inherit from from my Home-manager options, I think
    # it's quite reasonable to have my username declared as a variable.
    user = "mxxntype";

    # I don't store my config in /etc/nixos.
    flakePath = "/home/${user}/Aeon";

    # The name of the persistent volume, so I never mess it up.
    persist = "/persist";

    # SSH (and other?..) public keys, so I also never mess them up. Also,
    # should I make a new private key, this would make it much easier to
    # quickly update the public ones everywhere too.
    pubKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvBw3klXzVq5oTXtS061cfcGEjHWflPZNRBRg48N3w/ astrumaureus@Nox"
    ];
}
