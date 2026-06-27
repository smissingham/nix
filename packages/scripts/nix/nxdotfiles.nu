#!/usr/bin/env nu

def main [] {
  let dotfiles = ($env.NIX_CONFIG_HOME | path join dotfiles)

  if not ($dotfiles | path exists) {
    print $"dotfiles dir not found: ($dotfiles)"
    exit 1
  }

  ^stow -t $env.HOME -d $dotfiles -R .
}
