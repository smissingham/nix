# ----- PACKAGES TO INSTALL ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  pkgs,
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
    brave # for testing on chromium-based browsers

    # TODO find better solution to share across daily driver hosts
    #vscode
    spotify
    telegram-desktop
    obsidian
    discord
    lmstudio
    bruno
    gitkraken
    bruno
    gimp
  ];

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
    pciutils
    #usbutils
    findutils

    git
    gnupg
    eza
    fzf
    tldr
    xclip
    zoxide

    nixfmt-rfc-style # formatter
    nixd # lsp
  ];
}
