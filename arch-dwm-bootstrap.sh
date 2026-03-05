#!/usr/bin/env bash

set -e

echo "====================================="
echo " Arch Linux DWM Desktop Bootstrap"
echo "====================================="

SRC_DIR="$HOME/.local/src"
CONFIG_DIR="$HOME/.config"
FONT_DIR="$HOME/.local/share/fonts"

mkdir -p $SRC_DIR
mkdir -p $CONFIG_DIR
mkdir -p $FONT_DIR

########################################
echo "[1/8] Installing base dependencies"
########################################

sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    curl \
    unzip \
    xorg \
    xorg-xinit \
    libx11 \
    libxft \
    libxinerama \
    freetype2 \
    fontconfig \
    rofi \
    picom \
    feh \
    neovim \
    alacritty \
    network-manager-applet \
    ttf-dejavu \
    noto-fonts \
    noto-fonts-emoji

########################################
echo "[2/8] Installing Nerd Fonts"
########################################

cd /tmp

curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

unzip JetBrainsMono.zip -d JetBrainsMono

cp JetBrainsMono/*.ttf $FONT_DIR

fc-cache -fv

########################################
echo "[3/8] Clone suckless software"
########################################

cd $SRC_DIR

clone_or_pull () {
    if [ -d "$1" ]; then
        cd "$1"
        git pull
        cd ..
    else
        git clone "$2"
    fi
}

clone_or_pull dwm https://git.suckless.org/dwm
clone_or_pull st https://git.suckless.org/st
clone_or_pull dmenu https://git.suckless.org/dmenu

########################################
echo "[4/8] Build and install suckless"
########################################

cd $SRC_DIR/dwm
sudo make clean install

cd $SRC_DIR/st
sudo make clean install

cd $SRC_DIR/dmenu
sudo make clean install

########################################
echo "[5/8] Install dwmblocks"
########################################

cd $SRC_DIR

if [ ! -d dwmblocks ]; then
    git clone https://github.com/torrinfail/dwmblocks
fi

cd dwmblocks
sudo make clean install

########################################
echo "[6/8] Configure X init"
########################################

cat > $HOME/.xinitrc <<EOF
#!/bin/sh

picom &
nm-applet &
feh --bg-scale ~/wallpaper.jpg &

dwmblocks &

exec dwm
EOF

chmod +x $HOME/.xinitrc

########################################
echo "[7/8] Create config folders"
########################################

mkdir -p $CONFIG_DIR/picom
mkdir -p $CONFIG_DIR/rofi

########################################
echo "[8/8] Example picom config"
########################################

cat > $CONFIG_DIR/picom/picom.conf <<EOF
backend = "glx";
vsync = true;
shadow = true;
corner-radius = 8;
EOF

echo "====================================="
echo " DWM environment installed!"
echo "====================================="

echo ""
echo "Start with:"
echo ""
echo "startx"
echo ""

echo "Recommended next steps:"
echo "• Add wallpapers"
echo "• Patch DWM"
echo "• Customize config.h"