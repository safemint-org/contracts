pragma solidity ^0.8.11;

import "./access/AccessControl.sol";
import "./SafeMintAuditData.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SafeMintAudit is AccessControl, SafeMintAuditData {
    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "sender doesn't have admin role"
        );
        _;
    }

    /// @dev 构造函数
    constructor(address _token, address _safeMint) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        token = _token;
        safeMint = _safeMint;
    }

    /**
     * @dev 审计项目
     * @param name 项目名称
     * @param comments 审计备注
     * @param status 结果状态
     */
    function audit(
        string calldata name,
        string calldata comments,
        ISafeMint.Status status
    ) public {
        // 确认审计员身份
        require(
            hasRole(AUDITOR_ROLE, msg.sender),
            "sender doesn't have auditor role"
        );
        // 确认状态输入正确
        require(
            status == ISafeMint.Status.passed ||
                status == ISafeMint.Status.reject ||
                status == ISafeMint.Status.locked,
            "Status error!"
        );
        // 项目ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // 获取项目数据
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // 确认状态输入正确
        require(
            _project.status == ISafeMint.Status.pending,
            "Project status error!"
        );

        uint256 _auditFee;
        if (feeRecord[_projectId].auditTime == 0) {
            _auditFee = auditPrice;
            // 验证审计收费
            IERC20(token).transferFrom(msg.sender, address(this), _auditFee);
            feeRecord[_projectId].auditTime = block.timestamp;
            feeRecord[_projectId].auditor = msg.sender;
            feeRecord[_projectId].value += _auditFee;
        } else {
            require(
                feeRecord[_projectId].auditor == msg.sender,
                "auditor error!"
            );
        }
        // 推入审计记录
        auditRecord[_projectId].push(
            Audit({
                projectId: _projectId,
                auditor: msg.sender,
                auditTime: block.timestamp,
                comments: comments,
                auditFee: _auditFee,
                status: status
            })
        );
        // 修改状态
        ISafeMint(safeMint).projectStatus(name, status);
        if (
            status == ISafeMint.Status.passed ||
            status == ISafeMint.Status.locked
        ) {
            uint256 balanceBefore = IERC20(token).balanceOf(address(this));
            ISafeMint(safeMint).auditorClaimFee(name);
            feeRecord[_projectId].value +=
                IERC20(token).balanceOf(address(this)) -
                balanceBefore;
        }
        // 触发事件
        emit AuditProject(name, msg.sender, auditPrice, comments, status);
    }

    /**
     * @dev 挑战项目
     * @param name 项目名称
     * @param comments 审计备注
     */
    function challenge(string calldata name, string calldata comments) public {
        // 验证审计收费
        IERC20(token).transferFrom(msg.sender, address(this), challengePrice);
        // 项目ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // 确认项目审核时间
        require(
            feeRecord[_projectId].auditTime + duration > block.timestamp,
            "expired!"
        );
        // 推入挑战记录数组
        challengeRecord[_projectId].push(
            Challenge({
                projectId: _projectId,
                challenger: msg.sender,
                time: block.timestamp,
                challengeFee: challengePrice,
                comments: comments
            })
        );
        // 修改状态
        ISafeMint(safeMint).projectStatus(name, ISafeMint.Status.challenge);
        emit ChallengeProject(name, msg.sender, challengePrice, comments);
    }

    /**
     * @dev 仲裁项目
     * @param name 项目名称
     * @param status 仲裁结果
     */
    function arbitrate(string calldata name, ISafeMint.Status status) public {
        // 确认仲裁员身份
        require(
            hasRole(ARBITRATOR_ROLE, msg.sender),
            "sender doesn't have arbitrator role"
        );
        // 确认状态输入正确
        require(
            status == ISafeMint.Status.passed ||
                status == ISafeMint.Status.locked,
            "Status error!"
        );
        // 项目ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // 获取项目数据
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // 确认状态输入正确
        require(
            _project.status == ISafeMint.Status.challenge,
            "Project status error!"
        );

        // 如果状态为通过
        if (status == ISafeMint.Status.passed) {
            // 挑战押金
            uint256 _challengeFee;
            // 循环累计挑战押金
            for (uint256 i; i < challengeRecord[_projectId].length; ++i) {
                _challengeFee += challengeRecord[_projectId][i].challengeFee;
                challengeRecord[_projectId][i].challengeFee = 0;
            }
            // 将挑战押金记录到审核费用
            feeRecord[_projectId].value += _challengeFee;
        }
        // 如果状态为锁定
        if (status == ISafeMint.Status.locked) {
            // 挑战记录数组长度
            uint256 chellengeLength = challengeRecord[_projectId].length;
            // 挑战奖励 = 审计押金总和 * 1e18 / 挑战记录长度
            uint256 chellengeReward = (feeRecord[_projectId].value * 1e18) /
                chellengeLength;
            // 循环挑战记录数组
            for (uint256 i; i < chellengeLength; ++i) {
                // 为每个挑战记录增加审计奖金
                challengeRecord[_projectId][i].challengeFee +=
                    chellengeReward /
                    1e18;
            }
            feeRecord[_projectId].value = 0;
        }
        // 修改项目状态
        ISafeMint(safeMint).projectStatus(name, status);
        emit ArbitrateProject(name, msg.sender, status);
    }

    /// @dev 领取审计奖励
    function claimAuditReward(string calldata name) public {
        // 项目ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // 确认项目审核时间
        require(
            feeRecord[_projectId].auditTime + duration < block.timestamp,
            "auditTime < duration!"
        );
        // 获取项目数据
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // 确认项目状态必须为通过或者锁定状态
        require(
            _project.status == ISafeMint.Status.passed ||
                _project.status == ISafeMint.Status.locked,
            "Starus error!"
        );
        require(feeRecord[_projectId].auditor == msg.sender, "auditor error!");
        uint256 value = feeRecord[_projectId].value;
        if (value > 0) {
            IERC20(token).transfer(msg.sender, value);
        }
    }

    /// @dev 领取挑战奖励
    function claimChellengeReward(string calldata name) public {
        // 项目ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // 确认项目审核时间
        require(
            feeRecord[_projectId].auditTime + duration < block.timestamp,
            "auditTime < duration!"
        );
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // 确认项目状态必须为锁定状态
        require(_project.status == ISafeMint.Status.locked, "Starus error");
        // 挑战费用
        uint256 challengeFee;
        // 循环所有挑战
        for (uint256 i = 0; i < challengeRecord[_projectId].length; i++) {
            // 如果挑战者是当前用户,并且费用>0
            if (challengeRecord[_projectId][i].challenger == msg.sender) {
                challengeFee += challengeRecord[_projectId][i].challengeFee;
            }
        }
        if (challengeFee > 0) {
            IERC20(token).transfer(msg.sender, challengeFee);
        }
    }

    /// @dev 管理员设置审计押金
    function adminSetAuditPrice(uint256 _price) public onlyAdmin {
        auditPrice = _price;
    }

    /// @dev 管理员设置挑战价格
    function adminSetChellengePrice(uint256 _price) public onlyAdmin {
        challengePrice = _price;
    }

    /// @dev 管理员设置挑战时长
    function adminSetDuration(uint256 _duration) public onlyAdmin {
        duration = _duration;
    }

    /// @dev 管理员取款
    function adminWithdraw(address payable to) public onlyAdmin {
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    }
}
