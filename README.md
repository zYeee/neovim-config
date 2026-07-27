# neovim-config

My terminal environment in one repo — **Neovim**, **Ghostty** and **cmux** — reproducible on a
new Mac with a single command.

```sh
curl -fsSL https://raw.githubusercontent.com/zYeee/neovim-config/main/setup.sh | bash
```

That clones this repo to `~/source/neovim-config` (override with `NVIM_CONFIG_DIR=…`), installs
everything it needs, and symlinks the configs into place. If you'd rather see the script first:

```sh
git clone git@github.com:zYeee/neovim-config.git ~/source/neovim-config
~/source/neovim-config/setup.sh
```

Already have a machine set up? `./setup.sh --check` prints what's present and what isn't, and
changes nothing.

---

## What `setup.sh` does

1. **Preflight** — refuses anything but macOS (Ghostty and cmux are `.app`s), triggers the Xcode
   Command Line Tools installer if missing.
2. **Homebrew** — installs it if absent, then adds it to `PATH` for the rest of the run.
3. **Packages** — `brew bundle` over the [`Brewfile`](Brewfile): the two terminals, the Nerd Font,
   and Neovim's runtime deps.
4. **Neovim** — installed as `brew install --HEAD neovim` because this config uses 0.12+ APIs
   (`vim.lsp.config`, nvim-treesitter's `main` branch). Already on 0.12+? It's skipped, so
   re-running never triggers a source rebuild.
5. **pyright** — `npm install -g pyright` (the only dependency not available via Homebrew).
6. **Symlinks** — see the table below. Anything already sitting at one of those paths is moved to
   `<path>.bak.<timestamp>`, never deleted.
7. **Plugins** — `nvim --headless "+Lazy! sync"`, then compiles the treesitter parsers and waits
   for them (the install is async, so a plain headless run would exit mid-download).

It ends with a status report. Every step is a no-op once satisfied — re-run it any time.

| Repo path        | Symlinked to             |
| ---------------- | ------------------------ |
| *(repo root)*    | `~/.config/nvim`         |
| `ghostty/`       | `~/.config/ghostty`      |
| `cmux/cmux.json` | `~/.config/cmux/cmux.json` |

cmux is linked at file level on purpose: `~/.config/cmux` also holds session state and multi-MB
event logs that have no business in git.

### Options

| Flag | Effect |
| ---- | ------ |
| `-n`, `--dry-run` | print every action, touch nothing |
| `--check` | report status only; exits non-zero if something's missing |
| `-f`, `--force` | delete conflicting config paths instead of backing them up |
| `--skip-brew` | leave Homebrew and packages alone |
| `--skip-plugins` | skip the headless plugin/parser sync |

---

## Layout

```
.
├── setup.sh            one-command bootstrap (start here)
├── Brewfile            every Homebrew dependency, with a note on why
├── init.lua            Neovim entrypoint — bootstraps lazy.nvim, imports lua/
├── lua/
│   ├── config/         options, keymaps, autocmds, LSP
│   └── plugins/        one file per plugin spec
├── ghostty/config      Ghostty settings
├── cmux/cmux.json      cmux shortcut bindings
└── coc-settings.json   unused leftover from the pre-native-LSP era
```

---

## The three pieces

### Neovim

Nightly (0.12+), [lazy.nvim](https://github.com/folke/lazy.nvim)-managed, no `nvim-lspconfig` and
no `mason` — servers are configured directly with `vim.lsp.config` in `lua/config/lsp.lua` and each
one is enabled only if its binary is on `PATH`, so a missing toolchain just stays quiet.

| Area | Plugin |
| ---- | ------ |
| LSP | native `vim.lsp` — pyright, ruff, gopls, typos-lsp |
| Completion | blink.cmp |
| Finder / explorer / dashboard | snacks.nvim (picker, explorer, indent, words, bigfile) |
| Syntax | nvim-treesitter (`main` branch) |
| Git | gitsigns, diffview, `Snacks.gitbrowse` |
| Motion | flash.nvim |
| Search & replace | grug-far |
| AI | claudecode.nvim, CopilotChat |
| Misc | which-key, lualine, toggleterm, nvim-surround, autopairs, visual-multi, markview |

Format-on-save is native too: ruff's fix-all (which also sorts imports) for Python, gopls'
organize-imports for Go, then `vim.lsp.buf.format`.

### Ghostty

Gruvbox Dark at 90% opacity with blur, JetBrainsMono Nerd Font, `copy-on-select`, and zsh shell
integration (so `cmd+↑`/`cmd+↓` jump between prompts). `cmd+d` / `cmd+shift+d` split, `cmd+h` /
`cmd+l` move between tabs, and `cmd+\`` toggles a global quick terminal.

Neovim's gruvbox runs in `transparent_mode` so the terminal's translucency shows through the
editor — the two configs are matched on purpose.

### cmux

Only the shortcut bindings are tracked: `cmd+h` / `cmd+l` for previous/next surface, matching the
Ghostty tab keys so the same fingers work in both.

---

## Keymap cheat sheet

Leader is `;`. Pause after any prefix and which-key lists what's under it; `;?` shows the
buffer-local maps.

| Keys | Does |
| ---- | ---- |
| `<C-p>` / `;ff` `;fg` `;fr` `;fb` | files / grep / recent / buffers |
| `;<F2>` | toggle the file explorer |
| `gd`, `<C-]>`, `<C-w><C-]>` | definition; definition in a split (`<C-o>` to come back) |
| `;ca` | code action |
| `;;w` `;;b` `;;s` | flash forward / backward / treesitter node |
| `]c` `[c`, `;hs` `;hr` `;hp` | next/prev hunk, stage, reset, preview |
| `;hb` `;gB` `;tb` | blame line / blame panel / toggle inline blame |
| `;gh` `;go` | open file+line, or the repo, on the git remote |
| `<C-f>` / `;sr` `;sw` | search & replace (grug-far) |
| `;ac` `;af` `;as` | toggle / focus Claude Code, send selection |
| `<C-\>` / `;;t` | terminal / floating terminal |
| `H` `L` | previous / next tab |
| `<C-h/j/k/l>` | move between windows |
| `;y` `;p` | yank / put via the system clipboard |
| `jj` | escape insert mode |

---

## After the first run

- Launch Ghostty and cmux once so macOS clears the Gatekeeper prompt.
- `:Copilot setup` — CopilotChat needs a one-time GitHub auth.
- claudecode.nvim expects the Claude Code CLI on `PATH`.
- Go isn't installed by default. For gopls:
  `brew install go && go install golang.org/x/tools/gopls@latest`.

## Day-to-day

The configs *are* the repo — edit files here (or through `~/.config/nvim`, same thing) and commit.
After pulling on another machine, `./setup.sh` picks up any new dependency.

## Reproducibility notes

- `lazy-lock.json` is gitignored, so a fresh install resolves plugins to their current versions
  rather than the exact set on the source machine. To pin them instead, drop that line from
  `.gitignore`, commit the lockfile, and run `:Lazy restore` on the other machine.
- cmux writes `cmux.json` when you change shortcuts in its UI. It may replace the symlink with a
  regular file; `./setup.sh --check` will flag that, and re-running `./setup.sh` re-links it (your
  version is backed up first, so nothing is lost).
- Not covered here: zsh / oh-my-zsh / starship, git config, and everything else in `~`. This repo
  is deliberately scoped to the editor and the two terminals.

## Troubleshooting

| Symptom | Fix |
| ------- | --- |
| `nvim` older than 0.12 | `brew install --HEAD neovim` |
| Missing icons / boxes in the UI | `brew install --cask font-jetbrains-mono-nerd-font`, then set the terminal font |
| A language server never attaches | `:checkhealth vim.lsp` — its binary is probably not on `PATH` |
| Parsers failed to build | `brew install tree-sitter-cli`, then `:TSUpdate` |
| A cask says the app already exists | `brew install --cask --adopt cmux` (or `ghostty`) |
| Want the old config back | everything replaced is at `~/.config/*.bak.<timestamp>` |
