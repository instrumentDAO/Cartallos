// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;


import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract DiversifyPures is BEP20{
    using SafeMath for uint256;

    address a_btc = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address a_eth = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address a_wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    IBEP20 btc = IBEP20(a_btc);
    IBEP20 eth = IBEP20(a_eth);
    IBEP20 wbnb = IBEP20(a_wbnb);


    uint256 devFeesCollected = 0;
    uint256 gweiUnits = 1000000000;
    mapping(address => bool) assets;
    mapping(IBEP20 => uint256) assetPerDiversifyToken;


    constructor() BEP20("Diversify General Pool", "DRV-G") {
        assets[address(btc)] = true;
        assets[address(eth)] = true;
        assets[address(wbnb)] = true;


        assetPerDiversifyToken[btc] = gweiUnits / 200; //.005 tokens to 1
        assetPerDiversifyToken[eth] = (3 * gweiUnits) / 20; //.15 tokens to 1
        assetPerDiversifyToken[wbnb] = 10 * gweiUnits / 10; //.1 tokens to 1

    }

    function mint(uint256 amount) public{
        bool success = btc.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[btc] * amount) / gweiUnits);
        success = success && eth.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[eth] * amount) / gweiUnits);
        success = success && wbnb.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[wbnb] * amount) / gweiUnits);
        require(success, "could not transfer all assets to the contract, check balances and approvals");
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        _burn(msg.sender, amount);
        uint256 devfee = amount/1000;
        amount = amount - devfee;
        devFeesCollected += devfee;

        btc.transfer(msg.sender, (assetPerDiversifyToken[btc] * amount) / gweiUnits);
        eth.transfer(msg.sender, (assetPerDiversifyToken[eth] * amount) / gweiUnits);
        wbnb.transfer(msg.sender, (assetPerDiversifyToken[wbnb] * amount) / gweiUnits);
    }

    function collectDevFunds(uint256 amount) public onlyOwner{
        require(amount <= devFeesCollected, "Dev fees currently collected are less than the amount collected");
        devFeesCollected -= amount;
        btc.transfer(msg.sender, (assetPerDiversifyToken[btc] * amount) / gweiUnits);
        eth.transfer(msg.sender, (assetPerDiversifyToken[eth] * amount) / gweiUnits);
        wbnb.transfer(msg.sender, (assetPerDiversifyToken[wbnb] * amount) / gweiUnits);
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
            btc.transfer(msg.sender, (assetPerDiversifyToken[btc] * amount) / gweiUnits);
        }

        if(primeKey % 3 == 0){
            eth.transfer(msg.sender, (assetPerDiversifyToken[eth] * amount) / gweiUnits);
        }

        if(primeKey % 5 == 0){
            wbnb.transfer(msg.sender, (assetPerDiversifyToken[wbnb] * amount) / gweiUnits);
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