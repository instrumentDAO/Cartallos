const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('../contracts/TestTokens/WBNB.json'));
const abi = contract['abi'];
const bytecode = contract['bytecode'];

module.exports = function(deployer, network, accounts) {
    let web3 = new Web3();
    web3.setProvider(provider);
    let wBNB = new web3.eth.Contract(abi);
    wBNB.deploy({data: bytecode}).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'}).then(
        function(result){
            console.log(result.options.address);
        }
    );
};