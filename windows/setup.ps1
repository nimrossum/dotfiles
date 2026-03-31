npx -y cowsay "All done!"
# Windows PowerShell setup
Write-Host "[dotfiles] Checking for Chocolatey..."
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "[dotfiles] Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Host "[dotfiles] Checking for git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[dotfiles] Installing git..."
    choco install git
}

$dotfiles = "$env:USERPROFILE\dotfiles"

Write-Host "[dotfiles] Cloning or updating dotfiles repository..."
if (-not (Test-Path $dotfiles)) {
    git clone https://github.com/nimrossum/dotfiles.git $dotfiles
} else {
    git -C $dotfiles pull
}

# Symlink profile (fallback to copy if not admin)
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir }
try {
    Write-Host "[dotfiles] Creating symlink for PowerShell profile..."
    New-Item -Force -ItemType SymbolicLink -Path $PROFILE -Target "$dotfiles\windows\powershell\profile.ps1"
} catch {
    Write-Host "[dotfiles] Symlink failed, copying profile instead. (Run as admin for symlinks)"
    Copy-Item -Force "$dotfiles\windows\powershell\profile.ps1" $PROFILE
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "[dotfiles] Running package installation scripts..."
& "$ScriptDir\scripts\packages.ps1"

# Ensure environment is refreshed so nvm/npx are available
refreshenv

& "$ScriptDir\scripts\node.ps1"
& "$ScriptDir\scripts\git-credentials.ps1"
& "$ScriptDir\scripts\git.ps1"

# Check for npx (Node.js) before using cowsay
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Host "[dotfiles] Node.js (npx) not found after install. Please check nvm installation."
} else {
    Write-Host "[dotfiles] Setup complete!"
    npx -y cowsay "All done!"
}
