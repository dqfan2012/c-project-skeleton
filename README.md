# Table of Contents

- [Table of Contents](#table-of-contents)
  - [C Project Skeleton](#c-project-skeleton)
    - [Static Analysis Tools](#static-analysis-tools)
      - [Optional Static Analysis tools](#optional-static-analysis-tools)
        - [Free Options](#free-options)
        - [Premium, Paid Options](#premium-paid-options)
    - [Windows Installation](#windows-installation)
    - [Linux Installation](#linux-installation)
      - [Linux Testing Information](#linux-testing-information)
      - [Red Hat-based](#red-hat-based)
      - [Debian-based](#debian-based)
      - [Arch-based](#arch-based)
      - [NixOS-based](#nixos-based)
      - [OpenSUSE-based](#opensuse-based)
      - [Running the Linux script](#running-the-linux-script)
    - [MacOS Installation](#macos-installation)
      - [Running the MacOS install script](#running-the-macos-install-script)
    - [If you want to use Sonarqube with Sonar Scanner](#if-you-want-to-use-sonarqube-with-sonar-scanner)
      - [Linux Setup Instructions](#linux-setup-instructions)
      - [MacOS Setup Instructions](#macos-setup-instructions)

## C Project Skeleton

This is a basic C project skeleton. This project provides sane and strict CFLAGS for compiling C programs. This project also includes several make targets to run static analysis tools to help with code saftey and code smell.

### Static Analysis Tools

- cppcheck - The free open source version.
- valgrind
- leaks - MacOS only
- clang-analyze
- clang-tidy
- flawfinder
- sonarqube-scanner - Note: This is not the same thing as `sonarqube`. It works with `sonarqube` when you have `sonarqube` installed.
- infer
- ASAN

#### Optional Static Analysis tools

##### Free Options

- sonarqube - requires OpenJDK 17, PostgreSQL, and proper setup. (Free Community Edition. Option to purchase a more premium version.)
  - This is not the same as `sonarqube-scanner`. This works with `sonarqube-scanner` when it's installed along side the `sonarqube-scanner`.
  - This has to be downloaded manually for Fedora.
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

If you choose to change the distro away from Ubuntu in WSL, please read the disclaimer I've added to the [Linux Installation](#linux-installation) section.

### Linux Installation

**Disclaimer**: The only distro I'm testing with WSL in Windows is Ubuntu. If you choose a different distribution in WSL, you'll have to modify the `install_linux.sh` script should there be any errors or failures during installation. Find the section that matches your chosen distro. Modify the script so that it works with your distribution.

Here's a list of supported Linux distros. They all haven't been tested yet. The distros with a check beside them have been tested. As these distros are tested, I will specify which versions were tested.

#### Linux Testing Information

I created virtual machines for all the distros below on two machines: one running Pop!_OS 22.04 LTS and on a MacBook Pro M3 with the Apple Silicon chip. I used VirtualBox on Pop!_OS and VMWare Fusion on the MacBook Pro. I installed 64-bit versions of the operating systems. Specifically, `x86_64`/`amd64` on Pop!_OS and `aarch64`/`arm64` on Mac if available. If no `aarch64`/`arm64` versions were available for a specific version of Linux, then that version was not tested on the Mac. I will explicitly list versions tested for each distro. If I didn't list something, then it wasn't tested.

The Ubuntu running in WSL 2 on Windows is the latest `x86_64`/`amd64` architecture version.

I used the following specifications for **all** VMs:

- 40 GB disk
- 4 GB RAM
- 2 vCPUs
- 128MB Video Memory with 3D Acceleration enabled

#### Red Hat-based

- [ ] RHEL
  - RHEL 9.4 64-bit amd64
  - RHEL 9.4 64-bit aarch64
- [ ] CentOS
  - CentOS 9 64-bit amd64
  - CentOS 9 64-bit aarch64
- [ ] Fedora
  - Fedora Workstation 40 64-bit amd64 :white_check_mark: - SonarQube Scanner will have to be downloaded and installed manually.
  - Fedora Workstation 40 64-bit aarch64
- [ ] Rocky Linux
  - Rocky Linux v9.4 64-bit amd64
  - Rocky Linux v9.4 64-bit aarch64
- [ ] AlmaLinux
  - AlmaLinux 9 64-bit amd64
  - AlmaLinux 9 64-bit aarch64

#### Debian-based

- [ ] Debian
  - Debian 12.5 amd64 :white_check_mark:
  - Debian 12.5 arm64
- [ ] Ubuntu
  - Ubuntu 22.04.4 LTS amd64 :white_check_mark:
  - Ubuntu 22.04 LTS arm64
  - Ubuntu 24.04 LTS amd64 :white_check_mark:
  - Ubuntu 24.04 LTS arm64
- [ ] Ubuntu in WSL
  - Ubuntu 24.04 LTS amd64
- [x] Linux Mint
  - Linux Mint 20.3 Cinnamon amd64 :x: - the latest PostgreSQL available here is 12. The installer failed when trying to install PostgreSQL 16. You may be able to find a guide online to install PostgreSQL 16 on this version of Linux Mint. Highly advise going with the latest version instead of this version.
  - Linux Mint 21.3 Cinnamon amd64 :white_check_mark: - You'll have to follow [this guide](https://medium.com/@mglaving/how-to-install-postgresql-16-on-linux-mint-21-d58e875fe7c6) to install PostgreSQL 16 on this version of Linux Mint.
- [x] Pop!_OS
  - Pop!_OS 22.04 LTS amd64 :white_check_mark:
- [ ] Kali Linux
- [ ] MX Linux
- [ ] Zorin OS

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

### If you want to use Sonarqube locally with Sonar Scanner

Be sure to follow these instructions to setup PostgreSQL and SonarQube properly.

#### Linux Setup Instructions

I'm including instructions for installing PostgreSQL on Ubuntu 24.04 LTS and how to install SonarQube on Ubuntu 22.04 LTS. I couldn't find a document outlining the installation process for SonarQube on Ubuntu 24.04 LTS. However, the process for both should be identical. I used articles from Vultr. You don't have to setup a Vultr server. The instructions can be applied to a local installation of Ubuntu.

Note: A simple Google search will show you how to setup and configure these tools on your distro of choice.

[How to install PostgreSQL on Ubuntu 24.04](https://docs.vultr.com/how-to-install-postgresql-on-ubuntu-24-04)

[How to use SonarQube on Ubuntu 22.04 LTS](https://docs.vultr.com/how-to-use-sonarqube-on-ubuntu-22-04-lts)

#### MacOS Setup Instructions

[PostgreSQL 16 Setup Instructions](https://medium.com/@abhinavsinha_/download-and-configure-postgresql16-on-macos-d41dc49217b6)

[Setup Sonarqube](https://techblost.com/how-to-setup-sonarqube-locally-on-mac/)
