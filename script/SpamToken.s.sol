// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SpamToken} from "../src/SpamToken.sol";

contract SpamTokenScript is Script {
    SpamToken public spamToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        spamToken = new SpamToken();

        vm.stopBroadcast();
    }
}
