pragma solidity =0.7.5;


import "./openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract DiversifyGeneral is ERC20 {
    using SafeMath for uint256;

    IERC20 asset1;
    IERC20 asset2;
    IERC20 asset3;
    IERC20 asset4;
    IERC20 asset5;
    IERC20 asset6;
    IERC20 asset7;
    IERC20 asset8;

    uint256 weiUnits = 1000000000000000000;

    mapping(address => bool) assets;
    mapping(IERC20 => uint256) assetPerDiversifyToken;


    constructor() ERC20("Diversify General Pool", "DRV-G") public {
        assets[asset1] = true;
        assets[asset2] = true;
        assets[asset3] = true;
        assets[asset4] = true;
        assets[asset5] = true;
        assets[asset6] = true;
        assets[asset7] = true;
        assets[asset8] = true;

        assetPerDiversifyToken[asset1] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset2] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset3] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset4] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset5] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset6] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset7] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset8] = 10 * weiUnits; //10 tokens to 1

    }

    function mint(uint256 amount){
        asset1.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset1] * amount) / weiUnits);
        asset2.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset2] * amount) / weiUnits);
        asset3.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset3] * amount) / weiUnits);
        asset4.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset4] * amount) / weiUnits);
        asset5.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset5] * amount) / weiUnits);
        asset6.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset6] * amount) / weiUnits);
        asset7.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset7] * amount) / weiUnits);
        asset8.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset8] * amount) / weiUnits);
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount){
        require(balanceOf(msg.sender)> amount);
        _burn(msg.sender, amount);
        asset1.transfer(msg.sender, (assetPerDiversifyToken[asset1] * amount) / weiUnits);
        asset2.transfer(msg.sender, (assetPerDiversifyToken[asset2] * amount) / weiUnits);
        asset3.transfer(msg.sender, (assetPerDiversifyToken[asset3] * amount) / weiUnits);
        asset4.transfer(msg.sender, (assetPerDiversifyToken[asset4] * amount) / weiUnits);
        asset5.transfer(msg.sender, (assetPerDiversifyToken[asset5] * amount) / weiUnits);
        asset6.transfer(msg.sender, (assetPerDiversifyToken[asset6] * amount) / weiUnits);
        asset7.transfer(msg.sender, (assetPerDiversifyToken[asset7] * amount) / weiUnits);
        asset8.transfer(msg.sender, (assetPerDiversifyToken[asset8] * amount) / weiUnits);
    }

}