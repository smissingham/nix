# Welcome to Sean Missingham's PC Configuration Repo

I use this repo to maintain the hardware and OS configuration of my daily-driver desktop, which also acts as a home server, as well as my work macbook.

I use NixOS for the server operating system, and host many docker container services. 

All of the configuration for that is declarative, and version controlled, right here in this repo.



# Nix Darwin first install instructions for Jose

1. From nix website, install nix:
` sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)`
2. Close/restart shell


3. Git clone the system flake repo
`cd Documents && git clone -b jose https://github.com/smissingham/nix Nix`
- Follow prompt for installing mac dev tools, necessary anyway


4. Install the system flake using temporary nix-darwin 
`sudo nix run nix-darwin/nix-darwin-25.05#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake .#popmart`

