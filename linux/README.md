# Linux Setup

## Quick Start

> **Tip:** inspect the script before running it — download it first, review it, then execute.

Run the setup script directly:

```sh
curl -sL https://raw.githubusercontent.com/nimrossum/dotfiles/refs/heads/main/linux/setup.sh | bash
```

> **Note:** Run as your regular user — **no** `sudo` needed for the one-liner. The script will prompt for `sudo` automatically when elevated privileges are needed (e.g. for `apt install`).

## What it installs

- **unzip** – archive utility
- **bun** – fast JavaScript runtime & package manager
- **nvm** – Node Version Manager
- **node** – latest Node.js (via nvm)

- **just** – command runner

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
