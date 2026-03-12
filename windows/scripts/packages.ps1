# Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n=allowGlobalConfirmation

# Browsers
choco upgrade googlechrome firefox

# Development
choco upgrade nvm vscode cascadiacode gh

# Git
choco upgrade git --params "/WindowsTerminal /NoGuiHereIntegration /NoShellHereIntegration /NoGitLfs"

# Utility
choco upgrade wiztree googledrive
# choco upgrade unifiedremote vlc

# Gaming
# choco upgrade steam geforce-game-ready-driver geforce-experience

refreshenv
