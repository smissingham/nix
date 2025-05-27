return {
  {
    {
      'milanglacier/minuet-ai.nvim',
      config = function()
        require('minuet').setup {

          -- Model Provider Configuration --
          provider = 'openai_compatible',
          n_completions = 5,
          context_window = 4096,
          request_timeout = 2.5,
          throttle = 1500, -- Increase to reduce costs and avoid rate limits
          debounce = 600,  -- Increase to reduce costs and avoid rate limits
          provider_options = {
            openai_compatible = {
              api_key = 'TERM',
              name = 'Litellm',
              end_point = 'https://litellm.coeus.missingham.net/v1/chat/completions',
              model = 'OLL-qwen2.5-coder:7b',
              optional = {
                max_tokens = 4096,
                top_p = 0.9,
              },
            },
          },
        }
      end,
    },
    { 'nvim-lua/plenary.nvim' },
    { 'saghen/blink.cmp' },
  }
}
