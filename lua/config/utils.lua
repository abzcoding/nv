local M = {}

local api = vim.api
local fn = vim.fn
local ts = vim.treesitter

local import_filetypes = {
  c = true,
  cpp = true,
  go = true,
  rust = true,
  python = true,
}

local function import_directive(line, filetype)
  local indent = line:match("^%s*") or ""

  if filetype == "c" or filetype == "cpp" then
    if line:match("^%s*#%s*include%f[%W]") then
      return indent .. "#include", "@keyword.directive"
    end
  elseif filetype == "go" then
    if line:match("^%s*import%f[%W]") then
      return indent .. "import", "@keyword.import"
    end
  elseif filetype == "rust" then
    if line:match("^%s*pub%s+use%f[%W]") then
      return indent .. "pub use", "@keyword.import"
    end

    if line:match("^%s*use%f[%W]") then
      return indent .. "use", "@keyword.import"
    end
  elseif filetype == "python" then
    if line:match("^%s*from%s+[%w_%.]+%s+import%f[%W]") then
      return indent .. "from … import", "@keyword.import"
    end

    if line:match("^%s*import%f[%W]") then
      return indent .. "import", "@keyword.import"
    end
  end
end

local function fold_suffix(line)
  local count = vim.v.foldend - vim.v.foldstart
  local marker = line:match("{%s*$") and "... }" or "{ ... }"
  local unit = count == 1 and "line" or "lines"

  return string.format(" %s ( %d %s)", marker, count, unit)
end

local function import_run_length(lnum, filetype)
  local line = fn.getline(lnum)
  local indent = line:match("^%s*") or ""
  local first = lnum
  local last = lnum

  while first > 1 do
    local previous = fn.getline(first - 1)

    if not import_directive(previous, filetype) or (previous:match("^%s*") or "") ~= indent then
      break
    end

    first = first - 1
  end

  while last < fn.line("$") do
    local following = fn.getline(last + 1)

    if not import_directive(following, filetype) or (following:match("^%s*") or "") ~= indent then
      break
    end

    last = last + 1
  end

  return first, last
end

function M.foldexpr()
  local lnum = vim.v.lnum
  local filetype = vim.bo.filetype
  local line = fn.getline(lnum)
  local expression = ts.foldexpr(lnum)

  if not import_filetypes[filetype] or not import_directive(line, filetype) then
    return expression
  end

  local first, last = import_run_length(lnum, filetype)
  local minimum = filetype == "c" or filetype == "cpp" and 3 or 2

  if last - first + 1 < minimum then
    return expression
  end

  local level = (tonumber(expression:match("%d+")) or 0) + 1

  if lnum == first then
    return ">" .. level
  end

  if lnum == last then
    return "<" .. level
  end

  return tostring(level)
end

