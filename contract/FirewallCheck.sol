// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @dev Interface of the IFirewallSafe standard.
 */
interface IFirewallSafe {
    /**
     * @dev Validates transfer transactions.
     * Define status values: 0: no blocking; 1: global blacklist; 2: project party blacklist; 3: number exceeds max.
     * Returns the verification status.
     */
    function blockTxCheck(
        address token,
        address from,
        address _to,
        uint256 _value
    ) external returns (uint8);
}

/**
 * @title FirewallCheck
 * To use this library you can add a `using FirewallCheck for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library FirewallCheck {
    using Address for address;
    using SafeERC20 for IERC20;

    enum ErrorResults {
        pass,
        blackList,
        contractBlackList,
        maxAmountLimit
    }

    IFirewallSafe public constant Firewall =
        IFirewallSafe(0x5e17b14ADd6c386305A32928F985b29bbA34Eff5);

    /**
     * @dev Moves `value` tokens from the `token` account to `to` address.
     * This function will check for transaction exceptions.
     * Define status values: 0: no blocking; 1: global blacklist; 2: project party blacklist; 3: number exceeds max.
     * This function will call the blockTxCheck function of the Firewall contract.
     */
    function firewallTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        ErrorResults errorcode;

        uint8 error = Firewall.blockTxCheck(
            address(token),
            msg.sender,
            to,
            value
        );
        errorcode = ErrorResults(error);

        if (
            errorcode == ErrorResults.blackList ||
            errorcode == ErrorResults.contractBlackList ||
            errorcode == ErrorResults.maxAmountLimit
        ) {
            revert();
        }

        IERC20(token).safeTransfer(to, value);
    }

    /**
     * @dev Moves `value` tokens from `from` to `to` using the allowance mechanism
     * This function will check for transaction exceptions.
     * Define status values: 0: no blocking; 1: global blacklist; 2: project party blacklist; 3: number exceeds max
     * This function will call the blockTxCheck function of the Firewall contract.
     */
    function firewallTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        ErrorResults errorcode;
        uint8 error = Firewall.blockTxCheck(address(token), from, to, value);
        errorcode = ErrorResults(error);

        if (
            errorcode == ErrorResults.blackList ||
            errorcode == ErrorResults.contractBlackList ||
            errorcode == ErrorResults.maxAmountLimit
        ) {
            revert();
        }

        IERC20(token).safeTransferFrom(from, to, value);
    }
}
