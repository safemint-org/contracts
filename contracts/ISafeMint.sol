pragma solidity ^0.8.11;

interface ISafeMint {
    /// @dev 状态枚举类型
    enum Status {
        pending, // 处理中
        passed, // 通过
        reject, // 驳回
        challenge, // 挑战
        locked // 锁定
    }
    /// @dev 项目信息
    struct Project {
        string name; // 项目名称(唯一)
        address owner; // 项目创建者
        uint256 createTime; // 创建时间
        address projectContract; // 项目合约地址
        uint256 startTime; // 开始铸造的时间
        uint256 endTime; // 结束铸造的时间
        string ipfsAddress; // ipfs中存储的json信息地址
        uint256 projectFee; // 项目提交费
        Status status; // 状态
    }

    /// @dev 提交项目
    event SaveProject(
        string indexed name,
        address indexed owner,
        address indexed projectContract,
        uint256 startTime,
        uint256 endTime,
        string ipfsAddress,
        uint256 projectPrice,
        uint256 projectId
    );

    /// @dev 编辑项目
    event EditProject(
        string indexed name,
        uint256 startTime,
        uint256 endTime,
        string ipfsAddress
    );

    /// @dev 状态转换
    event ProjectStatus(string indexed name, Status status);

    /// @dev 审计合约提币
    event AuditorClaimFee(string indexed name, uint256 projectFee);

    /// @dev 返回项目ID
    function projectId(string calldata name) external view returns (uint256);

    /// @dev 修改项目状态
    function projectStatus(string calldata name, Status status) external;

    /// @dev 获取项目信息
    function getProject(string calldata name)
        external
        view
        returns (uint256, Project memory);

    /// @dev 获取项目信息
    function getProjectById(uint256 _projectId)
        external
        view
        returns (Project memory);

    /// @dev 审计合约提币
    function auditorClaimFee(string calldata name) external;
}
