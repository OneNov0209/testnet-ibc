XOS INSTALLATION NODE VALIDATOR

<p align="center">
  <img src="https://pbs.twimg.com/profile_images/1861059503325913088/axi4e4i1.jpg" width="250" height="250" alt="XOS Logo"/>
</p>

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange)  
![Docker](https://img.shields.io/badge/Tool-Docker-blue)  
![Node Status](https://img.shields.io/badge/Node%20Status-Active-brightgreen)

---

## 🧱 System Requirements

| Requirement | Minimum       | Recommended     |
|------------|----------------|-----------------|
| OS         | Ubuntu 20.04+  | Ubuntu 22.04+   |
| CPU        | 6 Cores        | 8+ Cores        |
| RAM        | 8 GB           | 16 GB+          |
| Storage    | 500 GB SSD     | 1 TB SSD/NVMe   |
| Network    | 10 Mbit/s      | 100 Mbit/s+     |

---

## 🚀 XOS Node Installation Guide (Testnet)

### 1. Download Binary
```bash
wget https://github.com/xos-labs/node/releases/download/v0.5.2/node_0.5.2_Linux_amd64.tar.gz
```

### 2. Extract Package
```bash
tar -xzf node_0.5.2_Linux_amd64.tar.gz
```

### 3. Install Binary
```bash
sudo mv ./bin/xosd /usr/local/bin/
chmod +x /usr/local/bin/xosd
which xosd
```

### 4. Check Version
```bash
xosd version
```

---

## 🛠️ Compile from Source (Optional)

### Install Dependencies
```bash
sudo apt-get update
sudo apt-get install build-essential
```

### Install Go
```bash
wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile
go version
```

### Clone Repository & Build
```bash
git clone https://github.com/xos-labs/node.git
cd node
make build
```

---

## ⚙️ Node Setup

### Init Node
```bash
xosd init Your_Validator_Nams --chain-id xos_1267-1
```

### Set Keyring Backend
```bash
xosd config set client keyring-backend file
```

### Create Wallet
```bash
xosd keys add wallet --keyring-backend file
```
Or if you recover wallet
```
xosd keys add myxoswallet --recover --keyring-backend file
```

---

## 🌐 Join the Network

### Download Genesis
```bash
wget https://raw.githubusercontent.com/xos-labs/networks/refs/heads/main/testnet/genesis.json -O ~/.xosd/config/genesis.json
```

### Configure Peers
```bash
PEERS=$(curl -sL https://raw.githubusercontent.com/xos-labs/networks/main/testnet/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -)
sed -i.bak -e "s/^seeds *=.*/seeds = \"$PEERS\"/" ~/.xosd/config/config.toml
cat ~/.xosd/config/config.toml | grep seeds
```

---

## 🔄 Start Node
```bash
xosd start
```

### Check Sync Status
```bash
xosd status | jq
```

---

## 🧭 Useful Links

### 🔗 XOS Official
- 🌐 Website: https://x.ink/
- 💬 Discord: https://discord.gg/xosnetwork
- 🐦 Twitter: https://x.com/xos_labs
- ✈️ Telegram: https://t.me/XosTelegram
- 📚 Docs: https://docs.x.ink/
- 🧪 Test IDE: https://ide.x.ink/

### 🧪 Testnet Tools
- 💧 Faucet: https://faucet.x.ink/
- 💱 DEX: https://dex.x.ink/
- 🔎 Explorer: https://xoscan.io/
- 🌍 Web3 Domain: https://openid.network/
- 🎮 Game.Game: https://game.game/
- 🎲 PlayFi: https://playfi.me/

---

> ⚡ *Redefining scalability with the first Solana Layer 2: high performance, low costs, and seamless multichain connectivity.*
