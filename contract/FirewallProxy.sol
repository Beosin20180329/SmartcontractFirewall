// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

contract BeosinProxy is Proxy, ERC1967Upgrade {
    modifier onlyAdmin() {
        require(msg.sender == _getAdmin());
        _;
    }

    constructor(address _logic) payable {
        _upgradeTo(_logic);
        _changeAdmin(msg.sender);
    }

    function upgradeTo(address newImplementation)
        public
        onlyAdmin
        returns (bool)
    {
        _upgradeTo(newImplementation);
        return true;
    }

    function changeAdmin(address newAdmin) public onlyAdmin returns (bool) {
        _changeAdmin(newAdmin);
        return true;
    }

    function showImplementation() public view returns (address) {
        return _implementation();
    }

    function showAdmin() public view returns (address) {
        return _getAdmin();
    }

    function _implementation()
        internal
        view
        virtual
        override
        returns (address impl)
    {
        return ERC1967Upgrade._getImplementation();
    }

}
