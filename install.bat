@echo off
REM Install static analysis tools for Windows

REM Update package lists and install packages using MSYS2
REM Assuming MSYS2 is installed in C:\msys64

C:\msys64\usr\bin\pacman -Syu
C:\msys64\usr\bin\pacman -S --noconfirm make gcc cppcheck

echo Static analysis tools installed successfully.
pause