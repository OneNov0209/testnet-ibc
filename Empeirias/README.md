
# 🚀 Empeirias Node Validator - Auto Installer & Guide

Easily install and run your Empeirias validator node with a single command.

![Node Status](https://img.shields.io/badge/Node%20Status-Active-brightgreen)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange)

---

### [EXPLORE](https://explorer-testnet.empe.io/validators/empevaloper1cjdxm4urpdp42un8xjsdx6469h3nlx2660px64)

[![Empeirias](https://i.ibb.co.com/FbtMWCx6/Screenshot-2025-03-24-15-23-30-216-com-android-chrome-edit.jpg)](https://ibb.co.com/KjHkGS06)
---
| **Requirement**  | **Minimum**  | **Recommended** |
|-----------------|-------------|----------------|
| **OS**         | Ubuntu 20.04+ | Ubuntu 22.04+  |
| **CPU**        | 6 Cores      | 8+ Cores       |
| **RAM**        | 8GB          | 16GB+          |
| **Storage**    | 500GB SSD/NVMe | 1TB SSD/NVMe |
| **Network**    | 10 Mbit/s    | 100 Mbit/s+    |

---

### **1. System Preparation**  
Update and install basic dependencies:  
```bash
sudo apt update && sudo apt upgrade -y  
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc chrony liblz4-tool -y  
```

---

### **2. Install Go 1.21.6**  
```bash
ver="1.21.6"  
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"  
sudo rm -rf /usr/local/go  
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"  
rm "go$ver.linux-amd64.tar.gz"  
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile  
source $HOME/.bash_profile  
go version  
```

---

### **3. Install `emped` Binary**  
```bash
mkdir -p $HOME/go/bin  
curl -LO https://github.com/empe-io/empe-chain-releases/raw/master/v0.3.0/emped_v0.3.0_linux_amd64.tar.gz  
tar -xvf emped_v0.3.0_linux_amd64.tar.gz  
rm emped_v0.3.0_linux_amd64.tar.gz  
chmod +x emped  
mv emped $HOME/go/bin/  
```
---
### **4. Initialize Node**  
```bash
emped init YOUR_NODE_NAME --chain-id empe-testnet-2  
```
### **5. Download Genesis and Addrbook**
```
wget -O $HOME/.empe-chain/config/genesis.json "https://raw.githubusercontent.com/empe-io/empe-chains/refs/heads/master/testnet-2/genesis.json"
```
### **6. Download Addrbook**
```
wget -O $HOME/.empe-chain/config/addrbook.json "https://raw.githubusercontent.com/111STAVR111/props/main/Empeiria/addrbook.json"
```
---
### **7. Create Service**  
```bash
sudo tee /etc/systemd/system/emped.service > /dev/null <<EOF  
[Unit]  
Description=emped  
After=network-online.target  

[Service]  
User=$USER  
ExecStart=$HOME/go/bin/emped start  
Restart=on-failure  
RestartSec=3  
LimitNOFILE=65535  

[Install]  
WantedBy=multi-user.target  
EOF  
```
---
### **8. Start Node**  
```bash
sudo systemctl daemon-reload  
sudo systemctl enable emped  
sudo systemctl start emped  
```

### **9. Download Snapshot**
  ```bash
  sudo systemctl stop emped  
  rm -rf $HOME/.empe-chain/data  
  curl -o - -L https://empe.snapshot-t.stavr.tech/emper-snap.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.empe-chain  
  sudo systemctl restart emped  
  ```
### 10. Chcek status syncron
```
emped status 2>&1 | jq
```
if status False Next Steps

### **11. (Optional) Create Validator**  
```bash
emped tx staking create-validator \  
  --amount 1000000uempe \  
  --commission-rate 0.1 \  
  --commission-max-rate 0.5 \  
  --commission-max-change-rate 0.2 \  
  --min-self-delegation 1 \  
  --pubkey $(emped tendermint show-validator) \  
  --moniker "YOUR_VALIDATOR_NAME" \  
  --chain-id empe-testnet-2 \  
  --from YOUR_WALLET_NAME -y  
```
### ***12Monitor logs:  
```bash
journalctl -fu emped -o cat  
```


