<h3 align="center"> 
    <img src="./.github/assets/nix-flake.png" width="250px"/>
</h3>
<h1 align="center">
    Aeon | <a href="https://nixos.org">NixOS</a> flake built with <a href="https://github.com/snowfallorg/lib">Snowfall</a> ⚜️ 
</h1>

<div align="center">
    <img alt="Static Badge" src="https://img.shields.io/badge/NixOS-23.11-d2a8ff?style=for-the-badge&logo=NixOS&logoColor=cba6f7&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/State-Forever_WIP-ff7b72?style=for-the-badge&logo=fireship&logoColor=ff7b72&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/Powered_by-Sleep_deprivation-79c0ff?style=for-the-badge&logo=nuke&logoColor=79c0ff&labelColor=161B22">
</div>

> [!NOTE]
> This is a WIP rewrite of my [Aeon](https://github.com/mxxntype/Aeon) flake with the [Snowfall](https://github.com/snowfallorg/lib) framework. This is absolutely not backwards-compatible and actually a hell of a breaking change. Once the flake is at least somewhat complete and "ready", it will be merged with Aeon.

Here's a quick and incomplete tour of what is going on in the repository:

| Directory   | Purpose |
| ----------- | ------- |
| `modules/`  | Stores **NixOS** and **Home-manager** modules. These are the main building block: Every `system` receives the options these declare. |
| `systems/`  | Stores **NixOS** system configurations. These are also often called `hosts` |
| `homes/`    | Stores **Home-manager** configurations, which are associated with a `system` |
| `lib/`      | A shared library of functions and variables, available everywhere in the flake at `lib.aeon.*` |
| `packages/` | Packages I could not find in [`nixpkgs`](https://github.com/nixos/nixpkgs), and packaged myself for use in this flake. Also shell scripts like [`aeon`](https://github.com/mxxntype/Aeon-snowfall/blob/main/packages/aeon/default.nix) and other misc stuff. |
| `shells/`   | **Nix** shells for bootstrapping, etc. |

Others are not as important. [Snowfall Guide/Reference](https://snowfall.org/guides/lib/quickstart/)
