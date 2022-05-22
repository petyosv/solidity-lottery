//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Storage Slot.
 * @author Petyo Stoyanov.
 * @notice Create library to transform address to store slot and backward.
 * @dev This is a test project.
 */
library StorageSlot {

  /**
   * @dev Transform store slot to address.
   */
  function getAddressAt(bytes32 slot) internal view returns (address a) {
    assembly {
      a := sload(slot)
    }
  }

  /**
   * @dev Transform address to store slot.
   */
  function setAddressAt(bytes32 slot, address address_) internal {
    assembly {
      sstore(slot, address_)
    }
  }
}
