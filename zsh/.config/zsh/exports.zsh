# === Editor ===
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# === Tools ===
export BAT_THEME="Dracula"
export XDG_CONFIG_HOME="$HOME/.config"   # чтобы lazygit и др. читали из ~/.config

# === PATH ===
export PATH="$HOME/.local/bin:$PATH"

