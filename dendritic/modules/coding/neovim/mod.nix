{ inputs, ... }:
let
  name = "sm-neovim";
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      treesitter =
        (builtins.getFlake "github:tree-sitter/tree-sitter/8a3dcc6155a9faae677544303b6bc0caf1aef296")
        .packages.${system}.cli;

      # packages to be installed alongside app
      includedPackages = with pkgs; [
        # critical cli utils
        git
        gnutar
        delta
        lazygit
        ripgrep
        fd
        treesitter
        #tree-sitter-grammars

        # Package managers and runtimes used by configured language servers
        bun
        cargo
        maven
        nushell
        uv

        # ------------------------- LSP's & Formatters -------------------------#
        prettier
        prettierd

        # Configuration and scripting
        bash-language-server
        yaml-language-server
        lua-language-server
        stylua
        taplo

        # Nix
        nixd
        nixfmt

        # Web
        astro-language-server
        svelte-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
        vtsls

        # Rust
        rust-analyzer
        rustfmt

        # JVM languages
        jdt-language-server

        # Python
        # basedpyright
        ruff
        ty
      ];

      # packages needed only within the nvim process
      extraPackages = [ ];

      # the wrapped neovim app runtime
      wrapped = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs extraPackages;

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
