# Neovim Config — Optimization TODO

Remaining suggestions from the config review. Already completed (not listed here):
treesitter branch fix + 3 keymap bugs (`abe6901`), markdown-preview → markview swap (`7778558`).

Tags: **[risk]** low / med / high · **[effort]** S / M / L

---

## 1. Quick wins — hygiene & cleanup  *(low risk, do anytime)*

- [x] **Remove dead/no-op settings from `init.vim`** — these are Neovim defaults or meaningless: `set nocompatible`, `set encoding=UTF-8`, `filetype on` / `filetype plugin on` / `filetype plugin indent on`, `syntax on` (treesitter now handles highlighting; `syntax on` is only a fallback). [risk: low][effort: S] — *done; verified Neovim defaults keep syntax + filetype on.*
- [x] **De-duplicate `mapleader`** — removed the vimscript `let mapleader=";"`; the Lua `vim.g.mapleader` (set first, via `lua require('init')`) is now the sole definition. [risk: low][effort: S]
- [x] **Remove duplicate `copilot.vim` declaration** — dropped the standalone string; it stays installed as a CopilotChat dependency. [risk: low][effort: S]
- [x] **Use `noremap` variants** — converted recursive `map`/`nmap`/`vmap`/`imap` to `noremap`/`nnoremap`/`vnoremap`/`inoremap` (kept the `<Plug>` coc mappings recursive, as `<Plug>` requires). [risk: low][effort: S]
- [x] **Review `g:python3_host_prog = '/usr/bin/python3'`** — *reviewed, kept.* That interpreter (3.9.6) has `pynvim` and the provider works; homebrew's python3 does **not**, so dropping it would risk auto-detection breaking LeaderF's Python backend. [risk: low][effort: S]
- [x] **Remove obsolete mkdp permission entries** — removed the two `markdown-preview.nvim` build allow-rules from `.claude/settings.local.json`. [risk: low][effort: S]
- [x] **Add lazy-loading triggers** — deferred `nvim-autopairs` (InsertEnter), `lualine`/`nvim-surround`/`vim-visual-multi` (VeryLazy), `gitsigns` (BufReadPre/BufNewFile), `vim-go` (ft=go); moved their `setup()` calls into the lazy specs (`config=true`/`opts`) and fixed the toggleterm double-setup. Kept `nvim-treesitter`/`startify`/`nerdtree`/`toggleterm` eager (needed at startup). [risk: low][effort: M]

---

## 2. Treesitter `main` migration  *(durable fix for the archived-master rot)*

- [x] **Migrate from the archived `master` branch to the maintained `main` API.** *Done.* `master` was frozen (~1yr+, no new parsers/fixes) and caused the `except*` parser-shadowing error we cleaned up. [risk: med][effort: M]
  - [x] Dropped `branch = "master"` from the spec; added `lazy = false` (`main` does not support lazy-loading).
  - [x] Replaced `require('nvim-treesitter.configs').setup{...}` with `require('nvim-treesitter').setup{}` + `require('nvim-treesitter').install({ 'python', 'go', 'lua', 'markdown', 'markdown_inline', 'json', 'yaml', 'bash' })`.
  - [x] Added a `FileType` autocmd calling `vim.treesitter.start()` (highlighting is no longer automatic on `main`), plus `vim.treesitter.language.register('bash', 'sh')` so `.sh` scripts highlight via the bash parser.
  - [x] Verified: all 8 parsers install, highlighting activates on python/sh/markdown buffers, markview loads with its markdown parser available.
  - **Toolchain bump (required by `main`):** needs **Neovim ≥ 0.12** (uses `vim.list.unique`, nil on 0.11) + **`tree-sitter-cli` ≥ 0.26.1**. Provisioned: Neovim upgraded to HEAD (`brew install --HEAD neovim`, now v0.13.0-dev) and `brew install tree-sitter-cli` (0.26.9). `lazy-lock.json` repinned to the `main` commit.

---

## 3. Modular pure-Lua restructure  *(eliminates the vimscript/Lua split that caused most of the bugs)*

- [x] **Convert to a modular Lua layout.** *Done.* Retired the `init.vim` + `lua/init.lua` split (root cause of the duplicate `mapleader`/mappings and scattered keymaps) for a single pure-Lua tree. [risk: med][effort: L]
  - [x] `init.lua` is now the single entrypoint (bootstraps lazy, then `require("lazy").setup("plugins")`); deleted `init.vim` and `lua/init.lua`.
  - [x] `lua/config/options.lua` (options + `mapleader` + `python3_host_prog`), `lua/config/keymaps.lua` (global maps), `lua/config/autocmds.lua`.
  - [x] `lua/plugins/*.lua` — one file per plugin (19 files), auto-imported by `lazy.nvim`. Plugin-specific keymaps/globals/commands moved into their own specs (coc, nerdtree, toggleterm, leaderf, hop, treesitter).
  - [x] Ported the `init.vim` autocmds (Python format-on-save, NERDTree auto-close, `checktime` on focus) into `lua/config/autocmds.lua`.
  - Verified headless: 23 specs load clean; options/leader/keymaps/autocmds apply; treesitter highlight activates on a python buffer; coc registers `Format`/`OR` + `gd` on load.

