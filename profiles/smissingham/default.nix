let
  #----- Basic User Info -----#
  username = "smissingham";
  name = "Sean Missingham";
  email = "sean@missingham.com";
  editor = "smissingham-nvim";
  terminal = "wezterm";
  browser = "floorp";

  emailAccounts = [
    {
      name = "personal";
      address = "sean@missingham.com";
      realName = "Sean Missingham";
      type = "proton";
    }
    {
      name = "work";
      address = "sean.missingham@pricefx.com";
      realName = "Sean Missingham";
      type = "microsoft365";
    }
  ];

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
        OPENAI_API_URL = { };
        OPENAI_API_KEY = { };
        OPENROUTER_API_URL = { };
        OPENROUTER_API_KEY = { };
        MORPH_API_KEY = { };
        CONTEXT7_API_KEY = { };

        SEARXNG_URL = { };
        PRICEFX_DEMO_DOMAIN = { };
        PRICEFX_DEMO_PARTITION = { };
        PRICEFX_DEMO_USERNAME = { };
        PRICEFX_DEMO_PASSWORD = { };
      };

      # Put secrets here that are needed in nix but not auto-exported to env
      other = { };
    };
  };

  shellAliases = {
    q = "exit";
    cl = "clear";
    ls = "eza";
    gg = "lazygit";
    ll = "eza -l";
    la = "eza -la";
    ez = "env | fzf | clip";
    ezk = "env | fzf | awk -F= '{print $1}' | clip";
    ezv = "env | fzf | awk -F= '{print $2}' | clip";
    clip = (if isDarwin { } then "pbcopy" else "xclip -selection clipboard");
    sec = "cd ${getSopsPath { }} && sops ${sops.secretsFileName} && cd -";

    # ----- Developer Stuff -----#
    j = "just";
    oc = "opencode";
    cc = "claude";
    pd = "podman";
    pdc = "podman-compose";
  };

  # ----- Helper Functions -----#
  isDarwin = { }: builtins.pathExists /Users;
  getHome = { }: "${(if isDarwin { } then "/Users" else "/home")}/${username}";
  getNixConfPath = { }: "${(getHome { })}/Documents/Nix";
  getProfilePath = { }: "${(getNixConfPath { })}/profiles/${username}";
  getSopsPath = { }: "${(getProfilePath { })}/private/sops";
  getPrivateModulesPath = { }: "${(getProfilePath { })}/private/modules";
in
{
  inherit
    username
    name
    email
    editor
    terminal
    browser
    emailAccounts
    sops
    shellAliases
    getHome
    getNixConfPath
    getProfilePath
    getPrivateModulesPath
    ;
}
