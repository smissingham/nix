{ inputs, ... }:
let
  name = "sm-neovim";
in
{
  perSystem =
    { pkgs, ... }:
    let
      delta = pkgs.writeShellScriptBin "delta" ''
        exec ${pkgs.delta}/bin/delta --navigate --line-numbers --dark "$@"
      '';

      #treesitter =
      #(builtins.getFlake "github:tree-sitter/tree-sitter/8a3dcc6155a9faae677544303b6bc0caf1aef296")
      #.packages.${system}.cli;

      # packages to be installed alongside app
      includedPackages = [
        # critical cli utils
        pkgs.git
        delta
        pkgs.lazygit
        pkgs.ripgrep
        pkgs.fd
        pkgs.tree-sitter
        #tree-sitter-grammars

        # ------------------------- Coding Assistance  -------------------------#
        pkgs.opencode

        # ------------------------- LSP's & Formatters -------------------------#
        pkgs.prettier
        pkgs.prettierd

        # Configuration and scripting
        pkgs.bash-language-server
        pkgs.yaml-language-server
        pkgs.lua-language-server
        pkgs.stylua
        pkgs.taplo

        # Nix
        pkgs.nixd
        pkgs.nixfmt

        # Web
        pkgs.bun
        pkgs.astro-language-server
        pkgs.svelte-language-server
        pkgs.tailwindcss-language-server
        pkgs.vscode-langservers-extracted
        pkgs.vtsls

        # Rust
        pkgs.cargo
        pkgs.rust-analyzer
        pkgs.rustfmt

        # Java
        #maven
        pkgs.jdt-language-server

        # Python
        # basedpyright
        pkgs.uv
        pkgs.ruff
        pkgs.ty
      ];

      # the wrapped neovim app runtime
      wrapped = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;

        env = {
          NVIM_APPNAME = name;
        };

        settings = {
          config_directory = ./.;
          dont_link = true;
          binName = name;
          aliases = [
            name
          ];
        };
      };

      package = pkgs.symlinkJoin {
        name = name;
        paths = [ wrapped ] ++ includedPackages;
      };
    in
    {
      packages.${name} = package;
    };
}
