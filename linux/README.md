# Linux Setup

## Quick Start

> **Tip:** inspect the script before running it — download it first, review it, then execute.

Run the setup script directly:

```sh
curl -sL https://raw.githubusercontent.com/nimrossum/dotfiles/refs/heads/main/linux/setup.sh | bash -
```

## What it installs

- **unzip** – archive utility
- **libatomic1** – runtime dependency required by some Node.js builds
- **zsh** – shell used by the dotfiles prompt/config
- **bun** – fast JavaScript runtime & package manager
- **nvm** – Node Version Manager
- **node** – latest Node.js (via nvm)
- **Neovim** – latest release extracted from `nvim-linux-x86_64.tar.gz` to `/opt/nvim-linux-x86_64`

- **just** – command runner (via apt when available, otherwise installed to `~/.local/bin`)
- **fastfetch** (preferred) or **neofetch** (fallback when available) – optional system info display in terminal

## Shell behavior

- Setup installs `zsh` and tries to set it as your default login shell via `chsh`.
- Setup starts `zsh` automatically at the end when run in an interactive terminal.
- If needed, you can still switch manually with `exec zsh`.
- Setup adds `/opt/nvim-linux-x86_64/bin` to managed shell configs and skips the Neovim download/extract step on reruns when `/opt/nvim-linux-x86_64/bin/nvim` already exists.

## Git Aliases

| Alias      | Command                              |
|------------|--------------------------------------|
| `rc`       | `rebase --continue`                  |
| `ra`       | `rebase --abort`                     |
| `ri`       | `rebase -i`                          |
| `remain`   | `rebase -i --autosquash origin/main` |
| `st`       | `status`                             |
| `co`       | `checkout`                           |
| `br`       | `branch`                             |
| `cm`       | `commit -m`                          |
| `ca`       | `commit --amend`                     |
| `cp`       | `cherry-pick`                        |
| `lg`       | `log --oneline --graph --decorate --all` |
| `please`   | `push --force-with-lease`            |
| `unstage`  | `reset HEAD --`                      |
