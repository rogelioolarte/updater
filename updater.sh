#!/bin/bash

user=$(whoami)
version=$(uname -r)
linux_version="linux-image-$version"
curkernel=$(uname -r | sed 's/-*[a-z]//g' | sed 's/-386//g')
linuxpkg="linux-(image|headers|ubuntu-modules|restricted-modules)"
metalinuxpkg="linux-(image|headers|restricted-modules)-(generic|i386|server|common|rt|xen)"
oldconf=$(dpkg -l| grep "^rc" | awk '{print $2}')
oldkernels=$(dpkg -l | awk '{print $2}'| grep -E $linuxpkg | grep -vE $metalinuxpkg | grep -v $curkernel)

echo "Welcome $user"
echo "Checking ..."
sudo apt-get check
echo "Updating the system ..."
sudo apt update $2
sudo apt upgrade $2
sudo apt-get dist-upgrade $2
sudo apt full-upgrade $2
echo "Updating the kernel ..."
sudo apt-get install $linux_version
echo "Cleaning ..."
sudo apt clean $2
sudo apt autoclean $2
sudo apt autoremove $2
echo "Deleting older files of configuration ..."
sudo apt purge $oldconf $2
echo "Deleting older kernels ..."
sudo apt purge $oldkernels $2
echo "Script completed."
echo "Goodbye."
