// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Interface of the IFirewall standard.
 */
interface IFirewall {
    /**
     * @dev Projects are registered only once.
     * returns a boolean value indicating whether the operation succeeded.
     * Emits a {Register} event.
     */
    function register() external returns (bool);

    /**
     * @dev Set project-specific blacklists.
     * returns a boolean value indicating whether the operation succeeded.
     * Emits a {setSpecialBlacklist} event.
     */
    function setSpecialBlacklist(address projectBlackAddr, bool status)
        external
        returns (bool);

    /**
     * @dev Set the maximum transfer amount of the specified `token` address.
     * returns a boolean value indicating whether the operation succeeded.
     * Emits a {setMaxTransferAmount} event.
     */
    function setMaxTransferAmount(address token, uint256 maxTransferAmount)
        external
        returns (bool);

    /**
     * @dev Change project owner.
     * returns a boolean value indicating whether the operation succeeded.
     * Emits a {changeProjectOwner} event.
     */
    function changeProjectOwner(address newOwner) external returns (bool);
}

/**
 * @dev The contract enables key functions such as：
 * 1、register.
 * 2、set project-specific blacklists.
 * 3、set maximum transfer amounts.
 * 4、change project owners.
 */
contract FirewallFeature is Ownable {
    using Address for address;
    IFirewall public constant firewall =
        IFirewall(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);

    /**
     * @dev Registration of project parties.
     * This function will call the register function of the Firewall contract.
     */
    function register() external {
        bool result = firewall.register();
        require(result, "register failed");
    }

    /**
     * @dev Set the blacklists of transfers for the project.
     * Black address under each project.
     * Set `status` to true or false.
     * This function will call the setSpecialBlacklist function of the Firewall contract.
     */
    function setSpecialBlacklist(address projectBlackAddr, bool status)
        external
    {
        bool result = firewall.setSpecialBlacklist(projectBlackAddr, status);
        require(result, "setSpecialBlacklist failed");
    }

    /**
     * @dev Set the maximum number of transfers for the specified `token` address.
     * Each `token` contract has a different maximum limit.
     * This function will call the setMaxTransferAmount function of the Firewall contract.
     */
    function setMaxTransferAmount(address token, uint256 maxTransferAmount)
        external
    {
        bool result = firewall.setMaxTransferAmount(token, maxTransferAmount);
        require(result, "setMaxTransferAmount failed");
    }

    /**
     * @dev Set the owner of the project.
     * This function will call the changeProjectOwner function of the Firewall contract.
     */
    function changeProjectOwner(address newOwner) external {
        bool result = firewall.changeProjectOwner(newOwner);
        require(result, "changeProjectOwner failed");
    }
}
