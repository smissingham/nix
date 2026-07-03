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
      containerSystem =
        pkgs.stdenv.hostPlatform.system
        |> pkgs.lib.replaceStrings [ "darwin" ] [ "linux" ];
      cpkgs = inputs.nixpkgs.legacyPackages.${containerSystem};
    in
    {
      packages.${pname} = cpkgs.dockerTools.buildImage {
        name = pname;
        tag = "latest";

        copyToRoot = cpkgs.buildEnv {
          name = "${pname}-root";
          paths = [
            inputs.self.packages.${containerSystem}.sm-cli-devtools
            cpkgs.dockerTools.fakeNss
          ];
          pathsToLink = [ "/" ];
        };

        extraCommands = ''
          mkdir -p .${home}
        '';

        config = {
          User = user.username;
          WorkingDir = home;
          Env = [
            "HOME=${home}"
            "USER=${user.username}"
            "PATH=${inputs.self.packages.${containerSystem}.sm-cli-devtools}/bin"
          ];
          Cmd = [ "sm-zsh" ];
        };
      };
    };
}
