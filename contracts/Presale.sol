
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "./BEP20/OpenZeppelinContracts/Context.sol";
import "./BEP20/OpenZeppelinContracts/IERC20.sol";
import "./BEP20/OpenZeppelinContracts/Ownable.sol";
import "./BEP20/OpenZeppelinContracts/ERC20.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";


contract Presale is Ownable, ERC20 {
    using SafeMath for uint256;
    IERC20 public saleToken;
    uint256 public saleRatioTimesEthUnits; //sale price is
    uint256 ethUnits = 1000000000000000000;
    uint256 public endDate = 0;
    uint256 public saleAmount;
    bool public exchangeOpen = false;


    constructor (
        address sale_Token,
        uint256 sale_Price,
        uint256 sale_Amount)
    ERC20(
        "CART Presale",
            "CRTP")
    {
        saleToken = IERC20(sale_Token);
        saleRatioTimesEthUnits = sale_Price;
        saleAmount = sale_Amount;
    }


    //amount is in wei
    //saleRatioTimesEthUnits is the saleprice multiplied by ethUnits, so it doesnt have to be fraction
    //if 1 of the sale token costs 5 matic, 5000000000000000000, aka 5e18
    //if 1 of the sale token costs .5 matic, 500000000000000000 aka 5e17

    // ethRequiredToSpend = (tokensWanted * saleRatioTimesEthUnits) / saleRatioTimesEthUnits
    // saleRatioTimesEthUnits/saleRatioTimesEthUnits is really the faction that represents the price, but we use communtive math to make solidity not have to do decimals

    //lets us basically use fraction without using fraction. Only has 1e18 units of precision tho


    function startPresale(uint256 duration) public onlyOwner{
        endDate = block.timestamp + duration;
    }


    function endPresale() public onlyOwner{
        require(
            block.timestamp > endDate,
            "Presale time is not over"
        );
        collectFunds();
        saleToken.transfer(
            owner(),
            saleToken.balanceOf(address(this))
        );
    }

    function openExchange(bool isOpen) public onlyOwner {
        exchangeOpen = isOpen;
    }

    function buyPresaleToken() public payable{
        uint256 tokensToBuy = (msg.value * ethUnits) / saleRatioTimesEthUnits;
        require(
            totalSupply() + tokensToBuy <= saleAmount,
            "There are not enough presale tokens left for that purchase amount"
        );
        require(
            block.timestamp <= endDate,
            "presale is either over or has not started"
        );
        _mint(
            msg.sender,
            tokensToBuy
        );
    }

    //exchanges all of the users presale tokens for the actual token. Requires exchanging to be open.
    function exchangeForSaleToken() public {
        require(exchangeOpen);
        uint256 userBal = balanceOf(msg.sender);
        _burn(
            msg.sender,
            userBal
        );
        saleToken.transfer(msg.sender, userBal);

    }

    function collectFunds() public onlyOwner{
        payable(owner()).transfer(
            address(this).balance
        );
    }
}
