// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IUniswapV2Factory {
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
}