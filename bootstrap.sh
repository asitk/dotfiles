#!/bin/bash

# Function to detect the current Linux distro and macOS version
detect_os() {
	os=$(uname -s)
	if [ "$os" = "Darwin" ]; then
		version=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
		echo "macOS $version"
	elif [ "$os" = "Linux" ]; then
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			echo "$ID_LIKE"
		else
			echo "Unknown Linux distro"
		fi
	else
		echo "Unsupported OS: $os"
	fi
}

# Function to install Homebrew
install_brew() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null
	eval "$(brew shellenv)" # Add to bashrc
}

# Message function
status() {
	local tool=$1
	if [ "$?" -eq 0 ]; then
		echo -e "\033[32m✓\033[0m $tool installed successfully"
	else
		echo -e "\033[31m✗\033[0m Failed to install $tool"
	fi
}

# Function to install dependencies
install_dependencies() {
	distro=$(detect_os)
	case $distro in
	macOS*)
		# macOS: just install git, assuming brew is pre-installed
		if ! command -v git &>/dev/null; then
			echo "Installing Git on $distro..."
			brew install git 2>/dev/null
			status git
		else
			echo -e "\033[32m✓\033[0m Git is already installed"
		fi
		;;
	debian)
		if ! command -v git &>/dev/null; then
			echo "Installing Git on $distro..."
			sudo apt update 2>/dev/null && sudo apt install -y git 2>/dev/null
			status git
		else
			echo -e "\033[32m✓\033[0m Git is already installed"
		fi
		if ! command -v brew &>/dev/null; then
			echo "Installing Homebrew on $distro..."
			install_brew
			status brew
		else
			echo -e "\033[32m✓\033[0m Homebrew is already installed"
		fi
		;;
	fedora)
		if ! command -v git &>/dev/null; then
			echo "Installing Git on $distro..."
			sudo dnf install -y git 2>/dev/null
			status git
		else
			echo -e "\033[32m✓\033[0m Git is already installed"
		fi
		if ! command -v brew &>/dev/null; then
			echo "Installing Homebrew on $distro..."
			install_brew
			status brew
		else
			echo -e "\033[32m✓\033[0m Homebrew is already installed"
		fi
		;;
	rhel)
		if ! command -v git &>/dev/null; then
			echo "Installing Git on $distro..."
			sudo dnf install -y git 2>/dev/null
			status git
		else
			echo -e "\033[32m✓\033[0m Git is already installed"
		fi
		if ! command -v brew &>/dev/null; then
			echo "Installing Homebrew on $distro..."
			install_brew
			status brew
		else
			echo -e "\033[32m✓\033[0m Homebrew is already installed"
		fi
		;;
	"")
		# Check ID for distros with empty ID_LIKE
		. /etc/os-release
		case $ID in
		arch)
			if ! command -v git &>/dev/null; then
				echo "Installing Git on $distro..."
				sudo pacman -S --noconfirm git 2>/dev/null
				status git
			else
				echo -e "\033[32m✓\033[0m Git is already installed"
			fi
			if ! command -v brew &>/dev/null; then
				echo "Installing Homebrew on $distro..."
				install_brew
				status brew
			else
				echo -e "\033[32m✓\033[0m Homebrew is already installed"
			fi
			;;
		opensuse*)
			if ! command -v git &>/dev/null; then
				echo "Installing Git on $distro..."
				sudo zypper install -y git 2>/dev/null
				status git
			else
				echo -e "\033[32m✓\033[0m Git is already installed"
			fi
			if ! command -v brew &>/dev/null; then
				echo "Installing Homebrew on $distro..."
				install_brew
				status brew
			else
				echo -e "\033[32m✓\033[0m Homebrew is already installed"
			fi
			;;
		*)
			echo -e "\033[31m✗\033[0m Unsupported distro"
			;;
		esac
		;;
	*)
		echo -e "\033[31m✗\033[0m Unsupported distro"
		;;
	esac
}

# Main execution
echo "Detected OS: $(detect_os)"
install_dependencies
