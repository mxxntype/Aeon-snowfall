## `packages`

Here live packages I could not find in [`nixpkgs`](https://search.nixos.org/packages), and packaged myself for use in this flake. Also shell scripts like [`aeon`](https://github.com/mxxntype/Aeon-snowfall/blob/main/packages/cli/aeon/default.nix) and other misc stuff. Also, there are *many* packages which are defined like this:

```nix
{
    pkgs,
    ...
}

pkgs.package
```

These are just exposed outputs for systems that do not run this flake. Mostly not needed.
