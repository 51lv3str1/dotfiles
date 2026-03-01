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

### System dependencies
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git curl build-essential pkg-config libssl-dev zip unzip
```

### ZSH
```bash
sudo apt install zsh
chsh -s $(which zsh)
```

### Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

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
| Alacritty | cargo install | `cargo install alacritty && sudo cp ~/.cargo/bin/alacritty /usr/local/bin/` |
| Go | brew install | `brew install go` |
| zoxide | brew install | `brew install zoxide` |
| fzf | brew install | `brew install fzf` |
| bat | brew install | `brew install bat` |
| btop | brew install | `brew install btop` |
| wl-clipboard | apt | `sudo apt install wl-clipboard` |
| ripgrep | brew install | `brew install ripgrep` |
| tmux | brew install | `brew install tmux` |
| lazygit | brew install | `brew install lazygit` |
| lazydocker | brew install | `brew install lazydocker` |
| eilmeldung | cargo install --git | `cargo install --git https://github.com/christo-auer/eilmeldung` |
| SDKMAN | curl script | See prerequisites |
| Node.js | nvm | `nvm install --lts` |
| yazi | brew install | `brew install yazi` |
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

### Install all brew tools at once
```bash
brew install go fzf bat btop ripgrep tmux lazygit lazydocker chafa ffmpeg imagemagick fd jq fastfetch eza glow neovim zoxide yazi
```

### Install Alacritty and make it globally available
```bash
cargo install alacritty
sudo cp ~/.cargo/bin/alacritty /usr/local/bin/alacritty
```

---

## 🖥️ DankMaterialShell

DankMaterialShell is installed via the DankLinux OBS repository for Debian 13.

### Add repositories

```bash
# DankLinux repository
curl -fsSL https://download.opensuse.org/repositories/home:AvengeMedia:danklinux/Debian_13/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/danklinux.gpg
echo "deb [signed-by=/etc/apt/keyrings/danklinux.gpg] https://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/Debian_13/ /" | \
  sudo tee /etc/apt/sources.list.d/danklinux.list

# DMS stable repository
curl -fsSL https://download.opensuse.org/repositories/home:/AvengeMedia:/dms/Debian_13/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/avengemedia-dms.gpg
echo "deb [signed-by=/etc/apt/keyrings/avengemedia-dms.gpg] https://download.opensuse.org/repositories/home:/AvengeMedia:/dms/Debian_13/ /" | \
  sudo tee /etc/apt/sources.list.d/avengemedia-dms.list

sudo apt update
```

### Install

```bash
sudo apt install dms
```

### Configure

```bash
# Run setup wizard (select: Niri, Alacritty, systemd)
dms setup

# Bind DMS to niri session
systemctl --user add-wants niri.service dms
```

Log out and log back in selecting **niri-session**.

### Optional dependencies

| Package | Purpose |
|---------|---------|
| `niri` | Recommended Wayland compositor |
| `dgop` | System telemetry for resource widgets |
| `dsearch` | Filesystem search engine (installed with dms) |
| `matugen` | Material Design color palette generation |
| `cliphist` | Clipboard history |
| `cava` | Audio visualizer widget (installed with dms) |
| `qt6-multimedia` | System sound feedback |

---

## 🔄 Update Everything

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a
```
