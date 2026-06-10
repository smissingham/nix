{ ... }:
let
  flakeName = "smisnix";
in
{
  flake = {
    defaults = {
      browser = "brave";
      editor = "sm-neovim";
      shell = "sm-zshell";
      terminal = "ghostty";
    };

    paths = rec {
      bin = "${prefix}/bin";
      cache = "/var/cache/${flakeName}";
      config = "/etc/${flakeName}/config";
      data = "/var/lib/${flakeName}";
      state = "${data}/state";
      prefix = "/opt/${flakeName}";
    };

    shells = {
      env = {
        EDITOR = "sm-neovim";
        TERM = "xterm-256color";
      };

      path = [
        "/run/wrappers/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ];
    };
  };
}
