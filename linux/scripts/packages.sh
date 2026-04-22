sudo apt update
sudo apt install -y unzip git curl tar libatomic1 neofetch zsh

# Install `just` (command runner) https://github.com/casey/just
if sudo apt install -y just; then
	:
else
	echo "[dotfiles] apt package 'just' not found; installing via upstream script to ~/.local/bin"
	if curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$HOME/.local/bin"; then
		:
	else
		echo "[dotfiles] failed to install 'just' via fallback installer"
	fi
fi

# GitHub Copilot CLI
curl -fsSL https://gh.io/copilot-install | bash
