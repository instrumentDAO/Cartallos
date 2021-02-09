pragma solidity =0.7.5;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract DerpCoin is ERC20 {
    using SafeMath for uint256;


    constructor() ERC20("DerpCoin", "DERRRR") public {

    }

    function mint(uint256 amount) public{
        _mint(msg.sender, amount);
    }


}