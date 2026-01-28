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
tldr --update

# Check if trash command exists before running stow operations
if command -v trash &>/dev/null; then
	echo -e "\033[32m✓\033[0m Restoring dotfiles with trash ..."
	trash ~/.config/git
	stow -R "git"
	trash ~/.config/nvim
	stow -R "nvim"
	trash ~/.config/starship
	stow -R "starship"
	trash ~/.config/tmux
	stow -R "tmux"
	trash ~/.bashrc
	stow -R "bashrc"

	# Copy custom nvim configuration files
	echo -e "\033[32m✓\033[0m Installing custom nvim configuration files ..."

	# Define paths
	ASTROCORE_TARGET="$HOME/.config/nvim/lua/plugins/astrocore.lua"
	NEOTREE_TARGET="$HOME/.config/nvim/lua/plugins/neo-tree.lua"
	ASTROCORE_SOURCE="$HOME/dotfiles/nvim-custom-astrocore.lua"
	NEOTREE_SOURCE="$HOME/dotfiles/nvim-custom-neo-tree.lua"

	# Backup existing files if they exist
	if [ -f "$ASTROCORE_TARGET" ]; then
		mv "$ASTROCORE_TARGET" "$ASTROCORE_TARGET.bak" || {
			echo -e "\033[31m✗\033[0m Failed to backup existing astrocore.lua"
			exit 1
		}
		echo -e "\033[33m⚠\033[0m Backed up existing astrocore.lua to astrocore.lua.bak"
	fi

	if [ -f "$NEOTREE_TARGET" ]; then
		mv "$NEOTREE_TARGET" "$NEOTREE_TARGET.bak" || {
			echo -e "\033[31m✗\033[0m Failed to backup existing neo-tree.lua"
			exit 1
		}
		echo -e "\033[33m⚠\033[0m Backed up existing neo-tree.lua to neo-tree.lua.bak"
	fi

	# Copy custom configuration files
	cp "$ASTROCORE_SOURCE" "$ASTROCORE_TARGET" || {
		echo -e "\033[31m✗\033[0m Failed to copy custom astrocore.lua"
		exit 1
	}

	cp "$NEOTREE_SOURCE" "$NEOTREE_TARGET" || {
		echo -e "\033[31m✗\033[0m Failed to copy custom neo-tree.lua"
		exit 1
	}

	echo -e "\033[32m✓\033[0m Custom nvim configuration files installed successfully"

	# Run headless install
	nvim --headless +q

else
	echo -e "\033[33m⚠\033[0m trash command not found. Skipping stow operations"
fi

# Activate
source "$HOME/dotfiles/bashrc/.bashrc"

echo ""
echo -e "\033[32m✓\033[0m Setup complete! :)"
