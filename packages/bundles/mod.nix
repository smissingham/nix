# Shared raw package bundles.
# Keep these free of wrapped app packages to avoid cycles.
{ ... }:
let
  pname = "sm-devtools";
in
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    let
      # Shared package groups consumed by wrapper packages and the dev shell.
      bundles = {
        cli-core = [
          # Core utilities
          pkgs.coreutils
          pkgs.git
          pkgs.curl
          pkgs.gnutar
          pkgs.gzip
          pkgs.zip
          pkgs.lsof
          pkgs.stow

          # Parsing and display
          pkgs.jq
          pkgs.yq
          pkgs.bat
          pkgs.tealdeer
          pkgs.pandoc

          # Search and navigation
          pkgs.fd
          pkgs.ripgrep
          pkgs.fzf
          pkgs.eza
          pkgs.zoxide
          pkgs.yazi

          # System inspection
          pkgs.fastfetch
          pkgs.btop
          pkgs.htop
          pkgs.dust

          # Nix environment helpers
          pkgs.nh
          pkgs.direnv
          pkgs.nix-direnv

          # Shells
          pkgs.nushell
        ];

        cli-dev = [
          # coding assistants
          pkgs.opencode

          # Build and version control
          pkgs.gcc
          pkgs.delta
          pkgs.lazygit

          # Services
          pkgs.gh
          pkgs.glab
          pkgs.jira-cli-go
        ];

        cli-lang = [
          # Syntax
          pkgs.tree-sitter

          # Shell and config
          pkgs.shfmt
          pkgs.stylua
          pkgs.taplo
          pkgs.bash-language-server
          pkgs.lua-language-server
          pkgs.yaml-language-server

          # Writing
          pkgs.typst
          pkgs.tinymist

          # Nix
          pkgs.nixfmt
          pkgs.nixd

          # Web
          pkgs.bun
          pkgs.astro-language-server
          pkgs.prettier
          pkgs.prettierd
          pkgs.svelte-language-server
          pkgs.tailwindcss-language-server
          pkgs.vscode-langservers-extracted
          pkgs.vtsls

          # Rust
          pkgs.cargo
          pkgs.rustfmt
          pkgs.rust-analyzer

          # Java
          pkgs.jdt-language-server

          # Python
          pkgs.uv
          pkgs.black
          pkgs.ruff
          pkgs.ty
        ];

      };

      # Concrete package output installed on hosts and injected into nix develop.
      all = [
        config.packages.sm-zsh
        config.packages.sm-tmux
        config.packages.sm-television
        config.packages.sm-scripts
      ]
      ++ bundles.cli-core
      ++ bundles.cli-dev;

      # nix develop always starts through Nix's shell; hand off interactive sessions to sm-zsh.
      devShell = pkgs.mkShell {
        packages = [ config.packages.${pname} ];
        SHELL = "${config.packages.sm-zsh}/bin/sm-zsh";
        shellHook = ''
          if [ -z "''${SM_ZSH_DEV_SHELL:-}" ] && [ -t 0 ]; then
            export SM_ZSH_DEV_SHELL=1
            exec ${config.packages.sm-zsh}/bin/sm-zsh
          fi
        '';
      };
    in
    {
      packages.${pname} = pkgs.symlinkJoin {
        name = pname;
        paths = all;
        meta.description = "Sean's development tool bundle";
      };

      devShells.default = devShell;

      _module.args.sm-bundles = bundles;
    };
}
