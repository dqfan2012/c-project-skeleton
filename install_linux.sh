#!/bin/bash

# Function to install packages for Red Hat and Fedora-based distributions
install_redhat_fedora() {
    sudo dnf group install -y "Development Tools" "Development Libraries"
    sudo dnf install -y llvm-toolset
    sudo dnf install -y cmake gdb cppcheck valgrind clang clang-tidy flawfinder lldb make
    sudo dnf install -y epel-release
    sudo dnf install -y sonar-scanner
}

# Function to install packages for Debian-based distributions
install_debian() {
    sudo apt-get update -y
    # Install build tools
    sudo apt-get install -y build-essential make cmake clang clang-tidy clang-tools llvm lldb gdb binutils libboost-dev wget curl vim neovim zed
    # Install static analysis tools
    sudo apt-gget install -y cppcheck valgrind flawfinder
    wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip
    unzip sonar-scanner-cli.zip -d /opt/sonar-scanner
    sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
}

# Function to install packages for Alpine-based distributions
install_alpine() {
    sudo apk update
    sudo apk add cppcheck valgrind clang clang-tidy flawfinder lldb make
    sudo apk add sonar-scanner
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

# Function to install packages for Gentoo-based distributions
install_gentoo() {
    sudo emerge --ask dev-util/cppcheck dev-util/valgrind sys-devel/clang dev-util/clang-tidy app-vim/flawfinder dev-util/lldb sys-devel/make
    sudo emerge --ask dev-util/cmake sys-devel/gdb
    sudo emerge --ask dev-java/sonar-scanner-bin
}

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        # This will not work with Red Hat/CentOS earlier than version 8 or earlier than Fedora 22
        rhel|centos|redhat|fedora|rocky|almalinux)
            install_redhat_fedora
            ;;
        debian|ubuntu|linuxmint|pop|kali|mx|zorin)
            install_debian
            ;;
        alpine)
            install_alpine
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
        gentoo)
            install_gentoo
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

echo "All tools installed successfully."
