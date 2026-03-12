# Git identity
git config --global user.name "Jonas Nim Røssum"
git config --global user.email "1959615+nimrossum@users.noreply.github.com"

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
