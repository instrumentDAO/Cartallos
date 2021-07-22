// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;

import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "./Interfaces/IUniswapV2Router02.sol";
import "./Interfaces/IWBNB.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract CartallosCore is BEP20 {
    using SafeMath for uint256;

    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68eA183eDbfc146407af1672D2d1cc351c2fb5b8;
    IUniswapV2Router02 public uniswapRouter;
    IWBNB public wbnbContract;

    address a_btc = 0x54824f67455A05Cad7b0751c4715e46C2aa226C2;
    address a_eth = 0xe778f496CE179f3895Fb10E040E4dA85A31e2724;
    address a_wbnb = 0x6DFAFB92fafA78E82802fFA07CCCE1dcD05Ec9de;
    address feeAddress = 0x6a2B6283AD99b412b717564c068Ab8Bd97294AC4;

    IBEP20 btc = IBEP20(a_btc);
    IBEP20 eth = IBEP20(a_eth);
    IBEP20 wbnb = IBEP20(a_wbnb);

    uint256 devFeesCollected = 0;
    uint256 ethUnits = 1000000000000000000;
    mapping(IBEP20 => uint256) assetPerCartallosToken;

    constructor() BEP20("Cartallos Core Index", "Cart-Core") {
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        wbnbContract = IWBNB(a_wbnb);

        assetPerCartallosToken[btc] = (82 * ethUnits) / 100000; //.00082 ethUnits of ETH ~ 25$ as of 7-21
        assetPerCartallosToken[eth] = (15 * ethUnits) / 1000; //.015 ethUnits of ETH ~ 25$ as of 7-21
        assetPerCartallosToken[wbnb] = (9 * ethUnits) / 100; //.09 ethunits of BNB ~ 25$ as of 7-21
        //assetPerCartallosToken[Matic] = 32 * ethUnits
    }

    function mint(uint256 amount, uint256 timeout) public payable {
        /*
        timeout is a unix timestamp of when to timeout the swaps
        amount is the amount of cartalos pool token user wants to mint
        */

        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = address(a_btc);
        uint256 btcRequired = (assetPerCartallosToken[btc] * amount) / (ethUnits);
        uint256 bnbNeededForBtc = uniswapRouter.getAmountsIn(btcRequired, path)[0];


        uint256 ethRequired = (assetPerCartallosToken[eth] * amount) / (ethUnits);
        path[1] = address(a_eth); //change the path array to path to eth
        uint256 bnbNeededForEth = uniswapRouter.getAmountsIn(ethRequired, path)[0];

        require((bnbNeededForBtc + bnbNeededForEth + 
            ((assetPerCartallosToken[wbnb] * amount) / ethUnits)) 
            <= msg.value, "Slippage limit exceeded after swaps, is value too low?");

        path[1] = address(a_btc); //change the path array to path back to btc so further functions use it properly
        uint256 btcResult = makeSwapMint(bnbNeededForBtc, btcRequired, timeout, path);
        path[1] = address(a_eth); //change the path array to path to eth
        uint256 ethResult = makeSwapMint(bnbNeededForEth, ethRequired, timeout, path);

        wbnbContract.deposit{
            value: ((assetPerCartallosToken[wbnb] * amount) / ethUnits)
        }();

        uint256 bnbspent = btcResult.add(ethResult).add(((assetPerCartallosToken[wbnb] * amount) / ethUnits));
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
        require(result[1] == amountRequired, "swap results not equal to amount required");
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
        uint256[] memory btcResult = uniswapRouter.swapExactTokensForETH(
            btcToExchange,
            minFromBTC,
            path,
            msg.sender,
            timeout
        );

        require(
            btcResult[0] >= minFromBTC,
            "bnb not equal to bnb required"
        );

        eth.approve(UNISWAP_ROUTER_ADDRESS, ethToExchange);
        path[0] = address(a_eth);
        uint256[] memory ethResult = uniswapRouter.swapExactTokensForETH(
            ethToExchange,
            minFromETH,
            path,
            msg.sender,
            timeout
        );

        require(
            ethResult[0] >= minFromETH,
            "bnb not equal to bnb required"
        );

        bool transferWbnb = wbnbContract.transfer(
            msg.sender,
            ((assetPerCartallosToken[wbnb] * amount) / ethUnits)
        );
        require(transferWbnb, "Transfer wbnb failed");
    }

    function burnRaw(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        uint256 devfee = amount / 1000;
        amount = amount.sub(devfee);

        require(
            transfer(feeAddress, amount),
            "Dev fees could not be transferred successfully"
        );
        devFeesCollected += devfee;

        _burn(msg.sender, amount);

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
        bool wbnbResult = wbnb.transfer(
            msg.sender,
            (assetPerCartallosToken[wbnb] * amount) / ethUnits
        );
        require(wbnbResult, "Cart-Core: wbnb could not be transferred");

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
        bool wbnbResult = wbnb.transfer(
            msg.sender,
            (assetPerCartallosToken[wbnb] * amount) / ethUnits
        );
        require(wbnbResult, "Cart-Core: wbnb could not be transferred");
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

    function btcTotalBal() external view returns (uint256) {
        return btc.balanceOf(address(this));
    }

    function ethTotalBal() external view returns (uint256) {
        return eth.balanceOf(address(this));
    }

    function wbnbTotalBal() external view returns (uint256) {
        return wbnb.balanceOf(address(this));
    }

    //---------------------------------------------------------------------------------------
    // Values of underlying tokens


    function btcPerToken() external view returns (uint256) {
        return assetPerCartallosToken[btc];
    }

    function ethPerToken() external view returns (uint256) {
        return assetPerCartallosToken[eth];
    }

    function wbnbPerToken() external view returns (uint256) {
        return assetPerCartallosToken[wbnb];
    }
}
