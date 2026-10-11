NEOVIM_ARCHIVE_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
NEOVIM_INSTALL_DIR="/opt/nvim-linux-x86_64"
NEOVIM_BIN="$NEOVIM_INSTALL_DIR/bin/nvim"

if [ -x "$NEOVIM_BIN" ]; then
	echo "[dotfiles] Neovim already installed at $NEOVIM_BIN"
	return 0
fi

tmp_nvim_archive="$(mktemp "${TMPDIR:-/tmp}/nvim-linux-x86_64.XXXXXX.tar.gz")"
cleanup_nvim_archive() {
	rm -f "$tmp_nvim_archive"
}
trap cleanup_nvim_archive EXIT

echo "[dotfiles] Installing Neovim..."
if ! curl -fL "$NEOVIM_ARCHIVE_URL" -o "$tmp_nvim_archive"; then
	echo "[dotfiles] failed to download Neovim archive from $NEOVIM_ARCHIVE_URL"
	return 1
fi

if ! sudo rm -rf "$NEOVIM_INSTALL_DIR"; then
	echo "[dotfiles] failed to remove existing Neovim directory at $NEOVIM_INSTALL_DIR"
	return 1
fi

if ! sudo tar -C /opt -xzf "$tmp_nvim_archive"; then
	echo "[dotfiles] failed to extract Neovim archive to /opt"
	return 1
fi

if [ ! -x "$NEOVIM_BIN" ]; then
	echo "[dotfiles] Neovim installation incomplete: expected binary not found at $NEOVIM_BIN"
	return 1
fi

cleanup_nvim_archive
trap - EXIT
