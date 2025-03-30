
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

## ⚙️ 1. Auto Installation

Run this script on your VPS:

```bash
curl -sSL https://raw.githubusercontent.com/OneNov0209/testnet-ibc/refs/heads/main/Empeirias/empeiria_install.sh | bash
```

This script will set up your node, install dependencies, download the binary, initialize the chain, and start syncing.

---

## ✅ 2. Register Your Validator (After Sync Complete)

Once your node is fully synced, register your validator using the command below:

```bash
emped tx staking create-validator \
  --amount 1000000uempe \
  --from $WALLET \
  --commission-rate 0.1 \
  --commission-max-rate 0.2 \
  --commission-max-change-rate 0.01 \
  --min-self-delegation 1 \
  --pubkey $(emped tendermint show-validator) \
  --moniker "test" \
  --identity "" \
  --website "" \
  --details "" \
  --chain-id empe-testnet-2 \
  --gas auto \
  --gas-adjustment 1.5 \
  --fees 30uempe \
  -y
```

Make sure to:
- Replace `test` with your validator name.
- Replace `$WALLET` with your wallet name.

  ## ✅ 3. Check status
  ```
  emped status 2>&1 | jq
  ```
  if status False, Let's Next steps

---

## 4. 📘 Cheat Sheet

---

### Create Wallet
```bash
emped keys add <wallet_name>
```

### Recover Wallet
```bash
emped keys add <wallet_name> --recover
```

### List Wallets
```bash
emped keys list
```

### Check Wallet Balance
```bash
emped query bank balances <wallet_address>
```

---

### Chain Info
```bash
emped status 2>&1 | jq .SyncInfo
emped status | jq
```

### Node Info
```bash
emped tendermint show-node-id
```

---

### Validator Operations

***Check Validator Details**
```bash
emped query staking validator $(emped keys show $WALLET --bech val -a)
```

**Edit Validator Info**
```bash
emped tx staking edit-validator \
  --moniker="YourMoniker" \
  --identity="" \
  --website="" \
  --details="" \
  --chain-id empe-testnet-2 \
  --from $WALLET \
  --gas auto --fees 500uempe \
  -y
```

**Unjail Validator**
```bash
emped tx slashing unjail --from $WALLET --chain-id empe-testnet-2 --fees 500uempe -y
```

---

### Delegation

**Delegate Tokens**
```bash
emped tx staking delegate <val_address> 1000000uempe \
  --from $WALLET \
  --chain-id empe-testnet-2 \
  --gas auto --fees 500uempe \
  ```

**Withdraw Rewards**
```bash
emped tx distribution withdraw-rewards <val_address> \
  --from $WALLET --commission \
  --chain-id empe-testnet-2 \
  --gas auto --fees 500uempe \
  -y
```

**Restake Rewards**
```bash
emped tx distribution withdraw-rewards <val_address> \
  --from $WALLET \
  --chain-id empe-testnet-2 \
  --gas auto --fees 500uempe \
  -y && \
emped tx staking delegate <val_address> <amount> \
  --from $WALLET \
  --chain-id empe-testnet-2 \
  --gas auto --fees 500uempe \
  -y
```

---

### Governance

**Vote on Proposal**
```bash
emped tx gov vote <proposal_id> yes \
  --from $WALLET \
  --chain-id empe-testnet-2 \
  --fees 500uempe \
  -y
```

**Check Proposal**
```bash
emped query gov proposals
```

---

### Service Management

**Start Service**
```bash
sudo systemctl start emped
```

**Stop Service**
```bash
sudo systemctl stop emped
```

**Restart Service**
```bash
sudo systemctl restart emped
```

**Check Logs**
```bash
journalctl -fu emped -o cat
```

**Check Status**
```bash
systemctl status emped
```
---

### > Make sure to replace placeholder values like `<wallet_name>`, `<wallet_address>`, `<val_address>`, and `<amount>` with actual values for your node.
---
## If you want to know more information, you can go directly here

## **[Social Media](https://linktr.ee/empe_io)**
