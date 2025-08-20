#!/bin/bash

set -e
set -o pipefail

TMP_DIR="/tmp"
INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
SYMLINK_DIR="$HOME/.local/bin"

echo "### INSTALL JETBRAINS TOOLBOX ###"

echo -e "\e[94mFetching the URL of the latest version...\e[39m"
ARCHIVE_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
ARCHIVE_FILENAME=$(basename "$ARCHIVE_URL")

echo -e "\e[94mDownloading $ARCHIVE_FILENAME...\e[39m"
rm "$TMP_DIR/$ARCHIVE_FILENAME" 2>/dev/null || true
wget -q --show-progress -cO "$TMP_DIR/$ARCHIVE_FILENAME" "$ARCHIVE_URL"

echo -e "\e[94mExtracting to $INSTALL_DIR...\e[39m"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_DIR/$ARCHIVE_FILENAME" -C "$INSTALL_DIR" --strip-components=1
rm "$TMP_DIR/$ARCHIVE_FILENAME"

echo -e "\e[94mSymlinking to $SYMLINK_DIR/jetbrains-toolbox...\e[39m"
mkdir -p $SYMLINK_DIR
rm "$SYMLINK_DIR/jetbrains-toolbox" 2>/dev/null || true
ln -s "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

# Ensure $HOME/.local/bin is in PATH permanently
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
    echo -e "\e[94mAdding $HOME/.local/bin to PATH in ~/.bashrc...\e[39m"
    {
        echo ""   # blank line
        echo 'export PATH="$HOME/.local/bin:$PATH"'
    } >> "$HOME/.bashrc"
 	source ~/.bashrc
fi

if [ -z "$CI" ]; then
	echo -e "\e[94mRunning for the first time to set-up...\e[39m"
	( "$INSTALL_DIR/bin/jetbrains-toolbox" & )
	echo -e "\n\e[32mDone! JetBrains Toolbox should now be running, in your application list, and you can run it in terminal as jetbrains-toolbox\e[39m\n"
else
	echo -e "\n\e[32mDone! Running in a CI -- skipped launching the AppImage.\e[39m\n"
fi
