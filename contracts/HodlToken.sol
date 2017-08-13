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

    function withdraw(bytes32 depositId) public returns (bool success) {
        require(balances[msg.sender] > 0);

        Deposit memory d;
        Deposit[] deposits = ethDeposits[msg.sender];
        // Using a for loop here is okay since we don't expect users
        // to have too many deposits
        for (var i = 0; i < deposits.length; i++) {
            if (deposits[i].id == depositId) {
                d = deposits[i];
                break;
            }

            // If this is true then we didn't find the deposit in the
            // user's deposits list
            if (i == deposits.length - 1) {
                return false;
            }
        }

        // Don't let users withdraw before due date or withdraw the same
        // deposit twice
        if (block.timestamp < d.withdrawDate || d.isWithdrawn) {
            return false;
        }
        
        d.isWithdrawn = true;
        balances[msg.sender] -= d.amount;
        msg.sender.transfer(d.amount);
        return true;
    }

}
