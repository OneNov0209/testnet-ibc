
<p align="center">
  <img src="https://pbs.twimg.com/profile_images/1571914336288776193/HmxJDHvF.jpg" alt="BlockX Logo" width="250"/>
</p>

<p align="center">
  <a href="https://x.com/BlockXnet">Twitter</a> • 
  <a href="https://discord.gg/WsX4XFRx">Discord</a> • 
  <a href="https://t.me/blockxnetwork">Telegram</a> • 
  <a href="https://t.me/blockxnetwork/1">Channel</a>
</p>

---

# 🚀 BlockX Node Installation Guide

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange)
![Node Status](https://img.shields.io/badge/Node%20Status-Active-brightgreen)

---

## 📋 System Requirements

| Requirement | Minimum       | Recommended    |
|-------------|---------------|----------------|
| OS          | Ubuntu 20.04+ | Ubuntu 22.04+  |
| CPU         | 4 Cores       | 6+ Cores       |
| RAM         | 8 GB          | 16 GB+         |
| Storage     | 250 GB SSD    | 500 GB+ SSD/NVMe |
| Network     | 10 Mbps       | 100 Mbps+      |

---

## 🧱 Step 1: Install Dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

## 🧰 Step 2: Install Go

```bash
cd $HOME
VER="1.21.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source ~/.bash_profile
```

## ⚙️ Step 3: Set Environment Variables

```bash
echo 'export WALLET="wallet"' >> ~/.bash_profile
echo 'export MONIKER="Your_Node_Name"' >> ~/.bash_profile
echo 'export BLOCKX_CHAIN_ID="blockx_19191-1"' >> ~/.bash_profile
echo 'export BLOCKX_PORT="49"' >> ~/.bash_profile
source ~/.bash_profile
```

## 📦 Step 4: Download and Build Binary

```bash
cd $HOME
rm -rf networks
git clone https://github.com/BlockXLabs/networks
cd ~/networks/chains/blockx_19191-1/source/
make install
```

## 🛠️ Step 5: Configure the Node

```bash
blockxd config node tcp://localhost:${BLOCKX_PORT}657
blockxd config keyring-backend os
blockxd config chain-id blockx_19191-1
blockxd init "$MONIKER" --chain-id blockx_19191-1
```

## 🌐 Step 6: Download Genesis & Addrbook

```bash
wget -O $HOME/.blockxd/config/genesis.json https://server-1.itrocket.net/mainnet/blockx/genesis.json
wget -O $HOME/.blockxd/config/addrbook.json  https://server-1.itrocket.net/mainnet/blockx/addrbook.json
```

## 🤝 Step 7: Set Peers & Seeds

```bash
SEEDS="4452d0be36c123b971c2b052c54b2645fd3122a9@blockx-mainnet-seed.itrocket.net:19656"
PEERS="...paste_peers_here..."
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.blockxd/config/config.toml
```

## 🧩 Step 8: Customize Ports & Config

```bash
# In app.toml
sed -i.bak -e "s%:1317%:${BLOCKX_PORT}317%g; s%:8080%:${BLOCKX_PORT}080%g; s%:9090%:${BLOCKX_PORT}090%g; s%:9091%:${BLOCKX_PORT}091%g; s%:8545%:${BLOCKX_PORT}545%g; s%:8546%:${BLOCKX_PORT}546%g; s%:6065%:${BLOCKX_PORT}065%g" $HOME/.blockxd/config/app.toml

# In config.toml
sed -i.bak -e "s%:26658%:${BLOCKX_PORT}658%g; s%:26657%:${BLOCKX_PORT}657%g; s%:6060%:${BLOCKX_PORT}060%g; s%:26656%:${BLOCKX_PORT}656%g; s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${BLOCKX_PORT}656\"%; s%:26660%:${BLOCKX_PORT}660%g" $HOME/.blockxd/config/config.toml
```

## 🧹 Step 9: Pruning & Prometheus

```bash
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.blockxd/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.blockxd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.blockxd/config/app.toml
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0abcx"|g' $HOME/.blockxd/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.blockxd/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.blockxd/config/config.toml
```

## 📄 Step 10: Create Systemd Service

```bash
sudo tee /etc/systemd/system/blockxd.service > /dev/null <<EOF
[Unit]
Description=BlockX Node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.blockxd
ExecStart=$(which blockxd) start --home $HOME/.blockxd
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## 🔁 Step 11: Reset & Download Snapshot

```bash
blockxd tendermint unsafe-reset-all --home $HOME/.blockxd
curl https://server-1.itrocket.net/mainnet/blockx/blockx_2025-06-29_26797818_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.blockxd
```

## 🚀 Step 12: Enable & Start Node

```bash
sudo systemctl daemon-reload
sudo systemctl enable blockxd
sudo systemctl start blockxd
```

---

🔧 **To check logs:**

```bash
sudo journalctl -u blockxd -fo cat
```

🧾 **Check Sync Status:**

```bash
blockxd status 2>&1 | jq
```

🔑 **Create Wallet:**

```bash
blockxd keys add $WALLET
```

🔁 **Restore Wallet:**

```bash
blockxd keys add $WALLET --recover
```

📄 **More commands (delegate, unbond, transfer)** available in the original instructions.

---

<p align="center"><i>Build secure and scalable dApps with BlockX ⚙️</i></p>
