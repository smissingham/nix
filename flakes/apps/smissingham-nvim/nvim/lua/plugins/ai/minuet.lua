-- VectorCode integration for RAG
local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
local vectorcode_cacher = nil
if has_vc then
  vectorcode_cacher = vectorcode_config.get_cacher_backend()
end

-- Common RAG context retrieval
local function get_rag_context(window_size, format_fn)
  window_size = window_size or 8000
  format_fn = format_fn or function(path, doc) return "File: " .. path .. "\n" .. doc .. "\n\n" end

  local rag_context = ""
  if has_vc then
    local cache_result = vectorcode_cacher.query_from_cache(0)
    for _, file in ipairs(cache_result) do
      rag_context = rag_context .. format_fn(file.path, file.document)
    end
    rag_context = vim.fn.strcharpart(rag_context, 0, window_size)
  end
  return rag_context
end

-- Common prompt instructions
local common_instructions = {
  "# IMPORTANT: Only complete with English code/comments. No Chinese characters.\n",
  "# IMPORTANT: Do not provide markdown block syntax or backticks. Only provide raw code output.\n",
}

-- Reusable FIM template with RAG support
local function create_fim_template_with_rag(rag_context_window_size)
  return {
    prompt = function(context_before_cursor, context_after_cursor, opts)
      local rag_context = get_rag_context(
        rag_context_window_size,
        function(path, doc) return "<|file_sep|>" .. path .. "\n" .. doc end
      )

      return rag_context
          .. "# language: " .. vim.bo.filetype .. "\n"
          .. table.concat(common_instructions)
          .. "<|fim_prefix|>" .. context_before_cursor
          .. "<|fim_suffix|>" .. context_after_cursor
          .. "<|fim_middle|>"
    end,
    suffix = false,
  }
end

-- Reusable standard template with RAG support for chat completion models
local function create_standard_template_with_rag(rag_context_window_size)
  return {
    prompt = function(context_before_cursor, context_after_cursor, opts)
      local rag_context = get_rag_context(rag_context_window_size)

      return "You are a code completion assistant. Complete the code at the cursor position.\n"
          .. "Language: " .. vim.bo.filetype .. "\n"
          .. "IMPORTANT: Only provide the completion LITERAL text, no explanations or markdown, and no wrapping backticks.\n"
          .. table.concat(common_instructions)
          .. (rag_context ~= "" and "Relevant code context:\n" .. rag_context .. "\n" or "")
          .. "Code before cursor:\n" .. context_before_cursor .. "\n\n"
          .. "Code after cursor:\n" .. context_after_cursor .. "\n\n"
          .. "Complete the code at the cursor position:"
    end,
    suffix = false,
  }
end

local models = {
  cerebras_glm_47 = {
    provider = "openai_compatible",
    context_window = 8192,
    provider_options = {
      name = "LiteLLM",
      model = "cerebras-glm-4.7",
      api_key = "HOSTING_COMMON_MASTER_KEY",
      end_point = vim.env.LITELLM_API_URL .. "/chat/completions",
      stream = true,
      optional = {
        --max_tokens = 256,
        top_p = 0.9,
        temperature = 0.3,
      },
    },
  },
  claude4_sonnet = {
    provider = "openai_compatible",
    context_window = 8192,
    provider_options = {
      name = "Anthropic",
      model = "claude-3-5-sonnet-20241022",
      api_key = "ANTHROPIC_API_KEY",
      end_point = "https://api.anthropic.com/v1/messages",
      stream = true,
      optional = {
        max_tokens = 256,
        top_p = 0.9,
        temperature = 0.3,
        repetition_penalty = 1.1,
        frequency_penalty = 0.1,
      },
    },
  },
  qwen3_coder_small = {
    provider = "openai_fim_compatible",
    context_window = 8192,
    provider_options = {
      api_key = "TERM",
      name = "LmStudio",
      end_point = "http://localhost:1234/v1/completions",
      model = "qwen/qwen3-30b-a3b-2507",
      stream = true,
      optional = {
        max_tokens = 64,
        top_p = 0.9,
        temperature = 0.15,
        repetition_penalty = 1.1,
        frequency_penalty = 0.1,
      },
      template = create_fim_template_with_rag(2000),
    },
  },
  qwen3_coder_large = {
    provider = "openai_fim_compatible",
    context_window = 8192,
    provider_options = {
      name = "OpenRouter",
      model = "qwen/qwen3-coder",
      api_key = "OPENROUTER_API_KEY",
      end_point = "https://openrouter.ai/api/v1/completions",
      stream = true,
      optional = {
        max_tokens = 256,
        top_p = 0.9,
        temperature = 0.3,
        repetition_penalty = 1.1,
        frequency_penalty = 0.1,
      },
      template = create_fim_template_with_rag(),
    },
  },
  kimik2 = {
    provider = "openai_compatible",
    context_window = 8192,
    provider_options = {
      name = "OpenRouter",
      model = "moonshotai/kimi-k2-0905",
      api_key = "OPENROUTER_API_KEY",
      end_point = "https://openrouter.ai/api/v1/chat/completions",
      stream = true,
      optional = {
        max_tokens = 256,
        top_p = 0.9,
        temperature = 0.3,
        repetition_penalty = 1.1,
        frequency_penalty = 0.1,
      },
    },
  },
  haiku45 = {
    provider = "openai_compatible",
    context_window = 16384,
    provider_options = {
      name = "OpenRouter",
      model = "anthropic/claude-haiku-4.5",
      api_key = "OPENROUTER_API_KEY",
      end_point = "https://openrouter.ai/api/v1/chat/completions",
      stream = true,
      optional = {
        max_tokens = 256,
        top_p = 0.9,
        temperature = 0.3,
        repetition_penalty = 1.1,
        frequency_penalty = 0.1,
      },
      template = create_standard_template_with_rag(),
    },
  },
}

return {
  -- VectorCode for RAG functionality
  {
    "Davidyz/VectorCode",
    config = function()
      require("vectorcode").setup({
        n_query = 3,
      })
    end,
  },
  -- Minuet Completion
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "Davidyz/VectorCode",
    },
    config = function()
      local model = models.cerebras_glm_47

      require("minuet").setup({
        provider = model.provider,
        provider_options = {
          [model.provider] = model.provider_options,
        },

        request_options = {
          hooks = {
            -- Strip markdown code block syntax from LLM responses
            on_response = function(response)
              if response and response.text then
                response.text = response.text:gsub("^%s*```[%w]*\n", ""):gsub("\n```%s*$", "")
              end
              return response
            end,
          },
        },

        context_window = model.context_window or 8192,

        n_completions = 1,
        request_timeout = 60,
        throttle = 1000,
        debounce = 400,

        --after_cursor_filter_length = 20,
        --before_cursor_filter_length = 5,

        virtualtext = {
          auto_trigger_ft = {},
          keymap = {
            accept = "<C-a>",
            accept_n_lines = "<C-y>",
            accept_line = "<C-u>",
            prev = "<C-h>",
            next = "<C-l>",
            dismiss = "<C-c>",
          },
        },
      })

      -- Set up VectorCode keymaps
      vim.keymap.set("n", "<leader>vr", ":VectorCode register<CR>", { desc = "Register buffer with VectorCode" })
      vim.keymap.set("n", "<leader>vi", ":VectorCode index<CR>", { desc = "Index project with VectorCode" })
    end,
  },
}
