{ inputs, ... }:
let
  name = "sm-zshell";
in
{
  perSystem =
    {
      config,
      pkgs,
      shell-common,
      ...
    }:
    let
      runtimeInputs = [
        pkgs.atuin
        pkgs.starship
        pkgs.zsh-autocomplete
        pkgs.zsh-autosuggestions
        config.packages.sm-tmux
        config.packages.sm-television
      ];

      wrapped = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;

        skipGlobalRC = true;
        zdotdir = "$HOME/.config/${name}";
        zshrc = {
          path = ./.zshrc;
        };

        zshAliases = shell-common.aliases;
        extraPackages = runtimeInputs;
      };
    in
    {
      packages.${name} = pkgs.writeShellApplication {
        inherit name runtimeInputs;
        text = ''exec ${wrapped}/bin/zsh "$@"'';
      };
    };
}
