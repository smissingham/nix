{ config, inputs, ... }:
let
  name = "sm-zshell";
  shells = config.flake.shells;
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
        pkgs.zoxide
        pkgs.zsh-autocomplete
        pkgs.zsh-autosuggestions
        pkgs.zsh-completions
        pkgs.zsh-syntax-highlighting
        config.packages.sm-neovim
        config.packages.sm-television
      ];

      wrapped = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;

        env = shells.env;
        prefixVar = [
          [
            "PATH"
            ":"
            (pkgs.lib.concatStringsSep ":" shells.path)
          ]
        ];
        skipGlobalRC = true;
        zdotdir = "$HOME/.config/${name}";
        zshrc = {
          content = ''
            bindkey -r '^L'
            bindkey -r '^J'

            fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
            autoload -Uz compinit && compinit

            source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
            source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
            source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

            eval "$(${pkgs.atuin}/bin/atuin init zsh)"
            eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
            eval "$(${pkgs.starship}/bin/starship init zsh)"
            eval "$(${config.packages.sm-television}/bin/tv init zsh)"
            eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

          '';
        };

        zshAliases = shell-common.aliases;
        extraPackages = runtimeInputs;
      };
    in
    {
      packages.${name} = pkgs.writeShellApplication {
        inherit name runtimeInputs;
        runtimeEnv = shells.env;
        text = ''exec ${wrapped}/bin/zsh "$@"'';
      };
    };
}
