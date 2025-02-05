{
  config,
  lib,
  pkgs,
  ...
}:

let
  moduleSet = "sharedModules";
  moduleCategory = "coding";
  moduleName = "vscodium";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions =
          with vscode-extensions;
          [
            # UI
            enkia.tokyo-night

            # Languages
            bbenoist.nix
            ms-python.python

            # Tools & System
            ms-vscode-remote.remote-ssh
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "remote-ssh-edit";
              publisher = "ms-vscode-remote";
              version = "0.47.2";
              sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
            }
          ];
      })
    ];
  };
}
