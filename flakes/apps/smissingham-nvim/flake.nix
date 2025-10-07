{
  description = "Portable NeoVim Configuration Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mcp-hub.url = "github:ravitemer/mcp-hub";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        pkgsUnstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

        vimName = "smissingham-nvim";

        nvimConfigured = pkgs.neovim.override {
          withNodeJs = true;
          withPython3 = true;
        };

        complementaryTools = with pkgs; [
          # ----- TUI Tools -----#
          lazygit

          # ----- AI Helpers -----#
          pkgsUnstable.vectorcode # for minuet RAG context
          pkgsUnstable.opencode
          pkgsUnstable.claude-code
          #inputs.mcp-hub.packages."${system}".default

          # ----- Language Servers -----#
          bash-language-server # sh / bash
          lua-language-server # lua
          nixd # Nix
          taplo # Toml
          vtsls # Typescript
          vscode-langservers-extracted # HTML, CSS, JSON, JS
          emmet-language-server # html shortcode expansions
          svelte-language-server # svelte, obviously
          yaml-language-server # YAML
          rust-analyzer
          jdt-language-server # (jdtls) java all-in-one LS
          pkgsUnstable.ruff # python lsp - linting & formatter
          basedpyright # python type checker

          # ----- Formatters -----#
          shfmt
          nixfmt-rfc-style
          prettierd
          rustfmt
          stylua

          # ----- Package Managers -----#
          pkgsUnstable.uv
          pkgsUnstable.bun
          poetry

          # ----- CLI Utils -----#
          bat
          btop
          dig
          eza
          fd
          fzf
          git
          just
          lazygit
          pandoc
          ripgrep
          ripgrep-all
          tldr
          xclip
          gcc
          gnumake
          gh
          watchexec

          # ----- Plugin Deps -----#
          tree-sitter # tree-sitter

          # Extras for fun dashboard
          fastfetch
          cowsay
          fortune
        ];

        vimWrapper = pkgs.writeShellScriptBin vimName ''
          SRC_CONF="${self}/nvim"
          TGT_CONF="''${XDG_CONFIG_HOME:-$HOME/.config}/${vimName}"

          if [ ! -d $TGT_CONF ]; then
            echo "Symlinking ${vimName} Config Folder"
            cp -rs $SRC_CONF $TGT_CONF
            chmod -R 755 $TGT_CONF
          fi

          export NVIM_APPNAME="${vimName}"
          exec ${nvimConfigured}/bin/nvim "$@"
        '';

        vimWrapperBin = "${vimWrapper}/bin/${vimName}";
        systemPackages = [ vimWrapper ] ++ complementaryTools;

      in
      {
        packages = {
          default = vimWrapper;
          ${vimName} = vimWrapper;
          inherit systemPackages;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = systemPackages;
          shellHook = ''
            echo "Portable NeoVim Environment Loaded!"
            echo "Run '${vimName}' to start your configured editor"
          '';
        };
        apps = {
          default = {
            type = "app";
            program = vimWrapperBin;
          };
        };
      }
    )
    // {
      sharedModules.default =
        {
          pkgs,
          ...
        }:
        {
          environment.systemPackages = self.packages.${pkgs.system}.systemPackages;
        };
    };
}
