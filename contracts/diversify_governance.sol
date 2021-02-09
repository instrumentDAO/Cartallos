pragma solidity =0.7.5;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DiversifyGovernance is ERC20 {
    using SafeMath for uint256;

    uint256 weiUnits = 1000000000000000000;

    mapping(address => bool) assets;
    mapping(IERC20 => uint256) assetPerDiversifyToken;


    constructor() ERC20("Diversify Governance", "DRV") public {

    }
}