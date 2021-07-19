const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('../contracts/StakingRewards.json'));
const abi = contract['abi'];
const bytecode = contract['bytecode'];
//governance token
const cartallosGovernanceToken = '0x7907d0C11B358dd1229C9332D85fA22783658bD4';
//cart-pures
const cartallosGeneralToken = '0x51a255540d8c915eC9f846A00044B864Bbd672D9';
const cartBNBliquidityAddress = '0x4B65E6B685B72c9fDD3E7C0D0c8ed248b632D30b';
const gCartBNBliquidityAddress = '0xfaf63d091493C603d42E0aeDa0fd5C8ACa975069';

module.exports = function(deployer, network, accounts) {
    let web3 = new Web3();
    let farmingPeriod = 15780000; //6 months in seconds
    web3.setProvider(provider);

    //stake carg-g earn cart
    let cartGenStake = new web3.eth.Contract(abi);
    cartGenStake.deploy({data: bytecode, arguments: [accounts[0], accounts[0], cartallosGovernanceToken, cartallosGeneralToken]}).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'}).then(
        function(result){
            console.log("cg " + result.options.address);
        }
    );

    //stake carg earn cart
    let cartGovStake = new web3.eth.Contract(abi);
    cartGovStake.deploy({data: bytecode, arguments: [accounts[0], accounts[0], cartallosGovernanceToken, cartallosGovernanceToken]}).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'}).then(
        function(result){
            console.log("c " + result.options.address);
        }
    );

    //stake cart/bnb liquidity earn cart
    let cartGovLiqStake = new web3.eth.Contract(abi);
    cartGovLiqStake.deploy({data: bytecode, arguments: [accounts[0], accounts[0], cartallosGovernanceToken, cartBNBliquidityAddress]}).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'}).then(
        function(result){
            console.log("clp " + result.options.address);
        }
    );

    //stake cart-g/bnb liquidity earn cart
    let cartGenLiqStake = new web3.eth.Contract(abi);
    cartGenLiqStake.deploy({data: bytecode, arguments: [accounts[0], accounts[0], cartallosGovernanceToken, gCartBNBliquidityAddress]}).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'}).then(
        function(result){
            console.log("cglp " + result.options.address);
        }
    );
};