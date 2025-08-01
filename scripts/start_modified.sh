#!/bin/bash

# ✅ 사용법: ./start.sh 
# ----------------------------------

NODE_ID="1"
CHAIN_ID="local-4221"
#EVMDBIN="./bin/evmd-main/evmd"
EVMDBIN="./bin/evmd-modified/evmd"
BASE_HOME="evmd-local/.testnets"
NODE_HOME="$BASE_HOME/node$NODE_ID"
NODE0_HOME="$BASE_HOME/node0"
KEYRING="test"
CLIENT_TOML=$NODE_HOME/config/client.tom
LOGLEVEL="info"

P2P_PORT=$((26656 + NODE_ID * 10))
RPC_PORT=$((26657 + NODE_ID * 10))
PROXY_APP=$((26658 + NODE_ID * 10))
PROME_PORT=$((26660 + NODE_ID * 10))

if [ -z "$NODE_ID" ]; then
  echo "❌ NODE_ID를 인자로 전달해주세요. 예: ./init_and_connect.sh 3"
  exit 1
fi


# 1. node0의 node-id 가져오기
NODE0_ID=$($EVMDBIN tendermint show-node-id --home "$NODE0_HOME")

# 2. 기존 디렉토리 삭제 및 init
rm -rf "$NODE_HOME"
$EVMDBIN init "node$NODE_ID" --chain-id "$CHAIN_ID" --home "$NODE_HOME"

# 3. node0의 genesis.json 복사
cp "$NODE0_HOME/config/genesis.json" "$NODE_HOME/config/genesis.json"

# 4. 포트 설정 및 persistent_peers 지정
CONFIG="$NODE_HOME/config/config.toml"
APP_TOML="$NODE_HOME/config/app.toml"

# P2P, RPC 포트 설정
# p2p.laddr 설정 (정확히 [p2p] 안에서만)
sed -i.bak "/^\[p2p\]/,/^\[.*\]/ s|^laddr *=.*|laddr = \"tcp://0.0.0.0:$P2P_PORT\"|" "$CONFIG"

# rpc.laddr 설정 (정확히 [rpc] 안에서만)
sed -i.bak "/^\[rpc\]/,/^\[.*\]/ s|^laddr *=.*|laddr = \"tcp://127.0.0.1:$RPC_PORT\"|" "$CONFIG"
# chain-id 설정
sed -i.bak "s|^chain-id *=.*|chain-id = \"$CHAIN_ID\"|" "$CLIENT_TOML"

# persistent_peers 설정
sed -i.bak "s|^persistent_peers *=.*|persistent_peers = \"$NODE0_ID@127.0.0.1:26656\"|" "$CONFIG"
sed -i.bak "s|^proxy_app *=.*|proxy_app = \"tcp://127.0.0.1:$PROXY_APP\"|" "$CONFIG"

sed -i.bak "s|^prometheus_listen_addr *=.*|prometheus_listen_addr = \":$PROME_PORT\"|" "$CONFIG"


# RPC 포트 및 gas 설정

#sed -i.bak "s|^laddr *=.*|laddr = \"tcp://127.0.0.1:$RPC_PORT\"|" "$APP_TOML"
#sed -i.bak "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0001atest\"|" "$APP_TOML"

exec $EVMDBIN start "$TRACE"\
  --log_level "$LOGLEVEL" \
  --minimum-gas-prices=0.0001atest \
  --home "$NODE_HOME" \
  --json-rpc.api eth,txpool,personal,net,debug,web3 \
  --chain-id "$CHAIN_ID"