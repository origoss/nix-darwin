# Project Requirements and Tooling

* **Target Architecture:** This configuration targets ARM-based Mac machines (**`aarch64-darwin`** / Apple Silicon). Hostname: `Eriks-MacBook-Pro-2`, user: `eja`.
* **Core Tooling:** We use **Determinate Nix** with **Nix Flakes** and **nix-darwin** for system configuration.
* **nixpkgs channel:** Tracking `nixpkgs-unstable`.
* **Nix Daemon:** Managed by **Determinate Nix** (not nix-darwin). The config has `nix.enable = false` to avoid conflicts.
* **Applying Changes:** To build and apply the configuration, run at the project root (requires sudo):
  ```
  sudo darwin-rebuild switch --flake .#Eriks-MacBook-Pro-2
  ```
  Or with askpass helper:
  ```
  SUDO_ASKPASS=/tmp/askpass.sh sudo -A darwin-rebuild switch --flake .#Eriks-MacBook-Pro-2
  ```
* **Dry-run / validate:** To check the build without switching:
  ```
  darwin-rebuild build --flake .#Eriks-MacBook-Pro-2
  ```
* **Updating Dependencies:** Run `nix flake update` to update the flake lock file.

## Module Structure

* `modules/darwin/` — system-level configuration (nix-darwin)
  * `modules/darwin/settings/` — system settings, packages, environment
  * `modules/darwin/homebrew/` — homebrew configuration (casks, brews, masApps)
  * `modules/darwin/services/` — system services (direnv, emacs)
* `modules/home/home.nix` — user-level configuration (home-manager)
  * Manages zsh (oh-my-zsh, autosuggestions, syntax highlighting)
  * Editor: `vim` for SSH connections, `hx` (helix) for local usage
  * Aerospace tiling window manager configuration

## Key Inputs

* **home-manager** — manages user environment and dotfiles; configured via `modules/home/home.nix`.
  * ZSH configuration is **fully managed** by home-manager (do not edit `~/.zshrc` directly)
  * Features enabled: oh-my-zsh, autosuggestions, syntax highlighting, completions
* **nix-homebrew** — Homebrew is managed **declaratively** with locked taps (`mutableTaps = false`). Do **not** run `brew install` directly; add packages in the nix config instead.
  * Cleanup strategy: `uninstall` (removes packages not in config)
* **mac-app-util** — integrates nix-managed apps with macOS Spotlight and Launchpad.

## Important Notes

* **Manual edits will be lost:** Files managed by home-manager (like `~/.zshrc`) are symlinks to the Nix store. Edit the source configuration files instead.
* **Determinate Nix:** This system uses Determinate Nix, so nix-darwin's Nix management is disabled (`nix.enable = false`).
* **Binary Cache:** Configured to use nix-community cachix for faster builds.
