{ inputs, ... }:
let
  pname = "sm-yazi";
in
{
  perSystem =
    { pkgs, ... }:
    let
      tokyo-night = pkgs.fetchFromGitHub {
        owner = "BennyOe";
        repo = "tokyo-night.yazi";
        rev = "main";
        hash = "sha256-LArhRteD7OQRBguV1n13gb5jkl90sOxShkDzgEf3PA0=";
      };
    in
    {
      packages.${pname} = inputs.wrapper-modules.wrappers.yazi.wrap {
        inherit pkgs;
        binName = pname;
        drv = {
          inherit pname;
          name = pname;
        };
        filesToExclude = [ "bin/yazi" ];
        runtimePkgs = [ pkgs.starship ];

        constructFiles.init = {
          relPath = "${pname}-config/init.lua";
          content = builtins.readFile ./init.lua;
        };

        flavors.tokyo-night = tokyo-night;
        settings = ./settings.toml |> builtins.readFile |> fromTOML;

        plugins = {
          inherit (pkgs.yaziPlugins)
            full-border
            git
            piper
            smart-enter
            starship
            ;
        };
      };
    };
}
