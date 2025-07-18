// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import './interfaces/IUniswapV2ERC20.sol';

contract UniswapV2ERC20 is IUniswapV2ERC20 {
    uint private _totalSupply;
    mapping(address => uint) private _balanceOf;
    mapping(address => mapping(address => uint)) private _allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure override returns (string memory) {
        return "InterfinSwap LP Token";
    }

    function symbol() external pure override returns (string memory) {
        return "IS-LP";
    }

    function decimals() external pure override returns (uint8) {
        return 18;
    }

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address owner) external view override returns (uint) {
        return _balanceOf[owner];
    }

    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint value) external override returns (bool) {
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _balanceOf[msg.sender] -= value;
        _balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        _allowance[from][msg.sender] -= value;
        _balanceOf[from] -= value;
        _balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function _mint(address to, uint value) internal {
        _totalSupply += value;
        _balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        _balanceOf[from] -= value;
        _totalSupply -= value;
        emit Transfer(from, address(0), value);
    }
}