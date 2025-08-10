// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Math Library for InterfinSwap DEX (min, sqrt)
library Math {
    /// @notice Returns the smaller of two numbers
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    /// @notice Returns the integer square root of a number (Babylonian method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // z is 0 if y == 0
    }
}