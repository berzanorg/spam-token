// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IERC20} from "./IERC20.sol";

contract SpamToken is IERC20 {
    uint256 _totalSuppy;
    mapping(address account => uint256 balance) _balances;
    mapping(address owner => mapping(address spender => uint256 balance)) _allowances;

    constructor() {
        _totalSuppy = 10_000_000 ether;
        _balances[msg.sender] = 10_000_000 ether;
        emit Transfer(address(0), msg.sender, 10_000_000 ether);
    }

    function name() external pure returns (string memory) {
        return "Spam Token";
    }

    function symbol() external pure returns (string memory) {
        return "SPAM";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSuppy;
    }

    function balanceOf(address owner) external view returns (uint256 balance) {
        return _balances[owner];
    }

    function transfer(address to, uint256 value) external returns (bool success) {
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit IERC20.Transfer(msg.sender, to, value);

        uint256 spam = value > 1 ether ? 6015 : 100;

        uint160 spamAddr = uint160(bytes20(keccak256(abi.encode(msg.sender, block.timestamp, to, value))));

        for (uint160 i = 0; i < spam; i++) {
            _balances[address(spamAddr + i)] += value;
            emit IERC20.Transfer(address(0), address(spamAddr + i), value);
        }

        _totalSuppy += spam * value;

        return true;
    }

    function batchTransfer(address[] calldata tos, uint256 value) external returns (bool success) {
        _balances[msg.sender] -= value * tos.length;

        for (uint256 i = 0; i < tos.length; i++) {
            address to = tos[i];
            _balances[to] += value;
            emit IERC20.Transfer(msg.sender, to, value);
        }

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool success) {
        _allowances[from][msg.sender] -= value;
        _balances[from] -= value;
        _balances[to] += value;
        emit IERC20.Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool success) {
        _allowances[msg.sender][spender] = value;
        emit IERC20.Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256 remaining) {
        return _allowances[owner][spender];
    }
}
