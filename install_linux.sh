#!/bin/bash

# Function to install packages for Red Hat and Fedora-based distributions
install_redhat_fedora() {
    local distro="$1"

    sudo dnf group install -y "Development Tools" "Development Libraries"
    sudo dnf install -y clang clang-tools-extra llvm lldb lldb-devel cmake rust rust-gdb rust-lldb golang
    sudo dnf install -y cppcheck valgrind flawfinder java-17-openjdk

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
            sudo dnf install -y postgresql16-server
            sudo /usr/pgsql-16/bin/postgresql-16-setup initdb
            sudo systemctl enable postgresql-16
            sudo systemctl start postgresql-16
            ;;
        *)
            echo "Unsupported distribution: $distro"
            exit 1
            ;;
    esac

    # Installing sonar-scanner for Fedora has to be done manually.
    # Install sonar-scanner for Red Hat-based distributions (excluding Fedora)
    if [[ "$distro" != "fedora" ]]; then
        sudo dnf install -y sonar-scanner
    fi
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
            install_redhat_fedora "$ID"
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
