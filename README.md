# dotfiles

Shell, terminal and desktop configuration shared across four machines: a
Debian 13 desktop, WSL, an Apple Silicon Mac, and a headless box reached over
ssh.

Managed with GNU Stow as a single flat package: the repo root mirrors `$HOME`
directly, so `.zshrc` here becomes `~/.zshrc`.

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
| `.config/console/` | same | the tty's 16 slots; its bright half carries the second Catppuccin tier, where Alacritty keeps upstream's duplicates |
| `.config/niri/` | same | compositor, plus the `dms/` fragments it includes |
| `.local/share/fonts/` | same | Departure Mono, see below |
| `.local/share/applications/`, `.local/share/icons/` | same | Alacritty desktop entry and icon |
| `.gitconfig` | `~/.gitconfig` | |
| `.claude/CLAUDE.md`, `.claude/themes/` | same | `.gitignore` excludes the rest of `~/.claude`, `settings.json` with it -- so the themes travel but the choice of one does not |

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

## Machine-specific settings

Never commit secrets. Per-machine values go in files that are git-ignored and
sourced last:

- `~/.config/shell/local.sh` -- environment, tokens, host quirks
- `~/.config/shell/local.zsh` -- interactive zsh tweaks
- `~/.config/alacritty/local.toml` -- enable the `import` in `alacritty.toml`

## Region and time

System state, not repo state: set once per machine.

The Debian installer splits the locale in `/etc/default/locale`: `LANG` in
`en_US.UTF-8` for program messages, the ten formatting categories in
`es_AR.UTF-8`. Keep the split. Unifying on `en_US` takes `LC_MEASUREMENT`,
`LC_PAPER` and `LC_MONETARY` back to imperial, Letter and USD.

`LC_NUMERIC` is a comma there, so `awk` prints `1234,50`. Where output has to
be parsed, `LC_ALL=C` goes in front of the script rather than in the session.

`sshd_config` carries `AcceptEnv LANG LC_*`, so over ssh the client's locale
wins over this one. Only what `locale -a` lists can be honoured; a client
forwarding anything else draws `cannot set locale`.

Timezone is separate from the locale:

    sudo timedatectl set-timezone America/Argentina/Buenos_Aires

A minimal Debian ships no NTP client, so nothing disciplines the clock:

    sudo apt install systemd-timesyncd

Enabled on install and needs no configuration -- `NTP=` is empty, so it falls
back to the Debian pool. `timedatectl` reports whether it took.

## Packages to install

Homebrew everywhere it can be, since it is the only package manager common to
every machine.

    brew bundle --file=~/dotfiles/Brewfile

`Brewfile` is the inventory below in machine-readable form. Keep the two in
step: `brew leaves` is what belongs in it.

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
| `fastfetch` | system summary, run by hand |
| `fzf` | sourced by `.zshrc` for `C-r`, `C-t` and `M-c` |
| `gh` | GitHub auth and PRs |
| `neovim` | editor |
| `pkgconf` | lets cargo find system libraries |
| `ripgrep` | what the nvim picker greps with |
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
- **Anything that exists on only one of the platforms.** Brew earns its keep
  by holding one inventory for all four machines; a formula that cannot be
  installed on three of them buys nothing and hides the fact that the tool is
  platform-specific. Those go through the platform's own manager.

## Linux only

    sudo apt install zsh wl-clipboard libfreetype-dev libfontconfig1-dev \
                     libxkbcommon-dev libxcb-xfixes0-dev

The last four are only needed to build Alacritty from source with cargo.

`wl-clipboard` gives `wl-copy` and `wl-paste`, which is how anything outside
the terminal reaches the system clipboard under Wayland. Wayland only: macOS
has `pbcopy`, and WSL has `clip.exe`. Whatever uses it has to pick at
runtime, so probe with `command -v` rather than assuming.

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

### The fonts need a symlink, not stow

fontconfig is not used by native macOS applications; they read
`~/Library/Fonts`. This repo targets `~/.local/share/fonts`, which is the
Linux path, so link both files directly instead:

    ln -s ~/dotfiles/.local/share/fonts/DepartureMono-Regular.otf \
          ~/dotfiles/.local/share/fonts/SymbolsNerdFontMono-Regular.ttf \
          ~/Library/Fonts/

The symbols font matters as much as the other one: the fontconfig rule that
supplies the Nerd Font icons on Linux does nothing here, so without it
installed there is nothing for Core Text to fall back to.

`brew install --cask font-departure-mono` also works, but pins a version
independent of this repo, so the terminal can end up looking different from
the other machines.

## Headless box

From a fresh Debian with nothing but git and brew:

    git clone git@github.com:51lv3str1/dotfiles.git ~/dotfiles
    brew bundle --file=~/dotfiles/Brewfile
    stow -d ~/dotfiles -t ~ .
    sudo apt install zsh
    chsh -s /usr/bin/zsh

Bundle before stow: stow itself comes out of the Brewfile. zsh comes from apt
rather than brew, for the reason under Inventory.

Skip `cargo install alacritty` here, and the `-dev` packages that go with it:
there is no display to draw on. `cargo install cargo-update` still applies.

The flat layout is all or nothing, so the font, the desktop entry and the niri
config land there too. They are inert without a display and cost about 90 KB,
which is cheaper than maintaining a second layout.

`.zshenv` matters most there: `ssh host 'command'` starts a shell that is
neither interactive nor login and reads nothing else, so without it a remote
command gets a bare PATH.

Bash has no equivalent. Its only hook there is `$BASH_ENV`, which has to be in
the environment already, and sshd exports none of the user's unless the server
sets `PermitUserEnvironment yes`. `env.sh` exports it anyway, which covers
scripts, make and git hooks started from a configured session. But where bash
is the login shell, `ssh host 'command'` still needs `bash -lc` around the
command, or that sshd setting.

## Departure Mono

The repo's only binary.
[Departure Mono](https://departuremono.com/) by Helena Zhang, under the
SIL Open Font License 1.1 (`.local/share/fonts/LICENSE-DepartureMono.txt`),
which permits redistribution.

It is vendored rather than installed per-machine so every terminal renders
identically, and because `alacritty.toml` naming a missing font fails silently
into the system monospace.

Note for HiDPI: this desktop runs fractional scaling. Bitmap console
fonts -- Terminus, the IBM VGA 8x16 clones -- get resampled into mush there.
Departure Mono is an outline pixel font and survives it.

### Nerd Font icons

Departure Mono ships no Nerd Font icons, so
`.config/fontconfig/conf.d/10-nerd-font-symbols.conf` prefers `Symbols Nerd
Font Mono` for it and for generic `monospace`. Only the icons come from there:
fontconfig weighs glyph coverage, so text keeps resolving to the real font.

    fc-match "Departure Mono"                # Departure Mono
    fc-match "Departure Mono:charset=e0b0"   # Symbols Nerd Font Mono
    fc-match "monospace"                     # Noto Sans Mono
    fc-match "monospace:charset=e0b0"        # Symbols Nerd Font Mono

This is the fontconfig side of it, so it covers Linux. Native macOS
applications go through Core Text and ignore the file; it links harmlessly
there, like the rest of the Linux-only entries.
