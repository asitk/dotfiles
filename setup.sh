#!/bin/bash
set -e

# Check if OS is Linux or macOS
if [[ "$OSTYPE" != "linux-gnu"* && "$OSTYPE" != "darwin"* ]]; then
	echo -e "\033[31m✗\033[0m OS is unsupported. Exiting"
	exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
	echo -e "\033[32m✓\033[0m Installing Homebrew ..."
	/bin/bash -c "$(curl -fsSL \
		https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
		echo -e "\033[31m✗\033[0m Failed to install Homebrew"
		exit 1
	}
fi

# Install prerequisites
echo -e "\033[32m✓\033[0m Installing prerequisites ..."
brew reinstall \
	stow fastfetch shellcheck git lazygit tree-sitter-cli lua luarocks \
	git-delta eza ripgrep shfmt tealdeer multitail tree bottom zoxide \
	trash-cli fzf fd curl bat nvim tmux tpm xclip gcc make cmake gh openjdk \
	go php ruby composer perl julia imagemagick tectonic node starship || {
	echo -e "\033[31m✗\033[0m Failed to install prerequisites"
	exit 1
}

# Install fonts
echo -e "\033[32m✓\033[0m Installing fonts ..."
brew reinstall \
	font-meslo-lg-nerd-font font-fira-code-nerd-font \
	font-jetbrains-mono-nerd-font || {
	echo -e "\033[31m✗\033[0m Failed to install fonts"
	exit 1
}

# Install bash completion
echo -e "\033[32m✓\033[0m Installing bash completion ..."
version=$(bash --version | head -n1 | cut -d' ' -f4 |
	cut -d'(' -f1)
if [[ $(printf '%s\n' "$version" "4.2" | sort -V |
	head -n1) == "4.2" ]]; then
	brew reinstall bash-completion@2 || {
		echo -e "\033[31m✗\033[0m Failed to install bash-completion@2"
		exit 1
	}
else
	brew reinstall bash-completion || {
		echo -e "\033[31m✗\033[0m Failed to install bash-completion"
		exit 1
	}
fi

# Install LazyVim
echo -e "\033[32m✓\033[0m Installing AstroVim Template ..."
# Remove existing nvim config if it exists
if [ -d "$HOME/dotfiles/nvim" ]; then
	if [ -d "/tmp/nvim" ]; then
		rm -rf /tmp/nvim
	fi
	mv "$HOME/dotfiles/nvim" /tmp || {
		echo -e "\033[31m✗\033[0m Failed to cleanup existing nvim config"
		exit 1
	}
fi

# Backup additional nvim directories (optional but recommended)
if [ -d ~/.local/share/nvim ]; then
	rm -rf ~/.local/share/nvim
fi
if [ -d ~/.local/state/nvim ]; then
	rm -rf ~/.local/state/nvim
fi
if [ -d ~/.cache/nvim ]; then
	rm -rf ~/.cache/nvim
fi

# Clone AstroVim starter

if [ -d $HOME/dotfiles/nvim ]; then
	rm -rf $HOME/dotfiles/nvim 
fi

git clone --depth 1 https://github.com/AstroNvim/template "$HOME/dotfiles/nvim/.config/nvim" || {
	echo -e "\033[31m✗\033[0m Failed to clone AstroVim starter"
	exit 1
}

# Remove .git directory
rm -rf ~/.config/nvim/.git || {
	echo -e "\033[31m✗\033[0m Failed to remove .git from nvim config"
	exit 1
}

# Restore dotfiles
DOTFILES_DIR="$HOME/dotfiles"

# Navigate to the dotfiles directory
cd "$DOTFILES_DIR" || {
	echo -e "\033[31m✗\033[0m $HOME/dotfiles not found"
	exit 1
}

echo "Restoring dotfiles ..."
stow -R "bashrc"
stow -R "git"
stow -R "nvim"
stow -R "starship"
stow -R "tmux"

# Run headless install
nvim --headless +q

# Activate
source "$HOME/dotfiles/bashrc/.bashrc"

echo ""
echo -e "\033[32m✓\033[0m Setup complete! :)"