---

## 4. Plugin replacements  *(modernization — bigger changes)*

- [ ] **`coc.nvim` → native LSP** *(highest-leverage change)* — replace the Node-based coc with `nvim-lspconfig` + `mason.nvim` (auto-installs pyright/gopls/ruff) + completion via **`blink.cmp`** (or `nvim-cmp`). Neovim 0.11 has built-in `vim.lsp.enable()`. Migrate the coc keymaps (`gd`, `<C-]>`, `<leader>ca`, jump-to-split). [risk: high][effort: L]
- [ ] **Replace the coc+ruff format-on-save hooks with `conform.nvim`** — unified formatting across Python/Go/etc. instead of the two `BufWritePre *.py` coc commands in `init.vim`. (Pairs with the LSP migration.) [risk: med][effort: M]
- [ ] **`LeaderF` → `fzf-lua` or `telescope.nvim`** — LeaderF is vimscript and needs a C-extension build. `fzf-lua` = fastest; `telescope` = most extensible. Remap `<C-P>`. [risk: med][effort: M]
- [ ] **`NERDTree` + `vim-nerdtree-tabs` → `neo-tree.nvim` / `nvim-tree.lua` / `oil.nvim`** — modern, git/diagnostics-aware; `vim-nerdtree-tabs` is semi-abandoned. Remap `<leader><F2>` toggle and `<C-g>` find. [risk: med][effort: M]
- [ ] **`hop.nvim` → `flash.nvim`** — flash adds search-integration, treesitter selection, and remote operations over hop's word-jump. Remap `<leader><leader>w/b`. [risk: low][effort: M]
- [x] **`vim-go` → `gopls` via native LSP.** *Done.* Removed vim-go for a native `vim.lsp` gopls setup in `lua/config/lsp.lua` (no nvim-lspconfig needed on 0.13-dev): `vim.lsp.config('gopls', …)` + `vim.lsp.enable` guarded on the `gopls` binary, an `LspAttach` autocmd with buffer-local `gd`/`<C-]>`/`<leader>ca` maps mirroring coc + native autocompletion, and format/organize-imports on save (replaces vim-go's gofmt autosave). coc still owns Python; gopls only attaches to Go buffers. Note: `go`/`gopls` aren't installed locally yet, so this is config-ready and stays quiet until they are. `ray-x/go.nvim` (`:GoTest`/struct-tag helpers) left as an optional follow-up. [risk: med][effort: M]
- [x] *(optional)* **`vim-startify` → `snacks.nvim` dashboard.** *Done.* Removed vim-startify; added `folke/snacks.nvim` (`lua/plugins/snacks.lua`) with only the dashboard module enabled — header, quick-action keys wired to this config's tools (LeaderF file/mru, grug-far), recent-files, and startup stats. The rest of snacks stays off. [risk: low][effort: S]
- [ ] *(optional)* **`vim-visual-multi` → `multicursor.nvim`** — only if you want native-feel multicursor; vim-visual-multi is fine as-is. [risk: low][effort: S]

---

## 5. New plugins worth adding

- [ ] **`folke/which-key.nvim`** — discoverability for the `;`-leader maps (`<leader>a*`, `<leader>s*`, etc.). [effort: S]
- [~] **`folke/snacks.nvim`** — now installed with the **dashboard** module only (see §4). Remaining modules still available to enable: indent guides, lazygit, picker, notifier, etc. [effort: M]
- [ ] **`folke/trouble.nvim` + `folke/todo-comments.nvim`** — diagnostics list + TODO/FIXME highlighting & search. [effort: S]
- [ ] **`nvim-treesitter-textobjects`** — `vif`/`vaf`/`vac` function/class motions (great for Python & Go). Requires treesitter (done). [effort: S]
- [ ] *(consider)* a git client — `lazygit` (via snacks) or `tpope/vim-fugitive` / `NeogitOrg/neogit` to complement `gitsigns`. [effort: S]

---

## Suggested order

1. Section 1 (quick hygiene wins) — safe, immediate.
2. Section 2 (treesitter `main`) — kills the archived-branch rot.
3. Section 3 (modular restructure) — foundation for everything below.
4. Section 4 `coc → native LSP` — the big modernization.
5. Remaining Section 4 swaps + Section 5 additions incrementally.
