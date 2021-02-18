pragma solidity =0.7.5;


import "./BEP20/BEP20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";



contract DerpCoin is BEP20 {
    using SafeMath for uint256;


    constructor() BEP20("DerpCoin", "DERRRR") public {

    }

    function mint(uint256 amount) public{
        _mint(msg.sender, amount);
    }


}