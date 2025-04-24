{ pkgs, lib, ... }:
let
  avanteMain = pkgs.vimPlugins.avante-nvim.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "yetone";
      repo = "avante.nvim";
      rev = "8620ea3e12cfdb90aef2e8ce6f7d5e864758ab71";
      sha256 = "sha256-m33yNoGnSYKfjTuabxx/QsMptiUxAcP8NVe/su+JfkE=";
    };

    # Require setup so we skip these.
    nvimSkipModules = [
      "avante.providers.vertex_claude"
      "avante.providers.azure"
      "avante.providers.ollama"
      "avante.providers.copilot"
    ];

    dependencies = with pkgs.vimPlugins; [
      copilot-lua
      dressing-nvim
      fzf-lua
      img-clip-nvim
      mini-pick
      nui-nvim
      nvim-cmp
      nvim-treesitter
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
      render-markdown-nvim
    ];
  });
in
{
  plugins = {

    # avante
    avante = {
      enable = true;
      package = avanteMain;
      settings = {
        hints.enabled = true;
        provider = "litellm-claude";
        vendors = {
          litellm-claude = {
            __inherited_from = "openai";
            api_key_name = "";
            endpoint = "https://litellm.coeus.missingham.net/v1";
            model = "claude-3.7";
          };
          litellm-gemma-27 = {
            __inherited_from = "openai";
            api_key_name = "";
            endpoint = "https://litellm.coeus.missingham.net/v1";
            model = "gemma-3-27b-qat-q3";
          };
          litellm-gemma-12 = {
            __inherited_from = "openai";
            api_key_name = "";
            endpoint = "https://litellm.coeus.missingham.net/v1";
            model = "gemma3:12b-it-qat";
          };
        };
        mappings = {
          ask = "<leader>aa";
          edit = "<leader>ae";
          refresh = "<leaderar>";
        };
      };
    };

    render-markdown.enable = true;
  };
}
