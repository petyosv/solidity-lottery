//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Owner Contract.
 * @author Petyo Stoyanov.
 * @notice Create simple contract to set admin.
 * @dev This is a test project.
 */
contract Ownable {

  address private owner;

  /**
   * @dev Check if caller is the owner.
   */
  modifier isOwner() {
    require(tx.origin == owner, "Caller is not the owner");
    _;
  }

  /**
   * @dev Set the owner.
   */
  constructor() {
    owner = tx.origin;
  }

  /**
   * @dev Change the owner.
   *
   * @param _owner The address of the new owner.
   */
  function transferOwnership(address _owner) public isOwner {
    owner = _owner;
  }

  /**
   * @dev Returns the address of the current owner.
   *
   * @return The address of the current owner.
   */
  function getOwner() public view virtual returns (address) {
    return owner;
  }

}
