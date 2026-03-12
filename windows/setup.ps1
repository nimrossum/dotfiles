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

nvm install latest
nvm use latest

# Git identity – update these before running
# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"

# Git aliases
git config --global alias.rc "rebase --continue"
git config --global alias.ra "rebase --abort"
git config --global alias.ri "rebase -i"
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.cm "commit -m"
git config --global alias.ca "commit --amend"
git config --global alias.cp "cherry-pick"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.please "push --force-with-lease"
git config --global alias.unstage "reset HEAD --"

npx --quiet cowsay "All done!"
