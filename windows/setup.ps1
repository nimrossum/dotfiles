$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$ScriptDir\scripts\packages.ps1"
& "$ScriptDir\scripts\node.ps1"
& "$ScriptDir\scripts\git-credentials.ps1"
& "$ScriptDir\scripts\git.ps1"

npx -y cowsay "All done!"
