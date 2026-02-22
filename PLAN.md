# Nix Setup Plan — popmart

A plain-English guide for managing, backing up, and restoring this machine's Nix config.
Also covers how to adapt it for Linux testing.

---

## Part 1 — Switching to the simplified config

The `simple-popmart/` folder contains a clean, flat, well-commented version of this machine's
config. The original setup supports multiple machines (popmart, plutus, coeus, thalos) and was
cloned from someone else's repo. The simplified version is yours alone.

### What to keep

- `simple-popmart/` — your new active config (flake.nix, configuration.nix, home.nix)
- `dots/auto/` — your real app configs (Neovim, Ghostty, tmux, mcphub, etc.)
- `scripts/` — optional helper scripts

### What to remove (once simple-popmart is confirmed working)

- `hosts/plutus/`, `hosts/coeus/`, `hosts/thalos/` — other people's machines
- `hosts/popmart/` — replaced by simple-popmart/configuration.nix
- `modules/` — replaced by the flat simple-popmart files
- `packages/` — old custom claude-code derivation, no longer needed
- `dots/other/` — Linux dotfiles (Hyprland, Waybar). Mac doesn't use these.
- Root `flake.nix` and `flake.lock` — replaced by simple-popmart versions

### One thing to add before switching

The `simple-popmart/home.nix` does not yet stow your `dots/auto/` folder automatically.
Add this activation block to the `home.activation` section in home.nix:

```nix
home.activation = {
  stowAutoDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.stow}/bin/stow -t "$HOME/.config" -d "$HOME/.config/nix/dots/auto" -R .
    echo "Dotfiles stowed into ~/.config"
  '';
};
```

Adjust the path to match wherever your Nix folder lives on disk.

### How to activate simple-popmart

From inside `simple-popmart/`:

```bash
sudo darwin-rebuild switch --flake .#popmart
```

---

## Part 2 — Backing up to your own GitHub repo

### One-time setup

1. Create a new repo on GitHub (private recommended)
   Name suggestion: `nix-config` or `dotfiles`

2. From your Nix folder on disk, initialize git and connect it:

```bash
cd ~/path/to/your/Nix/folder
git init
git remote add origin git@github.com:YOUR_USERNAME/nix-config.git
```

3. Create a `.gitignore` to exclude anything you don't want tracked:

```
.DS_Store
result
result-*
*.swp
```

4. Add everything and push:

```bash
git add .
git commit -m "initial commit: popmart nix config"
git push -u origin main
```

### Ongoing workflow

Every time you make a change and rebuild successfully:

```bash
git add .
git commit -m "describe what you changed"
git push
```

Commit `flake.lock` every time you run `nix flake update`. That file pins exact versions
of every dependency, so you can reproduce the exact same environment later.

### What NOT to commit

- API keys or tokens (check mcphub/servers.json — it may have API keys)
- Any `.env` files
- Passwords of any kind

---

## Part 3 — Restoring on a new Mac

### What you need

- A Mac with internet access
- Your GitHub repo URL
- Your Apple ID (for Mac App Store apps)
- About 20-30 minutes

### Steps

1. Install Nix (use the Determinate Systems installer — it's the most reliable):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. Close and reopen Terminal, then verify Nix works:

```bash
nix --version
```

3. Clone your config repo:

```bash
git clone git@github.com:YOUR_USERNAME/nix-config.git ~/nix-config
cd ~/nix-config/simple-popmart
```

4. Run the initial bootstrap (first time only — nix-darwin isn't installed yet):

```bash
nix run nix-darwin -- switch --flake .#popmart
```

5. After that first run, use the normal rebuild alias for all future updates:

```bash
sudo darwin-rebuild switch --flake .#popmart
```

6. Nix installs everything: packages, shell, git config, fonts, Homebrew, and all your casks.

7. Check that your dotfiles got stowed into `~/.config`. If the activation script ran, they
   should already be there. If not, run stow manually:

```bash
stow -t ~/.config -d ~/nix-config/dots/auto -R .
```

That's it. The Mac is configured. No hunting for apps, no copy-pasting settings.

---

## Part 4 — Making this config work on Linux

This is useful if you want to test changes on a Linux VM before applying them to your Mac.

### Why it's not plug-and-play

The `configuration.nix` file uses nix-darwin, which is macOS-only. It handles things like
Homebrew, Mac App Store apps, and macOS system settings. None of that exists on Linux.

The `home.nix` file, however, is almost entirely cross-platform. It manages your packages,
shell, git, dotfiles, and dev tools — and those work on Linux too.

### The simplest approach: Home Manager standalone on Linux

On Linux, you skip `configuration.nix` entirely and use only `home.nix`, activated through
home-manager standalone (no NixOS required — works on Ubuntu, Debian, Arch, etc.).

What to remove or wrap for Linux in home.nix:
- Any macOS-only packages (check for darwin-specific ones like `mas`)
- `homebrew`-related config (Linux doesn't have Homebrew)
- `launchd` agents (macOS service manager)

What works as-is on Linux:
- All CLI tools (eza, fzf, ripgrep, bat, zoxide, direnv, etc.)
- Git config
- Zsh and bash config
- Neovim and tmux
- Claude Code

### How to make home.nix cross-platform

Wrap macOS-only sections with a conditional:

```nix
home.packages = with pkgs; [
  # Works everywhere
  eza
  fzf
  ripgrep
  claude-code
] ++ lib.optionals pkgs.stdenv.isDarwin [
  # Mac only
  mas
];
```

### Testing on Linux without a second machine

Use UTM (free) or VMware Fusion on your Mac to spin up an Ubuntu VM, then install
Nix inside it and run home-manager with your home.nix. This lets you test config changes
without touching your working Mac setup.

### Future upgrade path

If you ever want full system management on Linux (like nix-darwin gives you on Mac),
you'd use NixOS — a Linux distro where the entire OS is declared in a Nix config file.
That's a bigger project, but the payoff is that restoring a Linux machine becomes as
easy as restoring your Mac.

---

## Quick reference

| Task | Command |
|---|---|
| Rebuild Mac config | `sudo darwin-rebuild switch --flake .#popmart` |
| Update all dependencies | `nix flake update` |
| Check what changed | `git diff` |
| Save a change | `git add . && git commit -m "message" && git push` |
| Restore on new Mac | See Part 3 above |
