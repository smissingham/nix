return {
  {
    {
      'milanglacier/minuet-ai.nvim',
      config = function()
        require('minuet').setup {

          -- Model Provider Configuration --
          provider = 'openai_fim_compatible',
          n_completions = 3,
          context_window = 8192,
          request_timeout = 2.5,
          throttle = 1500, -- Increase to reduce costs and avoid rate limits
          debounce = 600,  -- Increase to reduce costs and avoid rate limits
          provider_options = {
            openai_fim_compatible = {
              name = 'LiteLLM',
              end_point = 'https://litellm.coeus.missingham.net/v1/completions',
              api_key = 'LITELLM_API_KEY',
              model = 'code-fim-completion',
              stream = true,
              optional = {
                max_tokens = 8192,
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
