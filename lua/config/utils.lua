local M = {}

local api = vim.api
local fn = vim.fn
local ts = vim.treesitter

local import_patterns = {
  c = {
    { "^%s*#%s*include%f[%W]", "#include", "@keyword.directive" },
  },
  go = {
    { "^%s*import%f[%W]", "import", "@keyword.import" },
  },
  rust = {
    { "^%s*pub%s*%b()%s*use%f[%W]", "pub use", "@keyword.import", "use" },
    { "^%s*pub%s+use%f[%W]", "pub use", "@keyword.import", "use" },
    { "^%s*use%f[%W]", "use", "@keyword.import", "use" },
    { "^%s*pub%s*%b()%s*mod%s+[%w_]+%s*;", "pub mod", "@keyword.import", "mod" },
    { "^%s*pub%s+mod%s+[%w_]+%s*;", "pub mod", "@keyword.import", "mod" },
    { "^%s*mod%s+[%w_]+%s*;", "mod", "@keyword.import", "mod" },
  },
  python = {
    { "^%s*from%s+[%w_%.]+%s+import%f[%W]", "from … import", "@keyword.import" },
    { "^%s*import%f[%W]", "import", "@keyword.import" },
  },
}

import_patterns.cpp = import_patterns.c

local import_minimum = { c = 3, cpp = 3 }

local function import_directive(line, filetype)
  local patterns = import_patterns[filetype]

  if not patterns then
    return
  end

  for _, entry in ipairs(patterns) do
    if line:match(entry[1]) then
      return (line:match("^%s*") or "") .. entry[2], entry[3], entry[4] or entry[2]
    end
  end
end

local function fold_suffix(line, marker)
  local count = vim.v.foldend - vim.v.foldstart + 1
  local unit = count == 1 and "line" or "lines"
  if not marker then
    if line:match("{%s*$") then
      marker = "... }"
    else
      marker = "…"
    end
  end

  return { { string.format(" %s ( %d %s)", marker, count, unit), "Folded" } }
end

