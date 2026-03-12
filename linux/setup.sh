sudo apt update
sudo apt install unzip git

curl -fsSL https://bun.sh/install | bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source "$HOME/.bashrc"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node

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
git config --global alias.cp "cherry-pick"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.please "push --force-with-lease"
git config --global alias.unstage "reset HEAD --"
