// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Vm, Test, console} from "forge-std/Test.sol";
import {SpamToken} from "../src/SpamToken.sol";

contract SpamTokenTest is Test {
    address public deployer;
    SpamToken public spamToken;

    function setUp() public {
        deployer = makeAddr("deployer");
        vm.prank(deployer);
        spamToken = new SpamToken();
    }

    function test_Initialization() public view {
        assertEq(spamToken.name(), "Spam Token");
        assertEq(spamToken.symbol(), "SPAM");
        assertEq(spamToken.decimals(), 18);
        assertEq(spamToken.totalSupply(), 10_000_000 ether);
        assertEq(spamToken.balanceOf(deployer), 10_000_000 ether);
    }

    function test_BatchTransfer() public {
        address[] memory tos = new address[](999);

        for (uint256 i = 0; i < 999; i++) {
            tos[i] = (address(bytes20(keccak256(abi.encode(i)))));
        }

        vm.prank(deployer);
        vm.recordLogs();
        spamToken.batchTransfer(tos, 10_000 ether);
        Vm.Log[] memory recordedLogs = vm.getRecordedLogs();
        assertEq(spamToken.totalSupply(), 10_000_000 ether);
        assertEq(spamToken.balanceOf(deployer), 10_000 ether);
        assertEq(recordedLogs.length, 999);

        for (uint256 i = 0; i < tos.length; i++) {
            assertEq(spamToken.balanceOf(tos[i]), 10_000 ether);
        }
    }

    function test_Transfer_Small() public {
        address receiver = makeAddr("receiver");
        vm.prank(deployer);
        vm.recordLogs();
        spamToken.transfer(receiver, 1 ether);
        Vm.Log[] memory recordedLogs = vm.getRecordedLogs();
        assertEq(spamToken.totalSupply(), 10_000_100 ether);
        assertEq(spamToken.balanceOf(deployer), 9_999_999 ether);
        assertEq(spamToken.balanceOf(receiver), 1 ether);
        assertEq(recordedLogs.length, 101);

        for (uint160 i = 0; i < 100; i++) {
            assertEq(
                spamToken.balanceOf(
                    address(uint160(bytes20(keccak256(abi.encode(deployer, block.timestamp, receiver, 1 ether)))) + i)
                ),
                1 ether
            );
        }
    }

    function test_Transfer_Big() public {
        address receiver = makeAddr("receiver");
        vm.prank(deployer);
        vm.recordLogs();
        uint256 gasBefore = gasleft();
        spamToken.transfer(receiver, 100 ether);
        uint256 gasAfter = gasleft();
        Vm.Log[] memory recordedLogs = vm.getRecordedLogs();
        assertEq(gasBefore - gasAfter, 149_984_246);
        assertEq(spamToken.totalSupply(), 10_601_500 ether);
        assertEq(spamToken.balanceOf(deployer), 9_999_900 ether);
        assertEq(spamToken.balanceOf(receiver), 100 ether);
        assertEq(recordedLogs.length, 6016);

        for (uint160 i = 0; i < 6015; i++) {
            assertEq(
                spamToken.balanceOf(
                    address(uint160(bytes20(keccak256(abi.encode(deployer, block.timestamp, receiver, 100 ether)))) + i)
                ),
                100 ether
            );
        }
    }
}
