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

echo "creating snapshot"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = "{`"id`":1337,`"jsonrpc`":`"2.0`",`"method`":`"evm_snapshot`",`"params`":[]}"

$response = Invoke-RestMethod 'http://localhost:8545' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json