//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libraries/StorageSlot.sol";
import "./Ownable.sol";

/**
 * @title Proxy Contract.
 * @author Petyo Stoyanov.
 * @notice Create simple ticket proxy.
 * @dev This is a test project.
 */
contract TicketProxy is Ownable {
  bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

  /**
   * @dev Set the Ticket contract address.
   *
   * @param _implementation The address of the ticket contract.
   */
  function setImplementation(address _implementation) public {
    StorageSlot.setAddressAt(IMPLEMENTATION_SLOT, _implementation);
  }

  /**
   * @dev Get the Ticket contract address.
   *
   * @return The address of the ticket contract.
   */
  function getImplementation() public view returns (address) {
    return StorageSlot.getAddressAt(IMPLEMENTATION_SLOT);
  }

  /**
   * @dev A custom delegate call function.
   *
   * @param _implementation The address of the ticket contract.
   */
  function delegate(address _implementation) internal virtual {
    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize())

      let result := delegatecall(gas(), _implementation, ptr, calldatasize(), 0, 0)

      let size := returndatasize()
      returndatacopy(ptr, 0, size)

      switch result
      case 0 {
        revert(ptr, size)
      }
      default {
        return(ptr, size)
      }
    }
  }

  /**
   * @dev Implements fallback().
   */
  fallback() external payable {
    delegate(getImplementation());
  }

  /**
   * @dev Implements receive().
   */
  receive() external payable {
    delegate(getImplementation());
  }
}
