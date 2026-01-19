// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract SimpleBank {
    modifier hasBalance(uint256 amount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        _;
    }
    event Deposited(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    mapping(address => uint256) public balances; // хранит балансы пользователей
    uint256 public totalDeposits; // общий депозит в банке

    function deposit() public payable {
        require(msg.value > 0, "dep must be more than 0");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint256 userBalance) {
        userBalance = balances[msg.sender];
    }

    function withdraw(uint256 amount) public hasBalance(amount) {
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");        
        emit Withdrawn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public {
        require(to != address(0), "Cannot transfer to zero address"); // Защита от потери
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount); // event для логов
    }
}

