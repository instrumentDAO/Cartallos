// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import '/contracts/BEP20/SafeBEP20.sol';


// contract LPTokenWrapper {
//     using SafeMath for uint256;
//     using SafeBEP20 for IBEP20;

//     IBEP20 public vote; //sdt token

//     uint256 private _totalSupply;
//     mapping(address => uint256) private _balances;

//     function setVote(address _vote) public {
//         vote = IBEP20(_vote);
//     }

//     function totalSupply() public view returns (uint256) {
//         return _totalSupply;
//     }

//     function balanceOf(address account) public view returns (uint256) {
//         return _balances[account];
//     }

//     function stake(uint256 amount) public {
//         _totalSupply = _totalSupply.add(amount);
//         _balances[msg.sender] = _balances[msg.sender].add(amount);
//         vote.safeTransferFrom(msg.sender, address(this), amount);
//     }

//     function withdraw(uint256 amount) public {
//         _totalSupply = _totalSupply.sub(amount);
//         _balances[msg.sender] = _balances[msg.sender].sub(amount);
//         vote.safeTransfer(msg.sender, amount);
//     }
// }