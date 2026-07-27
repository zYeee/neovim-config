#!/usr/bin/env bash
#
# setup.sh — reproduce this CLI environment (Neovim + Ghostty + cmux) on a Mac.
#
#   ./setup.sh              install everything and link the configs
#   ./setup.sh --check      report what is missing, change nothing
#   ./setup.sh --dry-run    print every action without running it
#
# Safe to re-run: every step is a no-op once satisfied, and anything already
# living at a config path is moved aside to <path>.bak.<timestamp> — never
# deleted (unless you pass --force).

set -euo pipefail

REPO_HTTPS="https://github.com/zYeee/neovim-config.git"
CLONE_DIR="${NVIM_CONFIG_DIR:-$HOME/source/neovim-config}"
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d%H%M%S)"

DRY_RUN=0
CHECK_ONLY=0
FORCE=0
SKIP_BREW=0
SKIP_PLUGINS=0

# --- output ----------------------------------------------------------------

if [ -t 1 ]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'
  YELLOW=$'\033[33m'; BLUE=$'\033[34m'; DIM=$'\033[2m'; OFF=$'\033[0m'
else
  BOLD=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; DIM=""; OFF=""
fi

step() { printf '\n%s==>%s %s%s%s\n' "$BLUE" "$OFF" "$BOLD" "$*" "$OFF"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '    %s✓%s %s\n' "$GREEN" "$OFF" "$*"; }
skip() { printf '    %s·%s %s\n' "$DIM" "$OFF" "$*"; }
warn() { printf '    %s!%s %s\n' "$YELLOW" "$OFF" "$*" >&2; }
bad()  { printf '    %s✗%s %s\n' "$RED" "$OFF" "$*" >&2; }
die()  { printf '\n%serror:%s %s\n' "$RED" "$OFF" "$*" >&2; exit 1; }

# Echo a command, then run it (unless --dry-run).
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '    %s$ %s%s\n' "$DIM" "$*" "$OFF"
    return 0
  fi
  "$@"
}

usage() {
  cat <<'EOF'
setup.sh — reproduce this CLI environment (Neovim + Ghostty + cmux) on a Mac.

Usage:
  ./setup.sh              install everything and link the configs
  ./setup.sh --check      report what is missing, change nothing
  ./setup.sh --dry-run    print every action without running it

Options:
  -n, --dry-run     show what would happen, touch nothing
      --check       verify this machine and exit (non-zero if anything is missing)
  -f, --force       delete conflicting config paths instead of backing them up
      --skip-brew   don't install Homebrew packages
      --skip-plugins  don't sync Neovim plugins/parsers headlessly
  -h, --help        this text
EOF
}

# Kept verbatim so the curl-pipe bootstrap can hand them to the cloned copy.
ORIG_ARGS=("$@")

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)   DRY_RUN=1 ;;
    --check)        CHECK_ONLY=1 ;;
    -f|--force)     FORCE=1 ;;
    --skip-brew)    SKIP_BREW=1 ;;
    --skip-plugins) SKIP_PLUGINS=1 ;;
    -h|--help)      usage; exit 0 ;;
    *)              usage >&2; die "unknown option: $1" ;;
  esac
  shift
done

# --- locate the repo -------------------------------------------------------
#
# When piped (curl … | bash) there is no script file to anchor on, so clone the
# repo first and hand off to the checked-out copy.

if [ -f "${BASH_SOURCE[0]:-}" ]; then
  # -P/pwd -P so invoking this through ~/.config/nvim/setup.sh (itself a link
  # into the repo) still resolves to the real checkout, not the link path.
  REPO="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
else
  step "Bootstrapping from a pipe — cloning the repo"
  if [ ! -d "$CLONE_DIR/.git" ]; then
    run mkdir -p "$(dirname "$CLONE_DIR")"
    run git clone "$REPO_HTTPS" "$CLONE_DIR" || die "clone failed: $REPO_HTTPS"
  else
    skip "already cloned at $CLONE_DIR"
  fi
  if [ "$DRY_RUN" -eq 1 ] && [ ! -f "$CLONE_DIR/setup.sh" ]; then
    printf '    %s$ %s/setup.sh %s%s\n' "$DIM" "$CLONE_DIR" "${ORIG_ARGS[*]:-}" "$OFF"
    printf '\n%sDry run — nothing was changed.%s\n' "$DIM" "$OFF"
    exit 0
  fi
  ok "handing off to $CLONE_DIR/setup.sh"
  # ${a[@]+…} keeps `set -u` happy when no flags were passed (bash 3.2).
  exec bash "$CLONE_DIR/setup.sh" ${ORIG_ARGS[@]+"${ORIG_ARGS[@]}"}
fi

[ -f "$REPO/init.lua" ] || die "$REPO doesn't look like this repo (no init.lua)"

# --- helpers ---------------------------------------------------------------

have() { command -v "$1" >/dev/null 2>&1; }

