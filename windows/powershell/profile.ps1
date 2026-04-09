# PowerShell Profile - dotfiles configuration

# bun
$env:BUN_INSTALL = "$env:USERPROFILE\.bun"
$env:PATH = "$env:BUN_INSTALL\bin;$env:PATH"

# nvm
$env:NVM_DIR = "$env:USERPROFILE\.nvm"
if (Test-Path "$env:NVM_DIR\nvm.ps1") {
    & "$env:NVM_DIR\nvm.ps1"
}

# Git credentials and config via symlinked gitconfig
# (Git config is in dotfiles/git/gitconfig)
