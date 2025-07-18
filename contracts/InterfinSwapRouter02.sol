// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IInterfinSwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
    function decimals() external view returns (uint8);
}

contract InterfinSwapRouter02 {
    address public factory;
    address public WETH; // Use WBNB on BSC

    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }

    // Add liquidity, swap, etc. functions (see UniswapV2Router02 for full code)
}