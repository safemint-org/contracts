pragma solidity ^0.8.11;

import "./ISafeMintAudit.sol";

contract SafeMintAuditData is ISafeMintAudit {
    /// @dev 项目ID=>审计信息数组,审计记录
    mapping(uint256 => Audit[]) public auditRecord;
    /// @dev 项目ID=>挑战信息数组,挑战记录
    mapping(uint256 => Challenge[]) public challengeRecord;
    /// @dev 项目ID=>项目收费(提交收费+审计押金)
    mapping(uint256 => FeeRecord) public feeRecord;

    /// @dev ERC20 Token address
    address public token;
    /// @dev safeMint合约地址
    address public safeMint;
    /// @dev 审计押金
    uint256 public auditPrice;
    /// @dev 挑战押金
    uint256 public challengePrice;
    /// @dev 挑战时长
    uint256 public duration = 19;

    // Auditor 常量
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    // Arbitrator 常量
    bytes32 public constant ARBITRATOR_ROLE = keccak256("ARBITRATOR_ROLE");
}