function M.foldtext()
  local bufnr = api.nvim_get_current_buf()
  local start_line = vim.v.foldstart
  local row = start_line - 1
  local line = fn.getline(start_line)
  local filetype = vim.bo[bufnr].filetype

  if line == "" then
    return fn.foldtext()
  end

  local directive, highlight = import_directive(line, filetype)

  if directive then
    return {
      { directive, highlight },
      { fold_suffix(line), "Folded" },
    }
  end

  local lang = ts.language.get_lang(filetype)
  if not lang then
    return fn.foldtext()
  end

  local ok, parser = pcall(ts.get_parser, bufnr, lang, {
    error = false,
  })

  if not ok or not parser then
    return fn.foldtext()
  end

  local query = ts.query.get(parser:lang(), "highlights")
  if not query then
    return fn.foldtext()
  end

  local parsed, trees = pcall(parser.parse, parser, {
    row,
    row + 1,
  })

  local tree = parsed and trees and trees[1]
  if not tree then
    return fn.foldtext()
  end

  local captures = {}
  local seen = {}

  for id, node in query:iter_captures(tree:root(), bufnr, row, row + 1) do
    local start_row, start_col, end_row, end_col = node:range()

    if start_row == row and end_row == row then
      local key = start_col .. ":" .. end_col

      seen[key] = {
        start_col = start_col,
        end_col = end_col,
        highlight = "@" .. query.captures[id],
      }
    end
  end

  for _, capture in pairs(seen) do
    captures[#captures + 1] = capture
  end

  table.sort(captures, function(a, b)
    if a.start_col == b.start_col then
      return a.end_col < b.end_col
    end

    return a.start_col < b.start_col
  end)

  local result = {}
  local position = 0

  for _, capture in ipairs(captures) do
    if capture.start_col >= position then
      if capture.start_col > position then
        result[#result + 1] = {
          line:sub(position + 1, capture.start_col),
          "Folded",
        }
      end

      result[#result + 1] = {
        line:sub(capture.start_col + 1, capture.end_col),
        capture.highlight,
      }

      position = capture.end_col
    end
  end

  if position < #line then
    result[#result + 1] = {
      line:sub(position + 1),
      "Folded",
    }
  end

  result[#result + 1] = {
    fold_suffix(line),
    "Folded",
  }

  return result
end

function M.toggle_theme()
  if (vim.g.colors_name or ""):find("catppuccin") then
    vim.cmd.colorscheme("tokyonight-moon")
  else
    vim.cmd.colorscheme("catppuccin-mocha")
  end
end

function M.qftf(info)
  local items
  local ret = {}

  if info.quickfix == 1 then
    items = fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end

  local limit = 25
  local fname_fmt1 = "%-" .. limit .. "s"
  local fname_fmt2 = "…%." .. (limit - 1) .. "s"
  local valid_fmt = "%s |%5d:%-3d|%s %s"
  local invalid_fmt = "%s"
  local home_pattern = "^" .. vim.env.HOME

  -- use luajit table.new if available
  ret = table.new and table.new(info.end_idx - info.start_idx + 1, 0) or {}

  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local str

    if e.valid == 1 then
      local fname = ""
      if e.bufnr > 0 then
        fname = api.nvim_buf_get_name(e.bufnr)
        if fname == "" then
          fname = "[No Name]"
        else
          fname = fname:gsub(home_pattern, "~")
        end

        if #fname <= limit then
          fname = string.format(fname_fmt1, fname)
        else
          fname = string.format(fname_fmt2, fname:sub(1 - limit))
        end
      end

      local lnum = e.lnum > 99999 and "inf" or e.lnum
      local col = e.col > 999 and "inf" or e.col
      local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()

      str = string.format(valid_fmt, fname, lnum, col, qtype, e.text)
    else
      str = string.format(invalid_fmt, e.text)
    end

    ret[i - info.start_idx + 1] = str
  end

  return ret
end

M.set_terminal_keymaps = function()
  local map = vim.keymap.set
  local opts = { buffer = 0, noremap = true }

  map("t", "<esc>", [[<C-\><C-n>]], opts)
  map("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  map("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  map("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  map("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

M.kind_icons = {
  Array = "",
  Boolean = "󰨙",
  Class = "",
  Codeium = "󰘦",
  Color = "",
  Control = "",
  Collapsed = "",
  Constant = "󰏿",
  Constructor = "",
  Copilot = "",
  Enum = "ℰ",
  EnumMember = "",
  Event = "",
  Field = "󰜢",
  File = "󰈚",
  Folder = "",
  Function = "󰊕",
  Interface = " ",
  Implementation = "",
  Key = "",
  Keyword = "",
  Macro = " 󰁌 ",
  Method = "ƒ",
  Module = "",
  Namespace = "󰦮",
  Null = "",
  Number = "󰎠",
  Object = "",
  Operator = "",
  Package = "",
  Parameter = "",
  Property = "",
  Reference = "",
  Snippet = "", --" ",""," ","󱄽 "
  Spell = "󰓆",
  StaticMethod = "",
  String = "󰅳", -- " ","𝓐 " ," " ,"󰅳 "  
  Struct = "󰙅", -- "  "
  Supermaven = "",
  TabNine = "󰏚",
  Text = "󰉿",
  TypeAlias = "",
  TypeParameter = "",
  Unit = "󰑭",
  Value = "",
  Variable = "󰆦",
}

M.is_mcp_present = function()
  return M.is_online() and vim.uv.fs_stat(vim.fn.expand("~/.mcpservers.json")) ~= nil
end

M.is_online = function()
  return vim.env.NVIM_OFFLINE ~= "1"
end

return M
