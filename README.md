# C Project Skeleton

This is a basic C project skeleton. This project provides sane and strict CFLAGS for compiling C programs. This project also includes several make targets to run static analysis tools to help with code saftey and code smell.

## Static Analysis Tools

- cppcheck - The free open source version.
- valgrind
- leaks - MacOS only
- clang-analyze
- clang-tidy
- flawfinder
- sonarqube-scanner
- infer
- ASAN

### Optional Static Analysis tools

#### Free Options

- sonarqube - requires OpenJDK 17, PostgreSQL, and proper setup. (Free Community Edition. Option to purchase a more premium version.)
- coverity - requires registering a free account and following instructions to set it up.

#### Premium, Paid Options

- cppcheck premium - free trial, requires a purchase
- pvs-studio - free trial, requires a purchase

## Linux Installation

Here's a list of supported Linux distros. They all haven't been tested yet. The distros with a check beside them have been tested. As these distros are tested, I will specify which versions were tested.

Red Hat-based:

- [ ] RHEL
- [ ] CentOS
- [ ] Fedora
- [ ] Rocky Linux
- [ ] AlmaLinux

Debian-based:

- [ ] Debian
- [ ] Ubuntu
- [ ] Linux Mint
- [ ] Pop!_OS
- [ ] Kali Linux
- [ ] MX Linux
- [ ] Zorin OS

Alpine-based:

- [ ] Alpine Linux

Arch-based:

- [ ] Arch Linux
- [ ] Manjaro
- [ ] Garuda Linux
- [ ] ArcoLinux
- [ ] EndeavourOS

NixOS-based:

- [ ] NixOS

OpenSUSE-based:

- [ ] openSUSE
- [ ] SUSE
- [ ] SLES
- [ ] GeckoLinux

Gentoo-based:

- [ ] Gentoo

### Running the Linux script

Make the installation script executable:

## MacOS Installation

Install Xcode and the Xcode commandline tools. Install Xcode through the App Store. You can install the commandline tools with the following cli command:

```bash
xcode-select --install
```

Install Homebrew before running the script. Here's how you can install homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Running the MacOS install script

```bash
chmod +x ./install_macos.sh
```

Then run the script:

```bash
./install_linux.sh
```

### After running the MacOS install script

Be sure to follow these instructions to setup postgresql properly:

[PostgreSQL 16 Setup Instructions](https://medium.com/@abhinavsinha_/download-and-configure-postgresql16-on-macos-d41dc49217b6)

Be sure to follow these instructions to setup the free version of sonarqube locally:

[Setup Sonarqube](https://techblost.com/how-to-setup-sonarqube-locally-on-mac/)
