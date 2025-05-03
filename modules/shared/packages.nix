# ----- PACKAGES TO INSTALL ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  pkgs,
  pkgsUnstable,
  mainUser,
  inputs,
  system,
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
    alacritty
    spotify
    telegram-desktop
    obsidian
    vesktop
    #lmstudio
    bruno
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
    zoxide
    dig
    bat

    nixfmt-rfc-style # formatter
    nixd # lsp
  ];
}
