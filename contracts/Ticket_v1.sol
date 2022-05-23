//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./libraries/AddressArray.sol";

/**
 * @title Ticket Contract.
 * @author Petyo Stoyanov.
 * @notice Create simple lottery with tickets.
 * @dev This is a test project.
 */
contract Ticket_v1 is Ownable {
  using AddressArray for address[];

  bool initialized;
  uint256 startTime;
  uint256 blockTime;
  address[] players;
  bytes32 ipfs;

  /**
   * @dev Check if the send ethers match the price of the ticket.
   */
  modifier checkThePrice() virtual {
    require(msg.value == 0.001 ether, "Ticket price is 0.001 ether.");
    _;
  }

  /**
   * @dev Check if lottery is active.
   */
  modifier isAvailable() {
    require(startTime > 0, "This lottery hasn't been initiate.");
    require(msg.sender != getOwner(), "The owner of this lottery can not by a ticket.");
    require(checkAvailability(), "This lottery is no longer active.");
    _;
  }

  /**
   * @dev Initialize the lottery.
   */
  function init() public isOwner {
    require(!initialized, "The lottery is already initialized.");
    startTime = block.timestamp;
    blockTime = block.number;
    initialized = true;
  }

  /**
   * @dev Check if lottery is active.
   *
   * @return True if lottery is active.
   */
  function checkAvailability() private view returns(bool) {
    // The lottery will be available only for certain number of transactions (1000) in the blockchain.
    // The lottery will be available only for certain time (30 sec).
    return blockTime + 1000 > block.number && startTime + 30 > block.timestamp;
  }

  /**
   * @dev Buy a ticket for the lottery.
   */
  function buyTicket() public payable checkThePrice isAvailable {
    players.push(msg.sender);
  }

  /**
   * @dev Retrieve all players in the lottery.
   *
   * @return Array of addresses.
   */
  function getPlayers() public view returns(address[] memory) {
    return players;
  }

  /**
   * @dev Pick a random winner and transfer the current balance of the lottery.
   */
  function pickWinner() public isOwner {
    require(!checkAvailability(), "The lottery is still active.");
    require(players.length > 0, "No tickets were sold.");
    address _player = players[players.random()];
    payable (_player).transfer(address(this).balance);
  }

  /**
   * @dev Pick a random surprise winner and transfer half of the current balance.
   */
  function pickSurpriseWinner() public isOwner {
    require(checkAvailability(), "Suprise winner can be picked while the lottery is active.");
    require(players.length > 0, "No tickets were sold.");

    uint256 _index = players.random();
    address _player = players[_index];
    payable (_player).transfer(address(this).balance * 50 / 100);
    players.slice(_index, 1);
  }

  /**
   * @dev Retrieve the current balance of the lottery.
   */
  function getWinningPrice() public view returns (uint256) {
    return address(this).balance;
  }

  /**
   * @dev Save IPFS Hash for off-chain storage.
   */
  function setIPFSHash(bytes32 _hash) public isOwner {
    ipfs = _hash;
  }

  /**
   * @dev Retrieve IPFS Hash for off-chain storage.
   */
  function getIPFSHash() public view returns(bytes32) {
    return ipfs;
  }

}
