#!/bin/bash

# Function to install packages for Red Hat and Fedora-based distributions
install_redhat_fedora() {
    sudo dnf group install -y "Development Tools" "Development Libraries"
    sudo dnf install -y clang clang-tools-extra llvm lldb lldb-devel cmake rust rust-gdb rust-lldb golang
    sudo dnf install -y cppcheck valgrind flawfinder
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
    wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip
    unzip sonar-scanner-cli.zip -d /opt/sonar-scanner
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

echo "All tools installed successfully."
