let
  #----- Basic User Info -----#
  username = "smissingham";
  name = "Sean Missingham";
  email = "sean@missingham.com";
  editor = "smissingham-nvim";
  terminal = "ghostty";
  browser = "brave";

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
        HOME_NOTES = { };

        # home hosted
        SEARXNG_URL = { };
        LITELLM_URL = { };
        LITELLM_API_URL = { };
        LITELLM_API_KEY = { };

        # api keys & such
        OPENAI_API_URL = { };
        OPENAI_API_KEY = { };
        HF_IE_API_URL = { };
        HF_IE_API_KEY = { };

        JINA_API_KEY = { };
        CONTEXT7_API_KEY = { };
      };

      # Put secrets here that are needed in nix but not auto-exported to env
      other = {
        # SSH public keys for passwordless auth between hosts (pattern: SSH_PUBKEY_*)
        SSH_PUBKEY_COEUS = { };
        SSH_PUBKEY_PLUTUS = { };
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
    ez = "env | fzf | clip";
    ezk = "env | fzf | awk -F= '{print $1}' | clip";
    ezv = "env | fzf | awk -F= '{print $2}' | clip";
    clip = (if isDarwin { } then "pbcopy" else "xclip -selection clipboard");
    sec = "pushd ${getSopsPath { }} && sops ${sops.secretsFileName} && popd";

    notes = "cd \"$HOME/$HOME_NOTES\" && smissingham-nvim";

    # ----- Developer Stuff -----#
    j = "just";
    oc = "opencode";
    cc = "claude";
    pd = "podman";
    pdc = "podman-compose";

    ralph = "bunx --bun @th0rgal/ralph-wiggum";
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
