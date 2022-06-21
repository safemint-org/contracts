pragma solidity ^0.8.11;

import "./access/AccessControl.sol";
import "./utils/Arrays.sol";
import "./SafeMintData.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SafeMint is AccessControl, SafeMintData {
    using Arrays for uint256[];
    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "sender doesn't have admin role"
        );
        _;
    }

    modifier onlyAuditor() {
        // 确认审计员身份
        require(
            hasRole(AUDITOR_ROLE, msg.sender),
            "sender doesn't have auditor role"
        );
        _;
    }

    /// @dev 构造函数
    constructor(address _token) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        token = _token;
    }

    /**
     * @dev 提交项目
     * @param name 项目名称
     * @param projectContract 项目合约地址
     * @param startTime 开始铸造的时间
     * @param endTime 结束铸造的时间
     * @param ipfsAddress ipfs中存储的json信息地址
     */
    function saveProject(
        string calldata name,
        address projectContract,
        uint256 startTime,
        uint256 endTime,
        string calldata ipfsAddress
    ) public {
        // 验证项目收费
        IERC20(token).transferFrom(msg.sender, address(this), projectPrice);
        // 验证用户只能提交一次
        require(
            !user[msg.sender] && msg.sender == tx.origin,
            "user aleardy saved"
        );
        user[msg.sender] = true;
        // 一个项目地址只能提交一次
        require(
            !contractAddress[projectContract],
            "contractAddress aleardy saved"
        );
        contractAddress[projectContract] = true;
        // 验证项目名称
        require(!projectName(name), "name aleardy used");

        // 项目结构体
        Project memory _project = Project({
            name: name,
            owner: msg.sender,
            projectContract: projectContract,
            createTime: block.timestamp,
            startTime: startTime,
            endTime: endTime,
            ipfsAddress: ipfsAddress,
            projectFee: projectPrice,
            status: Status.pending
        });

        // 推入项目数组
        projectArr.push(_project);
        // 项目ID
        uint256 _projectId = projectArr.length;
        // 记录项目ID
        namehashToId[keccak256(abi.encodePacked(name))] = _projectId;
        // 推入处理中数组
        pendingArr.push(_projectId);
        emit SaveProject(
            name,
            msg.sender,
            projectContract,
            startTime,
            endTime,
            ipfsAddress,
            projectPrice,
            _projectId
        );
    }

    /**
     * @dev 修改
     * @param name 项目名称
     * @param startTime 开始铸造的时间
     * @param endTime 结束铸造的时间
     * @param ipfsAddress ipfs中存储的json信息地址
     */
    function editProject(
        string calldata name,
        uint256 startTime,
        uint256 endTime,
        string calldata ipfsAddress
    ) public {
        // 项目结构体
        (uint256 _projectId, Project memory _project) = getProject(name);
        // 确认调用者身份
        require(_project.owner == msg.sender, "caller is not project owner");
        // 确认状态输入正确
        require(_project.status == Status.reject, "Status error!");
        // 修改信息
        _project.startTime = startTime;
        _project.endTime = endTime;
        _project.ipfsAddress = ipfsAddress;
        _project.status = Status.pending;
        // 修改状态
        _saveProject(_projectId, _project);
        // 从驳回的数组中移除项目ID
        rejectArr.removeByValue(_projectId);
        // 推入到处理中数组
        pendingArr.push(_projectId);
        emit EditProject(name, startTime, endTime, ipfsAddress);
    }

    /**
     * @dev 状态转换
     * @param name 项目名称
     * @param status 结果状态
     */
    function projectStatus(string calldata name, Status status)
        public
        onlyAuditor
    {
        // 项目ID, 项目结构体
        (uint256 _projectId, Project memory _project) = getProject(name);
        if (_project.status == Status.pending) {
            // 确认状态输入正确
            require(
                status == Status.passed ||
                    status == Status.reject ||
                    status == Status.locked,
                "Status error!"
            );
            // 从pending数组中移除项目ID
            pendingArr.removeByValue(_projectId);
            // 如果状态为通过
            if (status == Status.passed) {
                // 推入通过数组
                passedArr.push(_projectId);
                // 修改状态
                _project.status = Status.passed;
            }
            // 如果状态为驳回
            if (status == Status.reject) {
                // 推入驳回数组
                rejectArr.push(_projectId);
                // 修改状态
                _project.status = Status.reject;
            }
            // 如果状态为锁定
            if (status == Status.locked) {
                // 推入锁定数组
                lockedArr.push(_projectId);
                // 修改状态
                _project.status = Status.locked;
            }
        } else if (_project.status == Status.challenge) {
            // 确认状态输入正确
            require(
                status == Status.passed || status == Status.locked,
                "1Status error!"
            );
            // 从挑战的数组中移除项目ID
            challengeArr.removeByValue(_projectId);
            if (status == Status.passed) {
                // 修改状态
                _project.status = Status.passed;
            }
            // 如果状态为锁定
            if (status == Status.locked) {
                // 从通过的数组中移除项目ID
                passedArr.removeByValue(_projectId);
                // 推入锁定数组
                lockedArr.push(_projectId);
                // 修改状态
                _project.status = Status.locked;
            }
        } else if (_project.status == Status.passed) {
            // 确认状态输入正确
            require(status == Status.challenge, "Status error!");
            // 推入挑战数组
            challengeArr.push(_projectId);
            // 修改状态
            _project.status = Status.challenge;
        } else {
            revert ProjectStatusError(_project.status);
        }
        _saveProject(_projectId, _project);
        // 触发事件
        emit ProjectStatus(name, status);
    }

    /// @dev 管理员设置价格
    function adminSetProjectPrice(uint256 _price) public onlyAdmin {
        projectPrice = _price;
    }

    /// @dev 管理员取款
    function adminWithdraw(address payable to) public onlyAdmin {
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    }

    function auditorClaimFee(string calldata name) public onlyAuditor {
        // 项目ID, 项目结构体
        (, Project memory _project) = getProject(name);
        require(
            _project.status == Status.locked ||
                _project.status == Status.passed,
            "Status error!"
        );
        if (_project.projectFee > 0) {
            IERC20(token).transfer(msg.sender, _project.projectFee);
            emit AuditorClaimFee(name, _project.projectFee);
        }
    }

    /// @dev 返回项目名称是否存在
    function projectName(string calldata name) public view returns (bool) {
        return namehashToId[keccak256(abi.encodePacked(name))] > 0;
    }

    function _saveProject(uint256 _projectId, Project memory _project) private {
        projectArr[_projectId - 1] = _project;
    }

    /**
     * @dev 根据开始索引和长度数量,返回制定数组
     * @param arr 指定的数组
     * @param start 开始索引
     * @param limit 返回数组长度
     */
    function getArrs(
        uint256[] memory arr,
        uint256 start,
        uint256 limit
    ) private view returns (Project[] memory) {
        // 数组长度赋值
        uint256 length = arr.length;
        // 如果开始的索引加返回的长度超过了数组的长度,则返回的长度等于数组长度减去开始索引
        uint256 _limit = start + limit <= length ? limit : length - start;
        // 返回的项目数组
        Project[] memory _projects = new Project[](_limit);
        // 开始的索引累加变量
        uint256 _index = start;
        // 用修改后的返回长度循环
        for (uint256 i = 0; i < _limit; ++i) {
            // 将项目信息赋值到新数组
            _projects[i] = projectArr[arr[_index] - 1];
            // 索引累加
            _index++;
        }
        // 返回数组
        return _projects;
    }

    /// @dev 返回通过的数组
    function getPassed(uint256 start, uint256 limit)
        public
        view
        returns (Project[] memory)
    {
        return getArrs(passedArr, start, limit);
    }

    /// @dev 返回处理中的数组
    function getPending(uint256 start, uint256 limit)
        public
        view
        returns (Project[] memory)
    {
        return getArrs(pendingArr, start, limit);
    }

    /// @dev 返回驳回的数组
    function getReject(uint256 start, uint256 limit)
        public
        view
        returns (Project[] memory)
    {
        return getArrs(rejectArr, start, limit);
    }

    /// @dev 返回锁定的数组
    function getLocked(uint256 start, uint256 limit)
        public
        view
        returns (Project[] memory)
    {
        return getArrs(lockedArr, start, limit);
    }

    /// @dev 返回挑战中的数组
    function getChallenge(uint256 start, uint256 limit)
        public
        view
        returns (Project[] memory)
    {
        return getArrs(challengeArr, start, limit);
    }

    function projectId(string calldata name)
        public
        view
        override
        returns (uint256)
    {
        uint256 _projectId = namehashToId[keccak256(abi.encodePacked(name))];
        require(_projectId > 0, "project not exist");
        return _projectId;
    }

    function getProject(string calldata name)
        public
        view
        returns (uint256, Project memory)
    {
        uint256 _projectId = projectId(name);
        return (_projectId, getProjectById(_projectId));
    }

    function getProjectById(uint256 _projectId)
        public
        view
        returns (Project memory)
    {
        Project memory _project = projectArr[_projectId - 1];
        return _project;
    }
}
