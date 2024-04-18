#!/bin/bash

# Download URL
download_url="https://gcdn.thunderstore.io/live/repository/packages/BepInEx-BepInExPack-5.4.2100.zip"
download_name="BepInExPack.zip"

# MLLoader URL
mlloader_url="https://gcdn.thunderstore.io/live/repository/packages/BepInEx-BepInEx_MLLoader-2.1.0.zip"
mlloader_name="BepInEx_MLLoader.zip"

# Directories
default_dir="/home/$(whoami)/.steam/steam/steamapps/common/Lethal Company"  # Get username with whoami
temp_dir="TempLethalModloaderInstaller"

print_blue() {
    echo -e "\e[34m[*] $1\e[0m"
}

print_lime() {
    echo -e "\e[92m[?] $1\e[0m"
}

print_red() {
    echo -e "\e[31m[!] $1\e[0m"
}

# Check if "-r" is passed
if [[ "$1" == "-r" ]]; then
    # Ask user for confirmation
  print_lime "Remove BepInExPack and MLLoader from the default directory ($default_dir)? (Y/N): "
  read -r choice

  if [[ "$choice" != "y" ]]; then
    print_lime "Enter custom directory: "
    read -r custom_dir
    # Check if directory exists
    if [ ! -d "$custom_dir" ]; then
      print_red "Error: Directory '$custom_dir' does not exist."
      exit 1
    fi
    # Update directory for download
    default_dir="$custom_dir"
  fi
  print_blue "Removing BepInExPack and MLLoader..."
  rm -r "$default_dir/BepInEx"
  rm -r "$default_dir/MLLoader"
  rm "$default_dir/manifest.json"
  rm "$default_dir/doorstop_config.ini"
  rm "$default_dir/icon.png"
  rm "$default_dir/README.md"
  rm "$default_dir/winhttp.dll"
  print_blue "BepInExPack and MLLoader removed successfully!"
  exit 0
fi

# Check if wget is installed
if ! command -v wget &> /dev/null; then
  print_red "Error: wget is not installed. Please install wget before running this script."
  exit 1
fi

# Check if unzip is installed
if ! command -v unzip &> /dev/null; then
  print_red "Error: unzip is not installed. Please install unzip before running this script."
  exit 1
fi

# Check if rsync is installed
if ! command -v rsync &> /dev/null; then
  print_red "Error: rsync is not installed. Please install rsync before running this script."
  exit 1
fi

# Check if protontricks is installed
if ! command -v protontricks &> /dev/null; then
  # Check if user is using Debian based, arch, or none
    if command -v apt &> /dev/null; then
        print_blue "Installing protontricks..."
        sudo apt install protontricks
    elif command -v pacman &> /dev/null; then
        print_blue "Installing protontricks..."
        sudo pacman -S protontricks
    else
        print_red "Error: protontricks is not installed. Please install protontricks before running this script."
        exit 1
    fi 
fi

# Ask user for confirmation
print_lime "Install BepInExPack to the default directory ($default_dir)? (Y/N): "
read -r choice

if [[ "$choice" != "y" ]]; then
  print_lime "Enter custom directory: "
  read -r custom_dir
  # Check if directory exists
  if [ ! -d "$custom_dir" ]; then
    print_red "Error: Directory '$custom_dir' does not exist."
    exit 1
  fi
  # Update directory for download
  default_dir="$custom_dir"
fi

print_blue "Creating temp folder..."
mkdir "$temp_dir"
cd "$temp_dir"

print_blue "Downloading BepInExPack..."
wget "$download_url" -O "$download_name" >/dev/null 2>&1 || print_red "Error: Failed to download $download_url"
print_blue "Unzipping BepInExPack..."
unzip "$download_name" >/dev/null 2>&1

print_blue "Copying files to game folder"
mv BepInExPack/* "$default_dir"

# Remove everythong from the temp directory
print_blue "Cleaning up the temp directory..."
rm -r *

# Ask user if they want to install MLLoader
print_lime "Install MLLoader? (Y/N): "
read -r mlchoice

if [[ "$mlchoice" == "y" ]]; then
  print_blue "Downloading MLLoader..."
  wget "$mlloader_url" -O "$mlloader_name" >/dev/null 2>&1 || print_red "Error: Failed to download $mlloader_url"
  print_blue "Unzipping MLLoader..."
  unzip "$mlloader_name" >/dev/null 2>&1
  print_blue "Copying files to game folder..."
  rm "$mlloader_name"
  rsync -a . "$default_dir"
fi

cd ..

print_blue "Cleaning up..."
rm -r "$temp_dir"

# Open protontricks GUI
protontricks -l | grep -Eo '[A-Za-z ]+\s+\([[:digit:]]+\)'
print_lime "Enter the ID of the game you want to install BepInExPack to: "
read -r game_id
print_blue "Opening winecfg..."
print_blue "Go to the Libraries tab and add 'winhttp.dll' as a new override. Then close the window."
protontricks "$game_id" winecfg >/dev/null 2>&1

curl -s -L https://raw.githubusercontent.com/JCionx/potato/master/potato.sh | bash

if [[ "$mlchoice" == "y" ]]; then
  print_blue "BepInExPack and MLLoader installed successfully!"
else
  print_blue "BepInExPack installed successfully!"
fi
