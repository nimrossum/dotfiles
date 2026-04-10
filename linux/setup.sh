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

  if [ -z "$zsh_path" ]; then
    log "zsh is not available, so the default login shell cannot be changed."
  elif [ "$current_shell" = "$zsh_path" ]; then
    log "Default login shell is already zsh."
  elif [ ! -t 0 ] || [ ! -t 1 ]; then
    log "Default login shell is not zsh. Run manually: chsh -s $zsh_path"
  elif command_exists chsh; then
    log "Setting default login shell to $zsh_path..."
    if chsh -s "$zsh_path" "$USER"; then
      log "Default login shell updated to zsh."
    else
      log "Could not change default shell automatically. Run: chsh -s $zsh_path"
    fi
  else
    log "chsh not available. Run manually: chsh -s $zsh_path"
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

ensure_openssh_client() {
  if command_exists ssh && command_exists ssh-keygen; then
    return
  fi

  log "Installing OpenSSH client..."
  if command_exists apt-get; then
    sudo apt-get update
    sudo apt-get install -y openssh-client
  elif command_exists apt; then
    sudo apt update
    sudo apt install -y openssh-client
  else
    log "No apt-based package manager found. Install openssh-client manually."
  fi
}

ensure_github_ssh_access() {
  local ssh_key
  local ssh_pub_key
  local pub_key_material
  local key_title
  local current_origin
  local desired_origin

  ssh_key="$HOME/.ssh/id_ed25519"
  ssh_pub_key="$ssh_key.pub"
  desired_origin="git@github.com:nimrossum/dotfiles.git"

  ensure_openssh_client

  if ! command_exists ssh-keygen; then
    log "ssh-keygen not available; skipping GitHub SSH setup."
    return
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ ! -f "$ssh_key" ] || [ ! -f "$ssh_pub_key" ]; then
    key_title="${USER}@$(hostname)-dotfiles"
    log "Generating SSH key at $ssh_key..."
    ssh-keygen -t ed25519 -C "$key_title" -f "$ssh_key" -N ""
  fi

  chmod 600 "$ssh_key"
  chmod 644 "$ssh_pub_key"

  if ! command_exists gh; then
    log "GitHub CLI (gh) not available; cannot upload SSH key automatically."
    return
  fi

  if ! gh auth status -h github.com >/dev/null 2>&1; then
    log "GitHub CLI is not authenticated. Run 'gh auth login', then rerun setup to upload SSH key."
    return
  fi

  pub_key_material="$(awk '{print $2}' "$ssh_pub_key")"
  if [ -z "$pub_key_material" ]; then
    log "Could not read SSH public key material from $ssh_pub_key."
    return
  fi

  if gh api user/keys --paginate --jq '.[].key' 2>/dev/null | grep -qxF "$pub_key_material"; then
    log "SSH public key already present on GitHub."
  else
    key_title="$(hostname)-$(date +%Y-%m-%d)-dotfiles"
    log "Uploading SSH public key to GitHub..."
    gh ssh-key add "$ssh_pub_key" --title "$key_title"
  fi

  current_origin="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
  if [ "$current_origin" != "$desired_origin" ]; then
    log "Switching dotfiles remote to SSH..."
    git -C "$DOTFILES_DIR" remote set-url origin "$desired_origin"
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
ln -sf "$DOTFILES_DIR/linux/shell/hushlogin" "$HOME/.hushlogin"
ln -sf "$DOTFILES_DIR/linux/bash/bashrc" "$HOME/.bashrc"

log "Open a new terminal to use zsh as your login shell."

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

ensure_github_ssh_access

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

dotfiles_origin="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
if [ "$dotfiles_origin" = "git@github.com:nimrossum/dotfiles.git" ]; then
  verify_pass "dotfiles origin uses SSH"
else
  verify_fail "dotfiles origin is not SSH"
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
check_symlink "$HOME/.hushlogin" "$DOTFILES_DIR/linux/shell/hushlogin"

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
