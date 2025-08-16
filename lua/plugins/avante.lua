local avante_prompts = require("config.prompts").avante
local function create_avante_call(prompt, use_context)
  if use_context then
    local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "unknown"
    local filename = vim.fn.expand("%:t")
    filename = filename ~= "" and filename or "unnamed buffer"
    local context = string.format("This is %s code from file '%s'. ", filetype, filename)
    return function()
      require("avante.api").ask({ question = context .. prompt })
    end
  else
    return function()
      require("avante.api").ask({ question = prompt })
    end
  end
end

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        filetypes = {
          ["*"] = false,
          avante = true,
          c = true,
          cpp = true,
          go = true,
          help = true,
          html = true,
          java = true,
          javascript = true,
          javascriptreact = true,
          lua = true,
          markdown = true,
          python = true,
          rust = true,
          typescript = true,
          typescriptreact = true,
        },
      })
    end,
  },
  {
    "yetone/avante.nvim",
    -- event = "BufReadPost",
    version = false,
    opts = function()
      local opts = {
        provider = "copilot",
        rag_service = {
          enabled = false,
        },
        cursor_applying_provider = "copilot",
        providers = {
          copilot = {
            endpoint = "https://api.githubcopilot.com",
            -- model = "claude-sonnet-4",
            model = "gpt-5",
            proxy = nil,
            allow_insecure = false,
            timeout = 60000,
            extra_request_body = {
              temperature = 0,
              max_tokens = 32768,
            },
            disable_tools = true,
            telemetry = false,
            disabled_tools = {
              "list_files",
              "search_files",
              "read_file",
              "create_file",
              "rename_file",
              "delete_file",
              "create_dir",
              "rename_dir",
              "delete_dir",
              "bash",
            },
          }
        },
        suggestion = {
          debounce = 900,
          throttle = 600,
        },
        behaviour = {
          auto_suggestions = false,
          auto_set_highlight_group = true,
          auto_set_keymaps = true,
          auto_apply_diff_after_generation = false,
          support_paste_from_clipboard = false,
          minimize_diff = true,
          enable_token_counting = true,
          enable_cursor_planning_mode = true,
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = "co",
            theirs = "ct",
            all_theirs = "ca",
            both = "cb",
            cursor = "cc",
            next = "]x",
            prev = "[x",
          },
          suggestion = {
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
          jump = {
            next = "]]",
            prev = "[[",
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
          sidebar = {
            apply_all = "A",
            apply_cursor = "a",
            switch_windows = "<Tab>",
            reverse_switch_windows = "<S-Tab>",
          },
        },
      }
      if vim.env.USER == "abz" then
        -- opts.auto_suggestions_provider = "ollama"
        -- opts.memory_summary_provider = "ollama"
        -- opts.ollama = {
        --   model = "llama3.1:latest",
        --   endpoint = "http://127.0.0.1:11434",
        --   options = {
        --     temperature = 0,
        --     num_ctx = 32768,
        --   },
        -- }
        opts.providers.copilot.disable_tools = false
        opts.auto_suggestions_provider = "copilot"
        opts.memory_summary_provider = "copilot"
        -- opts.cursor_applying_provider = "ollama"
        -- opts.rag_service = {
        --   enabled = true,
        --   host_mount = os.getenv("HOME"),
        --   provider = "ollama",
        --   llm_model = "llama3.1:latest",
        --   embed_model = "nomic-embed-text:latest",
        --   endpoint = "http://host.docker.internal:11434",
        -- }
        opts.web_search_engine = {
          provider = "tavily",
        }
      end
      if require("config.utils").is_mcp_present() then
        opts.system_prompt = function()
          local hub = require("mcphub").get_hub_instance()
          return hub:get_active_servers_prompt()
        end
        opts.custom_tools = function()
          return {
            require("mcphub.extensions.avante").mcp_tool(),
          }
        end
      end
      return opts
    end,
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
    },
    keys = {
      {
        "<leader>aa",
        function()
          require("avante.api").ask()
        end,
        desc = "Ask",
        mode = { "n", "v" },
      },
      {
        "<leader>ae",
        function()
          require("avante.api").edit()
        end,
        desc = "Edit",
        mode = { "n", "v" },
      },
      {
        "<leader>af",
        "<cmd>AvanteClear<cr>",
        mode = { "n", "v" },
        desc = "Clear",
      },
      {
        "<leader>a?",
        function()
          require("avante.api").select_model()
        end,
        desc = "Select model",
        mode = "n",
      },
      {
        "<leader>ar",
        create_avante_call(avante_prompts.refactor),
        mode = { "n", "v" },
        desc = "Refactor Code",
      },
      {
        "<leader>av",
        function()
          if vim.bo.filetype == "rust" or vim.bo.filetype == "toml" then
            create_avante_call(avante_prompts.rust_design_review)()
          else
            create_avante_call(avante_prompts.code_review)()
          end
        end,
        mode = { "n", "v" },
        desc = "Code Review",
      },
      {
        "<leader>aA",
        create_avante_call(avante_prompts.architecture_suggestion),
        mode = { "n", "v" },
        desc = "Architecture Suggestions",
      },
      {
        "<leader>al",
        create_avante_call(avante_prompts.readability_analysis),
        desc = "Code Readability Analysis",
        mode = { "n", "v" },
      },
      {
        "<leader>ao",
        create_avante_call(avante_prompts.optimize_code),
        mode = { "n", "v" },
        desc = "Optimize Code",
      },
      {
        "<leader>ax",
        create_avante_call(avante_prompts.explain_code, true),
        mode = { "n", "v" },
        desc = "Explain Code",
      },
      {
        "<leader>ab",
        create_avante_call(avante_prompts.fix_bugs, true),
        mode = { "n", "v" },
        desc = "Fix Bugs",
      },
      {
        "<leader>au",
        create_avante_call(avante_prompts.add_tests),
        mode = { "n", "v" },
        desc = "Add Tests",
      },
      {
        "<leader>az",
        create_avante_call(avante_prompts.security_review),
        mode = { "n", "v" },
        desc = "Security Analysis",
      },
      {
        "<leader>am",
        create_avante_call(avante_prompts.summarize),
        mode = { "n", "v" },
        desc = "Summarize text",
      },
      {
        "<leader>ap",
        function()
          local ft = vim.bo.filetype
          local prompt = avante_prompts.language_specific[ft]
              or ("Improve this code following best practices for " .. ft)
          create_avante_call(prompt)()
        end,
        mode = { "n", "v" },
        desc = "Language-specific improvements",
      },
    },
  },
}
