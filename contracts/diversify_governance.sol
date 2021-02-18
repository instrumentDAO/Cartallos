pragma solidity =0.7.5;


import "./BEP20/BEP20.sol";
import "./BEP20/IBEP20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract DiversifyGovernance is BEP20 {
    using SafeMath for uint256;

    uint256 weiUnits = 1000000000000000000;


    constructor() BEP20("Diversify Governance", "DRV") public {

    }
}