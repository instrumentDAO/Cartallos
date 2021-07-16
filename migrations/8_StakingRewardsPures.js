const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('../contracts/StakingRewards.json'));
const abi = contract['abi'];
const bytecode = contract['bytecode'];
//governance token
const rewardsToken = '0x7907d0C11B358dd1229C9332D85fA22783658bD4';
//cart-pures
const stakingToken = '0x51a255540d8c915eC9f846A00044B864Bbd672D9';

module.exports = function(deployer, network, accounts) {
    let web3 = new Web3();
    web3.setProvider(provider);
    let stakingRewards = new web3.eth.Contract(abi);
    stakingRewards.deploy({data: bytecode, arguments: [accounts[0], accounts[0], rewardsToken, stakingToken]}).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'}).then(
        function(result){
            console.log(result.options.address);
        }
    );
};