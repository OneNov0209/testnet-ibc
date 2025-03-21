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
bash <(curl -s https://raw.githubusercontent.com/OneNov0209/testnet-ibc/refs/heads/main/Ogchain/install.sh)
```

## **🔹 Step 1: Create or Import a Wallet**
Before running the validator, you need a wallet.

### **Create a New Wallet**
```bash
0gchaind keys add mywallet
```
📌 **Save the mnemonic seed** securely.

### **Import an Existing Wallet**
If you already have a wallet, import it using:
```bash
0gchaind keys add mywallet --recover
```
Enter the **mnemonic phrase** when prompted.

### **Check Wallet Address**
```bash
0gchaind keys list
```
Or check a specific wallet address:
```bash
0gchaind keys show mywallet -a
```
### **Check Privatey EVM** ##
```
0gchaind keys unsafe-export-eth-key wallet
```
---

## **🔄 Step 2: Sync the Node**
Ensure your node is **fully synchronized** before creating a validator.

Check sync status:
```bash
0gchaind status | jq .sync_info
```
If `"catching_up": false`, your node is fully synced.

---

## **🚀 Step 3: Create a Validator**
Once the node is synced, create your validator:
```bash
0gchaind tx staking create-validator \
--amount 1000000ua0gi \
--from $WALLET \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(0gchaind tendermint show-validator) \
--moniker "test" \
--identity "" \
--website "" \
--details "stake with me" \
--chain-id zgtendermint_16600-2 \
--gas-adjustment 1.5 --gas auto --gas-prices 0.00252ua0gi \
-y
```
📌 **Replace `--moniker="OneNov"` with your validator name.**

---

## **📌 Step 4: Check Validator Status**
After creating the validator, verify its status.

Check validator status:
```bash
0gchaind query staking validator $(0gchaind keys show wallet --bech val -a)
```

Check all validators in the network:
```bash
0gchaind query staking validators --limit=1000 -o json | jq '.validators[] | {moniker: .description.moniker, status: .status}'
```

---

## **📊 Step 5: Monitor Logs**
To view real-time logs:
```bash
journalctl -fu 0gchaind -o cat
```
Or, check systemd service status:
```bash
systemctl status 0gchaind
```

---

## **💰 Step 6: Delegate More Tokens**
To stake additional tokens to your validator:
```bash
0gchaind tx staking delegate $(0gchaind keys show mywallet --bech val -a) 1000000uog --from=mywallet --chain-id=zgtendermint_16600-2 --gas=auto
```
📌 **Replace `1000000uog` with the amount you want to delegate.**

---

## **🔄 Step 7: Unjail Validator (if Slashed)**
If your validator gets **slashed** and jailed, unjail it with:
```bash
0gchaind tx slashing unjail --from=wallet --chain-id=zgtendermint_16600-2 --gas=auto
```

---

## **🚀 Step 8: Check Wallet Balance**
```bash
0gchaind query bank balances $(0gchaind keys show wallet -a)
```

---

## **📌 Step 9: Withdraw Staking Rewards**
To withdraw staking rewards from your validator:
```bash
0gchaind tx distribution withdraw-rewards $(0gchaind keys show mywallet --bech val -a) --from=wallet --commission --chain-id=zgtendermint_16600-2 --gas=auto
```

---

## **✅ Step 10: Unbond Your Validator (if Needed)**
If you wish to remove your validator:
```bash
0gchaind tx staking unbond $(0gchaind keys show wallet --bech val -a) 1000000uog --from=mywallet --chain-id=zgtendermint_16600-2 --gas=auto
```
⚠️ **After unbonding, your tokens will be locked for a certain period before they become available.**

---

## **🔄 Step 11: Restart & Stop Node**
To **restart** the node:
```bash
systemctl restart 0gchaind
```

To **stop** the node:
```bash
systemctl stop 0gchaind
```

---

## **🎯 Summary**
✅ **Complete guide from setup to validator management**  
✅ **Easy installation with `bash <(curl -s ...)`**  
✅ **Essential commands for monitoring and staking**  

🚀 **Now your 0g Labs Validator is ready to run!** 🚀
