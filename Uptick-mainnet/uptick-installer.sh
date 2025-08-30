#!/bin/bash

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Functions ---
function printSection() {
    echo -e "${YELLOW}"
    echo "================================================================"
    echo "$1"
    echo "================================================================"
    echo -e "${NC}"
}

function printStatus() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓]${NC} $1"
    else
        echo -e "${RED}[✗]${NC} $1"
        exit 1
    fi
}

# --- Banner ---
clear
echo -e "${BLUE}"
cat << "EOF"
 ██████╗ ███╗   ██╗███████╗███╗   ██╗ ██████╗ ██╗   ██╗
██╔═══██╗████╗  ██║██╔════╝████╗  ██║██╔═══██╗██║   ██║
██║   ██║██╔██╗ ██║█████╗  ██╔██╗ ██║██║   ██║██║   ██║
██║   ██║██║╚██╗██║██╔══╝  ██║╚██╗██║██║   ██║╚██╗ ██╔╝
╚██████╔╝██║ ╚████║███████╗██║ ╚████║╚██████╔╝ ╚████╔╝
 ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝ 
EOF
echo -e "${NC}"
echo -e "${GREEN}Uptick Node Auto-Installer${NC}"
echo -e "${GREEN}Chain ID: uptick_117-1${NC}"
echo ""

# --- User Input ---
printSection "Configuration Setup"
read -p "Enter your validator moniker name: " MONIKER
read -p "Enter your wallet name: " WALLET
read -p "Enter custom RPC port (default: 26657): " RPC_PORT
RPC_PORT=${RPC_PORT:-26657}
read -p "Enter custom P2P port (default: 26656): " P2P_PORT
P2P_PORT=${P2P_PORT:-26656}
read -p "Enter pruning setting (default/custom/nothing): " PRUNING_MODE

# --- Configuration Variables ---
CHAIN_ID="uptick_117-1"
SNAP_URL="https://server-1.itrocket.net/mainnet/uptick/uptick_2025-08-25_13283544_snap.tar.lz4"
GENESIS_URL="https://raw.githubusercontent.com/UptickNetwork/uptick-mainnet/main/uptick_117-1/genesis.json"
ADDRBOOK_URL="https://server-1.itrocket.net/mainnet/uptick/addrbook.json"
GO_VERSION="1.21.1"
REPO_URL="https://github.com/UptickNetwork/uptick.git"
VERSION="v0.3.0"

# --- Installation Process ---
printSection "Step 1: System Update & Package Installation"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget jq lz4 build-essential git ca-certificates gnupg lsb-release
printStatus "System updated and packages installed"

printSection "Step 2: Install Go $GO_VERSION"
wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz -O go$GO_VERSION.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
go version
printStatus "Go $GO_VERSION installed"

printSection "Step 3: Clone and Build Uptick Network"
cd $HOME
git clone $REPO_URL
cd uptick
git checkout $VERSION
make install
printStatus "Uptick Network built and installed"

printSection "Step 4: Initialize Node"
$HOME/go/bin/uptickd init "$MONIKER" --chain-id $CHAIN_ID
$HOME/go/bin/uptickd config chain-id $CHAIN_ID
$HOME/go/bin/uptickd config keyring-backend file
$HOME/go/bin/uptickd config node tcp://localhost:$RPC_PORT
printStatus "Node initialized with moniker: $MONIKER"

printSection "Step 5: Configure Pruning"
if [ "$PRUNING_MODE" == "custom" ]; then
    sed -i 's/pruning = "default"/pruning = "custom"/' ~/.uptickd/config/app.toml
    sed -i 's/pruning-keep-recent = "0"/pruning-keep-recent = "100000"/' ~/.uptickd/config/app.toml
    sed -i 's/pruning-interval = "0"/pruning-interval = "100"/' ~/.uptickd/config/app.toml
    echo -e "${GREEN}Custom pruning configured${NC}"
