pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract HodlToken is StandardToken {

    string public name = "Hodl Tokens"; 
    uint8 public decimals = 18;
    string public symbol = "HODL"; 
    string public version = "H0.1"; 
    
    mapping(address => Deposit[]) public ethDeposits;

    struct Deposit {
        bytes32 id;
        address depositor;
        uint amount;
        uint withdrawDate;
        bool isWithdrawn;
    }

    // We use DepositEvent as a hack to retrieve deposit IDs later on
    // since we can't return a dynamically-sized list of deposits
    event DepositEvent(
        address indexed depositor,
        bytes32 depositId,
        uint amount,
        uint withdrawDate
    );

    event WithdrawEvent(
        address indexed withdrawer,
        bytes32 depositId,
        uint amount
    );

    modifier nonzeroBalanceOnly() {
        require(balances[msg.sender] > 0);
        _;
    }

    function() public payable {
        deposit();
    }

    function deposit() public payable returns (bool success) {
        require(msg.value > 0);
        uint withdrawDate = block.timestamp + (1 seconds);
        bytes32 depositId = sha256(uint(msg.sender) + withdrawDate);
        Deposit memory d = Deposit(
            depositId, msg.sender, msg.value, withdrawDate, false
        );
        ethDeposits[msg.sender].push(d);
        DepositEvent(msg.sender, depositId, msg.value, withdrawDate);
        balances[msg.sender] += msg.value;
        return true;
    }

    function _withdraw(Deposit d) internal nonzeroBalanceOnly returns (bool success) {
        require(msg.sender == d.depositor);
        
        // Don't let users withdraw before due date or withdraw the same
        // deposit twice
        if (block.timestamp < d.withdrawDate || d.isWithdrawn) {
            return false;
        }
        
        d.isWithdrawn = true;
        balances[msg.sender] -= d.amount;
        msg.sender.transfer(d.amount);
        WithdrawEvent(msg.sender, d.id, d.amount);
        return true;
    }

    function withdrawOne(bytes32 depositId) public nonzeroBalanceOnly returns (bool success) {

        Deposit[] deposits = ethDeposits[msg.sender];

        for (var i = 0; i < deposits.length; i++) {
            if (deposits[i].id == depositId) {
                success = _withdraw(deposits[i]);
                if (success) {
                    delete deposits[i];
                }
                return success;
            }
        }
        return false;
    }

    function withdrawAll() public nonzeroBalanceOnly returns (bool success) {
        
        Deposit[] deposits = ethDeposits[msg.sender];
        success = true;

        for (var i = 0; i < deposits.length; i++) {
            bool succ = _withdraw(deposits[i]);
            if (succ) {
                delete deposits[i];
            }
            success = success && succ;
        }
        return success;
    }

    function transfer(address to, uint256 value) returns (bool) {
        // Don't trade your tokens, just hodl!
        hodl();
    }

    function transferFrom(address from, address to, uint256 value) returns (bool) {
        // Don't trade your tokens, just hodl!
        hodl();
    }

    function hodl() {
        throw;
    }

}
