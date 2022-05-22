//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Array enhancer.
 * @author Petyo Stoyanov.
 * @notice Create library to extend array of addresses.
 * @dev This is a test project.
 */
library AddressArray {

  /**
   * @dev returns the first index at which a given address can be found in the array, or -1 if it is not present.
   */
  function indexOf(address[] storage _self, address _address) public view returns (int256) {
    for (uint256 _i; _i < _self.length; _i++) {
      if (_self[_i] == _address) {
        return int256(_i);
      }
    }
    return int256(-1);
  }

  /**
   * @dev returns the random index from the array.
   */
  function random(address[] storage _self) public view returns (uint256) {
    return uint256(keccak256(abi.encode(block.timestamp,  _self))) % _self.length;
  }

  /**
   * @dev Remove items from given index in the array.
   */
  function slice(address[] storage _self, uint256 _start, uint256 _count) public returns(address[] memory) {
    require(_count > 0);
    address[] memory _output = new address[](_count);

    for (uint256 _index; _index < _count; _index++) {
      _output[_index] = _self[_index + _start];
    }

    for (uint256 _index; _index < _self.length - _count; _index++) {
      if (_index >= _start) {
        _self[_index] = _self[_index + _count];
      }
    }

    for (uint256 _index; _index < _count; _index++) {
      _self.pop();
    }

    return _output;
  }
}