# Is <dest> a symlink already pointing at <src>? Link targets are normalised
# (relative -> absolute, symlinked parents -> physical) so a link made by hand
# still counts as satisfied. Stock macOS has no dependable `readlink -f`.
points_to() {
  local dest="$1" src="$2" target
  [ -L "$dest" ] || return 1
  target="$(readlink "$dest")" || return 1
  case "$target" in
    /*) ;;
    *) target="$(dirname "$dest")/$target" ;;
  esac
  if [ -d "$target" ]; then
    target="$(cd -P "$target" 2>/dev/null && pwd -P)" || return 1
  else
    target="$(cd -P "$(dirname "$target")" 2>/dev/null && pwd -P)/$(basename "$target")" || return 1
  fi
  [ "$target" = "$src" ]
}

# This config uses 0.12+ APIs (nvim-treesitter `main`, vim.lsp.config). Ask
# Neovim itself rather than parsing version strings, with -u NONE so an old
# binary doesn't choke on the config while answering.
nvim_new_enough() {
  have nvim || return 1
  nvim -u NONE --headless \
    -c 'lua vim.cmd(vim.fn.has("nvim-0.12") == 1 and "q" or "cq")' >/dev/null 2>&1
}

# link <path-in-repo> <destination>   (an empty path means the repo root)
link() {
  local src="$REPO/$1" dest="$2"
  src="${src%/}"
  [ -e "$src" ] || die "missing in repo: $src"

  if points_to "$dest" "$src"; then
    skip "$dest -> $src"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$FORCE" -eq 1 ]; then
      warn "replacing $dest"
      run rm -rf "$dest"
    else
      warn "backing up $dest -> $dest.bak.$STAMP"
      run mv "$dest" "$dest.bak.$STAMP"
    fi
  fi

  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  ok "$dest -> $src"
}

# --- steps -----------------------------------------------------------------

preflight() {
  step "Preflight"
  [ "$(uname -s)" = "Darwin" ] || die "macOS only — Ghostty and cmux ship as .app bundles"
  ok "macOS $(sw_vers -productVersion) ($(uname -m))"

  if ! xcode-select -p >/dev/null 2>&1; then
    warn "Xcode Command Line Tools missing (git, make, and Homebrew need them)"
    run xcode-select --install || true
    die "finish the Command Line Tools installer, then re-run this script"
  fi
  ok "Xcode Command Line Tools"
  info "repo: $REPO"
}

ensure_homebrew() {
  step "Homebrew"
  if have brew; then
    skip "already installed ($(brew --prefix))"
  elif [ "$DRY_RUN" -eq 1 ]; then
    printf '    %s$ /bin/bash -c "$(curl -fsSL .../Homebrew/install/HEAD/install.sh)"%s\n' "$DIM" "$OFF"
  else
    info "installing Homebrew (this will ask for your password)"
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "installed"
  fi
  # A fresh install isn't on $PATH yet for this shell.
  if ! have brew; then
    for prefix in /opt/homebrew /usr/local; do
      if [ -x "$prefix/bin/brew" ]; then
        eval "$("$prefix/bin/brew" shellenv)"
        break
      fi
    done
  fi
  have brew || [ "$DRY_RUN" -eq 1 ] || die "brew still not on \$PATH"
}

install_packages() {
  step "Packages (Brewfile)"
  # Don't abort the whole run on one bad entry — the usual cause is a cask
  # clashing with an app that was installed by hand, which is easy to fix.
  if run brew bundle install --file="$REPO/Brewfile"; then
    ok "Brewfile satisfied"
  else
    warn "brew bundle reported failures — continuing"
    warn "if a cask clashes with an app already in /Applications, adopt it:"
    warn "  brew install --cask --adopt <name>"
  fi
}

ensure_neovim() {
  step "Neovim (HEAD)"
  if nvim_new_enough; then
    skip "$(nvim --version | head -1)"
  else
    if have nvim; then
      warn "$(nvim --version | head -1) is too old — this config needs >= 0.12"
    fi
    info "building Neovim HEAD; this takes a few minutes"
    run brew install --HEAD neovim
    ok "installed"
  fi
}

ensure_pyright() {
  step "pyright (npm)"
  if have pyright-langserver; then
    skip "$(pyright-langserver --version 2>/dev/null || echo installed)"
  elif have npm; then
    run npm install -g pyright
    ok "installed"
  else
    warn "npm not found — skipping pyright (Python types/definitions will be off)"
  fi
}

link_configs() {
  step "Config symlinks"
  # The whole repo *is* the Neovim config (init.lua at its root).
  link "" "$XDG_CONFIG/nvim"
  link "ghostty" "$XDG_CONFIG/ghostty"
  # File-level for cmux: ~/.config/cmux also holds runtime state (session
  # locks, multi-MB event logs) that must stay out of git.
  link "cmux/cmux.json" "$XDG_CONFIG/cmux/cmux.json"
}

sync_plugins() {
  step "Neovim plugins and parsers"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '    %s$ nvim --headless "+Lazy! sync" +qa%s\n' "$DIM" "$OFF"
    printf '    %s$ nvim --headless (install treesitter parsers)%s\n' "$DIM" "$OFF"
    return 0
  fi

  info "lazy.nvim sync (bootstraps itself on first run)"
  nvim --headless "+Lazy! sync" +qa 2>&1 | sed 's/^/    /' || warn "lazy sync reported errors"

  # install() is async; wait on it explicitly or a headless nvim exits first.
  info "compiling treesitter parsers"
  nvim --headless \
    -c 'lua local ok, ts = pcall(require, "nvim-treesitter"); local p = vim.g.nvim_treesitter_parsers; if ok and p then pcall(function() ts.install(p):wait(600000) end) end' \
    -c 'qa' 2>&1 | sed 's/^/    /' || warn "parser install reported errors"
  ok "plugins synced"
}

# --- report ----------------------------------------------------------------

MISSING=0

check_bin() { # check_bin <binary> <what it powers>
  if have "$1"; then ok "$(printf '%-20s %s' "$1" "$2")"
  else bad "$(printf '%-20s %s' "$1" "$2")"; MISSING=$((MISSING + 1)); fi
}

check_link() { # check_link <destination> <path-in-repo>
  local dest="$1" want="$REPO/$2"
  want="${want%/}"
  if points_to "$dest" "$want"; then
    ok "$(printf '%-20s -> repo' "$(basename "$dest")")"
  elif [ -e "$dest" ]; then
    bad "$(printf '%-20s exists but is not linked to the repo' "$(basename "$dest")")"
    MISSING=$((MISSING + 1))
  else
    bad "$(printf '%-20s missing' "$(basename "$dest")")"
    MISSING=$((MISSING + 1))
  fi
}

check_app() { # check_app <Name.app> <what it is>
  if [ -d "/Applications/$1" ]; then ok "$(printf '%-20s %s' "$1" "$2")"
  else bad "$(printf '%-20s %s' "$1" "$2")"; MISSING=$((MISSING + 1)); fi
}

doctor() {
  step "Status"
  check_app "Ghostty.app" "terminal"
  check_app "cmux.app" "terminal / agent multiplexer"

  if nvim_new_enough; then
    ok "$(printf '%-20s %s' "nvim" "$(nvim --version | head -1 | cut -d' ' -f2)")"
  else
    bad "$(printf '%-20s %s' "nvim" "missing or older than 0.12")"
    MISSING=$((MISSING + 1))
  fi

  check_bin "tree-sitter"        "parser compiler"
  check_bin "rg"                 "picker grep"
  check_bin "fd"                 "picker file scan"
  check_bin "node"               "pyright + plugin builds"
  check_bin "pyright-langserver" "Python LSP"
  check_bin "ruff"               "Python lint/format"
  check_bin "typos-lsp"          "spell diagnostics"

  printf '\n'
  check_link "$XDG_CONFIG/nvim" ""
  check_link "$XDG_CONFIG/ghostty" "ghostty"
  check_link "$XDG_CONFIG/cmux/cmux.json" "cmux/cmux.json"

  printf '\n'
  # Optional extras — absent on the machine this repo came from.
  if have gopls; then ok "$(printf '%-20s %s' "gopls" "Go LSP (optional)")"
  else skip "$(printf '%-20s %s' "gopls" "Go LSP — optional, not installed")"; fi

  if [ "$MISSING" -gt 0 ]; then
    printf '\n%s%d item(s) missing.%s Run %s./setup.sh%s to fix.\n' \
      "$YELLOW" "$MISSING" "$OFF" "$BOLD" "$OFF"
    return 1
  fi
  printf '\n%sEverything is in place.%s\n' "$GREEN" "$OFF"
}

# --- main ------------------------------------------------------------------

if [ "$CHECK_ONLY" -eq 1 ]; then
  if doctor; then exit 0; else exit 1; fi
fi

preflight
if [ "$SKIP_BREW" -eq 0 ]; then
  ensure_homebrew
  install_packages
  ensure_neovim
  ensure_pyright
else
  step "Packages"
  skip "--skip-brew"
fi
link_configs
if [ "$SKIP_PLUGINS" -eq 0 ]; then
  sync_plugins
else
  step "Neovim plugins"
  skip "--skip-plugins"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  printf '\n%sDry run — nothing was changed.%s\n' "$DIM" "$OFF"
  exit 0
fi

doctor || true

cat <<EOF

${BOLD}Next steps${OFF}
  1. Open Ghostty or cmux — macOS will ask to confirm the first launch.
  2. Run ${BOLD}nvim${OFF}; the dashboard means everything loaded.
  3. GitHub Copilot chat needs one-time auth: ${BOLD}:Copilot setup${OFF}
  4. claudecode.nvim needs the Claude Code CLI on \$PATH.

Configs are symlinked from ${REPO} — edit there and commit.
EOF
