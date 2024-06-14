# Table of Contents

- [Table of Contents](#table-of-contents)
  - [C Project Skeleton](#c-project-skeleton)
    - [Static Analysis Tools](#static-analysis-tools)
      - [Optional Static Analysis tools](#optional-static-analysis-tools)
        - [Free Options](#free-options)
        - [Premium, Paid Options](#premium-paid-options)
    - [Windows Installation](#windows-installation)
    - [Linux Installation](#linux-installation)
      - [Red Hat-based](#red-hat-based)
      - [Debian-based](#debian-based)
      - [Alpine-based](#alpine-based)
      - [Arch-based](#arch-based)
      - [NixOS-based](#nixos-based)
      - [OpenSUSE-based](#opensuse-based)
      - [Gentoo-based](#gentoo-based)
      - [Running the Linux script](#running-the-linux-script)
    - [MacOS Installation](#macos-installation)
      - [Running the MacOS install script](#running-the-macos-install-script)
      - [After running the MacOS install script](#after-running-the-macos-install-script)

## C Project Skeleton

This is a basic C project skeleton. This project provides sane and strict CFLAGS for compiling C programs. This project also includes several make targets to run static analysis tools to help with code saftey and code smell.

### Static Analysis Tools

- cppcheck - The free open source version.
- valgrind
- leaks - MacOS only
- clang-analyze
- clang-tidy
- flawfinder
- sonarqube-scanner
- infer
- ASAN

#### Optional Static Analysis tools

##### Free Options

- sonarqube - requires OpenJDK 17, PostgreSQL, and proper setup. (Free Community Edition. Option to purchase a more premium version.)
- coverity - requires registering a free account and following instructions to set it up.

##### Premium, Paid Options

- cppcheck premium - free trial, requires a purchase
- pvs-studio - free trial, requires a purchase

### Windows Installation

For Windows users, it is recommended to use WSL 2 with Ubuntu and run the `install_linux.sh` script. This will provide a consistent development environment and simplify the setup process.

You can install WSL by following these steps. Open Command Prompt or Powershell in **administrator** mode and run the following command:

```powershell
wsl --install
```

The default distro installed with WSL is Ubuntu. If you don't like Ubuntu, you can see a list of available distros by running the following command:

`wsl --list --online` or `wsl -l -o`

You can change the default Linux distro by running the following command:

```powershell
wsl --install -d <Distribution Name>
```

Replace `<Distribution Name>` with the name of a distribution you found when you ran the command to list distributions.

### Linux Installation

Here's a list of supported Linux distros. They all haven't been tested yet. The distros with a check beside them have been tested. As these distros are tested, I will specify which versions were tested.

**Disclaimer**: The only distro I'm testing with WSL in Windows is Ubuntu. If you choose a different distribution, you'll have to modify the script that matches the distro should there be any errors or failures.

#### Red Hat-based

- [ ] RHEL
- [ ] CentOS
- [ ] Fedora
- [ ] Rocky Linux
- [ ] AlmaLinux

#### Debian-based

- [ ] Debian
- [ ] Ubuntu
- [ ] Ubuntu in WSL
- [ ] Linux Mint
- [ ] Pop!_OS
- [ ] Kali Linux
- [ ] MX Linux
- [ ] Zorin OS

#### Alpine-based

- [ ] Alpine Linux

#### Arch-based

- [ ] Arch Linux
- [ ] Manjaro
- [ ] Garuda Linux
- [ ] ArcoLinux
- [ ] EndeavourOS

#### NixOS-based

- [ ] NixOS

#### OpenSUSE-based

- [ ] openSUSE
- [ ] SUSE
- [ ] SLES
- [ ] GeckoLinux

#### Gentoo-based

- [ ] Gentoo

#### Running the Linux script

Make the installation script executable:

```bash
chmod +x ./install_linux.sh
```

Then run the installation script.

```bash
./install_linux.sh
```

### MacOS Installation

Install Xcode and the Xcode commandline tools. Install Xcode through the App Store. You can install the commandline tools with the following cli command:

```bash
xcode-select --install
```

Install Homebrew before running the script. Here's how you can install homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Running the MacOS install script

```bash
chmod +x ./install_macos.sh
```

Then run the script:

```bash
./install_linux.sh
```

#### After running the MacOS install script

Be sure to follow these instructions to setup postgresql properly:

[PostgreSQL 16 Setup Instructions](https://medium.com/@abhinavsinha_/download-and-configure-postgresql16-on-macos-d41dc49217b6)

Be sure to follow these instructions to setup the free version of sonarqube locally:

[Setup Sonarqube](https://techblost.com/how-to-setup-sonarqube-locally-on-mac/)
