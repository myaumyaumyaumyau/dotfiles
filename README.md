# dotfiles

Мои конфиги для macOS, разворачиваются одной командой через [GNU Stow](https://www.gnu.org/software/stow/).

## Установка на новой машине

Склонируй репозиторий и запусти установку:

```bash
git clone https://github.com/myaumyaumyaumyau/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

Скрипт `install.sh`:

1. ставит Homebrew (если его нет), brew-формулы и GUI-приложения (casks);
2. ставит `oh-my-zsh` и плагины `zsh-autosuggestions`, `zsh-syntax-highlighting`;
3. расставляет симлинки через `stow`;
4. ставит yazi-флейворы (`ya pkg install` по `package.toml`);
5. клонирует nvim-конфиг (LazyVim) в `~/.config/nvim`.

Скрипт **идемпотентен** — повторный запуск ничего не ломает. После установки перезапусти терминал (`exec zsh`).

## Что внутри

Каждая папка — отдельный «пакет» stow; её содержимое повторяет путь от `~`.

| Пакет      | Что разворачивает                                   |
|------------|------------------------------------------------------|
| `zsh`      | `~/.zshrc` + `~/.config/zsh/*.zsh`                   |
| `starship` | `~/.config/starship.toml` (промпт)                   |
| `git`      | `~/.gitconfig`                                       |
| `lazygit`  | `~/.config/lazygit/config.yml`                       |
| `yazi`     | `~/.config/yazi/` (конфиг; темы — через `ya pkg`)    |
| `ghostty`  | `~/.config/ghostty/config`                           |
| `tmux`     | `~/.tmux.conf`                                       |
| `aerospace`| `~/.config/aerospace/aerospace.toml`                 |
| `karabiner`| `~/.config/karabiner/karabiner.json`                 |

## Ручное управление stow

Из каталога `~/dotfiles`:

```bash
stow <пакет>            # развернуть симлинки одного пакета
stow */                 # развернуть все пакеты
stow -D <пакет>         # убрать симлинки пакета
stow -R <пакет>         # перествоить (после изменений структуры)
```

## nvim / LazyVim

Конфиг Neovim — **отдельный репозиторий**, в dotfiles он не входит.
`install.sh` клонирует его автоматически в `~/.config/nvim` (если папки
там ещё нет). Вручную, при необходимости:

```bash
git clone https://github.com/myaumyaumyaumyau/lazyvim ~/.config/nvim
```

## Git-identity

Имя и email не закоммичены — `git/.gitconfig` подключает их через
`[include]` из `~/.gitconfig-local`. На новой машине этот файл нужно
создать вручную:

```ini
[user]
	name  = Имя Фамилия
	email = you@example.com
```

## Karabiner

Конфиг Karabiner (`karabiner.json`) лежит в dotfiles и разворачивается
через `stow` — настраивать раскладку заново не нужно. А вот само
приложение `install.sh` **не ставит**: его cask требует пароль и ручного
одобрения системного расширения. Поставь его отдельно одной командой:

```bash
brew install --cask karabiner-elements
```

## Чего здесь нет

`~/.ssh`, `~/.gitconfig-github`, `~/.gitconfig-local`, `.env`/секреты
и прочие приватные файлы намеренно исключены через `.gitignore`.
