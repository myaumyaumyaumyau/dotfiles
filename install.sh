#!/usr/bin/env bash
# ============================================================
#  dotfiles installer — разворачивает конфиги на новой машине.
#  Идемпотентен: повторный запуск ничего не ломает.
# ============================================================
set -euo pipefail

# Папка, где лежит этот скрипт (= корень репозитория dotfiles)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"
echo "==> dotfiles: $DOTFILES_DIR"

# ------------------------------------------------------------
# 0. Xcode Command Line Tools
# ------------------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Устанавливаю Xcode Command Line Tools"
  xcode-select --install
  echo "    Дождись окончания установки и запусти скрипт снова"
  exit 1
fi

# ------------------------------------------------------------
# 1. Homebrew
# ------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Homebrew не найден — устанавливаю"
  # NONINTERACTIVE=1: не ждать ENTER, ставить без подтверждений
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Подхватываем brew в PATH текущей сессии
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

# Прописываем brew в PATH ПОСТОЯННО — append в ~/.zprofile (для новых сессий)
if command -v brew >/dev/null 2>&1; then
  ZPROFILE="$HOME/.zprofile"
  if [ ! -f "$ZPROFILE" ] || ! grep -qsF 'brew shellenv' "$ZPROFILE"; then
    echo "==> Прописываю brew в $ZPROFILE"
    printf '\neval "$(%s shellenv)"\n' "$(command -v brew)" >>"$ZPROFILE"
  fi
fi

# ------------------------------------------------------------
# 2. brew-пакеты: формулы (CLI) и casks (GUI-приложения)
# ------------------------------------------------------------
BREW_PACKAGES=(
  # CLI-утилиты
  stow git git-delta ripgrep fd fzf bat eza btop zoxide tldr jq yt-dlp
  # терминал, сессии, промпт
  tmux sesh starship
  # yazi + зависимости для превью
  yazi ffmpeg sevenzip poppler resvg imagemagick
  # git-инструменты
  lazygit
  # разработка
  neovim tree-sitter-cli luarocks go node pnpm libpq
  # контейнеры
  colima docker docker-compose
)
BREW_CASKS=(
  # шрифт для Ghostty
  font-fira-code-nerd-font
  # браузеры
  arc brave-browser google-chrome
  # терминал
  ghostty
  # редакторы
  sublime-text
  # оконные / системные утилиты
  mos raycast shottr
  # AI
  chatgpt claude
  # общение
  discord
  # заметки
  obsidian
  # медиа
  obs spotify vlc
  # файлы
  qbittorrent
)

echo "==> Устанавливаю brew-формулы"
brew install --formula "${BREW_PACKAGES[@]}" || echo "    ! часть формул не удалось установить"

echo "==> Устанавливаю casks / GUI-приложения"
brew install --cask "${BREW_CASKS[@]}" || echo "    ! часть касок не удалось установить"

# ------------------------------------------------------------
# 3. oh-my-zsh + кастомные плагины
# ------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Устанавливаю oh-my-zsh"
  # --keep-zshrc: не трогать наш .zshrc; RUNZSH=no: не запускать zsh по окончании
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
else
  echo "==> oh-my-zsh уже установлен"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
install_plugin() {
  # $1 — имя плагина, $2 — git-url
  if [ -d "$ZSH_CUSTOM/plugins/$1" ]; then
    echo "    ✓ плагин $1"
  else
    echo "    → клонирую плагин $1"
    git clone --depth=1 "$2" "$ZSH_CUSTOM/plugins/$1"
  fi
}
echo "==> Плагины zsh"
install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# ------------------------------------------------------------
# 4. stow — расстановка симлинков
# ------------------------------------------------------------
echo "==> Расставляю симлинки через GNU Stow"
# Если на месте будущего симлинка лежит обычный файл — уносим его в бэкап,
# чтобы stow не падал с конфликтом (делает скрипт идемпотентным).
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
for pkg in */; do
  pkg="${pkg%/}"
  while IFS= read -r -d '' file; do
    rel="${file#"$pkg"/}" # путь относительно $HOME
    target="$HOME/$rel"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "    ! $target — обычный файл, уношу в бэкап"
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
    fi
  done < <(find "$pkg" -type f -print0)
done
[ -d "$BACKUP_DIR" ] && echo "    конфликтующие файлы сохранены в: $BACKUP_DIR"

# --restow = снять и поставить заново; безопасно даже при первом запуске
stow --restow --verbose --target="$HOME" */

# ------------------------------------------------------------
# 5. Yazi-флейворы (темы) по манифесту package.toml
# ------------------------------------------------------------
if command -v ya >/dev/null 2>&1; then
  echo "==> Устанавливаю yazi-флейворы (ya pkg install)"
  # идемпотентно: уже установленные флейворы пропускаются
  ya pkg install || echo "    ! ya pkg install завершился с ошибкой — пропускаю"
else
  echo "==> ya не найден — пропускаю установку yazi-флейворов"
fi

# ------------------------------------------------------------
# 6. TPM — менеджер плагинов tmux
# ------------------------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
  echo "==> TPM уже установлен — пропускаю"
else
  echo "==> Клонирую TPM"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR" ||
    echo "    ! не удалось склонировать TPM — пропускаю"
fi
if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  echo "==> Устанавливаю tmux-плагины через TPM"
  "$TPM_DIR/bin/install_plugins" || echo "    ! не удалось установить tmux-плагины"
fi

# ------------------------------------------------------------
# 7. nvim — отдельный репозиторий, клонируется сюда
# ------------------------------------------------------------
NVIM_DIR="$HOME/.config/nvim"
if [ -e "$NVIM_DIR" ]; then
  echo "==> nvim-конфиг уже на месте — пропускаю"
else
  echo "==> Клонирую nvim-конфиг"
  git clone https://github.com/myaumyaumyaumyau/neovim "$NVIM_DIR" ||
    echo "    ! не удалось склонировать nvim-конфиг"
fi

echo ""
echo "==> Готово!"
echo "    Перезапусти терминал или выполни:  exec zsh"
