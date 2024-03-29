
const { assert } = require('chai')
const ganache = require("ganache-cli"); //a bunch of imports, some probably arent necessary
const Web3 = require("web3");
const provider = ganache.provider();
const web3 = new Web3(provider);


const CartallosGeneral = artifacts.require('CartallosGeneral')
const DerpCoin = artifacts.require('DerpCoin')

const timeMachine = require('ganache-time-traveler');

const BN = require('bn.js');

const truffleAssert = require('truffle-assertions');

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

contract('Cartallos General Token Tests', (accounts) => {

    describe('Dummy erc20 tests', async () => {

        it('Can mint at correct ratio', async () => {
            let derr1 = await DerpCoin.new()
            let derr2 = await DerpCoin.new()
            let derr3 = await DerpCoin.new()
            let derr4 = await DerpCoin.new()
            let derr5 = await DerpCoin.new()
            let derr6 = await DerpCoin.new()
            let derr7 = await DerpCoin.new()
            let derr8 = await DerpCoin.new()

            let CartallosGeneralToken = await CartallosGeneral.new()
            await CartallosGeneralToken.setassetTESTINGONLY(derr1.address, 1, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr2.address, 2, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr3.address, 3, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr4.address, 4, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr5.address, 5, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr6.address, 6, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr7.address, 7, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr8.address, 8, 10 * 1000000000);

            await derr1.mint(wei2eth.mul(web3.utils.toBN('10')))
            let number = await derr1.balanceOf(accounts[0])
            dprint(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth.mul(web3.utils.toBN('10')));

            await derr2.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr3.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr4.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr5.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr6.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr7.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr8.mint(wei2eth.mul(web3.utils.toBN('10')))

            await derr1.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr2.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr3.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr4.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr5.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr6.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr7.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr8.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))

            await CartallosGeneralToken.mint(wei2eth);

            number = await CartallosGeneralToken.balanceOf(accounts[0])
            dprint(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth);
        })


        it('cannot mint if assets provided are not correct ratio', async () => {
            console.log("hi")
            let derr1 = await DerpCoin.new()
            let derr2 = await DerpCoin.new()
            let derr3 = await DerpCoin.new()
            let derr4 = await DerpCoin.new()
            let derr5 = await DerpCoin.new()
            let derr6 = await DerpCoin.new()
            let derr7 = await DerpCoin.new()
            let derr8 = await DerpCoin.new()

            let CartallosGeneralToken = await CartallosGeneral.new()
            await CartallosGeneralToken.setassetTESTINGONLY(derr1.address, 1, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr2.address, 2, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr3.address, 3, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr4.address, 4, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr5.address, 5, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr6.address, 6, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr7.address, 7, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr8.address, 8, 10 * 1000000000);

            await derr1.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr2.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr3.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr4.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr5.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr6.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr7.mint(wei2eth.mul(web3.utils.toBN('20')))
            await derr8.mint(wei2eth.mul(web3.utils.toBN('20')))

            await derr1.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr2.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr3.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr4.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr5.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr7.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))
            await derr8.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('20')))

            await truffleAssert.reverts(
                CartallosGeneralToken.mint(wei2eth.mul(web3.utils.toBN('300')))
            )

            await logAccountBalances(accounts, 1, derr1)

            number = await CartallosGeneralToken.balanceOf(accounts[0])
            dprint(number.toString())
            number.should.be.a.bignumber.that.equal(web3.utils.toBN('0'));

        })

        it('burn correctly gives back assets minus devfee', async () => {
            let derr1 = await DerpCoin.new()
            let derr2 = await DerpCoin.new()
            let derr3 = await DerpCoin.new()
            let derr4 = await DerpCoin.new()
            let derr5 = await DerpCoin.new()
            let derr6 = await DerpCoin.new()
            let derr7 = await DerpCoin.new()
            let derr8 = await DerpCoin.new()

            let CartallosGeneralToken = await CartallosGeneral.new()
            await CartallosGeneralToken.setassetTESTINGONLY(derr1.address, 1, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr2.address, 2, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr3.address, 3, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr4.address, 4, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr5.address, 5, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr6.address, 6, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr7.address, 7, 10 * 1000000000);
            await CartallosGeneralToken.setassetTESTINGONLY(derr8.address, 8, 10 * 1000000000);

            await derr1.mint(wei2eth.mul(web3.utils.toBN('10')))
            let number = await derr1.balanceOf(accounts[0])
            dprint(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth.mul(web3.utils.toBN('10')));

            await derr2.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr3.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr4.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr5.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr6.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr7.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr8.mint(wei2eth.mul(web3.utils.toBN('10')))

            await derr1.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr2.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr3.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr4.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr5.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr6.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr7.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr8.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))

            await CartallosGeneralToken.mint(wei2eth);

            number = await CartallosGeneralToken.balanceOf(accounts[0])
            dprint("Balance after mint cartallos: " + number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth);

            await CartallosGeneralToken.burn(wei2eth);
            number = await CartallosGeneralToken.balanceOf(accounts[0])
            dprint("Balance after burn in cartallos: " + number.toString())
            number.should.be.a.bignumber.that.equal(web3.utils.toBN("0"));

            number = await derr1.balanceOf(accounts[0])
            dprint("Balance after burn in asset1: " + number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth.mul(web3.utils.toBN('10')).sub(web3.utils.toBN('10000000000000000')));

        })

        it('burn correctly gives back assets minus devfee when from different address', async () => {
            dprint("here1")
            let derr1 = await DerpCoin.new()
            let derr2 = await DerpCoin.new()
            let derr3 = await DerpCoin.new()
            let derr4 = await DerpCoin.new()
            let derr5 = await DerpCoin.new()
            let derr6 = await DerpCoin.new()
            let derr7 = await DerpCoin.new()
            let derr8 = await DerpCoin.new()
            dprint("here1")
            let CartallosGeneralToken = await CartallosGeneral.new({from: accounts[2]})
            dprint("here2")
            await CartallosGeneralToken.setassetTESTINGONLY(derr1.address, 1, 10 * 1000000000, {from: accounts[2], gas: "2000000"});
            await CartallosGeneralToken.setassetTESTINGONLY(derr2.address, 2, 10 * 1000000000, {from: accounts[2], gas: "2000000"});
            await CartallosGeneralToken.setassetTESTINGONLY(derr3.address, 3, 10 * 1000000000, {from: accounts[2], gas: "2000000"});
            await CartallosGeneralToken.setassetTESTINGONLY(derr4.address, 4, 10 * 1000000000, {from: accounts[2], gas: "2000000"});
            await CartallosGeneralToken.setassetTESTINGONLY(derr5.address, 5, 10 * 1000000000, {from: accounts[2], gas: "2000000"});
            await CartallosGeneralToken.setassetTESTINGONLY(derr6.address, 6, 10 * 1000000000, {from: accounts[2], gas: "2000000"});
            await CartallosGeneralToken.setassetTESTINGONLY(derr7.address, 7, 10 * 1000000000, {from: accounts[2], gas: "2000000"});
            await CartallosGeneralToken.setassetTESTINGONLY(derr8.address, 8, 10 * 1000000000, {from: accounts[2], gas: "2000000"});

            await derr1.mint(wei2eth.mul(web3.utils.toBN('10')))
            let number = await derr1.balanceOf(accounts[0])
            dprint(number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth.mul(web3.utils.toBN('10')));

            await derr2.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr3.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr4.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr5.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr6.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr7.mint(wei2eth.mul(web3.utils.toBN('10')))
            await derr8.mint(wei2eth.mul(web3.utils.toBN('10')))

            await derr1.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr2.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr3.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr4.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr5.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr6.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr7.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))
            await derr8.approve(CartallosGeneralToken.address, wei2eth.mul(web3.utils.toBN('10')))

            await CartallosGeneralToken.mint(wei2eth);

            number = await CartallosGeneralToken.balanceOf(accounts[0])
            dprint("Balance after mint cartallos: " + number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth);

            await CartallosGeneralToken.burn(wei2eth);
            number = await CartallosGeneralToken.balanceOf(accounts[0])
            dprint("Balance after burn in cartallos: " + number.toString())
            number.should.be.a.bignumber.that.equal(web3.utils.toBN("0"));

            number = await derr1.balanceOf(accounts[0])
            dprint("Balance after burn in asset1: " + number.toString())
            number.should.be.a.bignumber.that.equal(wei2eth.mul(web3.utils.toBN('10')).sub(web3.utils.toBN('10000000000000000')));

            await CartallosGeneralToken.collectDevFunds(web3.utils.toBN("1000000000000000"), {from: accounts[2], gas: "2000000"})
            number = await derr1.balanceOf(accounts[2])
            dprint("Balance in dev acc after dev collect in asset1: " + number.toString())
            number.should.be.a.bignumber.that.equal(web3.utils.toBN('10000000000000000'));


        })

    })
})