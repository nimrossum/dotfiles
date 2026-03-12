$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$ScriptDir\scripts\packages.ps1"
& "$ScriptDir\scripts\node.ps1"
& "$ScriptDir\scripts\git.ps1"

npx --quiet cowsay "All done!"
