

# State-Determinism Test for Cosmos EVM

This repository provides an automated setup for testing **state determinism** across two versions of the `evmd` binary (main vs. modified). The test environment runs a 2-node local network and sends identical transactions to both nodes to verify whether their final states match.

---

## ✅ Purpose

To verify whether a proposed modification to the `evmd` codebase affects the **determinism of state transitions**.  
We compare the resulting app states of:

- `evmd-main`: built from the `main` branch
- `evmd-modified`: built from a custom feature or experimental branch

---

## ⚙️ Setup Instructions

### 1. Clone and prepare

Just copy the scripts below into your repo cosmos/evm/scripts

 - scripts/build-evmds.sh
 - scripts/start_main.sh
 - scripts/start_modified.sh


```bash
mkdir bin/evmd-main
mkdir bin/evmd-modified
```

### 2. Build both binaries

Use the provided script to build both versions of the evmd binary:
```
./build_evmds.sh "your-branch-name"
```
(e.g. ``./build_evmd_pair.sh feat/evm-recycle``)

This will:
- Checkout main → make install → copy to ../bin/evmd-main
- Checkout feat/evm-recycle → make install → copy to ../bin/evmd-modified

⸻

### 3. Initialize and connect 2-node network

Use the custom shell script:
```
./start_main.sh   # Start node0 using evmd-main
```
```
./start_modified.sh   # Start node1 using evmd-modified
```

This script will:
- Initialize each node with evmd init
- Copy the genesis file from node0
- Assign unique ports
- Automatically inject persistent peer connection to node0
- Set chain ID and other config (e.g., client.toml, RPC, P2P, Prometheus)

⸻

🧪 Running the Test
1. Start both nodes
2. Use your TX-sending tool to submit identical transactions to both nodes
  ( ```surge run``` )
3. Wait until transactions are committed
4. Compare state root hashes or evmd query output from both nodes

⸻

📌 State Comparison Example

# Query app hash or block state
curl localhost:26657/commit
curl localhost:26667/commit

Or use:

evmd query bank balances <address> --home node0
evmd query bank balances <address> --home node1


⸻


🧠 Notes
- All nodes must share the exact same genesis.json
- Ensure that only one side initiates a P2P connection to avoid duplicate handshake issues
- pprof, Prometheus, and ports are all automatically deconflicted based on node ID
- **To enable in v0.3 release version, just modified part of build_evmds.sh like below**
  ```
  # original
  ...
  jq '.app_state.erc20.params.native_precompiles=["0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"]' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
  ...
  # modified
  ...
  jq '.app_state.erc20.native_precompiles=["0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"]' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
  ...

  ```

