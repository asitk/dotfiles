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
brew install --quiet \
  stow \
  fastfetch \
  shellcheck \
  git \
  lazygit \
  tree-sitter-cli \
  lua \
  luarocks \
  git-delta \
  eza \
  ripgrep \
  shfmt \
  tealdeer \
  multitail \
  tree \
  bottom \
  zoxide \
  trash-cli \
  fzf \
  fd \
  curl \
  bat \
  nvim \
  tmux \
  tpm \
  xclip \
  gcc \
  make \
  cmake \
  devtools \
  gh \
  openjdk \
  go \
  php \
  ruby \
  composer \
  perl \
  julia \
  imagemagick \
  tectonic \
  node \
  starship || {
  echo "❌ Failed to install prerequisites"
  exit 1
}

# Install fonts
echo "✅ Installing fonts ..."
brew install --quiet \
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
  brew install --quiet bash-completion@2 || {
    echo "❌ Failed to install bash-completion@2"
    exit 1
  }
else
  brew install --quiet bash-completion || {
    echo "❌ Failed to install bash-completion"
    exit 1
  }
fi

# Install LazyVim
echo "✅ Installing AstroVim Template ..."
# Backup existing nvim config if it exists
if [ -d ~/.config/nvim ]; then
  backup_dir=~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
  echo "Backing up existing nvim config to $backup_dir"
  mv ~/.config/nvim "$backup_dir" || {
    echo "❌ Failed to backup existing nvim config"
    exit 1
  }
fi

# Backup additional nvim directories (optional but recommended)
if [ -d ~/.local/share/nvim ]; then
  backup_dir=~/.local/share/nvim.backup.$(date +%Y%m%d_%H%M%S)
  mv ~/.local/share/nvim "$backup_dir"
fi
if [ -d ~/.local/state/nvim ]; then
  backup_dir=~/.local/state/nvim.backup.$(date +%Y%m%d_%H%M%S)
  mv ~/.local/state/nvim "$backup_dir"
fi
if [ -d ~/.cache/nvim ]; then
  backup_dir=~/.cache/nvim.backup.$(date +%Y%m%d_%H%M%S)
  mv ~/.cache/nvim "$backup_dir"
fi

# Clone LazyVim starter
git clone --depth 1 https://github.com/AstroNvim/template "$HOME/dotfiles/nvim/.config/nvim" || {
  echo "❌ Failed to clone AstroVim starter"
  exit 1
}

# Remove .git directory
rm -rf ~/.config/nvim/.git || {
  echo "❌ Failed to remove .git from nvim config"
  exit 1
}

# Run headless install
nvim --headless +q

# Restore dotfiles
DOTFILES_DIR="$HOME/dotfiles"

# Navigate to the dotfiles directory
cd "$DOTFILES_DIR" || {
  echo "❌ $HOME/dotfiles not found"
  exit 1
}

# Loop through all directories and stow them
for dir in */; do
  # Remove trailing slash for the package name
  package=$(basename "$dir")

  echo "Restoring $package..."
  # -R (restow) is useful if you are updating existing links
  stow -R "$package"
done

echo "All dotfiles have been restored!"

# Activate
source "$HOME/dotfiles/bashrc/.bashrc"

echo "✅ Setup complete!"
