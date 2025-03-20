[![Orchestra Labs Logo](https://i.postimg.cc/3N0qt7Jd/images.jpg)](https://postimg.cc/64wzQkZX)


## Node Status
My node has been running since August 1, 2024, with stable uptime and perfect synchronization.

## Reasons to Participate
I joined the Symphony Testnet to deepen my understanding of the Orchestralabs blockchain protocol and contribute to the validator community.

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange)  
![Docker](https://img.shields.io/badge/Tool-Docker-blue)  
![Node Status](https://img.shields.io/badge/Node%20Status-Active-brightgreen)

- **Explorer**: [testnet.ping.pub/symphony](https://testnet.ping.pub/symphony/staking/symphonyvaloper1cjdxm4urpdp42un8xjsdx6469h3nlx26smxv50)

[![Screenshot-2024-12-25-17-53-45-704-com-kiwibrowser-browser-edit.jpg](https://i.postimg.cc/QxX0K485/Screenshot-2024-12-25-17-53-45-704-com-kiwibrowser-browser-edit.jpg)](https://postimg.cc/s1NptJZD)

## Spesifikasi Server
- **CPU:** 4 Core  
- **RAM:** 8 GB  
- **Disk:** 160 GB SSD  
- **OS:** Ubuntu 22.04

# Symphony Node Setup

Instruksi ini menjelaskan cara mengatur node Symphony pada server Ubuntu.

```bash
sudo apt update
sudo apt-get install git curl build-essential make jq gcc snapd chrony lz4 tmux unzip bc -y
```

## Instalasi Go

```bash
rm -rf $HOME/go
sudo rm -rf /usr/local/go
cd $HOME
curl https://dl.google.com/go/go1.22.5.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile
go version
```

## Instalasi Symphony Node

```bash
cd $HOME
rm -rf symphony
git clone https://github.com/Orchestra-Labs/symphony.git
cd symphony
git checkout v0.4.1
make install
symphonyd version
```

## Inisialisasi Node

Ganti `NodeName` dengan moniker Anda sendiri.

```bash
symphonyd init NodeName --chain-id=symphony-testnet-4
```

## Unduh Genesis

```bash
wget -O $HOME/.symphonyd/config/genesis.json https://raw.githubusercontent.com/Orchestra-Labs/symphony/refs/heads/main/networks/symphony-testnet-4/genesis.json
```

## Unduh Addrbook

```bash
wget -O $HOME/.symphonyd/config/addrbook.json https://raw.githubusercontent.com/vinjan23/Testnet.Guide/refs/heads/main/Symphony/addrbook.json
```

## Buat Service

```bash
sudo tee /etc/systemd/system/symphonyd.service > /dev/null <<EOF
[Unit]
Description=symphonyd Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which symphonyd) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable symphonyd
```

## Unduh Snapshot (opsional)

```bash
sudo systemctl stop symphonyd
cp $HOME/.symphonyd/data/priv_validator_state.json $HOME/.symphonyd/priv_validator_state.json.backup
rm -rf $HOME/.symphonyd/data
curl -L https://snap-t.vinjan.xyz./symphony/latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.symphonyd
mv $HOME/.symphonyd/priv_validator_state.json.backup $HOME/.symphonyd/data/priv_validator_state.json
sudo systemctl restart symphonyd
sudo journalctl -u symphonyd -f -o cat
```

## Buat Wallet

```bash
symphonyd keys add wallet
```

## Import wallet

```bash
symphonyd keys add wallet --recover
```


## Luncurkan Node

```bash
sudo systemctl restart symphonyd
sudo journalctl -u symphonyd -f -o cat
```

## Check Sync ( If False than go to create validator )

```bash
symphonyd status 2>&1 | jq
```

## Create Validator

```bash
symphonyd tx staking create-validator \
--amount=1000000note \
--moniker="$Your_Validator_Name" \
--identity="" \
--details="" \
--website="" \
--from $WALLET \
--commission-rate 0.05 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.05 \
--min-self-delegation 1 \
--pubkey $(symphonyd tendermint show-validator) \
--chain-id symphony-testnet-4 \
--fees=800note \
-y
```

### ----------------------------------------------------------------------------------------------------------


# ⛓️ Oracle Installation Guide

This installation is exclusive to those who installed it from me. Those who install it elsewhere may encounter errors.

---

## ➡️ Prerequisites

Run the following commands to prepare your system:

```bash
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade
sudo apt-get update && apt-get install -y libssl-dev
```

###Install Python 3.10:

```bash
sudo apt update
sudo apt install python3.10
sudo apt install python3.10-venv
```
## ➡️ Installation Steps

```bash
cd $HOME
rm -rf symphony
git clone https://github.com/Orchestra-Labs/symphony
cd symphony
git checkout v0.4.1
make build
```
Clone the Symphony Oracle Voter repository:
```bash
cd $HOME
git clone https://github.com/cmancrypto/symphony-oracle-voter.git
```
Switch to the required version:
```bash
cd symphony-oracle-voter
git checkout v0.0.5
```
If you are going to use your own RPC/API, edit /root/.symphonyd/config/config.toml:

indexer = "kv"

Don't forget to add your Symphony address and valoper address.

### 1. Option --Default-- (keyring backend = os)

Create an .env file:
```bash
cat <<EOF > .env
VALIDATOR_ADDRESS= symphonyvaloperxxx
VALIDATOR_ACC_ADDRESS= symphonyxxx
KEY_PASSWORD= walletpassword;
KEY_BACKEND = os
SYMPHONY_LCD= https://api-symphonyd.vinjan.xyz # or http://localhost:35317 (default port 1317)
TENDERMINT_RPC= https://rpc-symphonyd.vinjan.xyz # or http://localhost:35657 (default port 26657)
EOF
```

## 2. Option --My Guide-- (keyring backend = test)

Create an .env file:
```bash
cat <<EOF > .env
VALIDATOR_ADDRESS= symphonyvaloperxxx
VALIDATOR_ACC_ADDRESS= symphonyxxx
KEY_BACKEND = test
SYMPHONY_LCD= https://api-symphonyd.vinjan.xyz # or http://localhost:35317 (default port 1317)
TENDERMINT_RPC= https://rpc-symphonyd.vinjan.xyz # or http://localhost:35657 (default port 26657)
EOF
```

## ➡️ Proceed After Choosing Option 1 or Option 2

Set up the Python environment:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
```

## ➡️ Service File

Create a systemd service for the Oracle:
```bash
sudo tee /etc/systemd/system/oracle.service > /dev/null << EOF
[Unit]
Description=Symphony Oracle
After=network.target

[Service]
# Environment variables
Environment="SYMPHONYD_PATH=/root/symphony/build/symphonyd"
Environment="PYTHON_ENV=production"
Environment="LOG_LEVEL=INFO"
Environment="DEBUG=false"

# Service configuration
Type=simple
User=root
WorkingDirectory=/root/symphony-oracle-voter/
ExecStart=/root/symphony-oracle-voter/venv/bin/python3 -u /root/symphony-oracle-voter/main.py
Restart=always
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```
Reload systemd and enable the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable oracle.service
sudo systemctl start oracle.service
```
Check the logs:
```
sudo journalctl -u oracle -f -o cat
```

## 📫 contact me

- **Email**: [onenov0209@gmail.com](mailto:onenov0209@gmail.com)
- **GitHub**: [OneNov0209](https://github.com/OneNov0209)
- **Twitter**: [@Surya021292](https://x.com/Surya021292)
- **Medium**: [OneNov Blog](https://medium.com/@OneNov02)

## 🌐 Contact Orchestra Labs

- **Website**: [Orchestra Labs](https://orchestralabs.org/)
- **Twitter**: [@orchestra_labs](https://x.com/orchestra_labs)
- **Documentation**: [Orchestra Labs Documentation](https://orchestralabs.org/documentation)
- **Questboard**: [Symphony Blockchain Questboard](https://zealy.io/cw/symphonyblockchain/questboard/sprints)
- **Linktree**: [Orchestra Labs Linktree](https://linktr.ee/OrchestraLabs)
- 
