#!/bin/bash
set -e

# Check if OS is Linux or macOS
if [[ "$OSTYPE" != "linux-gnu"* && "$OSTYPE" != "darwin"* ]]; then
	echo "❌ OS is unsupported. Exiting"
	exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
	echo "✅ Installing Homebrew ..."
	/bin/bash -c "$(curl -fsSL \
		https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
		echo "❌ Failed to install Homebrew"
		exit 1
	}
fi

# Install prerequisites
echo "✅ Installing prerequisites ..."
brew install \
	stow \
	fastfetch \
	git-delta \
	sh-fmt \
	tldr \
	multitail \
	tree \
	zoxide \
	trash-cli \
	fzf \
	bat \
	nvim \
	tmux \
	starship || {
	echo "❌ Failed to install prerequisites"
	exit 1
}

# Install fonts
echo "✅ Installing fonts ..."
brew install \
	font-meslo-lg-nerd-font \
	font-fira-code-nerd-font \
	font-jetbrains-mono-nerd-font || {
	echo "❌ Failed to install fonts"
	exit 1
}

# Install bash completion
echo "✅ Installing bash completion ..."
version=$(bash --version | head -n1 | cut -d' ' -f4 |
	cut -d'(' -f1)
if [[ $(printf '%s\n' "$version" "4.2" | sort -V |
	head -n1) == "4.2" ]]; then
	brew install bash-completion@2 || {
		echo "❌ Failed to install bash-completion@2"
		exit 1
	}
else
	brew install bash-completion || {
		echo "❌ Failed to install bash-completion"
		exit 1
	}
fi

source ~/dotfiles/bashrc/.bashrc

echo "✅ Setup complete!"
