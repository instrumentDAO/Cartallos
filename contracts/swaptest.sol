// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;


import "./IBEP20.sol";
import "./IWBNB.sol";
import "./IPancakeRouter02.sol";

import "./SafeMath.sol";

contract SwapTest{
    using SafeMath for uint256;

    address internal constant PANCAKESWAP_ROUTER_ADDRESS = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
    IPancakeRouter02 public pancakeswapRouter;
    IWBNB public wbnbContract;


    address a_btc = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address a_eth = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address a_wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    
    address deployer;

    IBEP20 btc = IBEP20(a_btc);
    IBEP20 eth = IBEP20(a_eth);
    IBEP20 wbnb = IBEP20(a_wbnb);


    uint256 devFeesCollected = 0;
    uint256 gweiUnits = 1000000000;
    mapping(address => bool) assets;
    mapping(IBEP20 => uint256) assetPerCartallosToken;


    constructor() {
        deployer = msg.sender;
        pancakeswapRouter = IPancakeRouter02(PANCAKESWAP_ROUTER_ADDRESS);
        wbnbContract = IWBNB(a_wbnb);
        
        
        assets[address(btc)] = true;
        assets[address(eth)] = true;
        assets[address(wbnb)] = true;
        
        
        assetPerCartallosToken[btc] = gweiUnits / 200; //.005 tokens to 1
        assetPerCartallosToken[eth] = (3 * gweiUnits) / 20; //.15 tokens to 1
        assetPerCartallosToken[wbnb] = 10 * gweiUnits / 10; //.1 tokens to 1
        
        //btc.approve()

    }
/*
TODO
DECIDE ON DEADLINE instead of block.timestamp SHOULD PASS FROM FRONTEND
*/
    function mint(uint256 amount, uint256 slippageMulGwei, uint256 timeout) public payable{
        /*
        timeout is a unix timestamp of when to timeout the swaps
        slippageMul1000 allows us to set slippage, multiply by gweiUnits so we can do decimal math
        amount is the amount of cartalos pool token user wants to mint
        */
        
        address[] memory path = new address[](2);
        path[0] = pancakeswapRouter.WETH();
        path[1] = address(a_btc);
        
        
        uint256 btcRequired = (assetPerCartallosToken[btc] * amount) / ( gweiUnits);
        uint256 ethRequired = (assetPerCartallosToken[btc] * amount) / ( gweiUnits);
        
        /*
        use pancakeswap to calculate how much bnb is needed to swap for the requested amount of tokens
        
        getAmountIns gives the cost in bnb you would need to produce a particular amount of tokens after the swap 
        
        */
        
        uint256 bnbNeededForBtc = pancakeswapRouter.getAmountsIn(btcRequired, path)[0];
        bnbNeededForBtc = (bnbNeededForBtc * slippageMulGwei) / gweiUnits; //calculate how much more bnb is needed with slippage parameter
        path[1] = address(a_eth); //change the path array to path to eth
        uint256 bnbNeededForEth = pancakeswapRouter.getAmountsIn(ethRequired, path)[0];
        bnbNeededForEth = (bnbNeededForEth * slippageMulGwei) / gweiUnits;
        path[1] = address(a_btc); //change the path array to path back to btc so further functions use it properly
        
        /*
        Do the swaps based on the info
        put things on different lines to improve readability
        */
        uint256[] memory btcResult = pancakeswapRouter.swapExactETHForTokens
            {value: bnbNeededForBtc} 
            (2, path, address(this), timeout);        
        path[1] = address(a_eth);
        uint256[] memory ethResult = pancakeswapRouter.swapExactETHForTokens
            {value: bnbNeededForEth}
            (2, path, address(this), timeout); 
        //check this works correctly
        
        //check to make sure we got the tokens we wanted
        require(btcResult[1] == btcRequired);
        require(ethResult[1] == ethRequired);
        
        wbnbContract.deposit{value: (assetPerCartallosToken[wbnb] * amount) / gweiUnits}();
    }
    
    
    function withdraw(uint256 amount, address tok) public {
        require(msg.sender == deployer);
        IBEP20 token = IBEP20(tok);
        token.transfer(msg.sender, amount);
    }

}
