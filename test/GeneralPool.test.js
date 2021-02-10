
const { assert } = require('chai')
const ganache = require("ganache-cli"); //a bunch of imports, some probably arent necessary
const Web3 = require("web3");
const provider = ganache.provider();
const web3 = new Web3(provider);


const DiversifyGeneral = artifacts.require('DiversifyGeneral')
const DiversifyGovernance = artifacts.require('DiversifyGovernance')
const DerpCoin = artifacts.require('DerpCoin')

const timeMachine = require('ganache-time-traveler');

const BN = require('bn.js');

const chai = require('chai') //chai is an assertion library
chai.use(require('chai-bn')(BN), require('chai-as-promised'))
//chai.use(require('chai-as-promised')) //chai does assertions for asynchronous behaviour
chai.should() // tells chai how to behave or something


const ERROR_MSG = 'VM Exception while processing transaction: revert';

const debug = true;

const wei2eth = web3.utils.toBN('1000000000000000000');

const logAccountBalances = async function(accounts, numToFetch, tokenContract, title = "account balances") {
    if (debug){
        console.log(title)
        let tokenName = await tokenContract.name()
        for (let i = 0; i < numToFetch; i++) {
            let balance = await tokenContract.balanceOf(accounts[i])
            console.log("Account " + i + " balance of " + tokenName + " : " + balance)
        }
        console.log("\n")
    }
}

const dprint = function(message){
    if (debug){
        console.log(message);
    }
}

contract('Diversify General Token Tests', (accounts) => {

    describe('Dummy erc20 tests', async () => {
        /*
        it('Can mint at correct ratio', async () => {
            let derr1 = await DerpCoin.new()
            let derr2 = await DerpCoin.new()
            let derr3 = await DerpCoin.new()
            let derr4 = await DerpCoin.new()
            let derr5 = await DerpCoin.new()
            let derr6 = await DerpCoin.new()
            let derr7 = await DerpCoin.new()
            let derr8 = await DerpCoin.new()

            let DiversifyGeneralToken = await DiversifyGeneral.new()
            await DiversifyGeneralToken.setassetTESTINGONLY(derr1.address, 1);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr2.address, 2);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr3.address, 3);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr4.address, 4);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr5.address, 5);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr6.address, 6);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr7.address, 7);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr8.address, 8);

            await derr1.mint(wei2eth.mul(web3.utils.toBN('10')))
            let number = await derr1.balanceOf(accounts[0])
            console.log(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth.mul(web3.utils.toBN('10')));

            await derr2.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr3.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr4.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr5.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr6.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr7.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr8.mint(wei2eth.mul(web3.utils.toBN('10')))

            await derr1.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr2.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr3.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr4.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr5.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr6.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr7.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr8.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))

            await DiversifyGeneralToken.mint(wei2eth);

            number = await DiversifyGeneralToken.balanceOf(accounts[0])
            console.log(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth);
        })
        */

        it('cannot mint if assets provided are not correct ratio', async () => {
            let derr1 = await DerpCoin.new()
            let derr2 = await DerpCoin.new()
            let derr3 = await DerpCoin.new()
            let derr4 = await DerpCoin.new()
            let derr5 = await DerpCoin.new()
            let derr6 = await DerpCoin.new()
            let derr7 = await DerpCoin.new()
            let derr8 = await DerpCoin.new()

            let DiversifyGeneralToken = await DiversifyGeneral.new()
            await DiversifyGeneralToken.setassetTESTINGONLY(derr1.address, 1, 10 * 1000000000);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr2.address, 2, 10 * 1000000000);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr3.address, 3, 10 * 1000000000);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr4.address, 4, 10 * 1000000000);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr5.address, 5, 10 * 1000000000);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr6.address, 6, 10 * 1000000000);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr7.address, 7, 10 * 1000000000);
            await DiversifyGeneralToken.setassetTESTINGONLY(derr8.address, 8, 10 * 1000000000);

            await derr1.mint(wei2eth.mul(web3.utils.toBN('20')))
            let number = await derr1.balanceOf(accounts[0])
            console.log(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth.mul(web3.utils.toBN('10')));

            await derr2.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr3.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr4.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr5.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr6.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr7.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr8.mint(wei2eth.mul(web3.utils.toBN('20')))

            await derr1.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr2.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr3.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr4.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr5.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr7.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr8.approve(DiversifyGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))

            await DiversifyGeneralToken.mint(wei2eth.mul(web3.utils.toBN('2')));

            number = await DiversifyGeneralToken.balanceOf(accounts[0])
            console.log(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth);
            
        })
    })
})