//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ticket_v1.sol";

/**
 * @title Ticket Contract V2.
 * @author Petyo Stoyanov.
 * @notice Create updated version of the lottery.
 * @dev This is a test project.
 */
contract Ticket_v2 is Ticket_v1 {

  /**
   * @dev Check if the send ethers match the price of the ticket.
   */
  modifier checkThePrice() override {
    require(msg.value == 0.002 ether, "Ticket price is 0.002 ether.");
    _;
  }

}
