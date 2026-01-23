{
  description = "Portable NeoVim Configuration Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    #mcp-hub.url = "github:ravitemer/mcp-hub";
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
      _system:
      let
        pkgs = import nixpkgs {
          #inherit system;
          config.allowUnfree = true;
          overlays = [
            (final: _prev: {
              groovyls = final.callPackage ./packages/groovyls/package.nix { };
            })
          ];
        };

        pkgsUnstable = import nixpkgs-unstable {
          #inherit system;
          config.allowUnfree = true;
        };

        pName = "smissingham-nvim";

        nvimConfigured = pkgs.neovim.override {
          withNodeJs = true;
          withPython3 = true;
        };

        pWrapper = pkgs.writeShellScriptBin pName ''
          SRC_CONF="${self}/nvim"
          TGT_CONF="''${XDG_CONFIG_HOME:-$HOME/.config}/${pName}"

          if [ ! -d $TGT_CONF ]; then
            echo "Symlinking ${pName} Config Folder"
            mkdir -p "$(dirname $TGT_CONF)" # ensure path to containing dir exists
            cp -rs $SRC_CONF $TGT_CONF # create target dir as symlink
            chmod -R 755 $TGT_CONF
          fi

          export NVIM_APPNAME="${pName}"
          exec ${nvimConfigured}/bin/nvim "$@"
        '';

        systemPackages =
          with pkgs;
          [
            # ----- TUI Tools -----#
            lazygit
            lazydocker

            # ----- AI Helpers -----#
            # pkgsUnstable.vectorcode # for minuet RAG context
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
            vscode-extensions.vadimcn.vscode-lldb # debug adapter

            # ----- Java Support -----#
            #gradle # package manager
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
            curl
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
            #pandoc
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
          ]
          ++ [ pWrapper ];

      in
      {
        packages = {
          default = pWrapper;
          ${pName} = pWrapper;
          inherit systemPackages;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = systemPackages;
          shellHook = ''
            echo "Portable NeoVim Environment Loaded!"
            echo "Run '${pName}' to start your configured editor"
          '';
        };
        apps = {
          default = {
            type = "app";
            program = "${pWrapper}/bin/${pName}";
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
