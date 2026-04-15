# Dotfiles

Managed with a **bare git repository** — no symlinks, no extra tooling. Config files are tracked in-place directly from `$HOME`.

---

## How it works

The repo lives at `~/dotfiles/` as a bare git repo. A shell alias called `dotfiles` points git at that repo while treating `$HOME` as the working tree. This means you can add, commit, and push any file under `$HOME` directly, and apps find their configs exactly where they expect them.

---

## Initial setup (first machine)

Add this alias to your shell config (`.bashrc`, `.zshrc`, etc.) and reload it:

```bash
alias dotfiles='git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'
```

Hide untracked files so `dotfiles status` isn't flooded with every file in `~`:

```bash
dotfiles config --local status.showUntrackedFiles no
```

---

## Day-to-day usage

```bash
dotfiles status                   # see tracked changes
dotfiles add ~/.config/nvim/init.lua  # track a new file
dotfiles commit -m "update nvim config"
dotfiles push
```

---

## Restoring on a new machine

```bash
# 1. Clone the bare repo
git clone --bare <your-repo-url> "$HOME/dotfiles"

# 2. Set up the alias
alias dotfiles='git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'

# 3. Check out the files
dotfiles checkout

# 4. Suppress untracked file noise
dotfiles config --local status.showUntrackedFiles no
```

If step 3 fails due to conflicting files (e.g. a default `.bashrc` already exists), back them up first then retry:

```bash
mkdir -p ~/.dotfiles-backup
dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' \
  | xargs -I{} mv {} ~/.dotfiles-backup/{}
dotfiles checkout
```

---

## Make the alias permanent

Make sure the alias is in your shell config and that the shell config itself is tracked:

```bash
dotfiles add ~/.bashrc   # or ~/.zshrc
dotfiles commit -m "add dotfiles alias"
```
