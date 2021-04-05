// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;


import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "./Interfaces/IPancakeRouter02.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract CartallosPures is BEP20{
    using SafeMath for uint256;

    address internal constant PANCAKESWAP_ROUTER_ADDRESS = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
    IPancakeRouter02 public pancakeswapRouter;


    address a_btc = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address a_eth = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address a_wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    IBEP20 btc = IBEP20(a_btc);
    IBEP20 eth = IBEP20(a_eth);
    IBEP20 wbnb = IBEP20(a_wbnb);


    uint256 devFeesCollected = 0;
    uint256 gweiUnits = 1000000000;
    mapping(address => bool) assets;
    mapping(IBEP20 => uint256) assetPerCartallosToken;


    constructor() BEP20("Cartallos General Pool", "DRV-G") {
        pancakeswapRouter = IPancakeRouter02(PANCAKESWAP_ROUTER_ADDRESS);
        assets[address(btc)] = true;
        assets[address(eth)] = true;
        assets[address(wbnb)] = true;


        assetPerCartallosToken[btc] = gweiUnits / 200; //.005 tokens to 1
        assetPerCartallosToken[eth] = (3 * gweiUnits) / 20; //.15 tokens to 1
        assetPerCartallosToken[wbnb] = 10 * gweiUnits / 10; //.1 tokens to 1

    }
/*
TODO
DECIDE ON DEADLINE instead of block.timestamp SHOULD PASS FROM FRONTEND
*/
    function mint(uint256 amount) public{
        address[] memory path = new address[](2);
        path[0] = pancakeswapRouter.WETH();
        path[1] = address(a_btc);
        //docs say 5 inputs (amountIn, amountOutMin, path, to, deadline)
        //Compiler demands 4 inputs though, I think amountIn isn't considered necessary??..
/*
TODO
Handle data from pancakeswap router, insert requires where necessary
*/
        pancakeswapRouter.swapExactETHForTokens(((assetPerCartallosToken[btc] * amount) / gweiUnits), path, address(this), block.timestamp);        
        //is reusing path like this okay??
        path[1] = address(a_eth);
        pancakeswapRouter.swapExactETHForTokens(((assetPerCartallosToken[eth] * amount) / gweiUnits), path, address(this), block.timestamp); 
        //should we even bother wrapping the bnb??
        //require(a_wbnb.deposit((assetPerCartallosToken[eth] * amount) / gweiUnits));
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        _burn(msg.sender, amount);
        uint256 devfee = amount/1000;
        amount = amount - devfee;
        devFeesCollected += devfee;

        btc.transfer(msg.sender, (assetPerCartallosToken[btc] * amount) / gweiUnits);
        eth.transfer(msg.sender, (assetPerCartallosToken[eth] * amount) / gweiUnits);
        wbnb.transfer(msg.sender, (assetPerCartallosToken[wbnb] * amount) / gweiUnits);
    }

    function collectDevFunds(uint256 amount) public onlyOwner{
        require(amount <= devFeesCollected, "Dev fees currently collected are less than the amount collected");
        devFeesCollected -= amount;
        btc.transfer(msg.sender, (assetPerCartallosToken[btc] * amount) / gweiUnits);
        eth.transfer(msg.sender, (assetPerCartallosToken[eth] * amount) / gweiUnits);
        wbnb.transfer(msg.sender, (assetPerCartallosToken[wbnb] * amount) / gweiUnits);
    }



    function currentDevFees() external view returns (uint256){
        return devFeesCollected;
    }

    function emergenyBurn(uint256 amount, uint256 primeKey) external{
        require(primeKey != 0, "primeKey cannot be 0");
        require(balanceOf(msg.sender) >= amount, "balance too low");
        _burn(msg.sender, amount);
        uint256 devfee = amount/1000;
        amount = amount - devfee;

        if(primeKey % 2 == 0){
            btc.transfer(msg.sender, (assetPerCartallosToken[btc] * amount) / gweiUnits);
        }

        if(primeKey % 3 == 0){
            eth.transfer(msg.sender, (assetPerCartallosToken[eth] * amount) / gweiUnits);
        }

        if(primeKey % 5 == 0){
            wbnb.transfer(msg.sender, (assetPerCartallosToken[wbnb] * amount) / gweiUnits);
        }
    }

    //---------------------------------------------------------------------------------------
    // total balances

    function btcTotalBal() external view returns (uint256){
        return btc.balanceOf(address(this));
    }

    function ethTotalBal() external view returns (uint256){
        return eth.balanceOf(address(this));
    }

    function wbnbTotalBal() external view returns (uint256){
        return wbnb.balanceOf(address(this));
    }

    //---------------------------------------------------------------------------------------
    // user balances

    function btcBal(address user) external view returns (uint256){
        return btc.balanceOf(user);
    }

    function ethBal(address user) external view returns (uint256){
        return eth.balanceOf(user);
    }

    function wbnbBal(address user) external view returns (uint256){
        return wbnb.balanceOf(user);
    }


}