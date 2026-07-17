local function env_cleanup(venv)
  return venv:match("[^/]+$") or venv
end

local vim_fn = vim.fn
local vim_api = vim.api
local vim_bo = vim.bo

local conditions = {
  buffer_not_empty = function()
    return vim_fn.empty(vim_fn.expand("%:t")) ~= 1
  end,
  hide_in_width = function()
    return vim.o.columns > 80
  end,
  hide_small = function()
    return vim.o.columns > 140
  end,
  check_git_workspace = function()
    local filepath = vim_fn.expand("%:p:h")
    local gitdir = vim_fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local function all_conditions(...)
  local checks = { ... }
  return function()
    for _, check in ipairs(checks) do
      if not check() then
        return false
      end
    end
    return true
  end
end

local function sidekick_status()
  local status = package.loaded["sidekick.status"]
  return type(status) == "table" and status.get() or nil
end

local icons = {
  normal = { " 󰊠 ", "  ", "  ", "  ", "  ", "  ", "  ", " 󰄌 ", "  " }, --  , 󱗃 ,  , 󰮣 , 󰌪 ,
  insert = { "  ", "  ", " 󰣙 ", "  ", " 󰛓 ", "  ", " 󰧑 ", " 󰚥 ", " 󰊴 " }, --  , ,   ,  , 󰼁
  visual = { "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", " 󰟡 " }, --  ,   , 󰖠 , 󰹭
  command = { " 󰏒 ", "  ", "  ", " 󰘳 ", " 󰼭 ", "  ", "  ", " 󰴾 ", " 󰸷 " }, --  ,  , 󰤱 ,   󰛮 󰍆
  replace = { "  ", "  ", "  ", " 󰤇 ", " 󰛗 ", "  ", " 󱩡 ", " 󱄇 ", "  " }, --  , 󰫿,  󱄛 ,  , 󰠥 , 
}
local mode_groups = {
  normal = { "n", "no", "nov" },
  insert = { "i", "ic", "ix" },
  visual = { "V", "v", "vs", "Vs", "cv" },
  command = { "c", "ce" },
  replace = { "r", "rm", "r?", "R", "Rc", "Rv" },
}

local mode_to_group = {}
for group, modes in pairs(mode_groups) do
  for _, m in ipairs(modes) do
    mode_to_group[m] = group
  end
end

local mode = function()
  local mod = vim_fn.mode()
  local selector = vim.g.lualine_icon_selector
  if selector == nil then
    math.randomseed(os.time())
    vim.g.lualine_icon_selector = math.random(#icons.normal)
    selector = vim.g.lualine_icon_selector
  end

  local group = mode_to_group[mod] or "normal"
  return icons[group][selector]
end

local colors = {
  bg = "#161617",
  fg = "#c9c7cd",
  subtext1 = "#b4b1ba",
  subtext2 = "#9f9ca6",
  subtext3 = "#8b8693",
  subtext4 = "#6c6874",
  -- bg_dark = "#1A1B26",
  bg_dark = "#1e1e2e",
  black = "#27272a",
  red = "#ea83a5",
  green = "#90b99f",
  yellow = "#e6b99d",
  purple = "#aca1cf",
  magenta = "#e29eca",
  orange = "#f5a191",
  blue = "#92a2d5",
  cyan = "#85b5ba",
  bright_black = "#353539",
  bright_red = "#f591b2",
  bright_green = "#9dc6ac",
  bright_yellow = "#f0c5a9",
  bright_purple = "#b9aeda",
  bright_magenta = "#ecaad6",
  bright_orange = "#ffae9f",
  bright_blue = "#a6b6e9",
  bright_cyan = "#99c9ce",
  gray0 = "#18181a",
  gray1 = "#1b1b1c",
  gray2 = "#2a2a2c",
  gray3 = "#313134",
  gray4 = "#3b3b3e",
  none = "NONE",
}

local modecolor = {
  n = colors.red,
  i = colors.cyan,
  v = colors.purple,
  [""] = colors.purple,
  V = colors.red,
  c = colors.yellow,
  no = colors.red,
  s = colors.yellow,
  S = colors.yellow,
  [""] = colors.yellow,
  ic = colors.yellow,
  R = colors.green,
  Rv = colors.purple,
  cv = colors.red,
  ce = colors.red,
  r = colors.cyan,
  rm = colors.cyan,
  ["r?"] = colors.cyan,
  ["!"] = colors.red,
  t = colors.bright_red,
}

local scrollbar = {
  function()
    local sbar_chars = {
      "▔",
      "🮂",
      "🬂",
      "🮃",
      "▀",
      "━",
      "▄",
      "▃",
      "🬭",
      "▂",
      "▁",
    }

    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)

    local i = math.floor((cur_line - 1) / lines * #sbar_chars) + 1
    local sbar = string.rep(sbar_chars[i], 2)

    return sbar
  end,
  color = { bg = colors.bg_dark, fg = colors.red },
}

local lsp_cache = { value = nil, clients_hash = nil }
local function getLspName()
  local bufnr = vim_api.nvim_get_current_buf()
  local buf_clients = vim.lsp.get_clients({ bufnr = bufnr })

  if next(buf_clients) == nil then
    lsp_cache.value = "  No servers"
    lsp_cache.clients_hash = ""
    return lsp_cache.value
  end

  local current_hash = ""
  for _, client in pairs(buf_clients) do
    current_hash = current_hash .. client.name
  end

  if lsp_cache.clients_hash == current_hash and lsp_cache.value then
    return lsp_cache.value
  end

  local buf_client_names = {}
  local buf_ft = vim_bo.filetype

  for _, client in pairs(buf_clients) do
    if client.name ~= "null-ls" then
      table.insert(buf_client_names, client.name)
    end
  end

  local lint = package.loaded["lint"]

  if lint and lint.linters_by_ft[buf_ft] then
    local linters = lint.linters_by_ft[buf_ft]
    if type(linters) == "table" then
      for _, linter in ipairs(linters) do
        table.insert(buf_client_names, linter)
      end
    elseif type(linters) == "string" then
      table.insert(buf_client_names, linters)
    end
  end

  local hash = {}
  local unique_client_names = {}

  for _, v in ipairs(buf_client_names) do
    if not hash[v] then
      unique_client_names[#unique_client_names + 1] = v
      hash[v] = true
    end
  end

  local language_servers = table.concat(unique_client_names, ", ")
  lsp_cache.value = language_servers
  lsp_cache.clients_hash = current_hash

  return language_servers
end

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local noice_status_mode = require("noice").api.status.mode

      local space = {
        function()
          return " "
        end,
        color = { bg = colors.bg_dark, fg = colors.blue },
      }

      local filename = {
        function()
          local fname = vim_fn.expand("%:p")
          local filename = vim_fn.expand("%:t")
          local ftype = vim_bo.filetype
          local cwd = vim_api.nvim_call_function("getcwd", {})

          if vim_bo.filetype == "yaml" and string.sub(filename, 1, 11) == "kubectl-edit" then
            return "kubernetes"
          end

          local show_name = filename
          if #cwd > 0 and #ftype > 0 then
            if string.find(fname, cwd) then
              local relative_path = fname:sub(#cwd + 2)
              local shortened_path = relative_path:gsub("([^/]+)/", function(dir)
                return dir:sub(1, 1) .. "/"
              end)
              show_name = shortened_path
            else
              show_name = filename
            end
          end

          local indicators = ""
          if vim_bo.readonly then
            indicators = indicators .. "  "
          end
          if vim_bo.modified then
            indicators = indicators .. "  "
          end

          return indicators .. show_name
        end,
        cond = all_conditions(conditions.buffer_not_empty, conditions.hide_small),
        color = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        separator = { left = "", right = "" },
      }

      local filetype = {
        "filetype",
        icons_enabled = false,
        color = { bg = colors.gray2, fg = colors.blue, gui = "bold" },
        separator = { left = "", right = "" },
        cond = all_conditions(conditions.buffer_not_empty, conditions.hide_small),
      }

      local branch = {
        "branch",
        icon = "",
        color = { bg = colors.green, fg = colors.bg, gui = "bold" },
        separator = { left = "", right = "" },
        cond = all_conditions(conditions.check_git_workspace, conditions.hide_in_width),
      }

      local location = {
        function()
          local line = vim.fn.line(".")
          local col = vim.fn.charcol(".")
          return string.format("%3d:%-2d", line, col)
        end,
        color = { bg = colors.yellow, fg = colors.bg_dark, gui = "bold" },
        separator = { left = "", right = "" },
        cond = all_conditions(conditions.buffer_not_empty, conditions.hide_small),
      }

      local diff = {
        "diff",
        color = { bg = colors.gray2, fg = colors.bg, gui = "bold" },
        separator = { left = "", right = "" },
        symbols = { added = " ", modified = " ", removed = " " },

        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.yellow },
          removed = { fg = colors.red },
        },
        cond = all_conditions(conditions.buffer_not_empty, conditions.hide_small),
      }

      local pyenv = {
        function()
          if vim_bo.filetype ~= "python" then
            return ""
          end

          local venv = vim.env.CONDA_DEFAULT_ENV or vim.env.VIRTUAL_ENV

          if venv then
            return string.format("  %s", env_cleanup(venv))
          end

          return ""
        end,
        separator = { left = "", right = "" },
        color = { bg = colors.gray2, fg = colors.blue, gui = "bold" },
        cond = conditions.hide_in_width,
      }

      local modes = {
        function()
          return mode()
        end,
        color = function()
          local mode_color = modecolor
          return { bg = mode_color[vim_fn.mode()], fg = colors.bg_dark, gui = "bold" }
        end,
        separator = { left = "", right = "" },
      }

      local kuber = {
        function()
          if vim_bo.filetype ~= "yaml" then
            return ""
          end

          local fname = vim_fn.expand("%:t")
          if fname:sub(1, 11) ~= "kubectl-edit" then
            return ""
          end

          local kube_env = vim.env.KUBECONFIG
          return string.format("⎈  (%s)", env_cleanup(kube_env))
        end,
        color = { fg = colors.cyan, bg = colors.bg },
        cond = conditions.hide_small,
      }

      local macro = {
        function()
          local reg = vim.fn.reg_recording()
          if reg ~= "" then
            return "󰃼 @" .. reg
          end
          return ""
        end,
        cond = noice_status_mode.has,
        color = { fg = colors.red, bg = colors.bg_dark, gui = "bold" },
      }

      local dia = {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.purple },
          hint = { fg = colors.cyan },
        },
        color = { bg = colors.gray2, fg = colors.blue, gui = "bold" },
        separator = { left = "" },
      }

      local overseer = {
        "overseer",
        -- color = { fg = colors.blue, bg = colors.bg_dark },
        separator = { left = "", right = "" },
        color = { bg = colors.gray2, fg = colors.blue, gui = "bold" },
      }

      local lsp = {
        function()
          return getLspName()
        end,
        separator = { left = "", right = "" },
        cond = conditions.hide_small,
        color = { bg = colors.purple, fg = colors.bg, gui = "bold" },
      }

      local opts = {
        options = {
          theme = "catppuccin",
          icons_enabled = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard", "snacks_terminal" },
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = vim.env.TMUX == nil,
        },
        sections = {
          lualine_a = {
            modes,
          },
          lualine_b = {
            kuber,
            pyenv,
            space,
          },
          lualine_c = {
            branch,
            filetype,
            diff,
            space,
            filename,
            location,
          },
          lualine_x = { macro },
          lualine_y = { overseer },
          lualine_z = {
            dia,
            lsp,
            scrollbar,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      }
      table.insert(opts.sections.lualine_y, 3, {
        function()
          local status = sidekick_status()
          if status and status.kind == "Normal" then
            return LazyVim.config.icons.kinds.Copilot
          end
          return ""
        end,
        cond = all_conditions(conditions.buffer_not_empty, conditions.hide_small, sidekick_status),
        color = { bg = colors.gray2, fg = colors.blue, gui = "bold" },
        separator = { left = "", right = "" },
      })
      if require("config.utils").is_mcp_present() then
        table.insert(opts.sections.lualine_y, 1, {
          function()
            local count_or_spinner = vim.g.mcphub_executing and "⠋" or tostring(vim.g.mcphub_servers_count or 0)
            return "󰐻 " .. count_or_spinner
          end,
          color = { bg = colors.gray2, fg = colors.blue, gui = "bold" },
          separator = { left = "", right = "" },
          cond = all_conditions(conditions.buffer_not_empty, conditions.hide_small, function()
            local status = vim.g.mcphub_status
            return status ~= nil and status ~= "stopped"
          end),
        })
      end

      local auto = require("lualine.themes.auto")
      local lualine_modes = { "insert", "normal", "visual", "command", "replace", "inactive", "terminal" }
      for _, field in ipairs(lualine_modes) do
        if auto[field] and auto[field].c then
          auto[field].c.bg = colors.bg_dark
        end
      end
      opts.options.theme = auto
      require("lualine").setup(opts)
      local lualine_nvim_opts = require("lualine.utils.nvim_opts")
      local base_set = lualine_nvim_opts.set

      lualine_nvim_opts.set = function(name, val, scope)
        if vim.env.TMUX and name == "statusline" then
          if scope and scope.window == vim_api.nvim_get_current_win() then
            vim.g.tpipeline_statusline = val
            vim.cmd("silent! call tpipeline#update()")
          end
          return
        end
        return base_set(name, val, scope)
      end
    end,
  },
  {
    "vimpostor/vim-tpipeline",
    dependencies = { "nvim-lualine/lualine.nvim" },
    event = "VeryLazy",
    enabled = vim.env.TMUX ~= nil,
    config = function()
      vim.opt.cmdheight = 0
      vim.opt.laststatus = 0
      vim.g.tpipeline_cursormoved = 1
      -- vim.g.tpipeline_clearstl = 1
      -- HACK: lualine hijacks the statusline, so we need to set it back to what we want
      -- if vim.env.TMUX then
      --   vim.cmd([[ autocmd WinEnter,BufEnter,VimResized,Filetype * setlocal laststatus=0 ]])
      -- end
    end,
  },
}
