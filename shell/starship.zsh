# Homebrew may not be on PATH yet in a fresh terminal on a new Mac.
if ! command -v starship >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
