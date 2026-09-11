# Shared raw package bundles.
# Keep these free of wrapped app packages to avoid cycles.
{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    let

      # Enforce FOSS-only packages in these bundles
      pkgsFree = import pkgs.path {
        inherit (pkgs.stdenv.hostPlatform) system;
        config = {
          allowUnfree = false;
          allowUnfreePredicate = _: false;
        };
      };

      pkgsUnstableFree = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config = {
          allowUnfree = false;
          allowUnfreePredicate = _: false;
        };
      };

      # Shared package groups consumed by wrapper packages and the dev shell.
      clibundles = with pkgsFree; {
        core = [
          # Core utilities
          coreutils
          git
          curl
          gnutar
          gzip
          zip
          lsof
          stow
          zstd

          # Parsing and display
          jq
          bat
          tealdeer

          # Search and navigation
          fd
          ripgrep
          fzf
          eza
          zoxide

          # System inspection
          fastfetch
          btop
          htop
          dust

          # Nix environment helpers
          nix
          nix-output-monitor
          nh
          direnv
          nix-direnv

          # Shells
          nushell
        ];

        # ---------- DEVELOPER TOOLING ---------- #
        dev = [
          # coding assistants
          pkgsUnstableFree.opencode

          # Build and version control
          git
          jujutsu
          gcc
          delta
          lazygit

          # Services
          gh
          glab
          python313Packages.huggingface-hub
          pkgsUnstableFree.git-xet
          git-lfs
        ];

        # ---------- LANGUAGE SUPPORT ---------- #
        lang = [
          # Syntax
          tree-sitter

          # Shell and config
          shfmt
          stylua
          taplo
          bash-language-server
          lua-language-server
          yaml-language-server

          # Writing
          typst
          tinymist

          # Nix
          nixfmt
          nixd

          # Web main
          bun
          prettier
          prettierd
          vtsls
          vscode-langservers-extracted

          # Web extra
          astro-language-server
          svelte-language-server
          tailwindcss-language-server

          # Rust
          cargo
          rustfmt
          rust-analyzer

          # Java
          jdt-language-server

          # Python
          uv
          black
          ruff
          ty
        ];

        # ---------- Wrapped Dev Tool Package Bundle ---------- #
        devtools = [
          # util
          config.packages.sm-scripts
          config.packages.sm-zsh

          # wrapps
          config.packages.sm-neovim
          config.packages.sm-herdr
          config.packages.sm-tmux
          config.packages.sm-television
          config.packages.sm-yazi
        ];
      };
    in
    {

      # Concrete package output sets
      packages.sm-cli-devtools = pkgs.symlinkJoin {
        name = "sm-cli-devtools";
        meta.description = "Sean's command-line development tool bundle";
        paths = clibundles.devtools;
      };

      _module.args.sm-clibundles = clibundles;
    };
}
