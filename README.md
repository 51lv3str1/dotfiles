# dotfiles

My personal configuration files for a customized and productive Linux environment running **Debian 13 (Trixie)** with **Niri** + **DankMaterialShell**.

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

### 1. Base system packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git curl build-essential pkg-config libssl-dev zip unzip stow \
  libfontconfig1-dev libxml2-dev libclang-dev libsqlite3-dev
```

### 2. ZSH + Oh My Zsh

```bash
sudo apt install zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. Clone the repository

```bash
git clone https://github.com/51lv3str1/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 4. Symlink configs

```bash
stow .
```

### 5. Clone assets

```bash
cd ~/.local/share
git clone https://github.com/51lv3str1/backgrounds
git clone https://github.com/51lv3str1/icons
git clone https://github.com/51lv3str1/fonts
git clone https://github.com/51lv3str1/sounds
```

---

## 🔧 Package Managers & Runtimes

### Rust & Cargo
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

### cargo-update
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
source ~/.zshrc
nvm install --lts
```

### SDKMAN (Java/JVM toolchain manager)
```bash
curl -s "https://get.sdkman.io" | bash
source ~/.zshrc
```

### Starship
```bash
curl -sS https://starship.rs/install.sh | sh
```

### GitHub CLI
```bash
sudo apt install gh
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
| GitHub CLI | apt | `sudo apt install gh` |
| Homebrew | curl script | See above |
| Alacritty | cargo install | See below |
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
| eilmeldung | cargo install --git | See below |
| SDKMAN | curl script | See above |
| Node.js | nvm | `nvm install --lts` |
| yazi | brew install | `brew install yazi` |
| chafa | brew install | `brew install chafa` |
| ffmpeg | brew install | `brew install ffmpeg` |
| poppler-utils | apt | `sudo apt install poppler-utils` |
| imagemagick | brew install | `brew install imagemagick` |
| fd-find | brew install | `brew install fd` |
| 7zip | apt | `sudo apt install 7zip` |
| jq | brew install | `brew install jq` |
| resvg | brew install | `brew install resvg` |
| kimageformat-plugins | apt | `sudo apt install kimageformat-plugins` |
| qtimageformats | brew install | `brew install qtimageformats` |
| Neovim | brew install | `brew install neovim` |
| fastfetch | brew install | `brew install fastfetch` |
| Claude Code | native installer | `curl -fsSL https://claude.ai/install.sh \| bash` |
| eza | brew install | `brew install eza` |
| glow | brew install | `brew install glow` |
| khal | apt | `sudo apt install khal` |
| fprintd | apt | `sudo apt install fprintd` |

### Install all brew tools at once
```bash
brew install go fzf bat btop ripgrep tmux lazygit lazydocker chafa ffmpeg imagemagick fd jq fastfetch eza glow neovim zoxide yazi resvg qtimageformats
```

### Install all apt extras at once
```bash
sudo apt install wl-clipboard poppler-utils 7zip kimageformat-plugins khal fprintd
```

### Alacritty
Alacritty must be installed via cargo and copied to a global path so it works in all desktop environments (GNOME, Niri, KDE, etc.):
```bash
cargo install alacritty
sudo cp ~/.cargo/bin/alacritty /usr/local/bin/alacritty
```

Then create a `.desktop` entry:
```bash
cat > ~/.local/share/applications/alacritty.desktop << 'EOF'
[Desktop Entry]
Name=Alacritty
Comment=A fast, cross-platform, OpenGL terminal emulator
Exec=alacritty
Icon=/home/silver/.local/share/icons/Alacritty.svg
Type=Application
Categories=System;TerminalEmulator;
Keywords=terminal;shell;
StartupNotify=true
Terminal=false
EOF
update-desktop-database ~/.local/share/applications/
```

### eilmeldung (RSS reader)
Requires system dependencies before building:
```bash
sudo apt install libxml2-dev libclang-dev libsqlite3-dev
cargo install --git https://github.com/christo-auer/eilmeldung
```

### Claude Code
```bash
curl -fsSL https://claude.ai/install.sh | bash
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
| `niri` | Recommended Wayland compositor (installed with dms) |
| `dgop` | System telemetry for resource widgets (installed with dms) |
| `dsearch` | Filesystem search engine (installed with dms) |
| `matugen` | Material Design color palette generation (installed with dms) |
| `cava` | Audio visualizer widget (installed with dms) |
| `cliphist` | Clipboard history |
| `qt6-multimedia` | System sound feedback |
| `qtimageformats` | Extended image format support |
| `khal` | Calendar integration |
| `fprintd` | Fingerprint authentication |

### Verify installation
```bash
dms doctor
```

---

## ⚙️ Neovim

Neovim is installed via brew. Configuration uses [LazyVim](https://lazyvim.org/).

Theme: **Catppuccin Mocha** with custom background color `hsl(233.33deg 24.32% 14.51%)`.

Config lives in `~/.config/nvim/`.

---

## 🔄 Update Everything

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a
```

---

## 📝 Notes

- Binaries installed with `cargo install` must be copied to `/usr/local/bin/` to be available globally across all desktop environments.
- `XDG_DATA_DIRS` must include `$HOME/.local/share` for custom `.desktop` files to appear in app launchers. This is set in `~/.config/environment.d/xdg.conf`.
- The DankLinux installer (`dankinstall`) adds the `danklinux` repo but **not** the `dms` repo — both must be added manually as shown above.
- `bat` is installed via brew (not apt) so the binary is called `bat` directly, not `batcat`.
