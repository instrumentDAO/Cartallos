#!/bin/bash
echo "Deploying contracts"
truffle deploy
echo "Filling Default Pools"
truffle exec ./test/FillPools.js
echo "minting index tokens"
truffle exec ./test/mint.js
echo "Filling index token pools"
truffle exec ./test/FillCartGPool.js