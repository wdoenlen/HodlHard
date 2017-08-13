pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

// Create single deposit
// List out all deposits
// Withdraw a given deposit or most recent deposit
// Create hodl tokens 1:1 with eth 

contract HodlToken is StandardToken {

    string public name = "Hodl Tokens"; 
    uint8 public decimals = 18;
    string public symbol = "HODL";         
    string public version = "H0.1"; 
    
    mapping(address => Deposit[]) public ethDeposits;

    struct Deposit {
        bytes32 id;
        uint amount;
        uint withdrawDate;
        bool isWithdrawn;
    }

    event DepositEvent(
        address indexed depositor,
        bytes32 depositId,
        uint amount,
        uint withdrawDate
    );

    function() public payable {
        deposit();
    }


    // One deposit per call
    // No adding to existing deposits
    // Deposit added to array
    function deposit() public payable returns (bool success) {
        require(msg.value > 0);
        uint withdrawDate = block.timestamp + (1 minutes);
        bytes32 depositId = sha256(uint(msg.sender) + withdrawDate);
        Deposit memory d = Deposit(depositId, withdrawDate, msg.value, false);
        ethDeposits[msg.sender].push(d);
        DepositEvent(msg.sender, depositId, msg.value, withdrawDate);
        balances[msg.sender] += msg.value;
        return true;
    }

    // function getDeposits() public returns (Deposit[]) {
    //     return ethDeposits[msg.sender];
    // }

    // function withdraw(Deposit d) public returns (bool success) {
    //     require(balances[msg.sender] > 0);

    //     if (block.timestamp < d.withdrawDate || d.isWithdrawn) {
    //         return false;
    //     }
        
    //     d.isWithdrawn = true;
    //     balances[msg.sender] -= d.amount;
    //     msg.sender.transfer(d.amount);
    //     return true;
    // }

    // function withdraw() public returns (bool success) {
    //     require(block.timestamp > releaseDates[msg.sender] && 
    //             etherBalances[msg.sender] > 0);
    //     msg.sender.transfer(etherBalances[msg.sender]);
    //     etherBalances[msg.sender] = 0;
    //     return true;
    // }
}
