{
  description = "Jose's Mac (popmart) - simple version";

  # ---------------------------------------------------------------------------
  # INPUTS: external things this config depends on.
  # Think of these like imports in any programming language.
  # Nix pins exact versions in flake.lock so builds are reproducible.
  # ---------------------------------------------------------------------------
  inputs = {

    # The main package repository - ~100,000 packages.
    # nixos-unstable = always latest versions (recommended for Mac).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Makes Nix work on macOS: manages system settings, Homebrew, fonts, etc.
    # Must follow the same nixpkgs as above.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manages your personal environment: shell, dotfiles, user packages.
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lets Nix manage Homebrew declaratively (so brew is also reproducible).
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    # The actual Homebrew taps (package sources).
    # flake = false means "just treat this as a plain git repo, not a flake".
    homebrew-core   = { url = "github:homebrew/homebrew-core";   flake = false; };
    homebrew-cask   = { url = "github:homebrew/homebrew-cask";   flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle";  flake = false; };
    timrogers-tap   = { url = "github:timrogers/homebrew-tap";    flake = false; };
  };

  # ---------------------------------------------------------------------------
  # OUTPUTS: what this flake produces.
  # For a Mac setup, the only output we care about is darwinConfigurations.
  # ---------------------------------------------------------------------------
  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }: {

    darwinConfigurations.popmart = nix-darwin.lib.darwinSystem {

      system = "aarch64-darwin"; # Apple Silicon Mac (M1/M2/M3/M4)

      # specialArgs lets us pass extra values into all our config files.
      # Here we pass 'inputs' so configuration.nix and home.nix can use them.
      specialArgs = { inherit inputs; };

      modules = [
        # 1. Homebrew module - enables Nix to control Homebrew
        inputs.nix-homebrew.darwinModules.nix-homebrew

        # 2. Home Manager module - enables per-user environment management
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;       # share system pkgs with HM
          home-manager.useUserPackages = true;     # install HM pkgs into /etc/profiles
          home-manager.backupFileExtension = "hm-bak"; # backup conflicting files
          home-manager.users.regionativo = import ./home.nix; # your personal config
        }

        # 3. Your actual machine config (apps, settings, homebrew list)
        ./configuration.nix
      ];
    };
  };
}
