# Kiichain Validator Setup

![Node Status](https://img.shields.io/badge/Node%20Status-Active-brightgreen)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange)  


### [EXPLORER KIICHAIN](https://explorer.kiichain.io/staking)
### [Docs Official](https://docs.kiiglobal.io/docs/validate-the-network/run-a-validator-full-node/step-by-step-guide)

A complete guide to setting up a full node and validator node on the **Kiichain Testnet**.

---
| **Requirement**  | **Minimum**  | **Recommended** |
|-----------------|-------------|----------------|
| **OS**         | Ubuntu 20.04+ | Ubuntu 22.04+  |
| **CPU**        | 6 Cores      | 8+ Cores       |
| **RAM**        | 8GB          | 16GB+          |
| **Storage**    | 500GB SSD/NVMe | 1TB SSD/NVMe |
| **Network**    | 10 Mbit/s    | 100 Mbit/s+    |
---

## 1. Install Dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget jq make gcc tmux unzip build-essential -y
```

---

## 2. Clone and Install Kiichain

```bash
git clone https://github.com/KiiChain/kiichain.git
cd kiichain
make install
```

Verify version:
```bash
kiichaind version
```

---

## 3. Initialize the Node

```bash
CHAIN_ID="kiichain3"
NODE_MONIKER="your name"
NODE_HOME="$HOME/.kiichain3"
PERSISTENT_PEERS="5b6aa55124c0fd28e47d7da091a69973964a9fe1@uno.sentry.testnet.v3.kiivalidator.com:26656,5e6b283c8879e8d1b0866bda20949f9886aff967@dos.sentry.testnet.v3.kiivalidator.com:26656"
GENESIS_URL="https://raw.githubusercontent.com/KiiChain/testnets/refs/heads/main/testnet_oro/genesis.json"

kiichaind init $NODE_MONIKER --chain-id $CHAIN_ID --home $NODE_HOME
sed -i -e "/persistent-peers =/ s^= .*^= \"$PERSISTENT_PEERS\"^" $NODE_HOME/config/config.toml
wget $GENESIS_URL -O genesis.json
mv genesis.json $NODE_HOME/config/genesis.json
```

Enable DB options:

```bash
sed -i.bak -e "s|^occ-enabled *=.*|occ-enabled = true|" $NODE_HOME/config/app.toml
sed -i.bak -e "s|^sc-enable *=.*|sc-enable = true|" $NODE_HOME/config/app.toml
sed -i.bak -e "s|^ss-enable *=.*|ss-enable = true|" $NODE_HOME/config/app.toml
sed -i.bak -e 's/^# concurrency-workers = 20$/concurrency-workers = 500/' $NODE_HOME/config/app.toml
```

---

## 4. Setup systemd

```bash
sudo tee /etc/systemd/system/kiichaind.service > /dev/null <<EOF
[Unit]
Description=Kiichain Daemon
After=network-online.target

[Service]
User=root
ExecStart=/root/go/bin/kiichaind start --home /root/.kiichain3
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

Enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable kiichaind
sudo systemctl start kiichaind
```

Check logs:
```bash
journalctl -u kiichaind -f -o cat
```

---

## 5. Create Wallet

```bash
kiichaind keys add wallet
# or recover
# kiichaind keys add wallet --recover
```

---

## 6. Request Faucet & Check Balance

```bash
kiichaind query bank balances $(kiichaind keys show wallet -a)
```

---

## 7. Create Validator

```bash
MONIKER="your name"
AMOUNT="100000000ukii"
COMMISSION_RATE="0.10"
COMMISSION_MAX_RATE="0.20"
COMMISSION_MAX_CHANGE_RATE="0.05"
MIN_SELF_DELEGATION="1"
WALLET_NAME="wallet"

kiichaind tx staking create-validator \
  --amount=$AMOUNT \
  --pubkey=$(kiichaind tendermint show-validator) \
  --moniker=$MONIKER \
  --identity "" \
  --website="" \
  --security-contact="" \
  --details="Stake With Me" \
  --chain-id=kiichain3 \
  --min-self-delegation=$MIN_SELF_DELEGATION \
  --commission-rate=$COMMISSION_RATE \
  --commission-max-rate=$COMMISSION_MAX_RATE \
  --commission-max-change-rate=$COMMISSION_MAX_CHANGE_RATE \
  --gas="auto" \
  --gas-adjustment 1.5 \
  --gas-prices="0.05ukii" \
  --from=$WALLET_NAME
```

---

## 8. Edit Validator Info (Optional)

```bash
kiichaind tx staking edit-validator \
  --identity="09F974A66062BDCC" \
  --website="https://github.com/OneNov0209" \
  --security-contact="onenov0209@gmail.com" \
  --details="Stake With Me" \
  --chain-id=kiichain3 \
  --from=wallet \
  --gas=auto \
  --gas-prices=0.05ukii
```

---

## 9. Verify Validator Status

```bash
kiichaind query staking validator $(kiichaind keys show wallet --bech val -a)
```

If `status: BOND_STATUS_BONDED`, your validator is active.

---

## 10. Monitor Logs

```bash
journalctl -u kiichaind -f -o cat
```
### check status syncron 
```
kiichaind status | jq .SyncInfo
```

---

## Credit

Created by [OneNov](https://github.com/OneNov0209)
