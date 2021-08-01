const BN = require('bn.js');
const Web3 = require('web3');
const fs = require('fs');

const provider = new Web3.providers.HttpProvider('http://localhost:8545');


const cartallosAddress = '0x7907d0C11B358dd1229C9332D85fA22783658bD4';
const presaleAddress = '0x15dcB51aeFd6081771332E046777f500fc1F18F4';
const owner = '0x6a2B6283AD99b412b717564c068Ab8Bd97294AC4';




const cartallosJson = require('../build/contracts/CartallosCore.json');
const cartallosAbi = cartallosJson['abi'];
const presaleJson = require('../build/contracts/Presale.json');
const presaleAbi = cartallosJson['abi'];

const presaleTokens = "550000000000000000000000"; //550,000 token for presale

const wei2eth = web3.utils.toBN('1000000000000000000');

module.exports = function () {
    async function setupPresale(callback) {
        let web3 = new Web3();
        web3.setProvider(provider);
        cartallos = await new web3.eth.Contract(cartallosAbi, cartallosAddress);
        //cartallos.methods.balanceOf(owner).call().then((res) => { console.log(res)})
        cartallos.methods.transfer(presaleAddress, presaleTokens).send({from: owner}).then((presale) => {
            console.log("Transfered tokens to presale: " + presale);
            console.log("Presale contains " + presaleTokens + " wei");
        }).catch(function (err) {
            console.log("error: " + err.message);
        })
    }
    setupPresale();
}