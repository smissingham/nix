{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pfx-opencode = inputs.wrapper-modules.wrappers.sops.wrap {
        inherit pkgs;
        binName = "pfx-opencode";
        age.yubikey = true;
        age.keyFile = toString ../../secrets/keys.txt;
        secrets.file = ../../secrets/llm-pricefx.env;
        secrets.env.export.keys = [
          "JINA_API_KEY"
          "PFX_GW_URL"
          "PFX_GW_KEY_LOCAL"
          "PFX_GW_KEY_BEDROCK"
        ];
        settings.creation_rules = [
          {
            path_regex = ".*";
            key_groups = [
              {
                age = [
                  "age1yubikey1qtpugaket6nqs3ezudp7w5n0h8xdwhdawsf6rus4ctfm249g5kg7vxm7egz"
                  "age1yubikey1q08jxsggfcsrvcjaq8kvnl4mxwnlnqx3wwxwlcwx30x6rxleh20rzdv0pep"
                ];
              }
            ];
          }
        ];
        package = inputs.wrapper-modules.wrappers.opencode.wrap {
          inherit pkgs;
          package =
            inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode;
          binName = "pfx-opencode";
          env.OPENCODE_CONFIG_DIR = pkgs.runCommand "pfx-opencode-config" { } ''
            cp -r ${./.} "$out"
            chmod u+w "$out"
            ln -s ${../../dotfiles/.agents/commands} "$out/commands"
            ln -s ${../../dotfiles/.agents/AGENTS.md} "$out/AGENTS.md"
          '';
          runShell = [
            ''export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}/pfx-opencode"''
            ''export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/pfx-opencode"''
            ''export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}/pfx-opencode"''
            ''export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}/pfx-opencode"''
          ];
          settings.skills.paths = [ "${../../dotfiles/.agents/skills}" ];
          tui-settings = ./tui.json |> builtins.readFile |> builtins.fromJSON;
        };
      };
    };
}
