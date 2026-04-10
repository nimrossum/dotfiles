# Bun
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
if [ ! -x "$BUN_INSTALL/bin/bun" ]; then
	tmp_bun_install="$(mktemp)"
	tmp_bun_home="$(mktemp -d)"
	cleanup_bun_install() {
		rm -rf "$tmp_bun_install" "$tmp_bun_home"
	}
	trap cleanup_bun_install EXIT
	curl -fsSL https://bun.sh/install -o "$tmp_bun_install"
	HOME="$tmp_bun_home" XDG_CONFIG_HOME="$tmp_bun_home/.config" bash "$tmp_bun_install"
	cleanup_bun_install
	trap - EXIT
fi

# Load Bun in the current shell so setup verification can detect it.
if [ -d "$BUN_INSTALL/bin" ]; then
	export PATH="$BUN_INSTALL/bin:$PATH"
fi

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install node
