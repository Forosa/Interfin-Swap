// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract InterfinSwapPair is ERC20, ReentrancyGuard {
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;

    bool public initialized;

    event Initialized(address indexed token0, address indexed token1);
    event LiquidityAdded(address indexed provider, uint112 amount0, uint112 amount1, uint liquidity);
    event LiquidityRemoved(address indexed provider, uint112 amount0, uint112 amount1, uint liquidity);
    event Swapped(address indexed trader, uint112 amountIn, uint112 amountOut, address inputToken, address outputToken);

    modifier onlyInitialized() {
        require(initialized, "InterfinSwapPair: NOT_INITIALIZED");
        _;
    }

    constructor() ERC20("InterfinSwap LP", "ISLP") {}

    function initialize(address _token0, address _token1) external {
        require(!initialized, "InterfinSwapPair: ALREADY_INITIALIZED");
        token0 = _token0;
        token1 = _token1;
        initialized = true;
        emit Initialized(_token0, _token1);
        _updateReserves();
    }

    function getReserves() external view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function addLiquidity(uint112 amount0, uint112 amount1) external nonReentrant onlyInitialized returns (uint liquidity) {
        require(amount0 > 0 && amount1 > 0, "InterfinSwapPair: INVALID_AMOUNTS");

        require(IERC20(token0).transferFrom(msg.sender, address(this), amount0), "TRANSFER_FAILED_TOKEN0");
        require(IERC20(token1).transferFrom(msg.sender, address(this), amount1), "TRANSFER_FAILED_TOKEN1");

        uint _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = sqrt(uint(amount0) * uint(amount1));
        } else {
            liquidity = min((uint(amount0) * _totalSupply) / reserve0, (uint(amount1) * _totalSupply) / reserve1);
        }
        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(msg.sender, liquidity);

        _updateReserves();
        emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
    }

    function removeLiquidity(uint liquidity) external nonReentrant onlyInitialized returns (uint112 amount0, uint112 amount1) {
        uint _totalSupply = totalSupply();
        require(_totalSupply > 0, "NO_LIQUIDITY");

        amount0 = uint112((uint(reserve0) * liquidity) / _totalSupply);
        amount1 = uint112((uint(reserve1) * liquidity) / _totalSupply);

        require(amount0 > 0 && amount1 > 0, "INSUFFICIENT_LIQUIDITY_BURNED");

        _burn(msg.sender, liquidity);
        require(IERC20(token0).transfer(msg.sender, amount0), "TRANSFER_FAILED_TOKEN0");
        require(IERC20(token1).transfer(msg.sender, amount1), "TRANSFER_FAILED_TOKEN1");

        _updateReserves();
        emit LiquidityRemoved(msg.sender, amount0, amount1, liquidity);
    }

    function swap(address inputToken, uint112 amountIn) external nonReentrant onlyInitialized {
        require(inputToken == token0 || inputToken == token1, "INVALID_TOKEN");
        address outputToken = inputToken == token0 ? token1 : token0;

        require(IERC20(inputToken).transferFrom(msg.sender, address(this), amountIn), "TRANSFER_FAILED_INPUT");

        uint inputReserve = inputToken == token0 ? reserve0 : reserve1;
        uint outputReserve = inputToken == token0 ? reserve1 : reserve0;

        // Take 0.3% fee
        uint amountInWithFee = uint(amountIn) * 997 / 1000;

        // Calculate output amount
        uint amountOut = (amountInWithFee * outputReserve) / (inputReserve + amountInWithFee);
        require(amountOut > 0 && amountOut <= outputReserve, "INSUFFICIENT_OUTPUT_AMOUNT");

        require(IERC20(outputToken).transfer(msg.sender, amountOut), "TRANSFER_FAILED_OUTPUT");

        _updateReserves();
        emit Swapped(msg.sender, amountIn, uint112(amountOut), inputToken, outputToken);
    }

    function _updateReserves() internal {
        reserve0 = uint112(IERC20(token0).balanceOf(address(this)));
        reserve1 = uint112(IERC20(token1).balanceOf(address(this)));
    }

    // Utility functions
    function min(uint x, uint y) private pure returns (uint z) {
        z = x < y ? x : y;
    }
    function sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}