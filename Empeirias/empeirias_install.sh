#!/bin/bash
source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/common.sh)

# Replace the original logo with ONENOV logo
function printLogo() {
  echo -e "\033[0;36m"
  echo ' ██████╗ ███╗   ██╗███████╗███╗   ██╗ ██████╗ ██╗   ██╗'
  echo '██╔═══██╗████╗  ██║██╔════╝████╗  ██║██╔═══██╗██║   ██║'
  echo '██║   ██║██╔██╗ ██║█████╗  ██╔██╗ ██║██║   ██║██║   ██║'
  echo '██║   ██║██║╚██╗██║██╔══╝  ██║╚██╗██║██║   ██║╚██╗ ██╔╝'
  echo '╚██████╔╝██║ ╚████║███████╗██║ ╚████║╚██████╔╝ ╚████╔╝'
  echo ' ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝'
  echo -e "\033[0m"
}

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${EMPED_PORT}317%g;
s%:8080%:${EMPED_PORT}080%g;
s%:9090%:${EMPED_PORT}090%g;
s%:9091%:${EMPED_PORT}091%g;
s%:8545%:${EMPED_PORT}545%g;
s%:8546%:${EMPED_PORT}546%g;
s%:6065%:${EMPED_PORT}065%g" $HOME/.empe-chain/config/app.toml


# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${EMPED_PORT}658%g;
s%:26657%:${EMPED_PORT}657%g;
s%:6060%:${EMPED_PORT}060%g;
s%:26656%:${EMPED_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${EMPED_PORT}656\"%;
s%:26660%:${EMPED_PORT}660%g" $HOME/.empe-chain/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.empe-chain/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.0001uempe"|g' $HOME/.empe-chain/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.empe-chain/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.empe-chain/config/config.toml
sleep 1
echo done

# create service file
sudo tee /etc/systemd/system/emped.service > /dev/null <<EOF
[Unit]
Description=empeiria node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.empe-chain
ExecStart=$(which emped) start --home $HOME/.empe-chain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

printGreen "8. Downloading snapshot and starting node..." && sleep 1
# reset and download snapshot
emped tendermint unsafe-reset-all --home $HOME/.empe-chain
if curl -s --head curl https://server-5.itrocket.net/testnet/empeiria/empeiria_2025-03-29_4243880_snap.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://server-5.itrocket.net/testnet/empeiria/empeiria_2025-03-29_4243880_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.empe-chain
    else
  echo "no snapshot found"
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable emped
sudo systemctl restart emped && sudo journalctl -u emped -f -o cat
