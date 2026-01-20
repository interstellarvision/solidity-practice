// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address owner;
    address user1;
    address user2;

    uint256 constant INITIAL_SUPPLY = 1000000 * 10 ** 18; // 1M токенов

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        token = new MyToken(INITIAL_SUPPLY);
    }

    // ТЕСТ 1: Начальный supply правильный
    function testInitialSupply() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    // ТЕСТ 2: Transfer работает
    function testTransfer() public {
        uint256 amount = 100 * 10 ** 18;

        token.transfer(user1, amount);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(token.balanceOf(user1), amount);
    }

    // ТЕСТ 3: Transfer fails если недостаточно баланса
    function testTransferInsufficientBalance() public {
        vm.prank(user1); // user1 у которого 0 токенов

        vm.expectRevert("Insufficient balance");
        token.transfer(user2, 100);
    }

    // ТЕСТ 4: Approve работает
    function testApprove() public {
        uint256 amount = 500 * 10 ** 18;

        token.approve(user1, amount);

        assertEq(token.allowance(owner, user1), amount);
    }

    // ТЕСТ 5: TransferFrom работает
    function testTransferFrom() public {
        uint256 approveAmount = 1000 * 10 ** 18;
        uint256 transferAmount = 300 * 10 ** 18;

        // Owner разрешает user1 тратить 1000 токенов
        token.approve(user1, approveAmount);

        // user1 переводит от owner к user2
        vm.prank(user1);
        token.transferFrom(owner, user2, transferAmount);

        // Проверяем балансы
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(user2), transferAmount);

        // Проверяем что allowance уменьшился
        assertEq(token.allowance(owner, user1), approveAmount - transferAmount);
    }

    // ТЕСТ 6: TransferFrom fails без approve
    function testTransferFromInsufficientAllowance() public {
        vm.prank(user1);

        vm.expectRevert();
        token.transferFrom(owner, user2, 100);
    }

    // ТЕСТ 7: Multiple transfers
    function testMultipleTransfers() public {
        token.transfer(user1, 100 * 10 ** 18);
        token.transfer(user2, 200 * 10 ** 18);

        vm.prank(user1);
        token.transfer(user2, 50 * 10 ** 18);

        assertEq(token.balanceOf(user1), 50 * 10 ** 18);
        assertEq(token.balanceOf(user2), 250 * 10 ** 18);
    }
}
