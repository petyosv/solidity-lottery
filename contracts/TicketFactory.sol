//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TicketProxy.sol";
import "./Ownable.sol";

/**
 * @title Factory Contract.
 * @author Petyo Stoyanov.
 * @notice Create simple factory to deploy ticket proxies and update them.
 * @dev This is a test project.
 */
contract TicketFactory is Ownable {
  address ticket;
  TicketProxy[] private proxies;

  /**
   * @dev Initialize the factory with default ticket contract.
   *
   * @param _ticket The default ticket contract.
   */
  constructor(address _ticket) {
    ticket = _ticket;
  }

  /**
   * @dev Deploy new implementation of Ticket Contract.
   *
   * @param _ticket The new ticket contract.
   */
  function updateTicket(address _ticket) public isOwner {
    ticket = _ticket;
    for (uint256 _index; _index < proxies.length; _index++) {
      proxies[_index].setImplementation(_ticket);
    }
  }

  /**
   * @dev Deploy new proxy contract and set the ticket implementation.
   */
  function create() public isOwner {
    TicketProxy _proxy = new TicketProxy();
    _proxy.setImplementation(ticket);
    proxies.push(_proxy);
  }

  /**
   * @dev Retrieve all proxies.
   *
   * @return Array of all created proxies.
   */
  function getAll() public view returns(TicketProxy[] memory) {
    return proxies;
  }

  /**
   * @dev Retrieve an address of given proxy by the index.
   *
   * @return The address of the proxy.
   */
  function getProxyAddress(uint256 _index) public view returns(address) {
    return address(proxies[_index]);
  }
}
