{
  description = "Expose all app flakes as overlays";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    smissingham-nvim = {
      url = "path:./smissingham-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
    smissingham-vscode = {
      url = "path:./smissingham-vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    containix = {
      url = "path:./containix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
  };
  outputs =
    {
      self,
      flake-utils,
      ...
    }@inputs:
    (flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        smissingham-nvim = inputs.smissingham-nvim.packages.${system};
        smissingham-vscode = inputs.smissingham-vscode.packages.${system};
        containix = inputs.containix.packages.${system};
      };
    }))
    // {
      overlays.myapps = final: _prev: {
        myapps = {
          smissingham-nvim = inputs.smissingham-nvim.packages.${final.system};
          smissingham-vscode = inputs.smissingham-vscode.packages.${final.system};
          containix = inputs.containix.packages.${final.system};
        };
      };
      overlays.default = self.overlays.myapps;
    };
}
