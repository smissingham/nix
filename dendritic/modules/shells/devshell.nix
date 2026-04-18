{ ... }:
let
  name = "sm-devshell";
in
{
  perSystem =
    {
      config,
      pkgs,
      shell-common,
      ...
    }:
    let
      runtimeInputs =
        with pkgs;
        [
          # core utilities
          busybox
          nix
          bash
          git
          gcc
          clang
          gdb
          lldb
          cmake
          pkg-config
          gnumake
          ncurses
          coreutils
          moreutils
          cacert
          curl
          stow

          # sysinfo
          fastfetch
          tealdeer
          btop
          htop
          dust

          # parsing
          jq
          yq
          bat
          poppler
          pandoc

          # browsing
          atuin
          television
          zoxide
          fd
          ripgrep-all
          fzf
          eza
          yazi

          # appearance
          gum

          # wrapped apps
          config.packages.sm-zsh
          config.packages.sm-nu
          config.packages.sm-neovim
          config.packages.sm-opencode
        ]
        ++
          # custom script binaries
          shell-common.scripts;

    in
    {
      packages.${name} = pkgs.writeShellApplication {
        inherit name runtimeInputs;
        text = ''exec sm-nu "$@"'';
      };
    };
}
