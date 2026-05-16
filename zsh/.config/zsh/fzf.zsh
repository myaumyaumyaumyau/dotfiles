# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

FZF_FD_FILES='fd --type f --hidden --follow --exclude .git'
FZF_FD_DIRS='fd --type d --hidden --follow --exclude .git'

export FZF_DEFAULT_COMMAND="$FZF_FD_FILES"
export FZF_CTRL_T_COMMAND="$FZF_FD_FILES"
export FZF_ALT_C_COMMAND="$FZF_FD_DIRS"

## чтобы при использовании **<Tab> в файлах и папках использовало fd
_fzf_compgen_path() { eval "$FZF_FD_FILES" . "$1"; }
_fzf_compgen_dir()  { eval "$FZF_FD_DIRS"  . "$1"; }

# Requires `brew install bat`.
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Requires `brew install eza`.
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always --level=2 --icons {} | head -200'
"
