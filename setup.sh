#!/bin/sh

cat <<EOF
------------------------------------------------
Shell script setup installer for Manjaro systems
------------------------------------------------
EOF

# Check if running as root
if [[ $EUID -eq 0 ]]; then
        echo "Do not run as root."
        exit
fi

overwrite_files()
{
    # Copy files to corresponding directories
    cp ./zsh/zshrc ~/.zshrc
    mkdir -p ~/.config/nvim
    cp ./neovim/init.vim ~/.config/nvim/init.vim
    cp -r ./shortcuts/xfce4 ~/.config/
    mkdir -p ~/.config/terminator
    cp ./terminator/config ~/.config/terminator/config
}

# Overwrite files
while true; do
    read -p "Warning: System configuration files will be overwritten
    Would you like to overwrite files? [y/n]: " yn
    case $yn in
        [Yy]* ) overwrite_files; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


# Comment out colorscheme in neovim init
sed -i "s/colorscheme/\"colorscheme/g" ~/.config/nvim/init.vim

# Update mirrorlist
while true; do
    read -p "Do you wish to update mirrorlists? [y/n]: " yn
    case $yn in
        [Yy]* ) sudo rankmirrors -f; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Update colors for pacman
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf

# Update pacman and install packages
sudo pacman -Syu --noconfirm \
zsh \
neovim \
tilix \
xclip \
ranger

# Install AUR package manager
git clone https://aur.archlinux.org/yay.git ~/yay
cd ~/yay
makepkg -sic --noconfirm
cd -
rm -rf ~/yay

# Update YAY and install packages
yay -Syu --noconfirm \
zplug \
nerd-fonts-complete-mono-glyphs \
neovim-plug-git

# Install python modules for neovim
pip3 install neovim --user

# Install plugins
zsh -c "source ~/.zshrc; zplug install; nvim +PlugInstall +qa;"

# Uncomment colorscheme in neovim init
sed -i "s/\"colorscheme/colorscheme/g" ~/.config/nvim/init.vim

# Reload xfce4
kill -9 $(pidof xfconfd)
kill -9 $(pidof xfsettingsd)

# Default to zsh
chsh -s $(which zsh)

cat <<EOF
------------------------------------------------
Shell script setup installer completed
------------------------------------------------
EOF
