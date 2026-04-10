# Bun
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
if [ ! -x "$BUN_INSTALL/bin/bun" ]; then
	tmp_bun_install="$(mktemp)"
	curl -fsSL https://bun.sh/install -o "$tmp_bun_install"
	bash "$tmp_bun_install"
	rm -f "$tmp_bun_install"
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
