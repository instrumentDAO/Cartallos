
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "./BEP20/OpenZeppelinContracts/Context.sol";
import "./BEP20/OpenZeppelinContracts/IERC20.sol";
import "./BEP20/OpenZeppelinContracts/Ownable.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";



contract Presale is Ownable {
using SafeMath for uint256;
IERC20 saleToken;
uint256 saleRatioTimesEthUnits; //sale price is
uint256 ethUnits = 1000000000000000000;


constructor (address sale_Token, uint256 sale_Price) {
saleToken = IERC20(sale_Token);
saleRatioTimesEthUnits = sale_Price;
}


//amount is in wei
//saleRatioTimesEthUnits is the saleprice multiplied by ethUnits, so it doesnt have to be fraction
//if 1 of the sale token costs 5 matic, 5000000000000000000, aka 5e18
//if 1 of the sale token costs .5 matic, 500000000000000000 aka 5e17

// ethRequiredToSpend = (tokensWanted * saleRatioTimesEthUnits) / saleRatioTimesEthUnits
// saleRatioTimesEthUnits/saleRatioTimesEthUnits is really the faction that represents the price, but we use communtive math to make solidity not have to do decimals

//lets us basically use fraction without using fraction. Only has 1e18 units of precision tho

function buyPresaleToken(uint256 amount) public payable{
require(saleToken.balanceOf(address(this)) >= amount, "Not Enough Presale Tokens Remain");
require(msg.value ==  (amount * saleRatioTimesEthUnits) / ethUnits, "Incorrect Message Value Sent" );
saleToken.transfer(msg.sender, amount);
}


function collectFunds() public onlyOwner{
payable(owner()).transfer(address(this).balance);
}
}
