{ inputs, ... }:
let
  appName = "sm-neovim";
in
{
  perSystem =
    { pkgs, ... }:
    let
      # packages to be installed alongside app
      includedPackages = with pkgs; [
        # Package managers and runtimes used by configured language servers
        bun
        cargo
        maven
        nushell
        uv

        # ------------------------- LSP's & Formatters -------------------------#

        # Configuration and scripting
        bash-language-server
        yaml-language-server
        lua-language-server
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

        # JVM languages
        jdt-language-server

        # Python
        basedpyright
        ruff
        ty
      ];

      # packages needed only within the nvim process
      extraPackages = with pkgs; [
      ];

      # the wrapped neovim app runtime
      wrapped = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs extraPackages;

        env = {
          NVIM_APPNAME = appName;
        };

        settings = {
          config_directory = ./.;
          aliases = [
            appName
          ];
        };
      };

      package = pkgs.symlinkJoin {
        name = appName;
        paths = [ wrapped ] ++ includedPackages;
      };
    in
    {
      packages.${appName} = package;
    };
}
