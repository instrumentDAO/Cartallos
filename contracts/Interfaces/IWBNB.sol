/**
 *Submitted for verification at BscScan.com on 2020-09-03
*/

/**
 *Submitted for verification at Bscscan.com on 2020-09-03
*/

pragma solidity >=0.4.18;

interface IWBNB {
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    function deposit() external payable;
    function withdraw(uint wad) external;
}