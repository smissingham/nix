# ----- PACKAGES TO INSTALL ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  pkgs,
  ...
}:
{
  #----- Fonts Available to System -----#
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu
    font-awesome
  ];

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [

    # System CLI Utils
    pciutils
    usbutils
    findutils

    # Nix CLI Utils
    nixfmt-rfc-style # formatter
    nixd # lsp

    # Dev Utils
    dig
    gnupg
    git
    just
    stow

    # CLI Usability
    bat
    btop
    fd
    eza
    fzf
    tldr
    xclip
  ];
}
