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

    uint256 devFeesCollected = 0;
    uint256 gweiUnits = 1000000000;
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

        assetPerDiversifyToken[asset1] = 10 * gweiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset2] = 10 * gweiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset3] = 10 * gweiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset4] = 10 * gweiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset5] = 10 * gweiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset6] = 10 * gweiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset7] = 10 * gweiUnits; //10 tokens to 1
        assetPerDiversifyToken[asset8] = 10 * gweiUnits; //10 tokens to 1

    }

    function setassetTESTINGONLY(address asset, uint256 whichone, uint256 ratioXgwei) public onlyOwner{
        if(whichone == 1){
            asset1 = IERC20(asset);
            assetPerDiversifyToken[asset1] = ratioXgwei;
        }
        if(whichone == 2){
            asset2 = IERC20(asset);
            assetPerDiversifyToken[asset2] = ratioXgwei;
        }
        if(whichone == 3){
            asset3 = IERC20(asset);
            assetPerDiversifyToken[asset3] = ratioXgwei;
        }
        if(whichone == 4){
            asset4 = IERC20(asset);
            assetPerDiversifyToken[asset4] = ratioXgwei;
        }
        if(whichone == 5){
            asset5 = IERC20(asset);
            assetPerDiversifyToken[asset5] = ratioXgwei;
        }
        if(whichone == 6){
            asset6 = IERC20(asset);
            assetPerDiversifyToken[asset6] = ratioXgwei;
        }
        if(whichone == 7){
            asset7 = IERC20(asset);
            assetPerDiversifyToken[asset7] = ratioXgwei;
        }
        if(whichone == 8){
            asset8 = IERC20(asset);
            assetPerDiversifyToken[asset8] = ratioXgwei;
        }
    }



    function mint(uint256 amount) public{
        bool success = asset1.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset1] * amount) / gweiUnits);
        //string memory message = "num to transfer ";
        //require(false, string(abi.encodePacked(message, uint2str((assetPerDiversifyToken[asset1] * amount) / gweiUnits))));////(assetPerDiversifyToken[asset1] * amount) / gweiUnits));
        success = success && asset2.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset2] * amount) / gweiUnits);
        success = success && asset3.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset3] * amount) / gweiUnits);
        success = success && asset4.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset4] * amount) / gweiUnits);
        success = success && asset5.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset5] * amount) / gweiUnits);
        success = success && asset6.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset6] * amount) / gweiUnits);
        success = success && asset7.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset7] * amount) / gweiUnits);
        success = success && asset8.transferFrom(msg.sender, address(this), (assetPerDiversifyToken[asset8] * amount) / gweiUnits);
        require(success, "could not transfer all assets to the contract, check balances and approvals");
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        _burn(msg.sender, amount);
        uint256 devfee = amount/1000;
        amount = amount - devfee;
        devFeesCollected += devfee;

        asset1.transfer(msg.sender, (assetPerDiversifyToken[asset1] * amount) / gweiUnits);
        asset2.transfer(msg.sender, (assetPerDiversifyToken[asset2] * amount) / gweiUnits);
        asset3.transfer(msg.sender, (assetPerDiversifyToken[asset3] * amount) / gweiUnits);
        asset4.transfer(msg.sender, (assetPerDiversifyToken[asset4] * amount) / gweiUnits);
        asset5.transfer(msg.sender, (assetPerDiversifyToken[asset5] * amount) / gweiUnits);
        asset6.transfer(msg.sender, (assetPerDiversifyToken[asset6] * amount) / gweiUnits);
        asset7.transfer(msg.sender, (assetPerDiversifyToken[asset7] * amount) / gweiUnits);
        asset8.transfer(msg.sender, (assetPerDiversifyToken[asset8] * amount) / gweiUnits);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

}