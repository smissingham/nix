{ inputs, ... }:
let
  name = "sm-zsh";
in
{
  perSystem =
    {
      pkgs,
      shell-common,
      ...
    }:
    let
      aliases = shell-common.aliases;
      runtimeInputs = [
        pkgs.zsh-autocomplete
        pkgs.zsh-autosuggestions
      ];

      wrapped = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;

        skipGlobalRC = true;
        zdotdir = "$HOME/.config/${name}";
        zshrc = {
          path = ./.zshrc;
        };

        zshAliases = aliases;
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