elif [ "$PRUNING_MODE" == "nothing" ]; then
    sed -i 's/pruning = "default"/pruning = "nothing"/' ~/.uptickd/config/app.toml
    echo -e "${GREEN}Pruning set to nothing${NC}"
else
    echo -e "${GREEN}Using default pruning settings${NC}"
fi

printSection "Step 6: Download Snapshot"
sudo systemctl stop uptickd 2>/dev/null
cp $HOME/.uptickd/data/priv_validator_state.json $HOME/.uptickd/priv_validator_state.json.backup 2>/dev/null || true
rm -rf $HOME/.uptickd/data
curl -L $SNAP_URL | tar -Ilz4 -xf - -C $HOME/.uptickd
mv $HOME/.uptickd/priv_validator_state.json.backup $HOME/.uptickd/data/priv_validator_state.json 2>/dev/null || true
printStatus "Snapshot downloaded and extracted"

printSection "Step 7: Download Genesis & Addrbook"
wget $GENESIS_URL -O ~/.uptickd/config/genesis.json
wget -O $HOME/.uptickd/config/addrbook.json $ADDRBOOK_URL
printStatus "Genesis and address book downloaded"

printSection "Step 8: Configure Node"
sed -i 's/seeds = ""/seeds = "61f9e5839cd2c56610af3edd8c3e769502a3a439@seed0.uptick.co:26656,8542cd7e6bf9d260fef543bc49e59be5a3fa9074@seed.uptick.co:26656"/' ~/.uptickd/config/config.toml
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.0001auptick"/' ~/.uptickd/config/app.toml
sed -i 's/prometheus = false/prometheus = true/' ~/.uptickd/config/config.toml
printStatus "Node configured"

printSection "Step 9: Custom Port Configuration"
sed -i "s#laddr = \"tcp://127.0.0.1:26657\"#laddr = \"tcp://0.0.0.0:$RPC_PORT\"#" ~/.uptickd/config/config.toml
sed -i "s#proxy_app = \"tcp://127.0.0.1:26658\"#proxy_app = \"tcp://0.0.0.0:26658\"#" ~/.uptickd/config/config.toml
sed -i "s#laddr = \"tcp://0.0.0.0:26656\"#laddr = \"tcp://0.0.0.0:$P2P_PORT\"#" ~/.uptickd/config/config.toml
sed -i 's#pprof_laddr = "localhost:6060"#pprof_laddr = "0.0.0.0:6060"#' ~/.uptickd/config/config.toml
printStatus "Ports configured: RPC=$RPC_PORT, P2P=$P2P_PORT"

printSection "Step 10: Create Systemd Service"
sudo tee /etc/systemd/system/uptickd.service > /dev/null <<EOF
[Unit]
Description=Uptick Node
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/uptickd start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable uptickd
printStatus "Systemd service created and enabled"

printSection "Step 11: Start Node"
sudo systemctl start uptickd
sleep 5
sudo systemctl status uptickd --no-pager
printStatus "Uptick node started successfully"

printSection "Installation Complete!"
echo -e "${GREEN}Uptick node has been successfully installed and configured${NC}"
echo -e "${YELLOW}Moniker:${NC} $MONIKER"
echo -e "${YELLOW}Wallet:${NC} $WALLET"
echo -e "${YELLOW}Chain ID:${NC} $CHAIN_ID"
echo -e "${YELLOW}RPC Port:${NC} $RPC_PORT"
echo -e "${YELLOW}P2P Port:${NC} $P2P_PORT"
echo -e "${YELLOW}Pruning:${NC} $PRUNING_MODE"
echo ""
echo -e "${GREEN}Check node status:${NC} sudo systemctl status uptickd"
echo -e "${GREEN}Check node logs:${NC} sudo journalctl -u uptickd -f -o cat"
echo -e "${GREEN}Check sync status:${NC} curl -s http://localhost:$RPC_PORT/status | jq .result.sync_info"
echo ""
echo -e "${YELLOW}Don't forget to create validator after synchronization is complete!${NC}"
