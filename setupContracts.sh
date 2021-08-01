#!/bin/bash
echo "Deploying contracts"
truffle deploy
echo "Filling Default Pools"
truffle exec ./test/FillPools.js
echo "minting index tokens"
truffle exec ./test/mint.js
echo "Filling index token pools"
truffle exec ./test/FillCartGPool.js
echo "Setting up staking pools"
truffle exec test/SetupStakingPools.js
echo "Filling Presale Contract"
truffle exec test/SetupPresale.js
echo "creating snapshot"
curl -H "Content-Type: application/json" -X POST --data \
        '{"id":1337,"jsonrpc":"2.0","method":"evm_snapshot","params":[]}' \
        http://localhost:8545
