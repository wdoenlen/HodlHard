pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract HodlToken is StandardToken {

    string public name = "Hodl Tokens"; 
    uint8 public decimals = 18;
    string public symbol = "HODL";         
    string public version = "H0.1"; 
    
    mapping(address => uint256) public etherBalances; 
    mapping(address => uint256) public releaseDates;

    function() public payable {
        deposit();
    }

    function deposit() public payable returns (bool success) {
        require(msg.value > 0);
        balances[msg.sender] += msg.value;
        etherBalances[msg.sender] += msg.value;
        releaseDates[msg.sender] = block.timestamp + (1 minutes);        
        return true;
    }

    function withdraw() public returns (bool success) {
        require(block.timestamp > releaseDates[msg.sender] && etherBalances[msg.sender] > 0);
        msg.sender.transfer(etherBalances[msg.sender]);
        etherBalances[msg.sender] = 0;
        return true;
    }
}
