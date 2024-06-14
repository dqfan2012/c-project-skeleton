#!/bin/bash

brew update
brew install cppcheck valgrind clang llvm flawfinder
brew install openjdk@17 postgresql@16
brew install sonarqube
brew install --cask sonar-scanner
brew install infer
