// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Firewall is Ownable {
    using Address for address;

    event SetTraceOracle(address account, bool status);
    event SetBlackList(address account, bool status);
    event SetSpecialBlacklist(address projectBlackAddr, bool status);
    event SetMaxTransferAmount(address token, uint256 maxTransferAmount);
    event ChangeProjectOwner(address newOwner);
    event Register(address indexed projectAddress, address projectOwner);

    mapping(address => bool) public isBlackList;
    mapping(address => bool) public traceOracle;

    mapping(address => mapping(address => bool)) public contractBlackList;

    mapping(address => address) public projectOwner;

    mapping(address => mapping(address => uint256)) public maxAmount;

    mapping(address => bool) public projectStatus;

    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public recordAmount;

    enum ErrorResults {
        pass,
        blackList,
        contractBlackList,
        maxAmountLimit
    }

    bool private _initialized;

    modifier onlyTraceOracle() {
        require(
            traceOracle[_msgSender()],
            "Firewall: caller is not the TraceOracle"
        );
        _;
    }

    function init() internal {
        require(!_initialized, "Firewall: has been initialized");
        _transferOwnership(_msgSender());
        setTraceOracle(_msgSender(), true);
        _initialized = true;
    }

    function setTraceOracle(address account, bool status) public onlyOwner {
        traceOracle[account] = status;

        emit SetTraceOracle(account, status);
    }

    function register() external returns (bool) {
        require(!projectStatus[_msgSender()], "Firewall: already registered");
        require(_msgSender().isContract(), "Firewall: not contract");

        projectOwner[_msgSender()] = tx.origin;

        projectStatus[_msgSender()] = true;
        emit Register(_msgSender(), tx.origin);
        return true;
    }

    function setBlackListAccountStatus(address account, bool status)
        external
        onlyTraceOracle
    {
        isBlackList[account] = status;
        emit SetBlackList(account, status);
    }

    function setSpecialBlacklist(address projectBlackAddr, bool status)
        external
        returns (bool)
    {
        require(
            projectOwner[_msgSender()] == tx.origin,
            "Firewall: caller is not the projectOwner"
        );
        contractBlackList[_msgSender()][projectBlackAddr] = status;
        emit SetSpecialBlacklist(projectBlackAddr,status);
        return true;
    }

    function setMaxTransferAmount(address token, uint256 maxTransferAmount)
        external
        returns (bool)
    {
        require(
            projectOwner[_msgSender()] == tx.origin,
            "Firewall: caller is not the projectOwner"
        );
        maxAmount[_msgSender()][token] = maxTransferAmount;
        emit SetMaxTransferAmount(token, maxTransferAmount);
        return true;
    }

    function changeProjectOwner(address newOwner) external returns (bool) {
        require(
            projectOwner[_msgSender()] == tx.origin,
            "Firewall: caller is not the projectOwner"
        );
        projectOwner[_msgSender()] = newOwner;
        emit ChangeProjectOwner(newOwner);
        return true;
    }

    function blockTxCheck(
        address token,
        address from,
        address to,
        uint256 value
    ) external returns (ErrorResults) {
        if (isBlackList[to] || isBlackList[from]) {
            return ErrorResults.blackList;
        }

        if (
            contractBlackList[_msgSender()][to] ||
            contractBlackList[_msgSender()][from]
        ) {
            return ErrorResults.contractBlackList;
        }

        if (maxAmount[_msgSender()][token] == 0) {
            return ErrorResults.pass;
        }

        recordAmount[_msgSender()][token][block.number] += value;

        if (
            recordAmount[_msgSender()][token][block.number] >
            maxAmount[_msgSender()][token]
        ) {
            return ErrorResults.maxAmountLimit;
        }

        return ErrorResults.pass;
    }
}
