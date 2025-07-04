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
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu
    font-awesome
  ];

  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
  ];

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
    pciutils
    pkgsUnstable.usbutils
    findutils

    btop
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
