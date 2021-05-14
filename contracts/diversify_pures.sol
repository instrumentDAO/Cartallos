// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;

import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "./Interfaces/IUniswapV2Router02.sol";
import "./Interfaces/IWBNB.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract CartallosPures is BEP20 {
    using SafeMath for uint256;

    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x68eA183eDbfc146407af1672D2d1cc351c2fb5b8;
    IUniswapV2Router02 public uniswapRouter;
    IWBNB public wbnbContract;

    address a_btc = 0x54824f67455A05Cad7b0751c4715e46C2aa226C2;
    address a_eth = 0xe778f496CE179f3895Fb10E040E4dA85A31e2724;
    address a_wbnb = 0x6DFAFB92fafA78E82802fFA07CCCE1dcD05Ec9de;

    IBEP20 btc = IBEP20(a_btc);
    IBEP20 eth = IBEP20(a_eth);
    IBEP20 wbnb = IBEP20(a_wbnb);

    uint256 devFeesCollected = 0;
    uint256 gweiUnits = 1000000000;
    mapping(address => bool) assets;
    mapping(IBEP20 => uint256) assetPerCartallosToken;

    constructor() BEP20("Cartallos General Pool", "Cart-G") {
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        wbnbContract = IWBNB(a_wbnb);
        assets[address(btc)] = true;
        assets[address(eth)] = true;
        assets[address(wbnb)] = true;

        assetPerCartallosToken[btc] = gweiUnits / 200; //.005 tokens to 1
        assetPerCartallosToken[eth] = (3 * gweiUnits) / 20; //.15 tokens to 1
        assetPerCartallosToken[wbnb] = (10 * gweiUnits) / 10; //.1 tokens to 1
    }

    function mint(
        uint256 amount,
        uint256 timeout
    ) public payable {
        /*
        timeout is a unix timestamp of when to timeout the swaps
        slippageMul1000 allows us to set slippage, multiply by gweiUnits so we can do decimal math
        amount is the amount of cartalos pool token user wants to mint
        */

        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = address(a_btc);

        uint256 btcRequired =
            (assetPerCartallosToken[btc] * amount) / (gweiUnits);
        uint256 ethRequired =
            (assetPerCartallosToken[eth] * amount) / (gweiUnits);

        /*
        use pancakeswap to calculate how much bnb is needed to swap for the requested amount of tokens
        
        getAmountIns gives the cost in bnb you would need to produce a particular amount of tokens after the swap 
        
        */
        uint256 bnbNeededForBtc =
            uniswapRouter.getAmountsIn(btcRequired, path)[0];
        path[1] = address(a_eth); //change the path array to path to eth
        uint256 bnbNeededForEth =
            uniswapRouter.getAmountsIn(ethRequired, path)[0];
        path[1] = address(a_btc); //change the path array to path back to btc so further functions use it properly

        require(
            (bnbNeededForBtc +
                bnbNeededForEth +
                ((assetPerCartallosToken[wbnb] * amount) / gweiUnits)) <= msg.value,
            "Slippage limit exceeded after swaps, is value too low?"
        );
        
        uint256[] memory btcResult =
            uniswapRouter.swapETHForExactTokens{value: bnbNeededForBtc}(
                btcRequired,
                path,
                address(this),
                timeout
            );
        require(btcResult[1] == btcRequired, "btc not equal to btc required");

        path[1] = address(a_eth);
        uint256[] memory ethResult =
            uniswapRouter.swapETHForExactTokens{value: bnbNeededForEth}(
                ethRequired,
                path,
                address(this),
                timeout
            );

        //check to make sure we got the tokens we wanted
        require(ethResult[1] == ethRequired, "eth not equal to btc required");


//TODO Check that doesn't break on swaps==true, but deposit==false.. (Check WBNB contract Deposit event??)
        wbnbContract.deposit{value: (assetPerCartallosToken[wbnb] * amount) / gweiUnits}();
        
//TODO Fix transfer funds
        if (bnbNeededForBtc > btcResult[0]) safeTransferFunds(msg.sender, (bnbNeededForBtc - btcResult[0]));
        if (bnbNeededForEth > ethResult[0]) safeTransferFunds(msg.sender, (bnbNeededForEth - ethResult[0]));

        _mint(msg.sender, amount);

    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        _burn(msg.sender, amount);
        uint256 devfee = amount / 1000;
        amount = amount - devfee;
        devFeesCollected += devfee;

        btc.transfer(
            msg.sender,
            (assetPerCartallosToken[btc] * amount) / gweiUnits
        );
        eth.transfer(
            msg.sender,
            (assetPerCartallosToken[eth] * amount) / gweiUnits
        );
        wbnb.transfer(
            msg.sender,
            (assetPerCartallosToken[wbnb] * amount) / gweiUnits
        );
    }

    function collectDevFunds(uint256 amount) public onlyOwner {
        require(
            amount <= devFeesCollected,
            "Dev fees currently collected are less than the amount collected"
        );
        devFeesCollected -= amount;
        btc.transfer(
            msg.sender,
            (assetPerCartallosToken[btc] * amount) / gweiUnits
        );
        eth.transfer(
            msg.sender,
            (assetPerCartallosToken[eth] * amount) / gweiUnits
        );
        wbnb.transfer(
            msg.sender,
            (assetPerCartallosToken[wbnb] * amount) / gweiUnits
        );
    }

    function currentDevFees() external view returns (uint256) {
        return devFeesCollected;
    }

    function emergenyBurn(uint256 amount, uint256 primeKey) external {
        require(primeKey != 0, "primeKey cannot be 0");
        require(balanceOf(msg.sender) >= amount, "balance too low");
        _burn(msg.sender, amount);
        uint256 devfee = amount / 1000;
        amount = amount - devfee;

        if (primeKey % 2 == 0) {
            btc.transfer(
                msg.sender,
                (assetPerCartallosToken[btc] * amount) / gweiUnits
            );
        }

        if (primeKey % 3 == 0) {
            eth.transfer(
                msg.sender,
                (assetPerCartallosToken[eth] * amount) / gweiUnits
            );
        }

        if (primeKey % 5 == 0) {
            wbnb.transfer(
                msg.sender,
                (assetPerCartallosToken[wbnb] * amount) / gweiUnits
            );
        }
    }

    function safeTransferFunds(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferFunds: Fund transfer failed');
    }

    //---------------------------------------------------------------------------------------
    // total balances

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
    // user balances

    function btcBal(address user) external view returns (uint256) {
        return btc.balanceOf(user);
    }

    function ethBal(address user) external view returns (uint256) {
        return eth.balanceOf(user);
    }

    function wbnbBal(address user) external view returns (uint256) {
        return wbnb.balanceOf(user);
    }
}
