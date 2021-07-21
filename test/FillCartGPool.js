const BN = require('bn.js');
const Web3 = require('web3');
const fs = require('fs');

const provider = new Web3.providers.HttpProvider('http://localhost:8545');

const wBNBAddress = '0x6DFAFB92fafA78E82802fFA07CCCE1dcD05Ec9de';
const bTCAddress = '0x54824f67455A05Cad7b0751c4715e46C2aa226C2';
const eTHAddress = '0xe778f496CE179f3895Fb10E040E4dA85A31e2724';
const cartGovAddress = '0x7907d0C11B358dd1229C9332D85fA22783658bD4';
const cartCoreAddress = '0x51a255540d8c915eC9f846A00044B864Bbd672D9';
const uniswapAddress = '0x68eA183eDbfc146407af1672D2d1cc351c2fb5b8';
const owner = '0x6a2B6283AD99b412b717564c068Ab8Bd97294AC4';
const account = '0x3e6E59c45c65F4Da3be7fB8bf67eef54B84B287b';

const wBNBJson = JSON.parse(fs.readFileSync('../contracts/TestTokens/WBNB.json'));
const wBNBAbi = wBNBJson['abi'];

const eTHJson = JSON.parse(fs.readFileSync('../build/contracts/ETH.json'));
const eTHAbi = eTHJson['abi'];

const bTCJson = JSON.parse(fs.readFileSync('../build/contracts/BTC.json'));
const bTCAbi = bTCJson['abi'];

const cartGovJson = JSON.parse(fs.readFileSync('../build/contracts/Cartallos.json'));
const cartGovAbi = cartGovJson['abi'];

const uniswapJson = require('../contracts/TestTokens/UniswapV2Router02.json');
const uniswapAbi = uniswapJson['abi'];

const cartallosJson = require('../build/contracts/CartallosCore.json');
const cartallosAbi = cartallosJson['abi'];


const wei2eth = web3.utils.toBN('1000000000000000000');

module.exports = function(){
    async function fillPools(callback){
        let web3 = new Web3();
        web3.setProvider(provider);
        wBNB = await new web3.eth.Contract(wBNBAbi, wBNBAddress);
        eTH = await new web3.eth.Contract(eTHAbi, eTHAddress);
        bTC = await new web3.eth.Contract(bTCAbi, bTCAddress);
        cartCore = await new web3.eth.Contract(cartallosAbi, cartCoreAddress);
        uniswap = await new web3.eth.Contract(uniswapAbi, uniswapAddress);

        //fill the cartallos general pool
        wBNB.methods.deposit().send({from: account, value: 20000000000000000000}).then(function(wBNBDeposit){
                wBNB.methods.approve(uniswapAddress, (wei2eth.mul(web3.utils.toBN('20')))).send({from: account}).then(function(approved){
                    cartCore.methods.approve(uniswapAddress, (wei2eth.mul(web3.utils.toBN('10')))).send({from: account}).then(function(cgapp){
                            uniswap.methods.addLiquidity(cartCoreAddress, wBNBAddress, (wei2eth.mul(web3.utils.toBN('5'))), (wei2eth), (2000000000000000), (2000000000000000), account, 1651311457).send({from: account, gas: 6721975, gasPrice: '20000000000'});
                        })
                    })

        }).catch(function(err){
                console.log("error: " + err.message);
            });
    }
    fillPools();
}
