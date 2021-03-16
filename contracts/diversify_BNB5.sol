// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;


import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract CartallosPures is BEP20{
    using SafeMath for uint256;

    address a_venus = 0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63;
    address a_cake = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address a_uni = 0xBf5140A22578168FD562DCcF235E5D43A02ce9B1;
    address a_bry = 0xf859Bf77cBe8699013d6Dbc7C2b926Aaf307F830;
    address a_comp = 0x52CE071Bd9b1C4B00A0b92D298c512478CaD67e8;

    IBEP20 venus = IBEP20(a_venus);
    IBEP20 cake = IBEP20(a_cake);
    IBEP20 uni = IBEP20(a_uni);
    IBEP20 bry = IBEP20(a_bry);
    IBEP20 comp = IBEP20(a_comp);




    uint256 devFeesCollected = 0;
    uint256 gweiUnits = 1000000000;
    mapping(address => bool) assets;
    mapping(IBEP20 => uint256) assetPerCartallosToken;


    constructor() BEP20("Cartallos General Pool", "DRV-G") {
        assets[address(venus)] = true;
        assets[address(cake)] = true;
        assets[address(uni)] = true;
        assets[address(bry)] = true;
        assets[address(comp)] = true;


/*
TODO
Decide on distribution of tokens
*/
        assetPerCartallosToken[venus] = gweiUnits / 200; //.005 tokens to 1
        assetPerCartallosToken[cake] = (3 * gweiUnits) / 20; //.15 tokens to 1
        assetPerCartallosToken[uni] = 10 * gweiUnits / 10; //.1 tokens to 1
        assetPerCartallosToken[bry] = 10 * gweiUnits / 10; //.1 tokens to 1
        assetPerCartallosToken[comp] = 10 * gweiUnits / 10; //.1 tokens to 1


    }

    function mint(uint256 amount) public{
        bool success = venus.transferFrom(msg.sender, address(this), (assetPerCartallosToken[venus] * amount) / gweiUnits);
        success = success && cake.transferFrom(msg.sender, address(this), (assetPerCartallosToken[cake] * amount) / gweiUnits);
        success = success && uni.transferFrom(msg.sender, address(this), (assetPerCartallosToken[uni] * amount) / gweiUnits);
        success = success && bry.transferFrom(msg.sender, address(this), (assetPerCartallosToken[bry] * amount) / gweiUnits);
        success = success && comp.transferFrom(msg.sender, address(this), (assetPerCartallosToken[comp] * amount) / gweiUnits);

        require(success, "could not transfer all assets to the contract, check balances and approvals");
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        _burn(msg.sender, amount);
        uint256 devfee = amount/1000;
        amount = amount - devfee;
        devFeesCollected += devfee;

        venus.transfer(msg.sender, (assetPerCartallosToken[venus] * amount) / gweiUnits);
        cake.transfer(msg.sender, (assetPerCartallosToken[cake] * amount) / gweiUnits);
        uni.transfer(msg.sender, (assetPerCartallosToken[uni] * amount) / gweiUnits);
        bry.transfer(msg.sender, (assetPerCartallosToken[bry] * amount) / gweiUnits);
        comp.transfer(msg.sender, (assetPerCartallosToken[comp] * amount) / gweiUnits);
    }

    function collectDevFunds(uint256 amount) public onlyOwner{
        require(amount <= devFeesCollected, "Dev fees currently collected are less than the amount collected");
        devFeesCollected -= amount;
        venus.transfer(msg.sender, (assetPerCartallosToken[venus] * amount) / gweiUnits);
        cake.transfer(msg.sender, (assetPerCartallosToken[cake] * amount) / gweiUnits);
        uni.transfer(msg.sender, (assetPerCartallosToken[uni] * amount) / gweiUnits);
        bry.transfer(msg.sender, (assetPerCartallosToken[bry] * amount) / gweiUnits);
        comp.transfer(msg.sender, (assetPerCartallosToken[comp] * amount) / gweiUnits);
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
            venus.transfer(msg.sender, (assetPerCartallosToken[venus] * amount) / gweiUnits);
        }

        if(primeKey % 3 == 0){
            cake.transfer(msg.sender, (assetPerCartallosToken[cake] * amount) / gweiUnits);
        }

        if(primeKey % 5 == 0){
            uni.transfer(msg.sender, (assetPerCartallosToken[uni] * amount) / gweiUnits);
        }
        if(primeKey % 7 == 0){
            bry.transfer(msg.sender, (assetPerCartallosToken[bry] * amount) / gweiUnits);
        }        
        if(primeKey % 11 == 0){
            comp.transfer(msg.sender, (assetPerCartallosToken[comp] * amount) / gweiUnits);
        }
    }

    //---------------------------------------------------------------------------------------
    // total balances

    function venusTotalBal() external view returns (uint256){
        return venus.balanceOf(address(this));
    }

    function cakeTotalBal() external view returns (uint256){
        return cake.balanceOf(address(this));
    }

    function uniTotalBal() external view returns (uint256){
        return uni.balanceOf(address(this));
    }

    function bryTotalBal() external view returns (uint256){
        return bry.balanceOf(address(this));
    }   

    function compTotalBal() external view returns (uint256){
        return comp.balanceOf(address(this));
    }

    //---------------------------------------------------------------------------------------
    // user balances

    function venusBal(address user) external view returns (uint256){
        return venus.balanceOf(user);
    }

    function cakeBal(address user) external view returns (uint256){
        return cake.balanceOf(user);
    }

    function uniBal(address user) external view returns (uint256){
        return uni.balanceOf(user);
    }

    function bryBal(address user) external view returns (uint256){
        return bry.balanceOf(user);
    }

    function compBal(address user) external view returns (uint256){
        return comp.balanceOf(user);
    }

}