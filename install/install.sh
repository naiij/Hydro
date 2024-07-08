#!/bin/bash
if [ $EUID != 0 ]; then
    echo "This script requires root however you are currently running under another user."
    echo "We will call sudo directly for you."
    echo "Please input your account password below:"
    echo "安装脚本需要使用 root 权限，请在下方输入此账号的密码确认授权："
    sudo "$0" "$@"
    exit $?
fi
set -e
echo "Executing Hydro install script v3.0.0"
echo "Hydro includes system telemetry,
which helps developers figure out the most commonly used operating system and platform.
To disable this feature, checkout our sourcecode."
mkdir -p /data/db /data/file ~/.hydro
bash <(curl https://hydro.ac/nix.sh)
export PATH=$HOME/.nix-profile/bin:$PATH
nix-env -iA nixpkgs.nodejs nixpkgs.yarn nixpkgs.coreutils nixpkgs.jq
# # First check if folder exist, delete it if it does
# if [ -d "$HOME/Hydro" ]; then
#     rm -rf $HOME/Hydro
# fi
# # Install Hydro with source code rather than npm
# git clone https://github.com/naiij/Hydro.git $HOME/Hydro
# cd $HOME/Hydro
# git checkout wj-dev
# # Backup the original package.json
# cp package.json package.json.bak

# # Modify the "workspaces" field in package.json
# jq '.workspaces = ["packages/*"]' package.json > package.json.temp && mv package.json.temp package.json
# yarn install
cat ./web_install.b64 | base64 -d >>/tmp/install.js 
node /tmp/install.js "$@"
set +e
