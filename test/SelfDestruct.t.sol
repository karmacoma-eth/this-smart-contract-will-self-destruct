// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/SelfDestruct.sol";

contract SelfDestructTest is Test {
    event Message(string content, string by);
    event Destroyed(uint256 balance);

    SelfDestruct public willSelfDestruct;

    function setUp() public {
        willSelfDestruct = new SelfDestruct();
    }

    function testSendMessageKeepsItAlive() public {
        // move forward 6 hours
        vm.warp(block.timestamp + 6 hours);

        // verify we receive the expected event
        vm.expectEmit(true, true, true, true);
        emit Message("just chillin'", "karma");

        willSelfDestruct.sendMessage("just chillin'", "karma");

        // the lastMessageTimestamp has been updated
        assertEq(willSelfDestruct.lastMessageTimestamp(), block.timestamp);
    }

    function testSendMessageTooLate(uint64 delay) public {
        vm.assume(delay > 1 days);

        // move forward > 24h
        vm.warp(block.timestamp + delay);

        // verify we receive the expected event
        vm.expectEmit(true, true, true, true);
        emit Destroyed(0);

        // the contract should self destruct
        willSelfDestruct.sendMessage("it's too late", "karma");
    }

    function testSendMessageTooLateWithFunds(uint64 delay, uint256 balance)
        public
    {
        vm.assume(delay > 1 days);

        // move forward > 24h
        vm.warp(block.timestamp + delay);

        // verify we receive the expected event
        vm.expectEmit(true, true, true, true);
        emit Destroyed(balance);

        // the contract should self destruct
        vm.deal(address(this), balance);
        willSelfDestruct.sendMessage{value: balance}("it's too late", "karma");
    }
}
