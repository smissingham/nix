{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages.pfx-claude = inputs.wrapper-modules.wrappers.sops.wrap {
        inherit pkgs;
        binName = "pfx-claude";
        age.yubikey = true;
        age.keyFile = toString ../../secrets/keys.txt;
        secrets.file = ../../secrets/llm-pricefx.env;
        package = inputs.wrapper-modules.wrappers.claude-code.wrap {
          inherit pkgs;
          unsetVar = [ "DEV" ];
          runShell = [
            ''export CLAUDE_CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/pfx-claude"''
            ''mkdir -p "$CLAUDE_CONFIG_DIR"''
            ''ln -sfn ${../../dotfiles/.agents/AGENTS.md} "$CLAUDE_CONFIG_DIR/CLAUDE.md"''
            ''ln -sfn ${../../dotfiles/.agents/commands} "$CLAUDE_CONFIG_DIR/commands"''
            ''ln -sfn ${../../dotfiles/.agents/skills/matt-pocock} "$CLAUDE_CONFIG_DIR/skills"''
          ];
        };
      };
    };
}
