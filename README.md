# dotfiles

My personal configuration files for a customized and productive Linux environment.

---

## Features

### Compositor
- [Niri](https://yalter.github.io/niri/) - A scrollable-tiling Wayland compositor.

### Desktop Shell
- [DankMaterialShell](https://danklinux.com/) - Desktop shell for wayland compositors built with Quickshell & GO, optimized for niri, hyprland, sway, MangoWC, and labwc.
- [Quickshell](https://quickshell.org/) - Building blocks for your desktop.

### Editors
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor.

### File System
- [Yazi](https://yazi-rs.github.io/) - Blazing fast terminal file manager written in Rust, based on async I/O.

### Terminal
- [Alacritty](https://alacritty.org/) - A modern terminal emulator with sensible defaults and extensive configuration.

### Shell
- [ZSH](https://www.zsh.org/) - A shell designed for interactive use and powerful scripting.
- [Oh My Zsh](https://ohmyz.sh/) - Community-driven framework for managing Zsh configuration.
- [Starship](https://starship.rs/) - Minimal, blazing fast, and extremely customizable prompt for any shell.

---

## 🚀 Getting Started

### 1. Install GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) is used to symlink dotfiles into your home directory for clean management.

```bash
sudo apt install stow
```

### 2. Clone the repository

```bash
git clone https://github.com/51lv3str1/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 3. Symlink configs

```bash
stow .
```

---

## 🔧 Prerequisites

Before installing the tools, set up the following package managers and runtimes:

### Rust & Cargo
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

### cargo-update
Keep cargo installs up to date:
```bash
cargo install cargo-update
```

### Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### nvm (Node Version Manager)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install --lts
```

### SDKMAN (Java/JVM toolchain manager)
```bash
sudo apt install zip unzip
curl -s "https://get.sdkman.io" | bash
```

---

## 📦 Tools

| Tool | Method | Install |
|------|--------|---------|
| zsh | apt | `sudo apt install zsh` |
| oh-my-zsh | curl script | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |
| GNU Stow | apt | `sudo apt install stow` |
| Chrome | .deb from web | Download from [google.com/chrome](https://www.google.com/chrome) |
| Starship | curl script | `curl -sS https://starship.rs/install.sh \| sh` |
| git | apt | `sudo apt install git` |
| GitHub CLI | official repo | `sudo apt install gh` |
| Homebrew | curl script | See prerequisites |
| Alacritty | cargo install | `cargo install alacritty` |
| Go | brew install | `brew install go` |
| zoxide | cargo install | `cargo install zoxide` |
| fzf | brew install | `brew install fzf` |
| bat | brew install | `brew install bat` |
| btop | brew install | `brew install btop` |
| wl-clipboard | apt | `sudo apt install wl-clipboard` |
| ripgrep | brew install | `brew install ripgrep` |
| tmux | brew install | `brew install tmux` |
| lazygit | brew install | `brew install lazygit` |
| eilmeldung | cargo install --git | `cargo install --git https://github.com/christo-auer/eilmeldung` |
| lazydocker | go install | `go install github.com/jesseduffield/lazydocker@latest` |
| SDKMAN | curl script | See prerequisites |
| Node.js | nvm | `nvm install --lts` |
| yazi | cargo install | `cargo install --locked yazi-fm yazi-cli` |
| chafa | brew install | `brew install chafa` |
| ffmpeg | brew install | `brew install ffmpeg` |
| poppler-utils | apt | `sudo apt install poppler-utils` |
| imagemagick | brew install | `brew install imagemagick` |
| fd-find | brew install | `brew install fd` |
| 7zip | apt | `sudo apt install 7zip` |
| jq | brew install | `brew install jq` |
| resvg | cargo install | `cargo install resvg` |
| kimageformat-plugins | apt | `sudo apt install kimageformat-plugins` |
| Neovim | brew install | `brew install neovim` |
| fastfetch | brew install | `brew install fastfetch` |
| Claude Code | native installer | `curl -fsSL https://claude.ai/install.sh \| bash` |
| eza | brew install | `brew install eza` |
| glow | brew install | `brew install glow` |

---

## 🔄 Update Everything

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a
```
