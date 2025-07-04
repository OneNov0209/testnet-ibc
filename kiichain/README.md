
<p align="center">
  <img src="https://pbs.twimg.com/profile_images/1800553180083666944/zZe128CW.jpg" width="200"/><br><br>
  <img src="https://img.shields.io/badge/Node%20Status-Active-brightgreen"/>
  <img src="https://img.shields.io/badge/Ubuntu-22.04-orange"/>
</p>

# 🌐 Kiichain Testnet Oro - Full Node & Validator Setup

### [EXPLORER KIICHAIN](https://explorer.kiichain.io/staking/kiivaloper1cjdxm4urpdp42un8xjsdx6469h3nlx26cu0axj)

Selamat datang di panduan lengkap untuk menjalankan **Node Full + Validator** jaringan **Kiichain Testnet Oro**. Panduan ini mencakup semua langkah mulai dari instalasi, setup validator, hingga integrasi dengan price feeder.

---

## 📦 Spesifikasi Minimum Rekomendasi

| Komponen | Rekomendasi |
|----------|-------------|
| CPU      | 4 Core      |
| RAM      | 8 GB        |
| Disk     | 1 TB NVMe SSD |
| OS       | Ubuntu 20.04 / 22.04 |
| Internet | 10 Mbps     |

---

## ⚙️ Instalasi & Setup Awal

### 1. Install Dependency
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget jq build-essential -y
```

### 2. Install Golang 1.23
```bash
cd $HOME
wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
```

### 3. Clone & Build Kiichain
```bash
git clone https://github.com/KiiChain/kiichain.git
cd kiichain
make install
```

### 4. Inisialisasi Node
```bash
CHAIN_ID="oro_1336-1"
NODE_HOME="$HOME/.kiichain"
NODE_MONIKER="moniker_anda"
PERSISTENT_PEERS="5b6aa55124c0fd28e47d7da091a69973964a9fe1@uno.sentry.testnet.v3.kiivalidator.com:26656,5e6b283c8879e8d1b0866bda20949f9886aff967@dos.sentry.testnet.v3.kiivalidator.com:26656"
MINIMUM_GAS_PRICES="1000000000akii"
GENESIS_URL="https://raw.githubusercontent.com/KiiChain/testnets/refs/heads/main/testnet_oro/genesis.json"
```
```
kiichaind init $NODE_MONIKER --chain-id $CHAIN_ID --home $NODE_HOME
```

### 5. Konfigurasi Peers & Gas
```bash
sed -i -e "/^persistent_peers *=/s|=.*|= \"$PERSISTENT_PEERS\"|" $NODE_HOME/config/config.toml
sed -i -e "/^minimum-gas-prices *=/s|=.*|= \"$MINIMUM_GAS_PRICES\"|" $NODE_HOME/config/app.toml
```

### 6. Setup Systemd Service
```bash
sudo tee /etc/systemd/system/kiichaind.service > /dev/null <<EOF
[Unit]
Description=Kiichain Full Node
After=network.target

[Service]
User=$USER
ExecStart=$(which kiichaind) start --home $HOME/.kiichain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kiichaind
sudo systemctl start kiichaind
```

---

## 🧑‍🌾 Membuat Wallet & Validator

### 1. Buat Wallet Baru / Recover Wallet Lama
```bash
# Wallet baru
kiichaind keys add validator --keyring-backend test

# Recover wallet lama (sebelum upgrade)
kiichaind keys add validator_old --recover --coin-type 118 --key-type secp256k1 --keyring-backend test
```

### 2. Buat Validator
```bash
kiichaind tx staking create-validator \
  --amount=1000000000000000000000akii \
  --pubkey=$(kiichaind tendermint show-validator) \
  --moniker="moniker_anda" \
  --chain-id=$CHAIN_ID \
  --commission-rate="0.1" \
  --commission-max-rate="0.2" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --from=validator \
  --keyring-backend=test \
  --gas="auto" \
  --gas-adjustment=1.3 \
  --gas-prices="1000000000akii" -y
```

---

## 🔐 Maintenance & Keamanan

- Gunakan sentry node architecture untuk keamanan
- Backup mnemonic & export key
- Gunakan firewall + fail2ban

---

## 📡 Price Feeder Setup
```bash
wget https://raw.githubusercontent.com/KiiChain/testnets/main/testnet_oro/run_price_feeder.sh
chmod +x run_price_feeder.sh
./run_price_feeder.sh
```

---

## 🔗 OFFICIAL LINKS

### 🔮 KiiChain
- [Discord](https://discord.gg/kiichain)
- [X (Twitter)](https://x.com/KiiChainio)
- [Telegram](https://t.me/KiiChainGlobal)
- [GitHub](https://github.com/KiiChain)
- [Medium](https://medium.com/@kiichain)
- [YouTube](https://www.youtube.com/@kiichain_)
- [Instagram](https://www.instagram.com/kiichainofficial)
- [Validators Reputation Form](https://forms.gle/SQ3jQx2KvLa4HwHd8)
- [Ambassador Program](https://forms.gle/HZ242J8hAowoLorc8)

### 🌐 Kii Global
- [Website](https://kiiglobal.io)
- [LinkedIn](https://www.linkedin.com/company/kiiglobal)

### 🏦 KIIEX
- [Website](https://kiiex.io)
- [Exchange Login](https://exchange.kiiex.io/login)
- [Instagram](https://www.instagram.com/kiiexchange)
- [Twitter](https://x.com/Kiiexio)
- [YouTube](https://www.youtube.com/@kiiexchange)

---

> 📘 Panduan ini dibuat berdasarkan dokumentasi resmi Kiichain di [docs.kiiglobal.io](https://docs.kiiglobal.io/)

---

❤️ Powered by the OneNov Community | Tutorial by @OneNov0209
