#!/bin/bash

# Define variables
THEME_NAME="cyber"
SOURCE_DIR="./cyber"
INSTALL_DIR="/boot/grub/themes/$THEME_NAME"
GRUB_CONFIG="/etc/default/grub"


if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi


if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Directory '$SOURCE_DIR' not found."
  echo "Please make sure you are running this script from the directory containing '$SOURCE_DIR'."
  exit 1
fi

echo "Installing $THEME_NAME theme..."

if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR already exists. Overwriting..."
    rm -rf "$INSTALL_DIR"
fi
mkdir -p "$INSTALL_DIR"

echo "Copying files to $INSTALL_DIR..."
cp -r "$SOURCE_DIR"/* "$INSTALL_DIR/"

if [ ! -f "$GRUB_CONFIG.bak" ]; then
    cp "$GRUB_CONFIG" "$GRUB_CONFIG.bak"
    echo "Backup of $GRUB_CONFIG created."
fi

if grep -q "^GRUB_THEME=" "$GRUB_CONFIG"; then
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$INSTALL_DIR/theme.txt\"|" "$GRUB_CONFIG"
else
    echo "GRUB_THEME=\"$INSTALL_DIR/theme.txt\"" >> "$GRUB_CONFIG"
fi

echo "Updating GRUB..."
if command -v update-grub >/dev/null 2>&1; then
    update-grub
elif command -v grub-mkconfig >/dev/null 2>&1; then
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "Error: Neither 'update-grub' nor 'grub-mkconfig' found. Please update GRUB manually."
    exit 1
fi
echo "Installation complete!"
