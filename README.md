<h3 align="center"> 
    <img src="./.github/assets/nix-flake.png" width="250px"/>
</h3>
<h1 align="center">
    Aeon | <a href="https://nixos.org">NixOS</a> flake built with <a href="https://github.com/snowfallorg/lib">Snowfall</a> ⚜️ 
</h1>

<div align="center">
    <img alt="Static Badge" src="https://img.shields.io/badge/NixOS-24.05-d2a8ff?style=for-the-badge&logo=NixOS&logoColor=cba6f7&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/State-Forever_WIP-ff938c?style=for-the-badge&logo=fireship&logoColor=ff938c&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/Powered_by-Sleep_deprivation-79c0ff?style=for-the-badge&logo=nuke&logoColor=79c0ff&labelColor=161B22">
</div>

> [!TIP]
> No clue what this is and want to know more about NixOS? Read [here](#what-is-this-even), and be aware that this hell of a flake is probably not the place to start. I've mentioned the places and people that helped me understand the Nix ecosystem, explore those links if you wish to know more.

Here's a quick (and incomplete) tour of what is going on in the repository:

| Directory   | Purpose |
| ----------- | ------- |
| `modules/`  | Stores **NixOS** and **Home-manager** modules. These are the main building block: Every `system` receives the options these declare. |
| `systems/`  | Stores **NixOS** system configurations. These are also often called `hosts` |
| `homes/`    | Stores **Home-manager** configurations, which are associated with a `system` |
| `lib/`      | A shared library of functions and variables, available everywhere in the flake at `lib.aeon.*` |
| `packages/` | Packages I could not find in [`nixpkgs`](https://github.com/nixos/nixpkgs), and packaged myself for use in this flake. Also shell scripts like [`aeon`](https://github.com/mxxntype/Aeon-snowfall/blob/main/packages/aeon/default.nix) and other misc stuff. |
| `shells/`   | **Nix** shells for bootstrapping, etc. |

Others are not as important. [Snowfall Guide/Reference](https://snowfall.org/guides/lib/quickstart/)

---

### What is this even?

**Nix** is a purely functional programming language. It's not executed, it's *evaluated*. No matter how many times you evaluate a mathematical expression, the answer is always the same. Nix is exactly that - looks alien (just like math sometimes), but all it does is just *evaluate* to something - a string, a number, or an attrset.

**Nix** is also a powerful package manager (and a whole ecosystem) that makes package management reliable and reproducible. It uses a purely functional approach to package management - you don't run commands to interact with it, you write everything out as nix code, that the package manager takes as input and does things based on what's written. Each package is built in isolation from each other, and its dependencies are explicitly defined. This ensures a package build will always produce the same result, regardless of the system it's built on or the packages already installed on the system.

**NixOS** is a Linux distribution that builds on the ideas of Nix. In NixOS, the entire operating system - including the kernel, applications, system packages, configuration files, shell scripts, secrets and services - is defined via code. This allows thorough customization and reproducibility across different systems.

Why would anyone even bother with this? Well, declaring system configurations and packages as code in a modular way is amazing for several reasons. Stateless systems are cool, right? *NixOS treats the system's state as a function of its configuration.* This means that the system can be easily recreated from its configuration at any time, which has several benefits.

- **Reproducibility**: Since everything is declared in code, you can replicate your system configuration and package environment on another machine with minimal effort. This is what sealed the deal for me - NixOS *feels solid and permanent*. It's like using (or perhaps even more like making!) a reliable piece of software. If a Linux system can truly feel like home, NixOS is the one that does for me.

- **Isolation**: Packages are built in isolation from each other, and you can have different versions of stuff without any problems whatsoever. Read about ephemeral `nix shell`s if you'd like to see what this means in practice. Also, nix separates the system and the state it holds (like your docs, media and other things you probably don't version-control), and you decide where that line of separation is.

- **Atomicity**: Nix and NixOS support atomic upgrades and rollbacks. If a lockfile update or configuration change (or whatever else) breaks something, just `git reset` & rebuild and you're back to safety.

- **Maintenance**: The system's behavior is predictable because it's defined by its configuration, not by a series of imperative changes made over time. System maintenance is simplified because changes are made through code rather than imperative touches. Well... those changes are now made to the codebase, not to the system itself, but code is version-controlled, pure and provides an excellent view at the system, when you *know that the code is the system*.

### Inspiration and resources

- The [NixOS website](https://nixos.org) and the [wiki](https://nixos.wiki), also [mynixos.com](https://mynixos.com/) - a great search engine for options and packages
- Misterio77's [`nix-starter-configs`](https://github.com/Misterio77/nix-starter-configs) (great starting point) and [`nix-config`](https://github.com/Misterio77/nix-config)
- Jake Hamilton's [`config`](https://github.com/jakehamilton/config) and the [Snowfall](https://github.com/snowfallorg/lib) framework
- VimJoyer's [Youtube channel](https://www.youtube.com/channel/UC_zBdZ0_H_jn41FDRG7q4Tw) and [Github](https://github.com/vimjoyer)
