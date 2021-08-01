const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:8545');
const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('../contracts/StakingRewards.json'));
const abi = contract['abi'];
const bytecode = contract['bytecode'];
//governance token
const cartallosGovernanceTokenAddress = '0x7907d0C11B358dd1229C9332D85fA22783658bD4';
//cart-pures
const cartallosGeneralTokenAddress = '0x51a255540d8c915eC9f846A00044B864Bbd672D9';
const cartBNBliquidityAddress = '0x4B65E6B685B72c9fDD3E7C0D0c8ed248b632D30b';
const gCartBNBliquidityAddress = '0xfaf63d091493C603d42E0aeDa0fd5C8ACa975069';

const cartStakeAddress = '0x54C907977dEa4970E5BAE27ff61636E605aFf320';
const cartGStakeAddress = '0xa0f4B4ad2B295be57A5F00257BFB2353b2Ab8d55';
const cartLPStakeAddress = '0x1480Ebb857509eb6af504F5e6F13438AaADD8dB8';
const cartGLPstakeAddress = '0x98Eb79973B4263Be68EfF98488Cde6e041eD9e15';

const accounts = ['0x6a2B6283AD99b412b717564c068Ab8Bd97294AC4','0x3e6E59c45c65F4Da3be7fB8bf67eef54B84B287b'];

const BEP20Json = JSON.parse(fs.readFileSync('../build/contracts/BEP20.json'));
const BEP20ABI = BEP20Json['abi'];

module.exports = async function(){
    let web3 = new Web3();
    let farmingPeriod = 600000;    //15780000; //6 months in seconds
    web3.setProvider(provider);

    let numPools = 4;
    let cartTotalSuppy = new web3.utils.BN("10000000000000000000000000"); //10 million tokens
    let cartForStakingDist = cartTotalSuppy.muln(4).divn(10); //40% for staking farming
    let cartPerPool = cartForStakingDist.divn(numPools);
    console.log(cartPerPool);


    cartallosGovernanceToken = await new web3.eth.Contract(BEP20ABI, cartallosGovernanceTokenAddress);
    cartallosGeneralToken = await new web3.eth.Contract(BEP20ABI, cartallosGeneralTokenAddress);
    cartBNBliquidityToken = await new web3.eth.Contract(BEP20ABI, cartBNBliquidityAddress);
    CartGenBNBliquidityToken = await new web3.eth.Contract(BEP20ABI, gCartBNBliquidityAddress);



    //stake carg earn
    let cartGovStake = new web3.eth.Contract(abi, cartStakeAddress);
    cartGovStake.methods.setRewardsDuration(farmingPeriod).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGovStake.methods.rewardsDuration().call().then((res) => {console.log("cartGovStake Rewards duration set: " + res)});
    cartallosGovernanceToken.methods.transfer(cartStakeAddress, cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGovStake.methods.notifyRewardAmount(cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});


    //stake carg-g e
    let cartGenStake = new web3.eth.Contract(abi, cartGStakeAddress);
    cartGenStake.methods.setRewardsDuration(farmingPeriod).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGenStake.methods.rewardsDuration().call().then((res) => {console.log("cartGenStake Rewards duration set: " + res)});
    cartallosGovernanceToken.methods.transfer(cartGStakeAddress, cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGenStake.methods.notifyRewardAmount(cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});



    //stake cart/bnb liquidity earn cart
    let cartGovLiqStake = new web3.eth.Contract(abi, cartLPStakeAddress);
    cartGovLiqStake.methods.setRewardsDuration(farmingPeriod).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGovLiqStake.methods.rewardsDuration().call().then((res) => {console.log("cartGovLiqStake Rewards duration set: " + res)});
    cartallosGovernanceToken.methods.transfer(cartLPStakeAddress, cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGovLiqStake.methods.notifyRewardAmount(cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});



    //stake cart-g/bnb liquidity earn cart
    let cartGenLiqStake = new web3.eth.Contract(abi, cartGLPstakeAddress);
    cartGenLiqStake.methods.setRewardsDuration(farmingPeriod).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGenLiqStake.methods.rewardsDuration().call().then((res) => {console.log("cartGenLiqStake Rewards duration set: " + res)});
    cartallosGovernanceToken.methods.transfer(cartGLPstakeAddress, cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});
    cartGenLiqStake.methods.notifyRewardAmount(cartPerPool).send({from: accounts[0], gas: 6721975, gasPrice: '20000000000'});



};

