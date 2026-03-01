## About
My personal configuration files for a customized and productive Linux environment.

---

## Features

### Compositor
- [Niri](https://yalter.github.io/niri/) - A scrollable-tiling Wayland compositor.

### Desktop Shell
- [DankMaterialShell](https://danklinux.com/) - Desktop shell for wayland compositors built with Quickshell & GO, optimized for niri, hyprland, sway, MangoWC, and labwc.
- [Quickshell](https://quickshell.org/) - building blocks for your desktop.

### Development

### Editors
- [Neovim](https://neovim.io/) - hyperextensible Vim-based text editor.

### File System
- [Yazi](https://yazi-rs.github.io/) - Blazing fast terminal file manager written in Rust, based on async I/O.

### Terminal
- [Alacritty](https://alacritty.org/) - Alacritty is a modern terminal emulator that comes with sensible defaults, but allows for extensive configuration.

### Shell
- [ohmyzsh](https://ohmyz.sh/) - Oh My Zsh is a delightful, open source, community-driven framework for managing your Zsh configuration. It comes bundled with thousands of helpful functions.
- [Starship](https://starship.rs/) - Starship is the minimal, blazing fast, and extremely customizable prompt for any shell! Shows the information you need, while staying sleek and minimal.
- [ZSH](https://www.zsh.org/) - Zsh is a shell designed for interactive use, although it is also a powerful scripting language.

---

## 🚀 Getting Started

- ### Install GNU Stow
[GNU Stow](https://www.gnu.org/software/stow/) is used to symlink dotfiles into your home directory for clean management.

- ### Clone Git repository
Clone the repository and symlink the configs to your home directory:

```bash
git clone https://github.com/51lv3str1/dotfiles ~/dotfiles
cd ~/dotfiles
```

- ### symlink
```bash
stow .
```

Before installing the tools, you need to set up the following package managers and runtimes:

### Rust & Cargo
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

### cargo-update (keep cargo installs up to date)
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
| fzf | apt | `sudo apt install fzf` |
| bat | apt | `sudo apt install bat` |
| btop | apt | `sudo apt install btop` |
| wl-clipboard | apt | `sudo apt install wl-clipboard` |
| ripgrep | apt | `sudo apt install ripgrep` |
| tmux | apt | `sudo apt install tmux` |
| lazygit | apt | `sudo apt install lazygit` |
| eilmeldung | cargo install --git | `cargo install --git https://github.com/christo-auer/eilmeldung` |
| lazydocker | go install | `go install github.com/jesseduffield/lazydocker@latest` |
| SDKMAN | curl script | See prerequisites |
| Node.js | nvm | `nvm install --lts` |
| yazi | cargo install | `cargo install --locked yazi-fm yazi-cli` |
| chafa | apt | `sudo apt install chafa` |
| ffmpeg | apt | `sudo apt install ffmpeg` |
| poppler-utils | apt | `sudo apt install poppler-utils` |
| imagemagick | apt | `sudo apt install imagemagick` |
| fd-find | apt | `sudo apt install fd-find` |
| 7zip | apt | `sudo apt install 7zip` |
| jq | apt | `sudo apt install jq` |
| resvg | cargo install | `cargo install resvg` |
| kimageformat-plugins | apt | `sudo apt install kimageformat-plugins` |
| Neovim | brew install | `brew install neovim` |
| fastfetch | apt | `sudo apt install fastfetch` |
| Claude Code | native installer | `curl -fsSL https://claude.ai/install.sh \| bash` |
| eza | apt | `sudo apt install eza` |
| glow | apt | `sudo apt install glow` |

---

## 🔄 Update Everything

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a
```
