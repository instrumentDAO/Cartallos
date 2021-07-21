$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = "{`"id`":1337,`"jsonrpc`":`"2.0`",`"method`":`"evm_revert`",`"params`":[`"0x1`"]}"

$response = Invoke-RestMethod 'http://localhost:8545' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json