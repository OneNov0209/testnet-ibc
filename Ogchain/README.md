# 🚀 0g Labs Node Validator - Automatic Installation

![Node Status](https://img.shields.io/badge/Node%20Status-Active-brightgreen)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange)  

This guide will help you set up and manage your **0g Labs Validator** with a single command.

| **Requirement**  | **Minimum**  | **Recommended** |
|-----------------|-------------|----------------|
| **OS**         | Ubuntu 20.04+ | Ubuntu 22.04+  |
| **CPU**        | 6 Cores      | 8+ Cores       |
| **RAM**        | 8GB          | 16GB+          |
| **Storage**    | 500GB SSD/NVMe | 1TB SSD/NVMe |
| **Network**    | 10 Mbit/s    | 100 Mbit/s+    |

## [EXPLORER](https://0g.exploreme.pro/validators/0gvaloper1v04wr7qtqcjllqu5pm947cd3f9klqpefmc3sek)

✅  RPC: https://rpc-0gchaind.onenov.xyz

✅  API: https://api-0gchaind.onenov.xyz

✅  Snapshot: https://snapshot-0gchaind.onenov.xyz

✅  Genesis: https://snapshot-0gchaind.onenov.xyz/genesis.json

✅  Addrbook: https://snapshot-0gchaind.onenov.xyz/addrbook.json

✅  Latest Snapshot: https://snapshot-0gchaind.onenov.xyz/latest.tar.lz4

✅  EVM JSON-RPC: https://evm-0gchaind.onenov.xyz




## **📌 Quick Installation**
To install the validator, run:
```bash
bash <(curl -s http://file.onenov.xyz/files/0g_validator.sh)
```

## **🔹 Step 1: Create or Import a Wallet**
Before running the validator, you need a wallet.

### **Create a New Wallet**
```bash
0g-chain keys add mywallet
```
📌 **Save the mnemonic seed** securely.

### **Import an Existing Wallet**
If you already have a wallet, import it using:
```bash
0g-chain keys add mywallet --recover
```
Enter the **mnemonic phrase** when prompted.

### **Check Wallet Address**
```bash
0g-chain keys list
```
Or check a specific wallet address:
```bash
0g-chain keys show mywallet -a
```

---

## **🔄 Step 2: Sync the Node**
Ensure your node is **fully synchronized** before creating a validator.

Check sync status:
```bash
0g-chain status | jq .sync_info
```
If `"catching_up": false`, your node is fully synced.

---

## **🚀 Step 3: Create a Validator**
Once the node is synced, create your validator:
```bash
0g-chain tx staking create-validator \
  --amount=1000000uog \
  --pubkey=$(0g-chain tendermint show-validator) \
  --moniker="OneNov" \
  --chain-id=0g-chain-testnet \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --gas="auto" \
  --from=mywallet
```
📌 **Replace `--moniker="OneNov"` with your validator name.**

---

## **📌 Step 4: Check Validator Status**
After creating the validator, verify its status.

Check validator status:
```bash
0g-chain query staking validator $(0g-chain keys show mywallet --bech val -a)
```

Check all validators in the network:
```bash
0g-chain query staking validators --limit=1000 -o json | jq '.validators[] | {moniker: .description.moniker, status: .status}'
```

---

## **📊 Step 5: Monitor Logs**
To view real-time logs:
```bash
journalctl -fu 0g-chain -o cat
```
Or, check systemd service status:
```bash
systemctl status 0g-chain
```

---

## **💰 Step 6: Delegate More Tokens**
To stake additional tokens to your validator:
```bash
0g-chain tx staking delegate $(0g-chain keys show mywallet --bech val -a) 1000000uog --from=mywallet --chain-id=0g-chain-testnet --gas=auto
```
📌 **Replace `1000000uog` with the amount you want to delegate.**

---

## **🔄 Step 7: Unjail Validator (if Slashed)**
If your validator gets **slashed** and jailed, unjail it with:
```bash
0g-chain tx slashing unjail --from=mywallet --chain-id=0g-chain-testnet --gas=auto
```

---

## **🚀 Step 8: Check Wallet Balance**
```bash
0g-chain query bank balances $(0g-chain keys show mywallet -a)
```

---

## **📌 Step 9: Withdraw Staking Rewards**
To withdraw staking rewards from your validator:
```bash
0g-chain tx distribution withdraw-rewards $(0g-chain keys show mywallet --bech val -a) --from=mywallet --commission --chain-id=0g-chain-testnet --gas=auto
```

---

## **✅ Step 10: Unbond Your Validator (if Needed)**
If you wish to remove your validator:
```bash
0g-chain tx staking unbond $(0g-chain keys show mywallet --bech val -a) 1000000uog --from=mywallet --chain-id=0g-chain-testnet --gas=auto
```
⚠️ **After unbonding, your tokens will be locked for a certain period before they become available.**

---

## **🔄 Step 11: Restart & Stop Node**
To **restart** the node:
```bash
systemctl restart 0g-chain
```

To **stop** the node:
```bash
systemctl stop 0g-chain
```

---

## **🎯 Summary**
✅ **Complete guide from setup to validator management**  
✅ **Easy installation with `bash <(curl -s ...)`**  
✅ **Essential commands for monitoring and staking**  

🚀 **Now your 0g Labs Validator is ready to run!** 🚀
