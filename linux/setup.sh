#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/nimrossum/dotfiles.git"

if [ -t 1 ]; then
  C_RESET='\033[0m'
  C_HEADER='\033[1;36m'
  C_INFO='\033[0;34m'
  C_PASS='\033[0;32m'
  C_FAIL='\033[0;31m'
else
  C_RESET=''
  C_HEADER=''
  C_INFO=''
  C_PASS=''
  C_FAIL=''
fi

log() {
  printf '%b[dotfiles]%b %s\n' "$C_INFO" "$C_RESET" "$1"
}

section() {
  echo
  printf '%b[dotfiles] %s%b\n' "$C_HEADER" "$1" "$C_RESET"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

verify_pass() {
  printf '%b[PASS]%b %s\n' "$C_PASS" "$C_RESET" "$1"
}

verify_fail() {
  printf '%b[FAIL]%b %s\n' "$C_FAIL" "$C_RESET" "$1"
}

ensure_zsh_default_shell() {
  if ! command_exists zsh; then
    log "Installing zsh..."
    if command_exists apt-get; then
      sudo apt-get update
      sudo apt-get install -y zsh
    elif command_exists apt; then
      sudo apt update
      sudo apt install -y zsh
    else
      log "No apt-based package manager found. Install zsh manually."
      return
    fi
  fi

  local zsh_path
  local current_shell
  zsh_path="$(command -v zsh)"
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"

  if [ -n "$zsh_path" ] && [ "$current_shell" != "$zsh_path" ]; then
    log "Setting default login shell to $zsh_path..."
    if command_exists chsh; then
      if chsh -s "$zsh_path" "$USER"; then
        log "Default login shell updated to zsh."
      else
        log "Could not change default shell automatically. Run: chsh -s $zsh_path"
      fi
    else
      log "chsh not available. Run manually: chsh -s $zsh_path"
    fi
  fi
}

ensure_libatomic_runtime() {
  if command_exists ldconfig && ldconfig -p 2>/dev/null | grep -q 'libatomic\.so\.1'; then
    return
  fi

  log "libatomic.so.1 not found. Installing runtime dependency..."
  if command_exists apt-get; then
    sudo apt-get update
    sudo apt-get install -y libatomic1
  elif command_exists apt; then
    sudo apt update
    sudo apt install -y libatomic1
  else
    log "No apt-based package manager found. Install libatomic manually for Node.js."
  fi
}

section "Starting Linux setup"

log "Checking for git..."
if ! command_exists git; then
  log "Installing git..."
  sudo apt update
  sudo apt install -y git
fi

log "Cloning or updating dotfiles repository..."
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  git -C "$DOTFILES_DIR" pull
fi

section "Creating symlinks"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/linux/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/linux/zsh/pr_prompt.sh" "$HOME/.config/pr_prompt.sh"
ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
# Optionally symlink .bashrc if desired
ln -sf "$DOTFILES_DIR/linux/bash/bashrc" "$HOME/.bashrc"

log "Open a new terminal or run 'source ~/.bashrc' to load shell changes."

section "Installing packages"
source "$DOTFILES_DIR/linux/scripts/packages.sh"
ensure_libatomic_runtime
source "$DOTFILES_DIR/linux/scripts/node.sh"

# Ensure Bun is visible to this process before verification checks.
export BUN_INSTALL="$HOME/.bun"
if [ -d "$BUN_INSTALL/bin" ]; then
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

ensure_zsh_default_shell

# Check for gh (GitHub CLI) for PR prompt integration
if ! command_exists gh; then
  log "Installing GitHub CLI (gh)..."
  sudo apt install -y gh
fi

# Check for npx (Node.js) before using cowsay
if ! command_exists npx; then
  log "Installing Node.js (for npx)..."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install node
fi

section "Verifying setup"

for cmd in git gh nvm node npx just bun zsh neofetch; do
  if command_exists "$cmd"; then
    verify_pass "$cmd installed"
  else
    verify_fail "$cmd missing"
  fi
done

# Check dotfiles repo
if [ -d "$DOTFILES_DIR/.git" ]; then
  verify_pass "dotfiles repo present"
  if [ -z "$(git -C "$DOTFILES_DIR" status --porcelain 2>/dev/null)" ]; then
    verify_pass "dotfiles repo working tree clean"
  else
    verify_fail "dotfiles repo has local changes"
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
check_symlink "$HOME/.bashrc" "$DOTFILES_DIR/linux/bash/bashrc"

if command_exists zsh; then
  zsh_path="$(command -v zsh)"
  login_shell="$(getent passwd "$USER" | cut -d: -f7)"
  if [ "$login_shell" = "$zsh_path" ]; then
    verify_pass "default shell is zsh"
  else
    verify_fail "default shell is not zsh"
  fi
else
  verify_fail "zsh missing; cannot verify default shell"
fi

# Check PR prompt script is executable
if [ -x "$DOTFILES_DIR/linux/zsh/pr_prompt.sh" ]; then
  verify_pass "pr_prompt.sh is executable"
else
  verify_fail "pr_prompt.sh is not executable"
fi

section "Setup complete"

if command_exists node; then
  if ! node --version >/dev/null 2>&1; then
    log "Node is installed but cannot start. Re-checking runtime dependencies..."
    ensure_libatomic_runtime
  fi
fi

if command_exists npx; then
  npx -y cowsay "All done!"
else
  log "Node.js (npx) not found after install. Please check nvm installation."
fi

echo
log "Next steps:"
echo "  - Open a new terminal"
echo "  - Or switch now in this shell: exec zsh"
echo "  - Run 'gh auth login' if this is a new machine"

if [ -t 1 ] && command_exists zsh; then
  current_shell_name="$(ps -p $$ -o comm= 2>/dev/null | tr -d '[:space:]')"
  if [ "$current_shell_name" != "zsh" ]; then
    log "Starting zsh for this session..."
    exec zsh -l
  fi
fi
