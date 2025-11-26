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
- [Neovim](https://neovim.io/) - hyperextensible Vim-based text editor.editor

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
