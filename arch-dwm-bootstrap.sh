#!/usr/bin/env bash

set -e

echo "==============================="
echo "Arch DWM Bootstrap"
echo "==============================="

SRC_DIR="$HOME/.local/src"
CONFIG_DIR="$HOME/.config"

mkdir -p "$SRC_DIR"
mkdir -p "$CONFIG_DIR"

#################################
echo "[1/7] Installing packages"
#################################

sudo pacman -S --needed --noconfirm \
base-devel \
git \
xorg \
xorg-xinit \
xorg-xauth \
libx11 \
libxft \
libxinerama \
freetype2 \
fontconfig \
picom \
feh \
rofi \
neovim \
ttf-dejavu \
noto-fonts \
noto-fonts-emoji

#################################
echo "[2/7] Clone source repos"
#################################

cd "$SRC_DIR"

clone_or_update () {
    if [ -d "$1" ]; then
        cd "$1"
        git pull
        cd ..
    else
        git clone "$2"
    fi
}

clone_or_update dwm https://git.suckless.org/dwm
clone_or_update st https://git.suckless.org/st
clone_or_update dmenu https://git.suckless.org/dmenu
clone_or_update dwmblocks-async https://github.com/UtkarshVerma/dwmblocks-async

#################################
echo "[3/7] Build suckless tools"
#################################

cd "$SRC_DIR/dwm"
sudo make clean install

cd "$SRC_DIR/st"
sudo make clean install

cd "$SRC_DIR/dmenu"
sudo make clean install

#################################
echo "[4/7] Build dwmblocks-async"
#################################

cd "$SRC_DIR/dwmblocks-async"

sudo make clean install

#################################
echo "[5/7] Configure dwmblocks"
#################################

mkdir -p "$CONFIG_DIR/dwmblocks"

cat > "$CONFIG_DIR/dwmblocks/blocks.h" <<EOF
static const Block blocks[] = {

    {"date '+%Y-%m-%d %H:%M'", 5, 0},

};

static char delim[] = " | ";
static unsigned int delimLen = 3;
EOF

#################################
echo "[6/7] Configure .xinitrc"
#################################

cat > "$HOME/.xinitrc" <<'EOF'

picom &
feh --bg-scale ~/wallpaper.jpg 2>/dev/null &

dwmblocks &

exec dwm

EOF

chmod +x "$HOME/.xinitrc"

#################################
echo "[7/7] Setup wallpaper placeholder"
#################################

if [ ! -f "$HOME/wallpaper.jpg" ]; then
    convert -size 1920x1080 xc:black "$HOME/wallpaper.jpg" 2>/dev/null || touch "$HOME/wallpaper.jpg"
fi

echo "==============================="
echo "Bootstrap Complete"
echo "==============================="

echo ""
echo "Run:"
echo ""
echo "startx"
echo ""