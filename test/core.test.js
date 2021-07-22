const BN = require("bn.js");
const chai = require("chai");
const expect = chai.expect;
chai.use(require('chai-as-promised'));
chai.use(require('chai-bn')(BN));

const CartCore = artifacts.require("CartallosCore");
const ETH = artifacts.require("ETH");
const BTC = artifacts.require("BTC");

const wBNBAddress = '0x6DFAFB92fafA78E82802fFA07CCCE1dcD05Ec9de';
const bTCAddress = '0x54824f67455A05Cad7b0751c4715e46C2aa226C2';
const eTHAddress = '0xe778f496CE179f3895Fb10E040E4dA85A31e2724';
const uniswapAddress = '0x68eA183eDbfc146407af1672D2d1cc351c2fb5b8';
const uniswapJson = require('../contracts/TestTokens/UniswapV2Router02.json');
const uniswapAbi = uniswapJson['abi'];

const gweiUnits = web3.utils.toBN('1000000000');
const wei2eth = web3.utils.toBN('1000000000000000000');

const UINT256MAX = '115792089237316195423570985008687907853269984665640564039457584007913129639935';

contract("CartCore", async accounts => {

    //mint appropriately
    it("should mint appropriate values", async () => {
        const amount = wei2eth;
        const slippageNum = "20";

        const core = await CartCore.deployed();

        const uniswap = await new web3.eth.Contract(uniswapAbi, uniswapAddress);
        const btcPerToken = await core.btcPerToken();
        const ethPerToken = await core.ethPerToken();
        const wbnbPerToken = await core.wbnbPerToken();
        const btcAmounts = await uniswap.methods.getAmountsIn(btcPerToken, [wBNBAddress, bTCAddress]).call();
        const btcCost = web3.utils.toBN(btcAmounts[0]);
        const ethAmounts = await uniswap.methods.getAmountsIn(ethPerToken, [wBNBAddress, eTHAddress]).call();
        const ethCost = web3.utils.toBN(ethAmounts[0]);
        const amountCost = btcCost.add(ethCost).add(wbnbPerToken);

        var slippage = new web3.utils.BN(slippageNum);
        var slippageTimesAmount = slippage.mul(amountCost);
        var slippageTotal = new web3.utils.BN(slippageTimesAmount.divn(web3.utils.toBN(100)));
        var costPlusSlippage = slippageTotal.add(amountCost);

        const mint = await core.mint(amount, 1652427671, { from: accounts[0], value: costPlusSlippage });

        const balance = await core.balanceOf(accounts[0], { from: accounts[0] });
        expect(balance).to.eql(amount);
        const btcBal = await core.btcTotalBal();
        expect(btcBal).to.eql(btcPerToken);
    });

    //burn appropriately
    it("should burn assets at correct rates", async () => {
        const core = await CartCore.deployed();
        const amount = wei2eth;
        const slippageNum = '20';

        const uniswap = await new web3.eth.Contract(uniswapAbi, uniswapAddress);
        const btcPerToken = await core.btcPerToken();
        const ethPerToken = await core.ethPerToken();
        const wbnbPerToken = await core.wbnbPerToken();
        const btcAmounts = await uniswap.methods.getAmountsIn(btcPerToken, [wBNBAddress, bTCAddress]).call();
        const btcCost = web3.utils.toBN(btcAmounts[0]);
        const ethAmounts = await uniswap.methods.getAmountsIn(ethPerToken, [wBNBAddress, eTHAddress]).call();
        const ethCost = web3.utils.toBN(ethAmounts[0]);
        const amountCost = btcCost.add(ethCost).add(wbnbPerToken);

        var slippageMint = new web3.utils.BN(slippageNum);
        var slippageTimesAmountMint = slippageMint.mul(amountCost);
        var slippageTotalMint = new web3.utils.BN(slippageTimesAmountMint.divn(web3.utils.toBN(100)));
        var costPlusSlippage = slippageTotalMint.add(amountCost);

        const mint = await core.mint(amount, 1652427671, { from: accounts[0], value: costPlusSlippage });

        const startBalance = await web3.eth.getBalance(accounts[0]);

        var amountMinusDevFee = new web3.utils.BN(amount);
        var devFeeMul = amount.divn(new web3.utils.BN(1000));
        amountMinusDevFee = amountMinusDevFee.sub(devFeeMul);
        console.log("amountMinusDevFee: " + amountMinusDevFee)

        const amountOutFromBtc = await uniswap.methods.getAmountsOut(btcPerToken, [wBNBAddress, bTCAddress]).call();
        const amountFromBtc = web3.utils.toBN(amountOutFromBtc[0]);
        const amountOutFromEth = await uniswap.methods.getAmountsOut(ethPerToken, [wBNBAddress, eTHAddress]).call();
        const amountFromEth = web3.utils.toBN(amountOutFromEth[0]);
        const amountToReceivePerToken = amountFromBtc.add(amountFromEth).add(wbnbPerToken);
        console.log("amountToReceivePerToken: " + amountToReceivePerToken);
        const amountToReceive = ((amountMinusDevFee.mul(amountToReceivePerToken)).div(wei2eth));
        console.log("amountToReceive: " + amountToReceive.toString());

        const btcExpected = (amountFromBtc.mul(amountMinusDevFee)).div(wei2eth);
        const ethExpected = (amountFromEth.mul(amountMinusDevFee)).div(wei2eth);

        var slippage = new web3.utils.BN(slippageNum);
        var btcExpectedWithSlippage = (slippage.mul(btcExpected)).div(wei2eth);
        var ethExpectedWithSlippage = (slippage.mul(ethExpected)).div(wei2eth);

        const burned = await core.burn(amount.toString(), 1652427671, btcExpectedWithSlippage.toString(), ethExpectedWithSlippage.toString(), { from: accounts[0] });
        const burnedBalance = await web3.eth.getBalance(accounts[0]);
        const balanceDifference = burnedBalance.sub(startBalance);

        var slippage = new web3.utils.BN(slippageNum);
        var slippageTimesAmount = slippage.mul(amountToReceive);
        var slippageTotal = new web3.utils.BN(slippageTimesAmount.divn(web3.utils.toBN(100)));
        var minimumAllowable = (amountToReceive.sub(slippageTotal));

        expect(balanceDifference).to.be.a.bignumber.that.is.at.least(minimumAllowable);
    });


    //Mint, should fail
    it("should fail on valueSubmitted =< cost of amount desired", async () => {
        const amount = wei2eth;
        const slippageNum = "20";

        const core = await CartCore.deployed();

        const uniswap = await new web3.eth.Contract(uniswapAbi, uniswapAddress);
        const btcPerToken = await core.btcPerToken();
        const ethPerToken = await core.ethPerToken();
        const wbnbPerToken = await core.wbnbPerToken();
        const btcAmounts = await uniswap.methods.getAmountsIn(btcPerToken, [wBNBAddress, bTCAddress]).call();
        const btcCost = web3.utils.toBN(btcAmounts[0]);
        const ethAmounts = await uniswap.methods.getAmountsIn(ethPerToken, [wBNBAddress, eTHAddress]).call();
        const ethCost = web3.utils.toBN(ethAmounts[0]);
        const amountCost = btcCost.add(ethCost).add(wbnbPerToken);

        var costOffset = amountCost.subn(1);

        await expect(core.mint(amount, 1652427671, { from: accounts[0], value: costOffset })).to.be.rejectedWith(Error);
    });

    it("should fail on 0 amountDesired for mint", async () => {
        const core = await CartCore.deployed();
        await expect(core.mint('0', 1652427671, { from: accounts[0], value: wei2eth })).to.be.rejectedWith(Error);
    });

    it("should fail on UINT256Max amountDesired and UINT256MAX for value for mint", async () => {
        const core = await CartCore.deployed();
        await expect(core.mint(UINT256MAX, 1652427671, { from: accounts[0], value: UINT256MAX })).to.be.rejectedWith(Error);
    });

    it("should fail on UINT256Max + 1 amountDesired for mint", async () => {
        const core = await CartCore.deployed();
        await expect(core.mint('115792089237316195423570985008687907853269984665640564039457584007913129639936', 1652427671, { from: accounts[0], value: wei2eth })).to.be.rejectedWith(Error);
    });

    it("should fail on expired timestamp for mint", async () => {
        const amount = wei2eth;
        const slippageNum = "20";

        const core = await CartCore.deployed();

        const uniswap = await new web3.eth.Contract(uniswapAbi, uniswapAddress);
        const btcPerToken = await core.btcPerToken();
        const ethPerToken = await core.ethPerToken();
        const wbnbPerToken = await core.wbnbPerToken();
        const btcAmounts = await uniswap.methods.getAmountsIn(btcPerToken, [wBNBAddress, bTCAddress]).call();
        const btcCost = web3.utils.toBN(btcAmounts[0]);
        const ethAmounts = await uniswap.methods.getAmountsIn(ethPerToken, [wBNBAddress, eTHAddress]).call();
        const ethCost = web3.utils.toBN(ethAmounts[0]);
        const amountCost = btcCost.add(ethCost).add(wbnbPerToken);

        var slippage = new web3.utils.BN(slippageNum);
        var slippageTimesAmount = slippage.mul(amountCost);
        var slippageTotal = new web3.utils.BN(slippageTimesAmount.divn(web3.utils.toBN(100)));
        var costPlusSlippage = slippageTotal.add(amountCost);

        await expect(core.mint('0', 1606841117, { from: accounts[0], value: costPlusSlippage })).to.be.rejectedWith(Error);
    });

 /*   it("should burn raw assets at correct rates", async () => {
        const core = await CartCore.deployed();
        const eth = await ETH.deployed();
        const amount = wei2eth;
        const slippageNum = '20';

        const uniswap = await new web3.eth.Contract(uniswapAbi, uniswapAddress);
        const btcPerToken = await core.btcPerToken();
        const ethPerToken = await core.ethPerToken();
        const wbnbPerToken = await core.wbnbPerToken();
        const btcAmounts = await uniswap.methods.getAmountsIn(btcPerToken, [wBNBAddress, bTCAddress]).call();
        const btcCost = web3.utils.toBN(btcAmounts[0]);
        const ethAmounts = await uniswap.methods.getAmountsIn(ethPerToken, [wBNBAddress, eTHAddress]).call();
        const ethCost = web3.utils.toBN(ethAmounts[0]);
        const amountCost = btcCost.add(ethCost).add(wbnbPerToken);

        var slippage = new web3.utils.BN(slippageNum);
        var slippageTimesAmount = slippage.mul(amountCost);
        var slippageTotal = new web3.utils.BN(slippageTimesAmount.divn(web3.utils.toBN(100)));
        var costPlusSlippage = slippageTotal.add(amountCost);

        const mint = await core.mint(amount, 1652427671, { from: accounts[0], value: costPlusSlippage });

        const startETHBalance = await eth.balanceOf(accounts[0], { from: accounts[0] });
        console.log(startETHBalance.toString());

        var amountMinusDevFee = new web3.utils.BN(amount);
        var devFeeMul = amount.divn(new web3.utils.BN(1000));
        amountMinusDevFee = amountMinusDevFee.sub(devFeeMul);
        console.log(amount.toString());


        const burned = await core.burnRaw(amount, { from: accounts[0] });

        const ethBal = await eth.balanceOf(accounts[0], { from: accounts[0] });
        const ethIncrease = ethBal.sub(startETHBalance);
        console.log(ethBal.toString());
        console.log(ethIncrease.toString());

        const ethIncreaseExpected = amountMinusDevFee.mul(ethPerToken).div(wei2eth);
        console.log(ethIncreaseExpected.toString());

        expect(ethIncrease).to.eql(ethIncreaseExpected);
    });*/
});