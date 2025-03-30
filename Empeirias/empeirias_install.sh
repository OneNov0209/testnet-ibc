#!/bin/bash

# Exit immediately if any command fails
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or using sudo"
  exit 1
fi

# Replace the original logo with ONENOV logo
function printLogo() {
  echo -e "\033[0;36m"
  echo ' ██████╗ ███╗   ██╗███████╗███╗   ██╗ ██████╗ ██╗   ██╗'
  echo '██╔═══██╗████╗  ██║██╔════╝████╗  ██║██╔═══██╗██║   ██║'
  echo '██║   ██║██╔██╗ ██║█████╗  ██╔██╗ ██║██║   ██║██║   ██║'
  echo '██║   ██║██║╚██╗██║██╔══╝  ██║╚██╗██║██║   ██║╚██╗ ██╔╝'
  echo '╚██████╔╝██║ ╚████║███████╗██║ ╚████║╚██████╔╝ ╚████╔╝'
  echo ' ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝'
  echo -e "\033[0m"
}

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    case $color in
        "green") echo -e "\033[0;32m$message\033[0m" ;;
        "red") echo -e "\033[0;31m$message\033[0m" ;;
        "blue") echo -e "\033[0;34m$message\033[0m" ;;
        *) echo -e "$message" ;;
    esac
}

# Display logo
printLogo

# Update and install dependencies
print_message "blue" "Updating system and installing dependencies..."
apt update && apt upgrade -y
apt install -y curl tar wget clang pkg-config libssl-dev jq build-essential \
              bsdmainutils git make ncdu gcc git jq chrony liblz4-tool

# Install Go 1.21.6
print_message "blue" "Installing Go 1.21.6..."
ver="1.21.6"
wget -q "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Verify Go installation
if ! command -v go &> /dev/null; then
    print_message "red" "Go installation failed!"
    exit 1
fi
print_message "green" "Go installed successfully: $(go version)"

# Build Empeiria node
print_message "blue" "Building Empeiria node..."
mkdir -p $HOME/go/bin/
wget -q https://github.com/empe-io/empe-chain-releases/raw/master/v0.3.0/emped_v0.3.0_linux_amd64.tar.gz
tar -xvf emped_v0.3.0_linux_amd64.tar.gz
rm -f emped_v0.3.0_linux_amd64.tar.gz
chmod +x emped
mv emped $HOME/go/bin/

# Verify emped installation
if ! command -v emped &> /dev/null; then
    print_message "red" "Emped installation failed!"
    exit 1
fi
print_message "green" "Emped installed successfully: $(emped version --long | grep -e version -e commit)"

# Initialize node
print_message "blue" "Initializing node..."
emped init replace your name Validator --chain-id empe-testnet-2

# Download Genesis
print_message "blue" "Downloading genesis file..."
wget -q -O $HOME/.empe-chain/config/genesis.json "https://raw.githubusercontent.com/111STAVR111/props/main/Empeiria/genesis.json"
print_message "green" "Genesis file SHA256: $(sha256sum $HOME/.empe-chain/config/genesis.json)"

# Configuration
print_message "blue" "Configuring node..."
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uempe\"/;" $HOME/.empe-chain/config/app.toml

external_address=$(wget -qO- eth0.me || echo "127.0.0.1")
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.empe-chain/config/config.toml

peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.empe-chain/config/config.toml

seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.empe-chain/config/config.toml

sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.empe-chain/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.empe-chain/config/config.toml

# Pruning settings
print_message "blue" "Setting up pruning..."
pruning="custom"
pruning_keep_recent="1000"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.empe-chain/config/app.toml

# Indexer settings
print_message "blue" "Setting up indexer..."
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.empe-chain/config/config.toml

# Download addrbook
print_message "blue" "Downloading address book..."
wget -q -O $HOME/.empe-chain/config/addrbook.json "https://raw.githubusercontent.com/111STAVR111/props/main/Empeiria/addrbook.json"

# Create service file
print_message "blue" "Creating service file..."
cat > /etc/systemd/system/emped.service <<EOF
[Unit]
Description=emped
After=network-online.target

[Service]
User=$USER
ExecStart=$(which emped) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Install snapshot
print_message "blue" "Installing snapshot..."
snap install lz4
systemctl stop emped || true
cp $HOME/.empe-chain/data/priv_validator_state.json $HOME/.empe-chain/priv_validator_state.json.backup || true
rm -rf $HOME/.empe-chain/data
curl -s -L https://empe.snapshot-t.stavr.tech/emper-snap.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.empe-chain --strip-components 2
mv $HOME/.empe-chain/priv_validator_state.json.backup $HOME/.empe-chain/data/priv_validator_state.json || true
wget -q -O $HOME/.empe-chain/config/addrbook.json "https://raw.githubusercontent.com/111STAVR111/props/main/Empeiria/addrbook.json"

# Start service
print_message "blue" "Starting service..."
systemctl daemon-reload
systemctl enable emped
systemctl restart emped

print_message "green" "Installation completed successfully!"
print_message "blue" "To check logs: journalctl -fu emped -o cat"
