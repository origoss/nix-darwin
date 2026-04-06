# Project Requirements and Tooling

* **Target Architecture:** This configuration targets ARM-based Mac machines (**`aarch64-darwin`** / Apple Silicon). Hostname: `Eriks-MacBook-Pro-2`, user: `eja`.
* **Core Tooling:** We use **Nix** with **Nix Flakes** and **nix-darwin** for system configuration.
* **nixpkgs channel:** Tracking `nixpkgs-unstable`.
* **Applying Changes:** To build and apply the configuration, run at the project root:
  ```
  darwin-rebuild switch --flake .#Eriks-MacBook-Pro-2
  ```
* **Dry-run / validate:** To check the build without switching:
  ```
  darwin-rebuild build --flake .#Eriks-MacBook-Pro-2
  ```
* **Updating Dependencies:** Run `nix flake update` to update the flake lock file.

## Module Structure

* `modules/darwin/` — system-level configuration (nix-darwin)
* `modules/home/home.nix` — user-level configuration (home-manager)

## Key Inputs

* **home-manager** — manages user environment and dotfiles; configured via `modules/home/home.nix`.
* **nix-homebrew** — Homebrew is managed **declaratively** with locked taps (`mutableTaps = false`). Do **not** run `brew install` directly; add packages in the nix config instead.
* **mac-app-util** — integrates nix-managed apps with macOS Spotlight and Launchpad.
