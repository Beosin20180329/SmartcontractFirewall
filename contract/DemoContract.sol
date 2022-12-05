// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./FirewallCheck.sol";
import "./FirewallFeature.sol";

interface IDemoContractINT {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) external;

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) external;

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract DemoToken is ERC20 {
    constructor() ERC20("DemoToken", "DemoToken") {}

    function mint(address addr, uint256 amount) public {
        _mint(addr, amount);
    }
}

contract DemoContract is FirewallFeature {
    using FirewallCheck for IERC20;

    function withdrawToken(
        IERC20 token,
        address to,
        uint256 value
    ) external returns (bool) {
        token.firewallTransfer(to, value);
        return true;
    }

    function buyToken(
        IERC20 token,
        address to,
        uint256 value
    ) external returns (bool) {
        token.firewallTransferFrom(msg.sender, to, value);
        return true;
    }
}
