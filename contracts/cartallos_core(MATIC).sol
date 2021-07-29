// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;

import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "./Interfaces/IUniswapV2Router02.sol";
import "./Interfaces/IMATIC.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract CartallosCoreMATIC is BEP20 {
    using SafeMath for uint256;

    address internal constant UNISWAP_ROUTER_ADDRESS =
        0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    IUniswapV2Router02 public uniswapRouter;
    IMATIC public wmaticContract;

    address a_btc = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address a_eth = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address a_wmatic = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address feeAddress = 0x93cC95b441b02c7E65d52018F1f7c8DfBdfDA03b;

    IBEP20 btc = IBEP20(a_btc);
    IBEP20 eth = IBEP20(a_eth);
    IBEP20 wmatic = IBEP20(a_wmatic);

    uint256 devFeesCollected = 0;
    uint256 ethUnits = 1000000000000000000;
    mapping(IBEP20 => uint256) assetPerCartallosToken;

    constructor() BEP20("Cartallos Core Index", "Cart-Core-MATIC") {
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        wmaticContract = IMATIC(a_wmatic);

        assetPerCartallosToken[btc] = (82 * ethUnits) / 100000; //.00082 ethUnits of ETH ~ 25$ as of 7-21
        assetPerCartallosToken[eth] = (15 * ethUnits) / 1000; //.015 ethUnits of ETH ~ 25$ as of 7-21
        assetPerCartallosToken[wmatic] = 32 * ethUnits;
    }

    function mint(uint256 amount, uint256 timeout) public payable {
        /*
        timeout is a unix timestamp of when to timeout the swaps
        amount is the amount of cartalos pool token user wants to mint
        */

        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = address(a_btc);
        uint256 btcRequired = (assetPerCartallosToken[btc] * amount) /
            (ethUnits);
        uint256 bnbNeededForBtc = uniswapRouter.getAmountsIn(btcRequired, path)[
            0
        ];

        uint256 ethRequired = (assetPerCartallosToken[eth] * amount) /
            (ethUnits);
        path[1] = address(a_eth); //change the path array to path to eth
        uint256 bnbNeededForEth = uniswapRouter.getAmountsIn(ethRequired, path)[
            0
        ];

        require(
            (bnbNeededForBtc +
                bnbNeededForEth + 
                ((assetPerCartallosToken[wmatic] * amount) / ethUnits)) <=
                msg.value,
            "Slippage limit exceeded after swaps, is value too low?"
        );

        path[1] = address(a_btc); //change the path array to path back to btc so further functions use it properly
        uint256 btcResult = makeSwapMint(
            bnbNeededForBtc,
            btcRequired,
            timeout,
            path
        );
        path[1] = address(a_eth); //change the path array to path to eth
        uint256 ethResult = makeSwapMint(
            bnbNeededForEth,
            ethRequired,
            timeout,
            path
        );

        wmaticContract.deposit{
            value: ((assetPerCartallosToken[wmatic] * amount) / ethUnits)
        }();

        uint256 bnbspent = btcResult.add(ethResult).add(
            ((assetPerCartallosToken[wmatic] * amount) / ethUnits)
        );
        uint256 leftoverBNB = msg.value.sub(bnbspent);
        safeTransferFunds(msg.sender, leftoverBNB);

        _mint(msg.sender, amount);
    }

    function makeSwapMint(
        uint256 bnbNeededForAsset,
        uint256 amountRequired,
        uint256 timeout,
        address[] memory path
    ) internal returns (uint256) {
        /*
        timeout is a unix timestamp of when to timeout the swaps
        amount is the amount of cartalos pool token user wants to mint
        amountRequired is the amount needed to recieve before transaction reverts
        path is the path taken to recieve asset
        */

        uint256[] memory result = uniswapRouter.swapETHForExactTokens{
            value: bnbNeededForAsset
        }(amountRequired, path, address(this), timeout);
        require(
            result[1] == amountRequired,
            "swap results not equal to amount required"
        );
        return result[0];
    }

    function burn(
        uint256 amount,
        uint256 timeout,
        uint256 minFromBTC,
        uint256 minFromETH
        ) public {
        /*
        timeout is a unix timestamp of when to timeout the swaps
        amount is the amount of cartalos pool token user wants to burn
        */

        require(balanceOf(msg.sender) >= amount, "balance too low");
        uint256 devfee = amount / 1000;
        amount = amount.sub(devfee);

        require(
            transfer(feeAddress, devfee),
            "Dev fees could not be transferred successfully"
        );
        devFeesCollected += devfee;

        _burn(msg.sender, amount);

        address[] memory path = new address[](2);
        path[0] = address(a_btc);
        path[1] = uniswapRouter.WETH();

        uint256 btcToExchange = (assetPerCartallosToken[btc] * amount) /
            (ethUnits);
        uint256 ethToExchange = (assetPerCartallosToken[eth] * amount) /
            (ethUnits);

        btc.approve(UNISWAP_ROUTER_ADDRESS, btcToExchange);
        makeSwapBurn( btcToExchange, minFromBTC, path, msg.sender, timeout);

        eth.approve(UNISWAP_ROUTER_ADDRESS, ethToExchange);
        path[0] = address(a_eth);
        makeSwapBurn( ethToExchange, minFromETH, path, msg.sender, timeout);

        bool transferWmatic = wmaticContract.transfer(
            msg.sender,
            ((assetPerCartallosToken[wmatic] * amount) / ethUnits)
        );
        require(transferWmatic, "Transfer wmatic failed");
    }

    function makeSwapBurn(
        uint256 assetToExchange,
        uint256 minFromAsset,
        address[] memory path,
        address burnTo,
        uint256 timeout
    ) internal {
        /*
        timeout is a unix timestamp of when to timeout the swaps
        assetToExchange is the amount of asset to exchange
        minFromAsset is the minimum amount of asset to be received before transaction reverts
        path is the path taken to recieve asset
        */

        uint256[] memory result = uniswapRouter.swapExactTokensForETH(
            assetToExchange,
            minFromAsset,
            path,
            burnTo,
            timeout
        );

        require(result[0] >= minFromAsset, "output not equal to output required for one of the burned assets");
    }

    function burnRaw(uint256 amount, address sendTo) public {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        uint256 devfee = amount / 1000;
        amount = amount.sub(devfee);

        require(
            transfer(feeAddress, devfee),
            "Dev fees could not be transferred successfully"
        );

        _burn(msg.sender, amount);
        devFeesCollected += devfee;


        uint256 btcToSend = (assetPerCartallosToken[btc] * amount) / (ethUnits);
        uint256 ethToSend = (assetPerCartallosToken[eth] * amount) / (ethUnits);
        uint256 maticToSend = (assetPerCartallosToken[wmatic] * amount) / (ethUnits);
        require (btcToSend > 0, "sending 0 BTC");
        require (ethToSend > 0, "sending 0 eth");
        require (maticToSend > 0, "sending 0 wmatic");



        btc.approve(address(this), btcToSend);
        bool btcResult = btc.transferFrom(
            address(this),
            sendTo,
            btcToSend
        );
        require(btcResult, "Cart-Core: btc Could not be transferred");

        eth.approve(address(this), ethToSend);
        bool ethResult = eth.transferFrom(
            address(this),
            sendTo,
            ethToSend
        );
        require(ethResult, "Cart-Core: eth could not be transferred");

        wmatic.approve(address(this), maticToSend);
        bool maticResult = wmatic.transferFrom(
            address(this),
            sendTo,
            maticToSend
        );
        require(maticResult, "Cart-Core: wmatic could not be transferred");
    }

    function collectDevFunds(uint256 amount) public onlyOwner {
        require(
            amount <= devFeesCollected,
            "Dev fees currently collected are less than the amount submitted"
        );
        devFeesCollected -= amount;
        bool btcResult = btc.transfer(
            msg.sender,
            (assetPerCartallosToken[btc] * amount) / ethUnits
        );
        require(btcResult, "Cart-Core: btc Could not be transferred");
        bool ethResult = eth.transfer(
            msg.sender,
            (assetPerCartallosToken[eth] * amount) / ethUnits
        );
        require(ethResult, "Cart-Core: eth could not be transferred");
        bool maticResult = wmatic.transfer(
            msg.sender,
            (assetPerCartallosToken[wmatic] * amount) / ethUnits
        );
        require(maticResult, "Cart-Core: wmatic could not be transferred");
    }
    
    function transferFeeAddress(address newFeeAddress) public onlyOwner {
        require(newFeeAddress != address(0), "Ownable: new owner is the zero address");
        feeAddress = newFeeAddress;
    }

    function currentDevFees() external view returns (uint256) {
        return devFeesCollected;
    }

    function safeTransferFunds(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferFunds: Fund transfer failed"
        );
    }

    //---------------------------------------------------------------------------------------
    // Values of underlying tokens

    function btcPerToken() external view returns (uint256) {
        return assetPerCartallosToken[btc];
    }

    function ethPerToken() external view returns (uint256) {
        return assetPerCartallosToken[eth];
    }
    
    function maticPerToken() external view returns (uint256) {
        return assetPerCartallosToken[wmatic];
    }
}
