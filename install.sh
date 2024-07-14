#!/bin/bash

set -exo pipefail

# The $OS environment variable is set in Windows by default.
if [ -z ${OS} ]; then
  export OS=$(uname)
fi

# Function to install packages for Red Hat and Fedora-based distributions
install_redhat_fedora() {
    local distro="$1"

    sudo dnf group install -y "Development Tools" "Development Libraries"
    sudo dnf install -y clang clang-tools-extra llvm lldb lldb-devel cmake rust rust-gdb rust-lldb golang valgrind

    # Distribution-specific installations
    case "$distro" in
        rhel|centos|redhat|rocky|almalinux)
            # PostgreSQL installation
            sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
            sudo dnf -qy module disable postgresql
            sudo dnf install -y postgresql16-server
            sudo /usr/pgsql-16/bin/postgresql-16-setup initdb
            sudo systemctl enable postgresql-16
            sudo systemctl start postgresql-16

            # CodeReady Builder and EPEL repositories
            case "$distro" in
                rhel|redhat)
                    sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
                    sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
                    ;;
                centos)
                    sudo dnf config-manager --set-enabled crb
                    sudo dnf install -y epel-release epel-next-release
                    ;;
                rocky|almalinux)
                    sudo dnf config-manager --set-enabled crb
                    sudo dnf install -y epel-release
                    ;;
            esac
            ;;
        fedora)
            # PostgreSQL installation for Fedora
            sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-40-x86_64/pgdg-fedora-repo-latest.noarch.rpm
            sudo dnf upgrade
            sudo dnf install -y wget java-17-openjdk postgresql16-server cppcheck flawfinder
            sudo /usr/pgsql-16/bin/postgresql-16-setup initdb
            sudo systemctl enable postgresql-16
            sudo systemctl start postgresql-16
            ;;
        *)
            echo "Unsupported distribution: $distro"
            exit 1
            ;;
    esac

    if [[ "$distro" != "fedora" ]]; then
        sudo dnf install -y wget cppcheck snapd java-17-openjdk
        sudo systemctl enable --now snapd.socket
        sudo ln -s /var/lib/snapd/snap /snap
        echo 'export PATH=$PATH:/var/lib/snapd/snap/bin' >> $HOME/.bashrc
        source $HOME/.bashrc
        sudo snap install flawfinder
    fi

    # Sonar Scanner
    wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.0.0.4432-linux.zip
    sudo unzip sonar-scanner-cli.zip -d /opt/sonar-scanner
    sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
}

# Function to install packages for Debian-based distributions
install_debian() {
    sudo apt-get update -y
    # For adding apt repositories
    sudo apt install -y curl ca-certificates
    # Install build tools
    sudo apt-get install -y build-essential make cmake clang clang-tidy clang-tools llvm lldb gdb binutils libglib2.0-dev libboost-dev wget vim neovim
    # Install static analysis tools
    sudo apt-get install -y cppcheck valgrind flawfinder
    # Sonar Scanner
    wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.0.0.4432-linux.zip
    sudo unzip sonar-scanner-cli.zip -d /opt/sonar-scanner
    sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
    # If you want to install sonarqube, install sonarqube prereqs first. Sonarqube relies on OpenJDK 17 and PostgreSQL
    sudo apt install -y openjdk-17-jdk postgresql-common
    sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
    sudo apt install postgresql-16
    # Manually download the sonarqube files. Follow a tutorial for configuring both postgresql 16 and sonarqube properly.
}

# Function to install packages for Arch-based distributions
install_arch() {
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm cppcheck valgrind clang clang-tidy flawfinder lldb make
    sudo pacman -S --noconfirm sonar-scanner
}

# Function to install packages for NixOS-based distributions
install_nixos() {
    nix-env -iA nixpkgs.cppcheck nixpkgs.valgrind nixpkgs.clang nixpkgs.clang-tools-extra nixpkgs.flawfinder nixpkgs.lldb nixpkgs.make
    nix-env -iA nixpkgs.sonarqube
}

# Function to install packages for OpenSUSE-based distributions
install_opensuse() {
    sudo zypper refresh
    sudo zypper install -y cppcheck valgrind clang clang-tools-extra flawfinder lldb make
    sudo zypper install -y sonar-scanner
}

# Before running this install script, be sure to install Xcode through the
# App store.
install_macos() {
  # Install Xcode commandline tools
  xcode-select --install

  if [[ $(command -v brew) == "" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    brew update
  fi

  # Install code editors
  brew install vim neovim kakoune helix
  brew install --cask vscodium

  # Good starting point for vim/neovim
  curl -sLf https://spacevim.org/install.sh | bash

  # Install shells
  brew install zsh fish ksh93 tcsh starship
  brew install thefuck fzf

  # Install SDKMAN
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"

  # Install Java
  sdk install java 17.0.11-tem # sonarqube
  sdk install java 21.0.3-tem # latest LTS

  # Install OCaml and opam
  # Some static analysis tools use ocaml/opam
  bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"
  # Initialize opam
  opam init
  # Setup an OCaml dev environment
  opam install ocaml-lsp-server odoc ocamlformat utop

  # clang, clang-format, and clang-tidy are available through Xcode
  # gcc is available on Apple Silicon, but gdb is not.
  brew install llvm gcc cppcheck flawfinder make cmake
  brew install postgresql@16 sonarqube
  brew install --cask sonar-scanner

  # Install Facebook Infer
  VERSION=1.2.0; \
  curl -sSL "https://github.com/facebook/infer/releases/download/v$VERSION/infer-osx-arm64-v$VERSION.tar.xz" \
    | sudo tar -C /opt -xJ && \
    sudo ln -s "/opt/infer-osx-arm64-v$VERSION/bin/infer" /usr/local/bin/infer

  # If you're not running Apple silicon
  case $(uname -m) in
    x86_64)
      # Install tools available only on amd64 versions of MacOS
      brew install valgrind gdb
      ;;
  esac

  # Install bun
  curl -fsSL https://bun.sh/install | bash

  # Install Crystal lang
  brew install crystal

  # Install Deno
  curl -fsSL https://deno.land/install.sh | sh

  # Install Guile (scheme dialect)
  brew install guile

  # Install golang
  brew install go

  # Install Lua
  brew install lua

  # Install nvm and node
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  nvm install 20 # latest LTS

  # Install Python
  brew install pyenv
  pyenv install 3.12.4

  # Install PHP
  brew install php

  # Install Ruby
  brew install ruby-build rbenv
  rbenv init
  rbenv install 3.3.4
  rbenv global 3.3.4

  # Install Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  # Install alternate cli commands
  cargo install bat broot delta eza fd-find just lfs dysk pipr rargs ripgrep tealdeer zoxide
  brew install tree htop
}

# Install the devtools on Linux based on distro.
if [ "${OS}" = "Linux" ]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        # This will not work with Red Hat/CentOS earlier than version 8 or earlier than Fedora 22
        rhel|centos|redhat|fedora|rocky|almalinux)
            install_redhat_fedora "$ID"
            ;;
        debian|ubuntu|linuxmint|pop|kali|zorin)
            install_debian
            ;;
        arch|manjaro|garuda|arcolinux|endeavouros)
            install_arch
            ;;
        nixos)
            install_nixos
            ;;
        opensuse|suse|sles|geckolinux)
            install_opensuse
            ;;
        *)
            echo "Unsupported distribution: $ID"
            exit 1
            ;;
    esac
  else
    echo "Cannot determine the Linux distribution."
    exit 1
  fi
fi

# Install dev tools on MacOS
if [ "${OS}" = "Darwin" ]; then
  install_macos
fi
