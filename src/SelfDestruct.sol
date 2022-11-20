// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice This contract will self destruct if it goes 24h without receiving a message
/// inspired by https://www.thiswebsitewillselfdestruct.com/
contract SelfDestruct {
    event Message(string content, string by);
    event Destroyed(uint256 balance);

    address constant WATSI_ADDR = 0xb4ce79c7592f53505d551cB57439Fc16a9e0eF5C;

    uint256 public lastMessageTimestamp;

    constructor() {
        lastMessageTimestamp = block.timestamp;
    }

    function sendMessage(string calldata content, string calldata by)
        external
        payable
    {
        // if it's too late, trigger the self destruct and transfer whatever funds we may have to watsi.org
        if (block.timestamp > lastMessageTimestamp + 1 days) {
            emit Destroyed(address(this).balance);
            selfdestruct(payable(WATSI_ADDR));
        }

        // otherwise, update the timestamp log the message
        lastMessageTimestamp = block.timestamp;
        emit Message(content, by);
    }
}
