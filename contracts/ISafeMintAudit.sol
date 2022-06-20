pragma solidity ^0.8.11;
import "./ISafeMint.sol";

interface ISafeMintAudit {
    /// @dev 审计信息
    struct Audit {
        uint256 projectId; // 项目id索引
        address auditor; // 审计员
        uint256 auditTime; // 审计时间
        string comments; // 审计备注
        uint256 auditFee; // 审计押金
        ISafeMint.Status status; // 状态
    }

    /// @dev 挑战信息
    struct Challenge {
        uint256 projectId; // 项目id索引
        address challenger; // 挑战者
        uint256 time; // 挑战时间
        string comments; // 原因备注
        uint256 challengeFee; // 审计押金
    }

    /// @dev 项目收费记录
    struct FeeRecord {
        uint256 auditTime; // 审计时间
        address auditor; // 审计员
        uint256 value; // 收费数量
    }

    /// @dev 审计项目
    event AuditProject(
        string indexed name,
        address indexed auditor,
        uint256 auditPrice,
        string comments,
        ISafeMint.Status status
    );

    /// @dev 挑战项目
    event ChallengeProject(
        string indexed name,
        address indexed challenger,
        uint256 challengePrice,
        string comments
    );

    event ArbitrateProject(
        string indexed name,
        address indexed arbitrator,
        ISafeMint.Status status
    );
}
