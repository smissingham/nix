{ ... }:
let
  name = "sm-television";
in
{
  perSystem =
    { pkgs, ... }:
    let
      # televisionFlake = builtins.getFlake "github:alexpasmantier/television/8db108d853e4d7f0d7c1a9738e2ec117c8ad6bab";
      # television = televisionFlake.packages.${pkgs.system}.default;
      television = pkgs.television;
    in
    {
      packages.${name} = pkgs.symlinkJoin {
        inherit name;
        paths = [
          television
          pkgs.nix-search-tv
          (pkgs.linkFarm "tv-xdg-config" [
            {
              name = "config/television";
              path = ./.;
            }
          ])
        ];
        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          makeWrapper ${television}/bin/tv $out/bin/${name} \
            --set XDG_CONFIG_HOME $out/config \
            --set SHELL sm-shell
        '';
      };
    };
}