local function truncate_chunks(chunks, max_width)
  local truncated = {}
  local remaining = max_width

  for _, chunk in ipairs(chunks) do
    local text, highlight = chunk[1], chunk[2]
    local width = fn.strdisplaywidth(text)

    if width <= remaining then
      truncated[#truncated + 1] = chunk
      remaining = remaining - width
    else
      local characters = fn.strchars(text)

      while characters > 0 and fn.strdisplaywidth(fn.strcharpart(text, 0, characters)) > remaining do
        characters = characters - 1
      end

      if characters > 0 then
        truncated[#truncated + 1] = { fn.strcharpart(text, 0, characters), highlight }
      end

      return truncated, true
    end
  end

  return truncated, false
end

local function foldtext_width()
  local winid = api.nvim_get_current_win()
  local wininfo = fn.getwininfo(winid)[1] or {}
  local available_width = api.nvim_win_get_width(winid) - (wininfo.textoff or 0)

  return math.max(math.min(available_width, 180), 1)
end

local run_cache = { bufnr = -1, tick = -1, first = 0, last = -1 }

local function import_run_length(lnum, filetype)
  local bufnr = api.nvim_get_current_buf()
  local tick = api.nvim_buf_get_changedtick(bufnr)

  if run_cache.bufnr == bufnr and run_cache.tick == tick and lnum >= run_cache.first and lnum <= run_cache.last then
    return run_cache.first, run_cache.last
  end
  local line = fn.getline(lnum)
  local indent = line:match("^%s*") or ""
  local _, _, group = import_directive(line, filetype)
  local first = lnum
  local last = lnum

  while first > 1 do
    local previous = fn.getline(first - 1)
    local _, _, other = import_directive(previous, filetype)
    if other ~= group or (previous:match("^%s*") or "") ~= indent then
      break
    end

    first = first - 1
  end

  while last < api.nvim_buf_line_count(bufnr) do
    local following = fn.getline(last + 1)
    local _, _, other = import_directive(following, filetype)
    if other ~= group or (following:match("^%s*") or "") ~= indent then
      break
    end

    last = last + 1
  end

  run_cache.bufnr = bufnr
  run_cache.tick = tick
  run_cache.first = first
  run_cache.last = last
  return first, last
end

local function paren_delta(line)
  local _, open = line:gsub("[%(%[]", "")
  local _, close = line:gsub("[%)%]]", "")

  return open - close
end

local function fold_level(expression)
  return math.max(tonumber(tostring(expression):match("%-?%d+")) or 0, 0)
end

local function signature_rows(start_line, end_line)
  local rows = { start_line }
  local depth = paren_delta(fn.getline(start_line))

  while depth > 0 and rows[#rows] < end_line and #rows < 6 do
    local lnum = rows[#rows] + 1

    rows[#rows + 1] = lnum
    depth = depth + paren_delta(fn.getline(lnum))
  end

  local truncated = depth > 0
  local last = rows[#rows]
  if last < end_line and not fn.getline(last):match("[{:]%s*$") and fn.getline(last + 1):match("^%s*{") then
    rows[#rows + 1] = last + 1
  end

  return rows, truncated
end

local function needs_space(previous, current)
  if previous:match("[%(%[{]%s*$") then
    return false
  end

  if current:match("^%s*[%)%]},;]") then
    return false
  end

  return true
end

local ignored_captures = {
  spell = true,
  nospell = true,
  conceal = true,
}

-- treesitter-highlighted chunks for `text` (row `row`), starting at `start_col`
local function append_chunks(result, query, root, bufnr, row, text, start_col)
  local captures = {}
  local seen = {}

  for id, node, metadata in query:iter_captures(root, bufnr, row, row + 1) do
    local name = query.captures[id]
    local start_row, node_start, end_row, node_end = node:range()

    if start_row == row and end_row == row and not ignored_captures[name] then
      local key = node_start .. ":" .. node_end
      local priority = tonumber(metadata.priority or (metadata[id] or {}).priority) or 100
      local existing = seen[key]

      if not existing or priority >= existing.priority then
        seen[key] = {
          start_col = node_start,
          end_col = node_end,
          highlight = "@" .. name,
          priority = priority,
        }
      end
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

  local position = start_col

  for _, capture in ipairs(captures) do
    if capture.start_col >= position and capture.start_col < #text then
      local stop = math.min(capture.end_col, #text)
      if capture.start_col > position then
        result[#result + 1] = { text:sub(position + 1, capture.start_col), "Folded" }
      end

      result[#result + 1] = {
        text:sub(capture.start_col + 1, stop),
        capture.highlight,
      }

      position = stop
    end
  end

  if position < #text then
    result[#result + 1] = { text:sub(position + 1), "Folded" }
  end
end

local function dim_trailing_brace(result)
  local chunk = result[#result]

  if not chunk or chunk[2] == "Folded" then
    return
  end

  local head, brace = chunk[1]:match("^(.-)([{:])$")

  if not brace then
    return
  end

  if head == "" then
    chunk[2] = "Folded"
  else
    chunk[1] = head
    result[#result + 1] = { brace, "Folded" }
  end
end

local function signature_tail(line)
  if not line:match("^%s*[%)%]}]") then
    return false
  end

  return line:match("{%s*$") ~= nil or line:match(":%s*$") ~= nil
end

function M.foldexpr()
  local lnum = vim.v.lnum
  local filetype = vim.bo.filetype
  local line = fn.getline(lnum)
  local expression = tostring(ts.foldexpr(lnum))

  if lnum > 1 and expression:sub(1, 1) == ">" and signature_tail(line) then
    local level = fold_level(expression)

    if fold_level(ts.foldexpr(lnum - 1)) >= level then
      expression = tostring(level)
    end
  end

  if not import_directive(line, filetype) then
    return expression
  end

  local first, last = import_run_length(lnum, filetype)
  local minimum = import_minimum[filetype] or 2

  if last - first + 1 < minimum then
    return expression
  end

  local level = fold_level(expression) + 1

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
  local line = fn.getline(start_line)
  local filetype = vim.bo[bufnr].filetype

  if line == "" then
    return fn.foldtext()
  end

  local directive, highlight = import_directive(line, filetype)

  if directive then
    local chunks = { { directive, highlight } }
    vim.list_extend(chunks, fold_suffix(line, "…"))
    return chunks
  end

  local rows, truncated = signature_rows(start_line, vim.v.foldend)
  local last_line = fn.getline(rows[#rows])
  local lang = ts.language.get_lang(filetype)
  if not lang then
    return fn.foldtext()
  end

  local parser = ts.get_parser(bufnr, lang, { error = false })

  if not parser then
    return fn.foldtext()
  end

  local query = ts.query.get(lang, "highlights")
  if not query then
    return fn.foldtext()
  end

  local parsed, trees = pcall(parser.parse, parser, {
    rows[1] - 1,
    rows[#rows],
  })

  local tree = parsed and trees and trees[1]
  if not tree then
    return fn.foldtext()
  end

  local root = tree:root()
  local result = {}

  for index, lnum in ipairs(rows) do
    local text = fn.getline(lnum):gsub("%s+$", "")
    local start_col = 0

    local following = rows[index + 1] and fn.getline(rows[index + 1])

    if not following or following:match("^%s*[%)%]}]") then
      text = text:gsub(",$", "")
    end

    if index > 1 then
      start_col = #(text:match("^%s*") or "")

      if needs_space(fn.getline(rows[index - 1]), text) then
        result[#result + 1] = { " ", "Folded" }
      end
    end

    append_chunks(result, query, root, bufnr, lnum - 1, text, start_col)
  end

  dim_trailing_brace(result)
  local regular_suffix = fold_suffix(last_line, truncated and "󱗾" or nil)
  local shortened_suffix = fold_suffix(last_line, "󱗾")
  local suffix_width = math.max(fn.strdisplaywidth(regular_suffix[1][1]), fn.strdisplaywidth(shortened_suffix[1][1]))
  local visible, width_truncated = truncate_chunks(result, foldtext_width() - suffix_width)

  vim.list_extend(visible, width_truncated and shortened_suffix or regular_suffix)

  return visible
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
  local home = vim.env.HOME
  local home_pattern = home and home ~= "" and ("^" .. vim.pesc(home)) or nil

  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local str
    if not e then
      break
    end

    if e.valid == 1 then
      local fname = ""
      if e.bufnr > 0 then
        fname = api.nvim_buf_get_name(e.bufnr)
        if fname == "" then
          fname = "[No Name]"
        elseif home_pattern then
          fname = fname:gsub(home_pattern, "~")
        end

        if #fname <= limit then
          fname = string.format(fname_fmt1, fname)
        else
          fname = string.format(fname_fmt2, fname:sub(1 - limit))
        end
      end

      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
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
  return M.is_online() and vim.uv.fs_stat(fn.expand("~/.mcpservers.json")) ~= nil
end

M.is_online = function()
  return vim.env.NVIM_OFFLINE ~= "1"
end

return M
