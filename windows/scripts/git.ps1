& "$PSScriptRoot\git-credentials.ps1"

# Git aliases
git config --global alias.rc "rebase --continue"
git config --global alias.ra "rebase --abort"
git config --global alias.ri "rebase -i"
git config --global alias.remain "rebase -i --autosquash origin/main"
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.cm "commit -m"
git config --global alias.ca "commit --amend"
git config --global alias.amend "commit --amend --no-edit"
git config --global alias.cp "cherry-pick"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.please "push --force-with-lease"
git config --global alias.unstage "reset HEAD --"
git config --global alias.pr "pull --rebase"

# Git pull configuration
git config --global pull.ff only
