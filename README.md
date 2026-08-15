# dotfiles

Shell, terminal and desktop configuration shared across four machines: a
Debian 13 desktop, WSL, an Apple Silicon Mac, and a headless box reached over
ssh.

Managed with GNU Stow as a single flat package: the repo root mirrors `$HOME`
directly, so `.zshrc` here becomes `~/.zshrc`.

ASCII only, everywhere except the vendored font. These files get read on a
bare tty where anything else is garbage.

## Layout

| Here | Links to | Notes |
|---|---|---|
| `.config/shell/env.sh` | `~/.config/shell/env.sh` | POSIX core sourced by bash and zsh |
| `.config/environment.d/` | same | PATH for apps started by the systemd user manager |
| `.zshrc`, `.zshenv`, `.zprofile` | same | login shell |
| `.bashrc`, `.profile` | same | kept working as a fallback |
| `.config/starship.toml` | same | one prompt for both shells |
| `.tmux.conf` | same | truecolor for named terminals only |
| `.config/alacritty/` | same | config and the generated DMS theme |
| `.config/niri/` | same | compositor, plus the `dms/` fragments it includes |
| `.local/share/fonts/` | same | Departure Mono, see below |
| `.local/share/applications/`, `.local/share/icons/` | same | Alacritty desktop entry and icon |
| `.gitconfig` | `~/.gitconfig` | |
| `.claude/CLAUDE.md` | same | that one file; `.gitignore` excludes the rest of `~/.claude` |

`README.md` and the git files stay out of `$HOME` through
`.stow-local-ignore`. Note that having that file at all *replaces* stow's
built-in ignore list, which is why it repeats the VCS entries.

## Install

    git clone git@github.com:51lv3str1/dotfiles.git ~/dotfiles
    stow -d ~/dotfiles -t ~ .

Both flags are required. Stow defaults its target to the parent of the stow
directory, which here would be `/home` rather than `$HOME`.

The repo must live at `~/dotfiles`: stow writes relative symlinks, so moving
or renaming the directory breaks every one of them. To move it, `stow -D`
first, then move, then stow again.

Stow aborts if a target already exists as a real file. Move the existing file
into the repo first -- do not copy it, or the two will drift.

Day to day: `stow -D -d ~/dotfiles -t ~ .` to unlink, and the same with `-R`
to restow after moving files around inside the repo.

### One caveat of the flat layout

Where a directory does not already exist under `$HOME`, stow links the whole
directory instead of its contents. Everything an application then writes there
lands inside this repo. That is how the DankMaterialShell installer came to
overwrite a tracked `alacritty.toml`: `~/.config/alacritty` is one of those
folded directories.

Everything else links file by file, because the parent already exists. Which
directories are folded right now:

    find ~ -maxdepth 3 -lname '*dotfiles*' -xtype d

GNU find only; macOS has no `-xtype`.

## Machine-specific settings

Never commit secrets. Per-machine values go in files that are git-ignored and
sourced last:

- `~/.config/shell/local.sh` -- environment, tokens, host quirks
- `~/.config/shell/local.zsh` -- interactive zsh tweaks
- `~/.config/alacritty/local.toml` -- enable the `import` in `alacritty.toml`

## Packages to install

Homebrew everywhere it can be, since it is the only package manager common to
every machine.

    brew install chafa cmake gh neovim pkgconf rustup starship stow tmux \
                 zsh-autosuggestions zsh-syntax-highlighting bitwarden-cli
    brew install --cask claude-code

Rust toolchain, then the binaries built from crates.io:

    rustup default stable
    cargo install alacritty cargo-update

### Inventory

Use this when bringing another machine in line: install what is missing, and
drop anything installed there by another means so all four stay on one
source.

From brew, requested explicitly. Everything else brew lists came along as a
dependency -- `brew leaves` is the list that matters, `brew list --formula`
is that plus the dependencies.

| Formula | Why |
|---|---|
| `bitwarden-cli` | secrets, kept out of this repo |
| `chafa` | images as terminal characters; works at 8 colours |
| `cmake` | build dependency for crates that ship C |
| `gh` | GitHub auth and PRs |
| `neovim` | editor |
| `pkgconf` | lets cargo find system libraries |
| `rustup` | keg-only; `env.sh` adds its shims to PATH |
| `starship` | the prompt |
| `stow` | installs this repo |
| `tmux` | multiplexer |
| `zsh-autosuggestions` | sourced by `.zshrc` |
| `zsh-syntax-highlighting` | sourced last by `.zshrc`, order matters |

