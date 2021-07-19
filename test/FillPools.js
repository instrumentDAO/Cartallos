const BN = require('bn.js');
const Web3 = require('web3');
const fs = require('fs');

const provider = new Web3.providers.HttpProvider('http://localhost:8545');

const wBNBAddress = '0x6DFAFB92fafA78E82802fFA07CCCE1dcD05Ec9de';
const eTHAddress = '0x54824f67455A05Cad7b0751c4715e46C2aa226C2';
const bTCAddress = '0xe778f496CE179f3895Fb10E040E4dA85A31e2724';
const cartGovAddress = '0x7907d0C11B358dd1229C9332D85fA22783658bD4';
const uniswapAddress = '0x68eA183eDbfc146407af1672D2d1cc351c2fb5b8';
const uniswapFactoryAddress = '0x9D85A0F7F986013D5cA371CCf35730E77CfA22b2';
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

const uniswapFactoryJson = require('../contracts/TestTokens/UniswapV2Factory.json');
const uniswapFactoryAbi = uniswapFactoryJson['abi'];

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
        cartGov = await new web3.eth.Contract(cartGovAbi, cartGovAddress);
        uniswap = await new web3.eth.Contract(uniswapAbi, uniswapAddress);
        uniswapFactory = await new web3.eth.Contract(uniswapFactoryAbi, uniswapFactoryAddress);

        // fill the pools for eth/bnb and btc/bnb
        wBNB.methods.deposit().send({from: owner, value: 20000000000000000000}).then(function(wBNBDeposit){
            eTH.methods.mint((wei2eth.mul(web3.utils.toBN('100')))).send({from: owner}).then(function(eTHMint){
                bTC.methods.mint((wei2eth.mul(web3.utils.toBN('100')))).send({from: owner}).then(function(bTCMint){
                    eTH.methods.approve(uniswapAddress, (wei2eth.mul(web3.utils.toBN('10')))).send({from: owner});
                    bTC.methods.approve(uniswapAddress, (wei2eth.mul(web3.utils.toBN('10')))).send({from: owner});
                    wBNB.methods.approve(uniswapAddress, (wei2eth.mul(web3.utils.toBN('20')))).send({from: owner}).then(function(approved){
                        uniswap.methods.addLiquidity(eTHAddress, wBNBAddress, (wei2eth), (wei2eth), (2000000000000000), (2000000000000000), owner, 1651311457).send({from: owner, gas: 6721975, gasPrice: '20000000000'});
                        uniswap.methods.addLiquidity(bTCAddress, wBNBAddress, (wei2eth), (wei2eth), (2000000000000000), (2000000000000000), owner, 1651311457).send({from: owner, gas: 6721975, gasPrice: '20000000000'}).then(function(liquidityFilled){
                            uniswapFactory.methods.getPair(eTHAddress, wBNBAddress).call().then( (res) => {
                                console.log("Eth/BNB liquidity token: " + res);
                            })
                            uniswapFactory.methods.getPair(bTCAddress, wBNBAddress).call().then( (res) => {
                                console.log("BTC/BNB liquidity token: " + res);
                            })
                            console.log(liquidityFilled);
                        })
                    })
                })
                        })


            //fill the cartallos governance pool
            wBNB.methods.deposit().send({from: account, value: 20000000000000000000}).then(function(wBNBDeposit){
                    wBNB.methods.approve(uniswapAddress, (wei2eth.mul(web3.utils.toBN('20')))).send({from: account}).then(function(approved){
                        cartGov.methods.approve(uniswapAddress, (wei2eth.mul(web3.utils.toBN('10')))).send({from: account}).then(function(cgapp){
                                uniswap.methods.addLiquidity(cartGovAddress, wBNBAddress, (wei2eth), (wei2eth), (2000000000000000), (2000000000000000), account, 1651311457).send({from: account, gas: 6721975, gasPrice: '20000000000'}).then( () => {
                                    uniswapFactory.methods.getPair(cartGovAddress, wBNBAddress).call().then( (res) => {
                                        console.log("CART/BNB liquidity token: " + res);
                                    })
                                });
                            })
                        })
                })
        }).catch(function(err){
                console.log("error: " + err.message);
            });
    }
    fillPools();
}
