# ---------------------------------------------------------------------------
# configuration.nix - Your Mac's system-level config
#
# This file controls:
#   - Machine identity (hostname)
#   - System packages (available to everyone on the machine)
#   - Homebrew apps (GUI apps + CLI tools via brew)
#   - macOS system preferences (dock, finder, keyboard, etc.)
#   - Homebrew tap sources
# ---------------------------------------------------------------------------
{ pkgs, inputs, ... }:

{
  # ---------------------------------------------------------------------------
  # MACHINE IDENTITY
  # ---------------------------------------------------------------------------
  networking.hostName     = "popmart";
  networking.computerName = "popmart";

  # Required by nix-darwin - don't change unless you know why.
  system.stateVersion = 5;

  # Your username - used in a few places below.
  users.users.regionativo = {
    name = "regionativo";
    home = "/Users/regionativo";
  };

  # Allows packages with non-open-source licenses (like claude-code).
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------------------
  # HOMEBREW - GUI apps and things not in nixpkgs
  #
  # Add or remove apps here, then run `nxr` to apply.
  # cleanup = "zap" means: if you remove something from this list, brew will
  # also uninstall it from your Mac. That's what makes this declarative.
  # ---------------------------------------------------------------------------
  nix-homebrew = {
    enable       = true;
    enableRosetta = true; # needed for Intel-only apps on Apple Silicon
    user         = "regionativo";
    taps = {
      "homebrew/homebrew-core"   = inputs.homebrew-core;
      "homebrew/homebrew-cask"   = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "timrogers/homebrew-tap"   = inputs.timrogers-tap;
    };
    mutableTaps = false; # Nix controls taps, not you manually
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # remove apps deleted from this list

    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
      "timrogers/tap"
    ];

    # CLI tools installed via brew (not GUI apps)
    brews = [
      "duckdb"
      "mas"   # Mac App Store CLI (needed for masApps below)
      "litra"
      "libomp"
    ];

    # GUI applications (.app bundles)
    casks = [
      # Browsers
      "orion"

      # Terminal
      "ghostty"

      # Workflow & PKM
      "raycast"
      "obsidian"
      "brainfm"

      # Productivity
      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "microsoft-edge"
      "microsoft-outlook"
      "todoist-app"
      "windows-app"
      "onedrive"
      "deskpad"

      # Data Science & Coding
      "knime"
      "rstudio"
      "visual-studio-code"
      "gitkraken"
      "chatgpt"
      "claude"

      # Mac Utilities
      "aldente"
      "bitwarden"
      "bartender"
      "logi-options+"
      "logitune"
      "pearcleaner"
      "finicky"
      "alt-tab"

      # Messaging
      "whatsapp"
      "discord"

      # 3D Printing & Design
      "bambu-studio"
      "autodesk-fusion"
      "gimp"

      # Gaming & Media
      "nvidia-geforce-now"
      "steam"
      "vlc"
    ];

    # Apps bought from the Mac App Store (ID numbers from their store URLs)
    masApps = {
      Xnip     = 1221250572;
      Dropover = 1355679052;
      Supernote = 1494992020;
    };
  };

  # ---------------------------------------------------------------------------
  # SYSTEM PACKAGES
  # These are available to all users system-wide via the terminal.
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gnupg

    # Shell utilities
    eza    # better `ls`
    fzf    # fuzzy finder
    bat    # better `cat`
    btop   # better `top`
    tldr   # simplified man pages
    yazi   # terminal file manager
    tmux   # terminal multiplexer
    stow   # symlink manager (used for dotfiles)
    dig    # DNS lookup

    # Nix tools
    nixfmt # formats .nix files
    nixd   # Nix language server (for editors)
  ];

  # ---------------------------------------------------------------------------
  # FONTS
  # These are installed system-wide and available in all apps.
  # ---------------------------------------------------------------------------
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu
    font-awesome
  ];

  # ---------------------------------------------------------------------------
  # AEROSPACE WINDOW MANAGER
  # Installed via homebrew above. This enables its nix-darwin module.
  # ---------------------------------------------------------------------------
  # Note: AeroSpace config lives in ~/.config/aerospace/aerospace.toml
  # (managed via your dots/auto folder or manually)

  # ---------------------------------------------------------------------------
  # MACOS SYSTEM PREFERENCES
  # These are the settings you'd normally set in System Preferences.
  # Run `nxr` after changing these to apply them.
  # ---------------------------------------------------------------------------
  system.defaults = {

    # Mouse speed (0 = slow, 3 = fast)
    ".GlobalPreferences"."com.apple.mouse.scaling" = 2.5;

    # Don't let Mission Control group windows by app
    spaces.spans-displays = false;

    dock = {
      autohide             = false;
      show-recents         = false;
      launchanim           = true;
      orientation          = "bottom";
      magnification        = true;
      largesize            = 64;
      tilesize             = 43;
      expose-group-apps    = true;  # group windows by app in Exposé
      minimize-to-application = true;
    };

    finder = {
      _FXShowPosixPathInTitle      = false;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle         = "Nlsv"; # list view
      AppleShowAllExtensions       = true;
      AppleShowAllFiles            = true;
      QuitMenuItem                 = false;
      ShowStatusBar                = true;
      ShowPathbar                  = true;
    };

    NSGlobalDomain = {
      AppleICUForce24HourTime               = false;
      AppleInterfaceStyle                   = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleMeasurementUnits                 = "Centimeters";
      AppleMetricUnits                      = 1;
      AppleTemperatureUnit                  = "Celsius";
      InitialKeyRepeat                      = 15;  # delay before key repeat starts
      KeyRepeat                             = 2;   # key repeat speed
      NSAutomaticCapitalizationEnabled      = false;
      NSAutomaticDashSubstitutionEnabled    = false;
      NSAutomaticPeriodSubstitutionEnabled  = false;
      NSAutomaticQuoteSubstitutionEnabled   = false;
      NSAutomaticSpellingCorrectionEnabled  = true;
      NSNavPanelExpandedStateForSaveMode    = true;
      NSNavPanelExpandedStateForSaveMode2   = true;
      AppleKeyboardUIMode                   = 2;
    };
  };

  # ---------------------------------------------------------------------------
  # KEYBOARD KEYBINDINGS (macOS text system)
  # Fixes Home/End keys to behave like non-Mac keyboards.
  # ---------------------------------------------------------------------------
  # Note: these are set in home.nix under targets.darwin.keybindings
}
