#!/bin/bash

# ==============================================
# ONENOV NODE AUTO-INSTALLER
# ==============================================

# --- Configuration ---
CHAIN_ID="empe-testnet-2"
BINARY_URL="https://github.com/empe-io/empe-chain-releases/raw/master/v0.4.0/emped_v0.4.0_linux_amd64.tar.gz"
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
echo -e "${GREEN}ONENOV Node Auto-Installer${NC}"
echo -e "${GREEN}Chain ID: ${CHAIN_ID}${NC}"
echo ""

# --- User Input ---
printSection "NODE CONFIGURATION"

# Get wallet name
while true; do
    read -p "Enter your wallet name: " WALLET_NAME
    if [ -n "$WALLET_NAME" ]; then
        break
    else
        echo -e "${RED}Wallet name cannot be empty!${NC}"
    fi
done

# Get moniker
while true; do
    read -p "Enter your moniker: " MONIKER
    if [ -n "$MONIKER" ]; then
        break
    else
        echo -e "${RED}Moniker cannot be empty!${NC}"
    fi
done

echo ""
echo -e "${BLUE}Wallet Name: ${GREEN}${WALLET_NAME}${NC}"
echo -e "${BLUE}Moniker: ${GREEN}${MONIKER}${NC}"
echo ""

# --- System Preparation ---
printSection "SYSTEM PREPARATION"
echo -e "${BLUE}Updating system packages...${NC}"
apt update -qq && apt upgrade -y -qq
printStatus "System updated"

echo -e "${BLUE}Installing dependencies...${NC}"
apt install -y -qq curl tar wget clang pkg-config libssl-dev jq build-essential \
                bsdmainutils git make ncdu gcc chrony liblz4-tool snapd
printStatus "Dependencies installed"

# --- Go Installation ---
printSection "GO INSTALLATION"
if ! command -v go &>/dev/null; then
    echo -e "${BLUE}Installing Go ${GO_VERSION}...${NC}"
    wget -q "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bashrc
    source $HOME/.bashrc
    printStatus "Go ${GO_VERSION} installed"
else
    echo -e "${YELLOW}Go already installed: $(go version)${NC}"
fi

# --- Node Installation ---
printSection "NODE INSTALLATION"
echo -e "${BLUE}Downloading emped binary...${NC}"
wget -q $BINARY_URL -O /tmp/emped.tar.gz
tar -xzf /tmp/emped.tar.gz -C /tmp/
chmod +x /tmp/emped
mkdir -p $HOME/go/bin
mv /tmp/emped $HOME/go/bin/
printStatus "Emped installed: $(emped version --long | grep -e version -e commit)"

# --- Node Initialization ---
printSection "NODE INITIALIZATION"
echo -e "${BLUE}Initializing node...${NC}"
emped init "$MONIKER" --chain-id $CHAIN_ID --home $HOME/.empe-chain
printStatus "Node initialized"

# --- Configuration ---
printSection "NODE CONFIGURATION"
echo -e "${BLUE}Downloading genesis file...${NC}"
wget -q $GENESIS_URL -O $HOME/.empe-chain/config/genesis.json
printStatus "Genesis file installed"

echo -e "${BLUE}Configuring node settings...${NC}"
# Set minimum gas price
sed -i "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"${MIN_GAS_PRICE}\"|" $HOME/.empe-chain/config/app.toml

# Set other configs
sed -i \
  -e "s|^pruning *=.*|pruning = \"custom\"|" \
  -e "s|^pruning-keep-recent *=.*|pruning-keep-recent = \"100\"|" \
  -e "s|^pruning-interval *=.*|pruning-interval = \"10\"|" \
  $HOME/.empe-chain/config/app.toml

sed -i \
  -e "s|^timeout_commit *=.*|timeout_commit = \"5s\"|" \
  -e "s|^seeds *=.*|seeds = \"\"|" \
  -e "s|^persistent_peers *=.*|persistent_peers = \"\"|" \
  $HOME/.empe-chain/config/config.toml

printStatus "Node configured"

# --- Download Addrbook ---
echo -e "${BLUE}Downloading address book...${NC}"
wget -q $ADDRBOOK_URL -O $HOME/.empe-chain/config/addrbook.json
printStatus "Address book downloaded"

# --- Service Setup ---
printSection "SERVICE SETUP"
echo -e "${BLUE}Creating systemd service...${NC}"
sudo tee /etc/systemd/system/emped.service > /dev/null <<EOF
[Unit]
Description=ONENOV Node
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/emped start --home $HOME/.empe-chain
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable emped
printStatus "Service created and enabled"

# --- Snapshot Installation ---
printSection "SNAPSHOT INSTALLATION"
echo -e "${BLUE}Installing snapshot...${NC}"
sudo systemctl stop emped

# Backup validator state
[ -f $HOME/.empe-chain/data/priv_validator_state.json ] && \
  cp $HOME/.empe-chain/data/priv_validator_state.json $HOME/.empe-chain/priv_validator_state.json.backup

# Clean and install snapshot
rm -rf $HOME/.empe-chain/data
mkdir -p $HOME/.empe-chain/data

echo -e "${BLUE}Downloading and extracting snapshot...${NC}"
wget -q -O - $SNAPSHOT_URL | lz4 -dc - | tar -xf - -C $HOME/.empe-chain/data

# Restore validator state
[ -f $HOME/.empe-chain/priv_validator_state.json.backup ] && \
  mv $HOME/.empe-chain/priv_validator_state.json.backup $HOME/.empe-chain/data/priv_validator_state.json

printStatus "Snapshot installed"

# --- Start Service ---
printSection "STARTING NODE"
echo -e "${BLUE}Starting node service...${NC}"
sudo systemctl start emped
printStatus "Node started"

# --- Final Instructions ---
printSection "INSTALLATION COMPLETE"
echo -e "${GREEN}ONENOV node has been successfully installed!${NC}"
echo ""
echo -e "${BLUE}Node Information:${NC}"
echo -e "Moniker: ${GREEN}${MONIKER}${NC}"
echo -e "Chain ID: ${GREEN}${CHAIN_ID}${NC}"
echo -e "Wallet Name: ${GREEN}${WALLET_NAME}${NC}"
echo ""
echo -e "${BLUE}Important Commands:${NC}"
echo -e "Check node status: ${GREEN}sudo systemctl status emped${NC}"
echo -e "Check node logs: ${GREEN}sudo journalctl -fu emped -o cat${NC}"
echo -e "Stop node: ${GREEN}sudo systemctl stop emped${NC}"
echo -e "Start node: ${GREEN}sudo systemctl start emped${NC}"
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
echo -e "  --moniker \"${MONIKER}\" \\"
echo -e "  --chain-id ${CHAIN_ID} \\"
echo -e "  --gas auto \\"
echo -e "  --gas-prices ${MIN_GAS_PRICE}${NC}"
echo ""
echo -e "${GREEN}ONENOV setup complete! Happy validating!${NC}"
