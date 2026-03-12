# Requires nvm to be installed (via packages.ps1) and environment refreshed
nvm install latest
nvm use latest

# Bun
powershell -c "irm bun.sh/install.ps1 | iex"
