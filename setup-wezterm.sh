#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════╗
# ║   WezTerm Shell Enhancement Setup Script                 ║
# ║   Installs: Starship prompt + shell autocomplete         ║
# ╚══════════════════════════════════════════════════════════╝
 
set -e
 
SHELL_NAME=$(basename "$SHELL")
echo "Detected shell: $SHELL_NAME"
 
# ─────────────────────────────────────────
# 1. Install Starship prompt
# ─────────────────────────────────────────
echo ""
echo "▶ Installing Starship prompt..."
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh
else
  echo "  Starship already installed: $(starship --version)"
fi
 
# ─────────────────────────────────────────
# 2. Place the starship config
# ─────────────────────────────────────────
echo ""
echo "▶ Placing Starship config..."
mkdir -p "$HOME/.config"
cp starship.toml "$HOME/.config/starship.toml"
echo "  Saved to ~/.config/starship.toml"
 
# ─────────────────────────────────────────
# 3. Install shell-specific autocomplete
# ─────────────────────────────────────────
echo ""
echo "▶ Setting up autocomplete for $SHELL_NAME..."
 
if [[ "$SHELL_NAME" == "bash" ]]; then
  # bash-completion is usually available via package manager
  # Also install 'fzf' for fuzzy history search
  if command -v apt &>/dev/null; then
    sudo apt install -y bash-completion fzf
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y bash-completion fzf
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm bash-completion fzf
  fi
 
  SHELL_RC="$HOME/.bashrc"
  cat >> "$SHELL_RC" << 'EOF'
 
# ── WezTerm enhancements ─────────────────────────────────
# Starship prompt
eval "$(starship init bash)"
 
# Better history search with arrow keys
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
 
# fzf fuzzy finder (Ctrl+R for history, Ctrl+T for files)
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && \
  source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f /usr/share/bash-completion/bash_completion ] && \
  source /usr/share/bash-completion/bash_completion
 
# ─────────────────────────────────────────────────────────
EOF
  echo "  Added Starship + fzf to ~/.bashrc"
 
elif [[ "$SHELL_NAME" == "zsh" ]]; then
  # Install zsh plugins via git (no plugin manager needed)
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.zsh}"
  mkdir -p "$ZSH_CUSTOM"
 
  # zsh-autosuggestions
  if [[ ! -d "$ZSH_CUSTOM/zsh-autosuggestions" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
      "$ZSH_CUSTOM/zsh-autosuggestions"
  fi
 
  # zsh-syntax-highlighting
  if [[ ! -d "$ZSH_CUSTOM/zsh-syntax-highlighting" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$ZSH_CUSTOM/zsh-syntax-highlighting"
  fi
 
  # fzf
  if ! command -v fzf &>/dev/null; then
    if command -v apt &>/dev/null;    then sudo apt install -y fzf
    elif command -v dnf &>/dev/null;  then sudo dnf install -y fzf
    elif command -v pacman &>/dev/null; then sudo pacman -S --noconfirm fzf
    fi
  fi
 
  SHELL_RC="$HOME/.zshrc"
  cat >> "$SHELL_RC" << EOF
 
# ── WezTerm enhancements ─────────────────────────────────
# Plugins
source "$ZSH_CUSTOM/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_CUSTOM/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
 
# Autocomplete settings
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
 
# Autosuggestion style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
 
# History
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
 
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
 
# Starship prompt (must be last)
eval "\$(starship init zsh)"
# ─────────────────────────────────────────────────────────
EOF
  echo "  Added Starship + zsh-autosuggestions + syntax-highlighting to ~/.zshrc"
 
elif [[ "$SHELL_NAME" == "fish" ]]; then
  fish -c "
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fisher install PatrickF1/fzf.fish
    starship init fish | source
  " 2>/dev/null || true
 
  FISH_CONF="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH_CONF")"
  echo 'starship init fish | source' >> "$FISH_CONF"
  echo "  Added Starship to ~/.config/fish/config.fish"
fi
 
# ─────────────────────────────────────────
# 4. Place the wezterm config
# ─────────────────────────────────────────
echo ""
echo "▶ Placing WezTerm config..."
mkdir -p "$HOME/.config/wezterm"
cp wezterm.lua "$HOME/.config/wezterm/wezterm.lua"
echo "  Saved to ~/.config/wezterm/wezterm.lua"

echo ""
echo "✅  Setup complete! Restart WezTerm to apply all changes."
echo ""
echo "   Prompt will show:  📂 dir   branch  🐍 venv"
echo ""

