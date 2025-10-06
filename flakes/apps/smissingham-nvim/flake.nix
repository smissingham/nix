{
  description = "Portable NeoVim Configuration Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mcp-hub.url = "github:ravitemer/mcp-hub";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = final: prev: {
          #opencode = final.callPackage ./packages/opencode/package.nix { };
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
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
          inputs.mcp-hub.packages."${system}".default

          # ----- Language Servers -----#
          bash-language-server # sh / bash
          lua-language-server # lua
          nil # Nix
          taplo # Toml
          vtsls # Typescript
          vscode-langservers-extracted # HTML, CSS, JSON, JS
          emmet-language-server # html shortcode expansions
          yaml-language-server # YAML
          pkgsUnstable.ruff # python lsp - linting & formatter
          pkgsUnstable.pyrefly # python lsp - types & symbols

          # ----- Formatters -----#
          shfmt
          nixfmt-rfc-style
          prettierd
          rustfmt
          stylua
          black

          # ----- Package Managers -----#
          pkgsUnstable.uv

          # ----- CLI Utils -----#
          fd
          ripgrep
          ripgrep-all
          pandoc
          gcc
          gnumake
          gh

          # ----- Plugin Deps -----#
          tree-sitter # tree-sitter
          dwt1-shell-color-scripts # snacks.nvim
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
