#!/bin/bash

# ==============================================
# AUTO INSTALLER EMPEIRIA NODE
# ==============================================

# --- Configuration ---
CHAIN_ID="empe-testnet-2"
REPO_URL="https://github.com/empe-io/empe-chain-releases"
BINARY_URL="${REPO_URL}/raw/master/v0.3.0/emped_v0.3.0_linux_amd64.tar.gz"
GENESIS_URL="https://raw.githubusercontent.com/111STAVR111/props/main/Empeiria/genesis.json"
ADDRBOOK_URL="https://raw.githubusercontent.com/111STAVR111/props/main/Empeiria/addrbook.json"
SNAPSHOT_URL="https://empe.snapshot-t.stavr.tech/emper-snap.tar.lz4"
GO_VERSION="1.21.6"
MIN_GAS_PRICE="0.0025uempe"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Functions ---
function printSection() {
    echo -e "${YELLOW}"
    echo "======================================================================"
    echo "$1"
    echo "======================================================================"
    echo -e "${NC}"
}

function printStatus() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} $1"
    else
        echo -e "${RED}[ERROR]${NC} $1"
        exit 1
    fi
}

function printError() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

function printWarning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

function printInfo() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

function isRoot() {
    if [ "$(id -u)" -ne 0 ]; then
        printError "This script must be run as root or with sudo"
    fi
}

function checkInput() {
    if [ -z "$1" ]; then
        printError "$2 cannot be empty!"
    fi
}

# --- Initial Checks ---
isRoot

