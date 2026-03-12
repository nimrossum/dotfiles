# Windows Setup

## Quick Start

> **Tip:** inspect the script before running it — download it first, review it, then execute.

Run the setup script in an **elevated PowerShell** session:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-RestMethod https://raw.githubusercontent.com/nimrossum/dotfiles/refs/heads/main/windows/setup.ps1 | Invoke-Expression
```

## What it installs

- **Chocolatey** – Windows package manager
- **Google Chrome** & **Firefox** – browsers
- **nvm-windows** – Node Version Manager for Windows
- **VS Code** – code editor
- **Cascadia Code** – programming font
- **GitHub CLI** (`gh`)
- **Git** – with Windows Terminal integration
- **WizTree** – disk space analyser
- **Google Drive**

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
