# Neovim configuration

This is my daily Neovim configuration. It uses [LazyVim](https://github.com/LazyVim/LazyVim) as a base, keeps plugin installation explicit, and leaves network-dependent AI tools out of the normal startup path.

![Neovim dashboard](https://github.com/user-attachments/assets/1a8fe839-d31b-4478-bb60-9793903254ca)

## What is included

- LSP configuration using `vim.lsp`
- Completion with Blink.cmp
- Git integration with Gitsigns, Lazygit, and Diffview
- Testing and task execution with Neotest and Overseer
- Persistent undo history with Undotree
- Telescope, Grapple, and Oil for navigation
- Optional Copilot, Sidekick, Avante, and MCPHub integrations
- Custom statusline, bufferline, diagnostics, and Markdown rendering

## Requirements

- Neovim 0.13 or newer
- Git
- Rust, used to build Blink.cmp from its `main` branch
- A Nerd Font if you want the configured icons
- The language servers, formatters, linters, and debuggers needed by your projects

Ripgrep and Lazygit are optional, but several search and Git workflows expect them to be available.

## Install

Back up any existing configuration, then clone this repository:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/abzcoding/nv.git ~/.config/nvim
nvim
```

The first launch bootstraps `lazy.nvim` at the commit recorded in `lazy-lock.json`. It does not automatically install the rest of the missing plugins. Review the lockfile, then restore its exact versions from inside Neovim:

```vim
:Lazy restore
```

Restart Neovim after the restore finishes.

## Plugin updates and trust

`lazy-lock.json` is part of this configuration and should remain under version control. Automatic update checks, local plugin specs, Lua rocks, and install-on-startup are disabled. This prevents silent dependency drift; it does not make third-party plugins safe. Plugins and their build hooks still run with your user permissions.

When updating plugins:

1. Run `:Lazy update` deliberately.
2. Review the source changes and the `lazy-lock.json` diff.
3. Test the configuration before committing the new lockfile.

To return to the committed versions, restore `lazy-lock.json` from version control and then run `:Lazy restore`.

This configuration is not a sandbox for hostile repositories. For a quick, plugin-free editing session, use:

```sh
nvim --clean --noplugin -i NONE path/to/file
```

Use an OS-level sandbox or container when the repository itself requires stronger isolation.

## AI tools

The AI plugins are lazy-loaded rather than started with Neovim. Press `<leader>aE` (`Space a E`) to load the configured stack and enable:

- Copilot completion items in Blink.cmp
- Sidekick next-edit suggestions
- Avante
- MCPHub, when `~/.mcpservers.json` exists

The individual plugin commands can still load their respective plugins without enabling the entire stack. Provider authentication and API keys are managed outside this repository.

Set `NVIM_OFFLINE=1` to disable network-dependent AI integrations for a session:

```sh
NVIM_OFFLINE=1 nvim
```

To keep them disabled by default, add this to your shell profile:

```sh
export NVIM_OFFLINE=1
```

While offline mode is set, `<leader>aE` warns and does nothing. Unset the variable before starting Neovim to enable AI again.

MCPHub is only enabled when `~/.mcpservers.json` exists. Its external runtime must be installed separately; this configuration does not run a global npm installation on your behalf.

Avante's RAG service is disabled by default. Its optional RAG and web-search integrations require additional local services or credentials; see `lua/plugins/avante.lua` before enabling them.

## Useful commands and mappings

| Command or mapping | Action |
| --- | --- |
| `<leader>aE` | Enable the AI stack |
| `<leader>aM` | Open MCPHub when configured |
| `<leader>uT` | Toggle Undotree |
| `<leader>gdd` | Open Diffview |
| `<leader>gdm` | Diff against the remote's main branch |
| `<leader>gD` | Show the current file's history |
| `<leader>ol` | Restart the last Overseer task |
| `:Lint` | Run the configured linter for the current buffer |
| `:LintTerraform` | Run Terraform validation and TFLint manually |
| `:LintTrivy` | Run Trivy manually |

LazyVim provides most of the remaining mappings. Press `<leader>` and follow the WhichKey labels to discover them.

## Configuration layout

- `lua/config/options.lua` — editor options and filetype detection
- `lua/config/keymaps.lua` — global mappings
- `lua/config/autocmds.lua` — autocommands
- `lua/config/utils.lua` — shared utility functions
- `lua/plugins/*.lua` — plugin specs and configuration

## Screenshots

![Avante in Neovim](https://github.com/user-attachments/assets/f1f93baa-892f-48dd-810d-460a205231f8)

![Neotest and Overseer](https://github.com/user-attachments/assets/0ecde105-2744-4705-800a-35345db47fc9)
