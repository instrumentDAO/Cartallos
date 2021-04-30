const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('../contracts/TestTokens/UniswapV2Router02.json'));
const abi = contract['abi'];
const bytecode = contract['bytecode'];

module.exports = function(deployer, network, accounts) {
    let web3 = new Web3();
    web3.setProvider(provider);
    let wBNB = new web3.eth.Contract(abi);
    wBNB.deploy({data: bytecode, arguments: ["0x9D85A0F7F986013D5cA371CCf35730E77CfA22b2", "0x6DFAFB92fafA78E82802fFA07CCCE1dcD05Ec9de"]}).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'}).then(
        function(result){
            console.log(result.options.address);
        }
    );
};