log() { echo "[setup] $*"; }
warn() { echo "[setup][WARN] $*" >&2; }
die() {
  echo "[setup][ERROR] $*" >&2
  exit 1
}
as_user() { sudo -u "$REAL_USER" "$@"; }
dotfiles_git() { as_user git --git-dir="$REAL_HOME/dotfiles/" --work-tree="$REAL_HOME" "$@"; }
