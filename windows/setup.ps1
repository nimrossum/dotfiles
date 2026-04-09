# Windows PowerShell setup
$ErrorActionPreference = 'Stop'

function Write-Step($message) { Write-Host "[dotfiles] $message" -ForegroundColor Cyan }
function Write-Section($message) {
    Write-Host ""
    Write-Host "[dotfiles] $message" -ForegroundColor Magenta
}

Write-Section "Starting Windows setup"
Write-Step "Checking for Chocolatey..."
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Step "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Step "Checking for git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Step "Installing git..."
    choco install git -y
}

$dotfiles = "$env:USERPROFILE\dotfiles"

Write-Step "Cloning or updating dotfiles repository..."
if (-not (Test-Path "$dotfiles\.git")) {
    if (Test-Path $dotfiles) {
        Write-Step "Existing folder found at $dotfiles but it is not a git repository."
        exit 1
    }
    git clone https://github.com/nimrossum/dotfiles.git $dotfiles
} else {
    git -C $dotfiles pull
}

# Symlink profile (fallback to copy if not admin)
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir }
try {
    Write-Step "Creating symlink for PowerShell profile..."
    New-Item -Force -ItemType SymbolicLink -Path $PROFILE -Target "$dotfiles\windows\powershell\profile.ps1"
} catch {
    Write-Step "Symlink failed, copying profile instead. (Run as admin for symlinks)"
    Copy-Item -Force "$dotfiles\windows\powershell\profile.ps1" $PROFILE
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Section "Installing packages"
& "$ScriptDir\scripts\packages.ps1"

# Ensure environment is refreshed so nvm/npx are available
if (Get-Command refreshenv -ErrorAction SilentlyContinue) {
    refreshenv
} else {
    Write-Step "refreshenv not available; continuing with current session environment."
}

# Verification section
Write-Section "Verifying setup"

function Verify-Pass($msg) { Write-Host "[PASS] $msg" -ForegroundColor Green }
function Verify-Fail($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red }

# Check commands
$commands = @('git','gh','nvm','node','npx','just','bun')
foreach ($cmd in $commands) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Verify-Pass "$cmd installed"
    } else {
        Verify-Fail "$cmd missing"
    }
}

# Check dotfiles repo
if (Test-Path "$dotfiles\.git") {
    Verify-Pass "dotfiles repo present"
    $status = git -C $dotfiles status --porcelain 2>$null
    if (-not $status) {
        Verify-Pass "dotfiles repo working tree clean"
    } else {
        Verify-Fail "dotfiles repo has local changes"
    }
} else {
    Verify-Fail "dotfiles repo missing"
}

# Check symlink or file for profile
if (Test-Path $PROFILE) {
    Verify-Pass "PowerShell profile present"
} else {
    Verify-Fail "PowerShell profile missing"
}

Write-Section "Setup complete"

if (Get-Command npx -ErrorAction SilentlyContinue) {
    npx -y cowsay "All done!"
} else {
    Write-Step "Node.js (npx) not found after install. Please check nvm installation."
}

Write-Host ""
Write-Step "Next steps:"
Write-Host "  - Open a new PowerShell window"
Write-Host "  - Run 'gh auth login' if this is a new machine"
