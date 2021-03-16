// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;


import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract CartallosPures is BEP20{
    using SafeMath for uint256;

    address a_btc = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address a_eth = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address a_uni = 0xBf5140A22578168FD562DCcF235E5D43A02ce9B1;
    address a_sushi = 0x947950BcC74888a40Ffa2593C5798F11Fc9124C4;
    address a_link = 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD;

    IBEP20 btc = IBEP20(a_btc);
    IBEP20 eth = IBEP20(a_eth);
    IBEP20 uni = IBEP20(a_uni);
    IBEP20 sushi = IBEP20(a_sushi);
    IBEP20 link = IBEP20(a_link);




    uint256 devFeesCollected = 0;
    uint256 gweiUnits = 1000000000;
    mapping(address => bool) assets;
    mapping(IBEP20 => uint256) assetPerCartallosToken;


    constructor() BEP20("Cartallos General Pool", "DRV-G") {
        assets[address(btc)] = true;
        assets[address(eth)] = true;
        assets[address(uni)] = true;
        assets[address(sushi)] = true;
        assets[address(link)] = true;


/*
TODO
Decide on distribution of tokens
*/
        assetPerCartallosToken[btc] = gweiUnits / 200; //.005 tokens to 1
        assetPerCartallosToken[eth] = (3 * gweiUnits) / 20; //.15 tokens to 1
        assetPerCartallosToken[uni] = 10 * gweiUnits / 10; //.1 tokens to 1
        assetPerCartallosToken[sushi] = 10 * gweiUnits / 10; //.1 tokens to 1
        assetPerCartallosToken[link] = 10 * gweiUnits / 10; //.1 tokens to 1


    }

    function mint(uint256 amount) public{
        bool success = btc.transferFrom(msg.sender, address(this), (assetPerCartallosToken[btc] * amount) / gweiUnits);
        success = success && eth.transferFrom(msg.sender, address(this), (assetPerCartallosToken[eth] * amount) / gweiUnits);
        success = success && uni.transferFrom(msg.sender, address(this), (assetPerCartallosToken[uni] * amount) / gweiUnits);
        success = success && sushi.transferFrom(msg.sender, address(this), (assetPerCartallosToken[sushi] * amount) / gweiUnits);
        success = success && link.transferFrom(msg.sender, address(this), (assetPerCartallosToken[link] * amount) / gweiUnits);

        require(success, "could not transfer all assets to the contract, check balances and approvals");
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
        uni.transfer(msg.sender, (assetPerCartallosToken[uni] * amount) / gweiUnits);
        sushi.transfer(msg.sender, (assetPerCartallosToken[sushi] * amount) / gweiUnits);
        link.transfer(msg.sender, (assetPerCartallosToken[link] * amount) / gweiUnits);
    }

    function collectDevFunds(uint256 amount) public onlyOwner{
        require(amount <= devFeesCollected, "Dev fees currently collected are less than the amount collected");
        devFeesCollected -= amount;
        btc.transfer(msg.sender, (assetPerCartallosToken[btc] * amount) / gweiUnits);
        eth.transfer(msg.sender, (assetPerCartallosToken[eth] * amount) / gweiUnits);
        uni.transfer(msg.sender, (assetPerCartallosToken[uni] * amount) / gweiUnits);
        sushi.transfer(msg.sender, (assetPerCartallosToken[sushi] * amount) / gweiUnits);
        link.transfer(msg.sender, (assetPerCartallosToken[link] * amount) / gweiUnits);
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
            uni.transfer(msg.sender, (assetPerCartallosToken[uni] * amount) / gweiUnits);
        }
        if(primeKey % 7 == 0){
            sushi.transfer(msg.sender, (assetPerCartallosToken[sushi] * amount) / gweiUnits);
        }        
        if(primeKey % 11 == 0){
            link.transfer(msg.sender, (assetPerCartallosToken[link] * amount) / gweiUnits);
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

    function uniTotalBal() external view returns (uint256){
        return uni.balanceOf(address(this));
    }

    function sushiTotalBal() external view returns (uint256){
        return sushi.balanceOf(address(this));
    }   

    function linkTotalBal() external view returns (uint256){
        return link.balanceOf(address(this));
    }

    //---------------------------------------------------------------------------------------
    // user balances

    function btcBal(address user) external view returns (uint256){
        return btc.balanceOf(user);
    }

    function ethBal(address user) external view returns (uint256){
        return eth.balanceOf(user);
    }

    function uniBal(address user) external view returns (uint256){
        return uni.balanceOf(user);
    }

    function sushiBal(address user) external view returns (uint256){
        return sushi.balanceOf(user);
    }

    function linkBal(address user) external view returns (uint256){
        return link.balanceOf(user);
    }

}