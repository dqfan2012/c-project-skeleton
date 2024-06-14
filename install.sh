#!/bin/bash
# Install static analysis tools for Mac/Linux
# Update package lists and install basic packages
#
# You'll need to install OpenJDK 17 and PostgreSQL if you want to
# install sonarqube.
#
# Coverity requires you to sign up for an account and to follow instructions to
# setup and configure.
#
# PVS-Studio has a free trial. Purchasing a license is necessary and could be costly.
#
# cppcheck has a premium paid-for edition that's also kind of costly. The open source,
# free verison is included here.
if [ "$(uname)" == "Darwin" ]; then
    # Be sure to install XCode from the App Store
    # Install the xcode cli tools
    xcode-select --install
    brew update
    brew install cppcheck valgrind clang llvm flawfinder
    brew install --cask sonar-scanner
    brew install infer
else
    # Assuming debian-based Linux
    sudo apt update
    sudo apt install -y build-essential clang llvm lldb cppcheck valgrind clang-tidy flawfinder sonar-scanner
    sudo apt install -y infer
fi

echo "Static analysis tools installed successfully."