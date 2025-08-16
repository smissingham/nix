let
  #----- Basic User Info -----#
  username = "smissingham";
  name = "Sean Missingham";
  email = "sean@missingham.com";
  terminalApp = "ghostty";
  browserApp = "Floorp";
  editorApp = "nvim-smissingham";

  sops = {
    getPath = getSopsPath;
    ageKeyFileName = "keys.txt";
    secretsFileName = "secrets.yaml";
    secrets = {
      autoExport = {
        ANTHROPIC_API_KEY = { };
        LITELLM_API_KEY = { };
        LITELLM_API_URL = { };
        MORPH_API_KEY = { };
        OPENROUTER_API_KEY = { };
        OPENROUTER_API_URL = { };
      };
      other = {
      };
    };
  };

  shellAliases = {
    q = "exit";
    cl = "clear";
    ls = "eza";
    gg = "lazygit";
    ll = "eza -l";
    la = "eza -la";
    clip = "xclip -selection clipboard";
    sec = "pushd ${getSopsPath { }}; sops ${sops.secretsFileName}; popd";

    # ----- Developer Stuff -----#
    oc = "opencode";
    cc = "claude-code";
  };

  # ----- Helper Functions -----#
  isDarwin = { }: builtins.match ".*-darwin" builtins.currentSystem != null;
  getHome = { }: "${(if isDarwin { } then "/Users" else "/home")}/${username}";
  getNixConfPath = { }: "${(getHome { })}/Documents/Nix";
  getProfilePath = { }: "${(getNixConfPath { })}/profiles/${username}";
  getSopsPath = { }: "${(getProfilePath { })}/private/sops";
in
{
  inherit
    username
    name
    email
    terminalApp
    editorApp
    browserApp
    sops
    shellAliases
    getHome
    getNixConfPath
    getProfilePath
    ;
}
