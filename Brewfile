# Homebrew dependencies for this environment. Installed by `./setup.sh`
# (or by hand with `brew bundle --file=Brewfile`).
#
# Neovim is deliberately NOT listed here: this config needs the HEAD build
# (>= 0.12, see README), and `brew install --HEAD` from a Brewfile would risk a
# source rebuild on every run. setup.sh installs and version-checks it instead.

# --- Terminals -------------------------------------------------------------
cask "ghostty" # configured by ghostty/config
cask "cmux"    # configured by cmux/cmux.json

# The family named in ghostty/config; also supplies the glyphs snacks.nvim,
# lualine and blink.cmp draw (blink is configured with nerd_font_variant=mono).
cask "font-jetbrains-mono-nerd-font"

# Shell prompt (shared by Ghostty and cmux).
brew "starship"

# --- Neovim runtime --------------------------------------------------------
brew "tree-sitter-cli" # nvim-treesitter `main` compiles parsers with this
brew "node"            # pyright (installed via npm) and a few plugin builds
brew "ripgrep"         # snacks.picker grep + grug-far backend
brew "fd"              # snacks.picker file scanning

# --- Language servers ------------------------------------------------------
# lua/config/lsp.lua enables each server only if its binary is on $PATH, so
# anything omitted here simply stays quiet.
brew "ruff"      # Python lint, format, import sorting
brew "typos-lsp" # misspellings as diagnostics
# gopls is intentionally absent (no Go toolchain on the source machine). To add
# Go support:  brew install go && go install golang.org/x/tools/gopls@latest
