#!/usr/bin/env bash

set -e

FAIL="\e[31m"
SUCCESS="\e[32m"
WARN="\e[33m"
RESETCOLOR="\e[0m"
INFO="\e[37m"
EMAIL=david.cheal@gmail.com
NAME="David Cheal"

printer () {
 level=$1
 printf "${!level}$2${RESETCOLOR}\n"
}

printer INFO "Starting build"
if [ ! -f  phase1 ]; then
    printer INFO "Running Ubuntu upgrade"
    sudo apt-get update
    sudo apt-get dist-upgrade -y
    touch phase1
    sudo shutdown -r +1
else
    printer INFO "Skipping Ubuntu upgrade"
fi
if [ ! -f  phase2 ]; then
    printer INFO "Doing release upgrade"
    sudo do-release-upgrade
    # -f DistUpgradeViewNonInteractive
    touch phase2
else
    printer INFO "Skipping release upgrade"
fi
if [ ! -f  phase3 ]; then
    mkdir ~/apps
    printer INFO "Installing apt applications"
    APPS=~/apps
    # Packages
    ## APT
    sudo apt-get install net-tools php-fpm git nmap curl rar \
        p7zip-full p7zip-rar vlc terminator libfuse2 \
        open-vm-tools-desktop open-vm-tools openvpn \
        kompare krusader trash-cli krename qbittorent \
        filezilla libreoffice-calc postman qBittorent \
        krename kompare ruby-full python3-pip
        -y
    sudo apt remove unattended-upgrades -y
    sudo apt-get autoremove -y
    ## Config Git
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    ## naconda 
    ## PIP
    curl https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh -o /tmp/anaconda.sh
    bash /tmp/anaconda.sh -p
    ## SNAP
    sudo snap install ffmpeg   
    # Install apps
    ## KDENlive video editor
    printer INFO "Installing KDENlive"
    wget -O $APPS/kdenlive https://download.kde.org/stable/kdenlive/22.12/linux/kdenlive-22.12.3-x86_64.AppImage
    chmod +x $APPS/kdenlive
    ## AWS CLI
    printer INFO "Installing AWS CLI"
    wget -O temp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    unzip awscliv2.zip temp/
    sudo ./temp/aws/install
    ## VSCode
    printer INFO "Installing VSCode"
    sudo snap install --classic code
    ## Node Version Manager, npm and Node
    printer INFO "Install Node Version Manager and NPM LTS"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  
    nvm install --lts
    ## Global NPM Packages
    npm install -g npm-check-updates create-react-app express-generator
    ## Docker
    printer INFO "Installing Docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
    sudo apt-cache policy docker-ce
    sudo apt install docker-ce -y
    ## Chrome
    wget -O temp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg --install temp/google-chrome-stable_current_amd64.deb
    ## Postman
    
    ## Tor
    wget -O temp/tor-browser-linux64-12.0.5_ALL.tar.xz https://www.torproject.org/dist/torbrowser/12.0.5/tor-browser-linux64-12.0.5_ALL.tar.xz
    tar -xf temp/tor-browser-linux64-12.0.5_ALL.tar.xz -C ~/apps/
    # Copy Configs
    ## Terminator
    mkdir ~/.config/terminator
    cp assets/terminator-config ~/.config/terminator/config
    ## Profile
    cp assets/profile ~/.profile
    cp assets/bashrc ~/.bashrc
    ## Set shell prompt
    echo "export PS1='\[\033[1;32m\]$(whoami)@\[\033[1;34m\]$(hostname):\[\033[33m\]$(pwd)\[\033[0;37m\]\[\e[91m\]$(parse_git_branch)\[\e[00m\]\n'" >> ~/.bashrc
    # Clean up
    rm temp/* -r
    touch phase3
else
    printer INFO "Skipping apt applications"
fi
