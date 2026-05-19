{ ... }:
let
  name = "sm-bundle-devtools";
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
      packages =
        with pkgs;
        [
          # core utilities
          git
          gnutar
          zip
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

          # nixpkgs apps
          opencode
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ busybox ]
        ++ (with config.packages; [
          sm-neovim
          sm-nushell
          sm-shell
          sm-tmux
          sm-television
          sm-zshell
        ])
        ++ shell-common.scripts;
    in
    {
      packages.${name} = pkgs.symlinkJoin {
        inherit name;
        paths = packages;
      };

      devShells.default = pkgs.mkShell {
        packages = [ config.packages.${name} ];
      };
    };
}
