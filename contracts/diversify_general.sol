pragma solidity =0.7.5;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract DiversifyGeneral is ERC20, Ownable {
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
        assets[address(asset1)] = true;
        assets[address(asset2)] = true;
        assets[address(asset3)] = true;
        assets[address(asset4)] = true;
        assets[address(asset5)] = true;
        assets[address(asset6)] = true;
        assets[address(asset7)] = true;
        assets[address(asset8)] = true;

        assetPerDiversifyToken[asset1] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset2] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset3] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset4] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset5] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset6] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset7] = 10 * weiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset8] = 10 * weiUnits; //10 tokens to 1

    }

    function setassetTESTINGONLY(address asset, uint256 whichone) public onlyOwner{
        if(whichone == 1){
            asset1 = IERC20(asset);
        }
        if(whichone == 2){
            asset2 = IERC20(asset);
        }
        if(whichone == 3){
            asset3 = IERC20(asset);
        }
        if(whichone == 4){
            asset4 = IERC20(asset);
        }
        if(whichone == 5){
            asset5 = IERC20(asset);
        }
        if(whichone == 6){
            asset6 = IERC20(asset);
        }
        if(whichone == 7){
            asset7 = IERC20(asset);
        }
        if(whichone == 8){
            asset8 = IERC20(asset);
        }
    }



    function mint(uint256 amount) public{
        bool worked = asset1.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset1] * amount) / weiUnits);
        require(worked);
        worked = asset2.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset2] * amount) / weiUnits);
        require(worked);
        worked = asset3.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset3] * amount) / weiUnits);
        require(worked);
        worked = asset4.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset4] * amount) / weiUnits);
        require(worked);
        worked = asset5.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset5] * amount) / weiUnits);
        require(worked);
        worked = asset6.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset6] * amount) / weiUnits);
        require(worked);
        worked = asset7.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset7] * amount) / weiUnits);
        require(worked);
        worked = asset8.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset8] * amount) / weiUnits);
        require(worked);
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
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