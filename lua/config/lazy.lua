local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
  local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
  local lazy_commit = assert(lock["lazy.nvim"] and lock["lazy.nvim"].commit, "lazy.nvim is not pinned in lazy-lock.json")
  local clone = vim.system({ "git", "clone", "--filter=blob:none", "--no-checkout", lazyrepo, lazypath }, { text = true }):wait()
  local checkout = clone.code == 0
      and vim.system({ "git", "-C", lazypath, "checkout", "--detach", lazy_commit }, { text = true }):wait()
    or nil
  if clone.code ~= 0 or not checkout or checkout.code ~= 0 then
    local out = clone.code ~= 0 and clone.stderr or checkout and checkout.stderr or "Unknown bootstrap error"
    vim.fn.delete(lazypath, "rf")
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out or "", "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins", version = false },
    { import = "plugins" },
  },
  defaults = {
    version = false,
  },
  install = {
    -- Restore missing plugins explicitly with :Lazy restore; never fetch code during startup.
    missing = false,
    colorscheme = {
      "tokyonight",
      "catppuccin",
      "habamax",
    },
  },
  local_spec = false,
  rocks = { enabled = false },
  checker = {
    enabled = false,
    notify = false,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
