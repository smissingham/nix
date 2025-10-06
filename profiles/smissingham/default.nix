let
  #----- Basic User Info -----#
  username = "smissingham";
  name = "Sean Missingham";
  email = "sean@missingham.com";
  terminalApp = "ghostty";
  browserApp = "Floorp";
  editorApp = "smissingham-nvim";

  sops = {
    getPath = getSopsPath;
    ageKeyFileName = "keys.txt";
    secretsFileName = "secrets.yaml";
    secrets = {

      # SECURITY NOTE: These are auto-sourced into user shell env.
      # Add nothing here that you might not want stolen by a malicious CLI app
      autoExport = {
        ANTHROPIC_API_KEY = { };
        LITELLM_API_KEY = { };
        LITELLM_API_URL = { };
        MORPH_API_KEY = { };
        OPENAI_API_URL = { };
        OPENAI_API_KEY = { };
        OPENROUTER_API_URL = { };
        OPENROUTER_API_KEY = { };
      };

      # Put secrets here that are needed in nix but not auto-exported to env
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
    clip = if isDarwin { } then "pbcopy" else "xclip -selection clipboard";
    sec = "pushd ${getSopsPath { }}; sops ${sops.secretsFileName}; popd";

    # ----- Developer Stuff -----#
    j = "just";
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
