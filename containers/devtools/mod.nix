{ config, inputs, ... }:
let
  pname = "oci-devtools";
  profileUser = config.profileUsers.smissingham;
in
{
  perSystem =
    { pkgs, ... }:
    let
      user = profileUser;
      home = "/home/${user.username}";
      containerSystem = pkgs.lib.replaceStrings [ "darwin" ] [ "linux" ] pkgs.stdenv.hostPlatform.system;
      cpkgs = inputs.nixpkgs.legacyPackages.${containerSystem};
    in
    {
      packages.${pname} = cpkgs.dockerTools.buildImage {
        name = pname;
        tag = "latest";

        contents = [
          inputs.self.packages.${containerSystem}.sm-devtools
          cpkgs.dockerTools.fakeNss
        ];

        extraCommands = ''
          mkdir -p .${home}
        '';

        config = {
          User = user.username;
          WorkingDir = home;
          Env = [
            "HOME=${home}"
            "USER=${user.username}"
            "PATH=${inputs.self.packages.${containerSystem}.sm-devtools}/bin"
          ];
          Cmd = [ "sm-zsh" ];
        };
      };
    };
}
