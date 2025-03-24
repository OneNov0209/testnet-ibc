
# 🚀 Empeirias Node Validator - Auto Installer & Guide

Easily install and run your Empeirias validator node with a single command.

---

## ⚙️ 1. Auto Installation

Run this script on your VPS:

```bash
wget -O empeirias.sh https://file.onenov.xyz/files/1742794103445-empeirias.sh
chmod +x empeirias.sh
./empeirias.sh
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

---

## 📘 Cheat Sheet

| Command | Description |
|--------|-------------|
| `emped status` | Check node status |
| `emped config chain-id empe-testnet-2` | Set the chain ID |
| `emped keys add <wallet>` | Create a new wallet |
| `emped keys list` | Show wallets |
| `emped keys show <wallet> -a` | Show wallet address |
| `emped keys show <wallet> --pubkey` | Show public key |
| `emped query account <address>` | Check wallet balance |
| `emped query staking validator <val_address>` | Check validator info |
| `emped tx staking delegate <val_address> <amount>uempe --from <wallet> --chain-id empe-testnet-2 --gas auto --fees 30uempe` | Delegate tokens |
| `emped logs -f` | Follow log output |
| `emped start` | Run the node |
| `journalctl -u empeirias.service -f` | Check service logs |

---

Need help? Reach out to the Empeirias team or fellow validators!
