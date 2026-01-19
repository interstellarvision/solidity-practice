// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank bank;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        bank = new SimpleBank();
        user1 = makeAddr("user1"); // ✅ Создаёт нормальный адрес
        user2 = makeAddr("user2"); // ✅ Создаёт нормальный адрес
        vm.deal(user1, 10 ether);
        vm.deal(user2, 5 ether);
    }

    // ТЕСТ 1: Депозит работает
    function testDeposit() public {
        vm.startPrank(user1);
        bank.deposit{value: 1 ether}();

        assertEq(bank.getBalance(), 1 ether);
        vm.stopPrank();
    }

    // ТЕСТ 2: Несколько депозитов суммируются
    function testMultipleDeposits() public {
        vm.startPrank(user1);

        bank.deposit{value: 1 ether}();
        bank.deposit{value: 2 ether}();

        assertEq(bank.getBalance(), 3 ether);
        vm.stopPrank();
    }

    // ТЕСТ 3: Withdraw работает
    function testWithdraw() public {
        vm.startPrank(user1);

        // Сначала вносим
        bank.deposit{value: 5 ether}();

        // Потом снимаем
        bank.withdraw(2 ether);

        // Проверяем что осталось 3 ETH
        assertEq(bank.getBalance(), 3 ether);
        vm.stopPrank();
    }

    // ТЕСТ 4: Нельзя снять больше чем есть
    function testCannotWithdrawMoreThanBalance() public {
        vm.startPrank(user1);
        bank.deposit{value: 1 ether}();

        // Ожидаем что упадёт
        vm.expectRevert();
        bank.withdraw(2 ether);

        vm.stopPrank();
    }

    // ТЕСТ 5: Разные юзеры имеют разные балансы
    function testSeparateBalances() public {
        // User1 вносит 3 ETH
        vm.prank(user1);
        bank.deposit{value: 3 ether}();

        // User2 вносит 1 ETH
        vm.prank(user2);
        bank.deposit{value: 1 ether}();

        // Проверяем балансы
        vm.prank(user1);
        assertEq(bank.getBalance(), 3 ether);

        vm.prank(user2);
        assertEq(bank.getBalance(), 1 ether);
    }

    // ТЕСТ 6: Полный вывод обнуляет баланс
    function testFullWithdraw() public {
        vm.startPrank(user1);

        bank.deposit{value: 5 ether}();
        bank.withdraw(5 ether);

        assertEq(bank.getBalance(), 0);
        vm.stopPrank();
    }

    function testTransfer() public {
        vm.prank(user1);
        bank.deposit{value: 5 ether}();

        vm.prank(user1);
        bank.transfer(user2, 2 ether);

        vm.prank(user1);
        assertEq(bank.getBalance(), 3 ether);

        vm.prank(user2);
        assertEq(bank.getBalance(), 2 ether);
    }
}