Casks are macOS-only in general, but `claude-code` installs on Linux too.

From cargo, for what brew does not carry: `alacritty`, and `cargo-update`,
whose binaries are `cargo-install-update` and `cargo-install-update-config`.

Upgrades: `brew upgrade` for the table, `cargo install-update -a` for the
two crates.

Deliberately NOT from brew:

- **zsh** -- the login shell comes from the system on every machine. Under the
  brew prefix, a broken prefix means a broken login.
- **Display and font development headers** -- these link against the platform's
  graphics stack, so brew's copies are the wrong ones on Linux.
- **niri and DankMaterialShell** -- a compositor and its shell. Not packaged by
  brew, and not on crates.io either: the `niri` crate there is an empty 0.0.0
  name reservation. See below.

## Linux only

    sudo apt install zsh libfreetype-dev libfontconfig1-dev \
                     libxkbcommon-dev libxcb-xfixes0-dev

The last four are only needed to build Alacritty from source with cargo.

`.config/environment.d/10-path.conf` puts `~/.cargo/bin` on the PATH the
systemd user manager hands to desktop applications; without it the session
cannot launch a cargo-installed Alacritty. It applies at the next login, and
only where systemd runs the session.

Do not add the brew prefix to that file. Having it there makes `command -v
brew` succeed before `env.sh` runs, which silently skips `brew shellenv` --
and that is what exports `HOMEBREW_PREFIX` and puts brew's completions on
`fpath`.

### niri and DankMaterialShell

Installed with the installer from <https://danklinux.com/>, which adds two
OpenSUSE Build Service repositories and pulls everything from apt:

    /etc/apt/sources.list.d/home-AvengeMedia-danklinux.list
    /etc/apt/sources.list.d/home-AvengeMedia-dms.list

It brings in `niri`, `dms`, `quickshell`, `xwayland-satellite`, `matugen`,
`dgop`, `danksearch`, `dankcalendar-git`, and `greetd` with `dms-greeter`.

The greeter replaces GDM: it takes over
`/etc/systemd/system/display-manager.service` and logs straight into niri.
`/etc/X11/default-display-manager` still says `gdm3` and is simply stale --
systemd goes by the symlink. To go back:

    sudo systemctl disable greetd
    sudo ln -sf /lib/systemd/system/gdm3.service \
                /etc/systemd/system/display-manager.service

If a graphical login ever fails, Ctrl+Alt+F3 still gives a text console.

Two files in here are generated and will show up as modified whenever the
theme changes. They are tracked on purpose, so a fresh machine looks right
before DMS has run once:

- `.config/niri/dms/colors.kdl`
- `.config/alacritty/dank-theme.toml`

## macOS

Alacritty is installed from cargo there too, with the `.app` bundle built by
hand, since `cargo install` only drops a bare binary. Same version as every
other machine.

The brew prefix is `/opt/homebrew` on Apple Silicon. Nothing here hardcodes
it: `env.sh` probes the three known prefixes at runtime.

`environment.d` is systemd, so it is inert there, as are the `.desktop` entry,
the icon, and everything under `.config/niri`. They link harmlessly and are
ignored.

### The font needs a symlink, not stow

fontconfig is not used by native macOS applications; they read
`~/Library/Fonts`. This repo targets `~/.local/share/fonts`, which is the
Linux path, so link the file directly instead:

    ln -s ~/dotfiles/.local/share/fonts/DepartureMono-Regular.otf \
          ~/Library/Fonts/

`brew install --cask font-departure-mono` also works, but pins a version
independent of this repo, so the terminal can end up looking different from
the other machines.

## Headless box

The flat layout is all or nothing, so the font, the desktop entry and the niri
config land there too. They are inert without a display and cost about 90 KB,
which is cheaper than maintaining a second layout.

`.zshenv` matters most there: `ssh host 'command'` starts a shell that is
neither interactive nor login and reads nothing else, so without it a remote
command gets a bare PATH.

## Departure Mono

The repo's only binary, and the only exception to the ASCII rule.
[Departure Mono](https://departuremono.com/) by Helena Zhang, under the
SIL Open Font License 1.1 (`.local/share/fonts/LICENSE-DepartureMono.txt`),
which permits redistribution.

It is vendored rather than installed per-machine so every terminal renders
identically, and because `alacritty.toml` naming a missing font fails silently
into the system monospace.

Note for HiDPI: this desktop runs fractional scaling. Bitmap console
fonts -- Terminus, the IBM VGA 8x16 clones -- get resampled into mush there.
Departure Mono is an outline pixel font and survives it.
