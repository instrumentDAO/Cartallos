// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "./OpenZeppelinContracts/ERC20.sol";
import "./OpenZeppelinContracts/Ownable.sol";

contract BEP20 is ERC20, Ownable {
    constructor (string memory name_, string memory symbol_) ERC20(name_, symbol_){

    }
    function getOwner() external view returns (address){
        return owner();
    }
}