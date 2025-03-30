#!/bin/bash

# Empeirias Node Installer
# Complete Version with Manual Wallet/Moniker Input
# Original Script by OneNov0209, Enhanced by [YourName]

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
CHAIN_HOME="$HOME/.empe-chain"
CHAIN_ID="empeiria_9000-1"
SNAPSHOT_URL="https://server-5.itrocket.net/testnet/empeiria/empeiria_2025-03-29_4243880_snap.tar.lz4"
BINARY_NAME="emped"
EMPED_PORT="26"

# ONENOV Logo
function printLogo() {
  echo -e "${CYAN}"
  echo ' ██████╗ ███╗   ██╗███████╗███╗   ██╗ ██████╗ ██╗   ██╗'
  echo '██╔═══██╗████╗  ██║██╔════╝████╗  ██║██╔═══██╗██║   ██║'
  echo '██║   ██║██╔██╗ ██║█████╗  ██╔██╗ ██║██║   ██║██║   ██║'
  echo '██║   ██║██║╚██╗██║██╔══╝  ██║╚██╗██║██║   ██║╚██╗ ██╔╝'
  echo '╚██████╔╝██║ ╚████║███████╗██║ ╚████║╚██████╔╝ ╚████╔╝'
  echo ' ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝'
  echo -e "${NC}"
}

# Get user input with validation
function getUserInput() {
  echo -e "${YELLOW}"
  read -p ">>> Enter your WALLET NAME: " WALLET_NAME
  while [ -z "$WALLET_NAME" ]; do
    echo -e "${RED}❌ Wallet name cannot be empty!${NC}"
    read -p ">>> Enter your WALLET NAME: " WALLET_NAME
  done

  read -p ">>> Enter your MONIKER (Node Name): " MONIKER_NAME
  while [ -z "$MONIKER_NAME" ]; do
    echo -e "${RED}❌ Moniker cannot be empty!${NC}"
    read -p ">>> Enter your MONIKER (Node Name): " MONIKER_NAME
  done
  echo -e "${NC}"
}

# Initialize chain
function initChain() {
  echo -e "${GREEN}>>> Initializing chain with moniker: $MONIKER_NAME...${NC}"
  $BINARY_NAME init "$MONIKER_NAME" --chain-id $CHAIN_ID --home $CHAIN_HOME || {
    echo -e "${RED}>>> Failed to initialize chain!${NC}"
    exit 1
  }
}

# Configure chain
function configureChain() {
  echo -e "${GREEN}>>> Configuring chain...${NC}"
  
  # Port configuration
  sed -i.bak \
    -e "s%:1317%:${EMPED_PORT}317%g" \
    -e "s%:8080%:${EMPED_PORT}080%g" \
    -e "s%:9090%:${EMPED_PORT}090%g" \
    -e "s%:8545%:${EMPED_PORT}545%g" \
    $CHAIN_HOME/config/app.toml

  sed -i.bak \
    -e "s%:26657%:${EMPED_PORT}657%g" \
    -e "s%:26656%:${EMPED_PORT}656%g" \
    -e "s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${EMPED_PORT}656\"%" \
    $CHAIN_HOME/config/config.toml

  # Pruning settings
  sed -i \
    -e "s/^pruning *=.*/pruning = \"custom\"/" \
    -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" \
    -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" \
    $CHAIN_HOME/config/app.toml

  # Gas price and prometheus
  sed -i \
    -e 's|minimum-gas-prices =.*|minimum-gas-prices = "0.0001uempe"|g' \
    $CHAIN_HOME/config/app.toml
  
  sed -i \
    -e "s/prometheus = false/prometheus = true/" \
    -e "s/^indexer *=.*/indexer = \"null\"/" \
    $CHAIN_HOME/config/config.toml
}

# Create service file
function createService() {
  echo -e "${GREEN}>>> Creating systemd service...${NC}"
  sudo tee /etc/systemd/system/emped.service > /dev/null <<EOF
[Unit]
Description=Empeiria Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$CHAIN_HOME
ExecStart=$(which $BINARY_NAME) start --home $CHAIN_HOME
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
}

# Main installation
function main() {
  printLogo
  getUserInput
  
  # Initialize chain if not exists
  if [ ! -d "$CHAIN_HOME/config" ]; then
    initChain
    configureChain
  else
    echo -e "${YELLOW}>>> Using existing chain configuration...${NC}"
  fi

  # Download snapshot
  echo -e "${GREEN}>>> Downloading snapshot...${NC}"
  if curl -s --head $SNAPSHOT_URL | grep "200 OK" > /dev/null; then
    $BINARY_NAME tendermint unsafe-reset-all --home $CHAIN_HOME
    curl -L $SNAPSHOT_URL | lz4 -dc - | tar -xf - -C $CHAIN_HOME
  else
    echo -e "${YELLOW}>>> No snapshot available. Syncing from genesis...${NC}"
  fi

  createService

  # Start service
  sudo systemctl daemon-reload
  sudo systemctl enable emped
  sudo systemctl start emped

  # Final output
  echo -e "${GREEN}\n\n>>> Installation Complete! <<<${NC}"
  echo -e "${YELLOW}>>> Node Status:${NC} sudo journalctl -u emped -f -o cat"
  echo -e "${YELLOW}>>> Create Wallet:${NC} $BINARY_NAME keys add $WALLET_NAME --keyring-backend os --home $CHAIN_HOME"
  echo -e "${YELLOW}>>> Check Sync:${NC} $BINARY_NAME status --home $CHAIN_HOME"
}

# Run main function
main
