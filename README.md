# Dotfiles

Personal dotfiles managed with a bare git repository. Config files are tracked with paths relative to `$HOME`, so they land where programs expect them on checkout.

---

## Setup

### 1. Clone the repo

```bash
git clone --bare git@github.com:LukasPW/dotfiles.git "$HOME/.dotfiles"
```

### 2. Define the alias

```bash
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
```

Add this to your `.bashrc` or `.zshrc` to persist it across sessions.

### 3. Check out the files

```bash
dotfiles checkout
```

If git complains about existing files conflicting with the checkout, back them up and remove them, then try again:

```bash
mkdir -p "$HOME/.dotfiles-backup"
dotfiles checkout 2>&1 | grep "^\s" | awk '{print $1}' | xargs -I{} mv "$HOME/{}" "$HOME/.dotfiles-backup/{}"
dotfiles checkout
```

### 4. Hide untracked files

Prevents `dotfiles status` from cluttering output with every untracked file in `$HOME`:

```bash
dotfiles config --local status.showUntrackedFiles no
```

---

## Install packages

Run the install script as root from the dotfiles directory:

```bash
sudo ./install.sh --install
```

This reads `packages.txt` and installs everything with pacman.

### Uninstall packages

```bash
sudo ./install.sh --uninstall
```

Removes the packages listed in `packages.txt`. Dependencies of other installed packages are left untouched.

---

## Branches

Currently a single stable branch. A `dev` branch may be introduced in the future for testing changes before merging to stable. If that happens, this section will be updated with the relevant checkout instructions.
