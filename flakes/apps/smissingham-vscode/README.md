# Sean Missingham's Portable Data Science Setup

## Usage

### Run Temporarily, Without Install
```bash
nix --experimental-features "nix-command flakes" run "github:smissingham/nix?dir=flakes/apps/smissingham-vscode"
```

### Install into Nix Profile
```bash
nix --experimental-features "nix-command flakes" profile install "github:smissingham/nix?dir=flakes/apps/smissingham-vscode"
cp -r ~/.nix-profile/Applications/VSCodium.app ~/Applications/
```

### Update Nix Profile Install
```bash
nix profile upgrade flakes/apps/smissingham-vscode
```
