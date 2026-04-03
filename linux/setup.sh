#!/usr/bin/env bash
set -e

# Warn if running as root; dotfiles should be set up for the target user, not root.
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "[dotfiles] WARNING: Running as root. Dotfiles will be created under root's HOME ($HOME)."
  echo "[dotfiles] If you meant to set up dotfiles for a regular user, run without sudo:"
  echo "[dotfiles]   curl -sL https://raw.githubusercontent.com/nimrossum/dotfiles/refs/heads/main/linux/setup.sh | bash"
  # If invoked via sudo, prefer the original user's home directory.
  if [ -n "${SUDO_USER:-}" ]; then
    _sudo_home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
    if [ -n "$_sudo_home" ]; then
      HOME="$_sudo_home"
      echo "[dotfiles] Using home directory of '$SUDO_USER': $HOME"
    else
      echo "[dotfiles] WARNING: Could not resolve home directory for '$SUDO_USER'; using $HOME."
    fi
    unset _sudo_home
  fi
fi

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/nimrossum/dotfiles.git"

echo "[dotfiles] Checking for git..."
if ! command -v git >/dev/null 2>&1; then
  echo "[dotfiles] Installing git..."
  sudo apt update
  sudo apt install -y git
fi

echo "[dotfiles] Cloning or updating dotfiles repository..."
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  git -C "$DOTFILES_DIR" pull
fi

echo "[dotfiles] Creating symlinks..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/linux/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/linux/zsh/pr_prompt.sh" "$HOME/.config/pr_prompt.sh"
ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
# Optionally symlink .bashrc if desired
ln -sf "$DOTFILES_DIR/linux/bash/bashrc" "$HOME/.bashrc"

echo "[dotfiles] Running package installation scripts..."
source "$DOTFILES_DIR/linux/scripts/packages.sh"
source "$DOTFILES_DIR/linux/scripts/node.sh"
source "$DOTFILES_DIR/linux/scripts/git-credentials.sh"
source "$DOTFILES_DIR/linux/scripts/git.sh"

# Check for gh (GitHub CLI) for PR prompt integration
if ! command -v gh >/dev/null 2>&1; then
  echo "[dotfiles] Installing GitHub CLI (gh)..."
  sudo apt install -y gh
fi

# Check for npx (Node.js) before using cowsay
if ! command -v npx >/dev/null 2>&1; then
  echo "[dotfiles] Installing Node.js (for npx)..."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install node
fi

echo "[dotfiles] Setup complete!"

# Verification section
echo
echo "[dotfiles] Verifying setup..."

verify_pass() { echo -e "[PASS] $1"; }
verify_fail() { echo -e "[FAIL] $1"; }

# Check commands
for cmd in git gh nvm node npx just bun; do
  if command -v "$cmd" >/dev/null 2>&1; then
    verify_pass "$cmd installed"
  else
    verify_fail "$cmd missing"
  fi
done

# Check dotfiles repo
if [ -d "$DOTFILES_DIR/.git" ]; then
  verify_pass "dotfiles repo present"
  if git -C "$DOTFILES_DIR" status | grep -q 'up to date'; then
    verify_pass "dotfiles repo up to date"
  else
    verify_fail "dotfiles repo not up to date"
  fi
else
  verify_fail "dotfiles repo missing"
fi

# Check symlinks
check_symlink() {
  local link="$1"; local target="$2"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    verify_pass "$link symlinked to $target"
  else
    verify_fail "$link not symlinked to $target"
  fi
}
check_symlink "$HOME/.zshrc" "$DOTFILES_DIR/linux/zsh/zshrc"
check_symlink "$HOME/.config/pr_prompt.sh" "$DOTFILES_DIR/linux/zsh/pr_prompt.sh"
check_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/git/gitconfig"

# Check PR prompt script is executable
if [ -x "$DOTFILES_DIR/linux/zsh/pr_prompt.sh" ]; then
  verify_pass "pr_prompt.sh is executable"
else
  verify_fail "pr_prompt.sh is not executable"
fi

echo
echo "[dotfiles] Verification complete."
npx -y cowsay "All done!"
