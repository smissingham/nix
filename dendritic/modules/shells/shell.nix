{ ... }:
let
  name = "sm-shell";
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
      defaultShell = "sm-nushell";

      runtimeInputs =
        with pkgs;
        [
          # core utilities
          nix
          bash
          git
          gcc
          gnutar
          zip
          clang
          cmake
          pkg-config
          gnumake
          ncurses
          coreutils
          moreutils
          cacert
          curl
          stow

          # env
          direnv
          nix-direnv

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

          # browsing
          zoxide
          fd
          ripgrep
          fzf
          eza
          yazi

          # appearance
          gum

        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ busybox ]
        ++
          # wrapped apps
          (with config.packages; [
            sm-neovim
            sm-nushell
            sm-opencode
            sm-tmux
            sm-television
            sm-zshell
          ])
        ++
          # custom script binaries
          shell-common.scripts;

    in
    {
      packages.${name} = pkgs.writeShellApplication {
        inherit name runtimeInputs;
        text = ''exec ${config.packages.${defaultShell}}/bin/${defaultShell} "$@"'';
      };

      devShells.default = pkgs.mkShell {
        packages = runtimeInputs;
      };
    };
}
