# ----- PACKAGES TO INSTALL ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  pkgs,
  pkgsUnstable,
  mainUser,
  ...
}:
{
  #----- Fonts Available to System -----#
  fonts.packages = with pkgs; [
    nerdfonts
    font-awesome
  ];

  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    spotify
    telegram-desktop
    obsidian
    vesktop
    pkgsUnstable.zed-editor
    gitkraken
    bruno
    gimp
  ];

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
    pciutils
    pkgsUnstable.usbutils
    findutils

    git
    gnupg
    eza
    fzf
    tldr
    xclip
    dig
    bat
    stow
    yazi
    tmux

    nixfmt-rfc-style # formatter
    nixd # lsp
  ];
}