# --- Banner ---
clear
echo -e "${BLUE}"
cat << "EOF"
  ______ __  __ _____ _____ _____   _____ _____ ____  _   _ 
 |  ____|  \/  |_   _|_   _|  __ \ / ____|_   _/ __ \| \ | |
 | |__  | \  / | | |   | | | |__) | |  __  | || |  | |  \| |
 |  __| | |\/| | | |   | | |  _  /| | |_ | | || |  | | . ` |
 | |____| |  | |_| |_ _| |_| | \ \| |__| |_| || |__| | |\  |
 |______|_|  |_|_____|_____|_|  \_\\_____|_____\____/|_| \_|
EOF
echo -e "${NC}"
echo -e "${GREEN}Empeiria Node Auto-Installer${NC}"
echo -e "${GREEN}Chain ID: ${CHAIN_ID}${NC}"
echo ""

# --- User Input ---
printSection "Node Configuration"
read -p "Enter your wallet name: " WALLET_NAME
checkInput "$WALLET_NAME" "Wallet name"

read -p "Enter your moniker: " MONIKER
checkInput "$MONIKER" "Moniker"

echo ""
printInfo "Wallet Name: ${WALLET_NAME}"
printInfo "Moniker: ${MONIKER}"
echo ""

# --- System Update ---
printSection "System Preparation"
printInfo "Updating system packages..."
apt update &>/dev/null
apt upgrade -y &>/dev/null
printStatus "System updated"

printInfo "Installing dependencies..."
apt install -y curl tar wget clang pkg-config libssl-dev jq build-essential \
              bsdmainutils git make ncdu gcc chrony liblz4-tool &>/dev/null
printStatus "Dependencies installed"

# --- Go Installation ---
printSection "Go Installation"
if ! command -v go &>/dev/null; then
    printInfo "Installing Go ${GO_VERSION}..."
    wget -q "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go${GO_VERSION}.linux-amd64.tar.gz
    rm -rf /usr/local/go
    tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz
    rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz
    
    echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $HOME/.bash_profile
    source $HOME/.bash_profile
    printStatus "Go ${GO_VERSION} installed"
else
    printWarning "Go is already installed: $(go version)"
fi

# --- Node Installation ---
printSection "Node Installation"
printInfo "Downloading and installing emped binary..."
mkdir -p $HOME/go/bin/
wget -q $BINARY_URL -O /tmp/emped.tar.gz
tar -xvf /tmp/emped.tar.gz -C /tmp/ &>/dev/null
rm /tmp/emped.tar.gz
chmod +x /tmp/emped
mv /tmp/emped $HOME/go/bin/
printStatus "Emped binary installed: $(emped version --long | grep -e version -e commit)"

# --- Node Initialization ---
printSection "Node Initialization"
printInfo "Initializing node..."
emped init "$MONIKER" --chain-id $CHAIN_ID &>/dev/null
printStatus "Node initialized"

# --- Configuration ---
printInfo "Downloading genesis file..."
wget -q $GENESIS_URL -O $HOME/.empe-chain/config/genesis.json
printStatus "Genesis file downloaded: $(sha256sum $HOME/.empe-chain/config/genesis.json)"

printInfo "Configuring node..."
# Set minimum gas price
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"${MIN_GAS_PRICE}\"/" $HOME/.empe-chain/config/app.toml

# Set external address
external_address=$(wget -qO- eth0.me || echo "127.0.0.1")
sed -i.bak -e "s/^external_address *=.*/external_address = \"${external_address}:26656\"/" $HOME/.empe-chain/config/config.toml

# Set peers and seeds (empty in this case)
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"\"/" $HOME/.empe-chain/config/config.toml
sed -i.bak -e "s/^seeds =.*/seeds = \"\"/" $HOME/.empe-chain/config/config.toml

# Set connection limits
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.empe-chain/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.empe-chain/config/config.toml

# Pruning settings
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"1000\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"0\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.empe-chain/config/app.toml

# Disable indexer
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.empe-chain/config/config.toml

printStatus "Node configured"

# --- Download Addrbook ---
printInfo "Downloading address book..."
wget -q $ADDRBOOK_URL -O $HOME/.empe-chain/config/addrbook.json
printStatus "Address book downloaded"

# --- Service Setup ---
printSection "Service Setup"
printInfo "Creating emped service..."

sudo tee /etc/systemd/system/emped.service > /dev/null <<EOF
[Unit]
Description=emped
After=network-online.target

[Service]
User=$USER
ExecStart=$(which emped) start --home $HOME/.empe-chain
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

printStatus "Service file created"

# --- Snapshot Installation ---
printSection "Snapshot Installation"
printInfo "Installing snapshot (this may take a while)..."
snap install lz4 &>/dev/null
systemctl stop emped &>/dev/null || true

# Backup validator state if exists
if [ -f $HOME/.empe-chain/data/priv_validator_state.json ]; then
    cp $HOME/.empe-chain/data/priv_validator_state.json $HOME/.empe-chain/priv_validator_state.json.backup
fi

# Clean and install snapshot
rm -rf $HOME/.empe-chain/data
curl -s -L $SNAPSHOT_URL | lz4 -c -d - | tar -x -C $HOME/.empe-chain --strip-components 2

# Restore validator state if backup exists
if [ -f $HOME/.empe-chain/priv_validator_state.json.backup ]; then
    mv $HOME/.empe-chain/priv_validator_state.json.backup $HOME/.empe-chain/data/priv_validator_state.json
fi

printStatus "Snapshot installed"

# --- Start Service ---
printSection "Starting Node"
printInfo "Starting emped service..."
systemctl daemon-reload
systemctl enable emped &>/dev/null
systemctl restart emped

printStatus "Service started"
printInfo "To check logs: journalctl -fu emped -o cat"

# --- Final Instructions ---
printSection "Installation Complete"
echo -e "${GREEN}Empeiria node has been successfully installed!${NC}"
echo ""
echo -e "${BLUE}Node Information:${NC}"
echo -e "Moniker: ${MONIKER}"
echo -e "Chain ID: ${CHAIN_ID}"
echo -e "Wallet Name: ${WALLET_NAME}"
echo ""
echo -e "${BLUE}Important Commands:${NC}"
echo -e "Check node status: ${GREEN}systemctl status emped${NC}"
echo -e "Check node logs: ${GREEN}journalctl -fu emped -o cat${NC}"
echo -e "Stop node: ${GREEN}systemctl stop emped${NC}"
echo -e "Start node: ${GREEN}systemctl start emped${NC}"
echo -e "Restart node: ${GREEN}systemctl restart emped${NC}"
echo ""
echo -e "${BLUE}To create validator:${NC}"
echo -e "${GREEN}emped tx staking create-validator \\"
echo -e "  --amount 1000000uempe \\"
echo -e "  --from ${WALLET_NAME} \\"
echo -e "  --commission-max-change-rate 0.01 \\"
echo -e "  --commission-max-rate 0.2 \\"
echo -e "  --commission-rate 0.1 \\"
echo -e "  --min-self-delegation 1 \\"
echo -e "  --pubkey \$(emped tendermint show-validator) \\"
echo -e "  --moniker ${MONIKER} \\"
echo -e "  --chain-id ${CHAIN_ID} \\"
echo -e "  --gas auto \\"
echo -e "  --gas-adjustment 1.5 \\"
echo -e "  --gas-prices ${MIN_GAS_PRICE}${NC}"
echo ""
echo -e "${GREEN}Setup complete! Happy validating!${NC}"
