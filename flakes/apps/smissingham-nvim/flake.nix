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
          overlays = [
            (final: _prev: {
              groovyls = final.callPackage ./packages/groovyls/package.nix { };
            })
          ];
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
          lazydocker

          # ----- AI Helpers -----#
          pkgsUnstable.vectorcode # for minuet RAG context
          pkgsUnstable.opencode
          pkgsUnstable.claude-code
          #inputs.mcp-hub.packages."${system}".default

          # ----- General Language Support -----#
          bash-language-server # sh / bash
          shfmt # general scripting formatter
          taplo # Toml lsp
          yaml-language-server # YAML lsp

          # ----- Lua Support -----#
          lua-language-server # lsp
          stylua # formatter

          # ----- Nix Support -----#
          nixd # lsp
          nixfmt-rfc-style # formatter

          # ----- WebDev Support -----#
          pkgsUnstable.bun # package manager
          vscode-langservers-extracted # HTML, CSS, JSON, JS
          vtsls # Typescript lsp
          emmet-language-server # html shortcode expansions
          svelte-language-server # svelte, obviously
          astro-language-server # astro
          tailwindcss-language-server # tailwind
          prettierd # formatter

          # ----- Rust Support -----#
          rust-analyzer # lsp
          rustfmt # formatter

          # ----- Java Support -----#
          gradle # package manager
          maven # package manager
          jdt-language-server # (jdtls) java all-in-one LS
          groovyls # Groovy language server

          # ----- Python Support -----#
          pkgsUnstable.uv # package manager
          poetry # package manager
          black # formatter
          pkgsUnstable.ruff # lsp, lint, format
          basedpyright # type checker

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
          lsof # Required for opencode.nvim process discovery
          pandoc
          procps # Provides pgrep, required for opencode.nvim process discovery
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
