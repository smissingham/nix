{
  description = "Portable NeoVim Configuration Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mcp-hub.url = "github:ravitemer/mcp-hub";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        vimName = "nvim-smissingham";

        nvimConfigured = pkgs.neovim.override {
          withNodeJs = true;
          withPython3 = true;
        };

        complementaryTools = with pkgs; [
          # ----- TUI Tools -----#
          lazygit
          inputs.mcp-hub.packages."${system}".default
          opencode

          # ----- Language Servers -----#
          nixd # Nix
          taplo # Toml
          vtsls # Typescript
          vscode-langservers-extracted # HTML, CSS, JSON, JS

          # ----- Formatters -----#
          prettierd
          rustfmt
          stylua
          black

          # ----- SDK's & Runtimes -----#
          uv

          # ----- CLI Utils -----#
          fd
          ripgrep
          gcc
          gnumake

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
