local icons = {
  error = " ",
  warn = " ",
  info = "",
  hint = " ",
}

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts = opts or {}
    opts.servers["*"] = opts.servers["*"] or {}
    opts.servers["*"].keys = opts.servers["*"].keys or {}
    vim.list_extend(opts.servers["*"].keys, {
      { "gd", "<cmd>Trouble lsp_definitions<cr>", desc = "Goto Definition", has = "definition" },
      { "gr", "<cmd>Trouble lsp_references<cr>", desc = "References", nowait = true },
      { "gI", "<cmd>Trouble lsp_implementations<cr>", desc = "Goto Implementation", nowait = true },
      { "gy", "<cmd>Trouble lsp_type_definitions<cr>", desc = "Goto T[y]pe Definition", nowait = true },
    })
    opts.diagnostics = {
      virtual_text = false,
      underline = false,
      signs = {
        active = true,
        text = {
          [vim.diagnostic.severity.ERROR] = icons.error,
          [vim.diagnostic.severity.WARN] = icons.warn,
          [vim.diagnostic.severity.INFO] = icons.info,
          [vim.diagnostic.severity.HINT] = icons.hint,
        },
        values = {
          { name = "DiagnosticSignError", text = icons.error },
          { name = "DiagnosticSignWarn", text = icons.warn },
          { name = "DiagnosticSignInfo", text = icons.info },
          { name = "DiagnosticSignHint", text = icons.hint },
        },
      },
    }
    opts.codelens = {
      enabled = false,
    }
    opts.inlay_hints = {
      enabled = false,
    }
    if not require("config.utils").is_online() then
      opts.servers.copilot = { enabled = false }
    end
    -- opts.servers = opts.servers or {}
    opts.servers.jsonls = {
      before_init = function(_, new_config)
        new_config.settings.json.schemas = new_config.settings.json.schemas or {}
        vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
      end,
      settings = {
        json = {
          format = {
            enable = true,
          },
          validate = { enable = true },
        },
      },
    }
    opts.servers.yamlls = {
      cmd = { "yaml-language-server", "--stdio" },
      flags = {
        allow_incremental_sync = false,
        debounce_text_changes = 150,
      },
      filetypes = { "yaml", "gha", "dependabot", "yaml", "yaml.docker-compose", "yaml.gitlab" },
      on_attach = function(client, _)
        -- yaml-language-server mis-handles incremental sync and crashes
        -- vim.lsp.sync with assertion failures on yank/paste. Force Full sync.
        if client.server_capabilities then
          client.server_capabilities.textDocumentSync = {
            openClose = true,
            change = 1, -- 1 = Full, 2 = Incremental
            save = { includeText = false },
          }
        end
      end,
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
          synchronization = {
            dynamicRegistration = true,
            willSave = false,
            willSaveWaitUntil = false,
            didSave = true,
          },
        },
      },
      before_init = function(_, new_config)
        new_config.settings.yaml.schemas = vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {
          kubernetes = {
            "daemon.{yml,yaml}",
            "manager.{yml,yaml}",
            "restapi.{yml,yaml}",
            "kubectl-edit*.yaml",
          },
          ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/configmap.json"] = "*onfigma*.{yml,yaml}",
          ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/deployment.json"] = "*eployment*.{yml,yaml}",
          ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/service.json"] = "*ervic*.{yml,yaml}",
          ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/ingress.json"] = "*ngres*.{yml,yaml}",
          ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/secret.json"] = "*ecre*.{yml,yaml}",
        }, require("schemastore").yaml.schemas())
      end,
      root_markers = { ".git" },
      settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
          keyOrdering = false,
          schemaStore = {
            enable = true,
            url = "https://www.schemastore.org/api/json/catalog.json",
          },
          -- schemas = require("schemastore").yaml.schemas(),
          validate = true,
          hover = true,
          format = {
            enable = false, -- delegate to conform.nvim
          },
        },
      },
    }
    opts.servers.dockerls = {
      cmd = { "docker-langserver", "--stdio" },
      filetypes = { "dockerfile" },
      root_markers = { "Dockerfile" },
      settings = {
        docker = {},
      },
    }
    opts.servers.clangd = {
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      keys = {
        { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
      },
      root_markers = {
        ".clang-format",
        ".clang-tidy",
        ".clangd",
        ".git",
        "Makefile",
        "build.ninja",
        "compile_commands.json",
        "compile_flags.txt",
        "config.h.in",
        "configure.ac",
        "configure.in",
        "meson.build",
        "meson_options.txt",
      },
      capabilities = {
        positionEncodings = { "utf-16" },
        textDocument = {
          completion = {
            editsNearCursor = true,
          },
        },
      },
      cmd = {
        "clangd",
        "--all-scopes-completion",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--enable-config",
        "--fallback-style=llvm",
        "--function-arg-placeholders=1",
        "--header-insertion-decorators",
        "--header-insertion=iwyu",
        "--log=error",
        "--offset-encoding=utf-16",
        "--pch-storage=memory",
        "--ranking-model=heuristics",
        "-j=12",
      },
      before_init = function(_, config)
        local fallback_flags = { "-std=c++23", "-stdlib=libc++" }
        local compile_flags = config.root_dir and (config.root_dir .. "/compile_flags.txt") or nil

        -- Let project-local compile flags win; only apply the C++23 fallback when clangd
        -- has no compilation database or compile_flags.txt to read from.
        if compile_flags and vim.uv.fs_stat(compile_flags) then
          config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
            fallbackFlags = {},
          })
          return
        end

        config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
          fallbackFlags = fallback_flags,
        })
      end,
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
    }

    local pylance_bundle = vim.fn.expand("~/.pylance/extension/dist/server.bundle.js")
    if vim.uv.fs_stat(pylance_bundle) then
      local root_files = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
      }

      local function exepath(expr)
        local ep = vim.fn.exepath(expr)
        return ep ~= "" and ep or nil
      end
      opts.servers.pylance = {
        mason = false,
        before_init = function(_, config)
          if not config.settings.python.pythonPath then
            config.settings.python.pythonPath = exepath("python3") or exepath("python") or "python"
          end
        end,
        cmd = {
          "node",
          pylance_bundle,
          "--stdio",
        },
        filetypes = { "python" },
        single_file_support = true,
        root_markers = root_files,
        settings = {
          python = {
            analysis = {
              inlayHints = {
                variableTypes = true,
                functionReturnTypes = false,
                callArgumentNames = true,
                pytestParameters = true,
              },
            },
          },
        },
      }
    end
    return opts
  end,
}
