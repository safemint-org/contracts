// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File @openzeppelin/contracts/utils/structs/EnumerableSet.sol@v4.6.0

// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// File @openzeppelin/contracts/utils/Address.sol@v4.6.0

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// File @openzeppelin/contracts/utils/Context.sol@v4.6.0

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File contracts/access/AccessControl.sol


pragma solidity 0.8.11;

// This is adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/access/AccessControl.sol
// The only difference is added getRoleMemberIndex(bytes32 role, address account) function.



/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the index of the account that have `role`.
     */
    function getRoleMemberIndex(bytes32 role, address account) public view returns (uint256) {
        return _roles[role].members._inner._indexes[bytes32(uint256(uint160(account)))];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// File contracts/ISafeMint.sol

pragma solidity ^0.8.11;

interface ISafeMint {
    /// @dev ??????????????????
    enum Status {
        pending, // ?????????
        passed, // ??????
        reject, // ??????
        challenge, // ??????
        locked // ??????
    }
    /// @dev ????????????
    struct Project {
        string name; // ????????????(??????)
        address owner; // ???????????????
        uint256 createTime; // ????????????
        address projectContract; // ??????????????????
        uint256 startTime; // ?????????????????????
        uint256 endTime; // ?????????????????????
        string ipfsAddress; // ipfs????????????json????????????
        uint256 projectFee; // ???????????????
        Status status; // ??????
    }

    /// @dev ????????????
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

    /// @dev ????????????
    event EditProject(
        string indexed name,
        uint256 startTime,
        uint256 endTime,
        string ipfsAddress
    );

    /// @dev ????????????
    event ProjectStatus(string indexed name, Status status);

    /// @dev ??????????????????
    event AuditorClaimFee(string indexed name, uint256 projectFee);

    /// @dev ????????????ID
    function projectId(string calldata name) external view returns (uint256);

    /// @dev ??????????????????
    function projectStatus(string calldata name, Status status) external;

    /// @dev ??????????????????
    function getProject(string calldata name)
        external
        view
        returns (uint256, Project memory);

    /// @dev ??????????????????
    function getProjectById(uint256 _projectId)
        external
        view
        returns (Project memory);

    /// @dev ??????????????????
    function auditorClaimFee(string calldata name) external;
}


// File contracts/ISafeMintAudit.sol

pragma solidity ^0.8.11;

interface ISafeMintAudit {
    /// @dev ????????????
    struct Audit {
        uint256 projectId; // ??????id??????
        address auditor; // ?????????
        uint256 auditTime; // ????????????
        string comments; // ????????????
        uint256 auditFee; // ????????????
        ISafeMint.Status status; // ??????
    }

    /// @dev ????????????
    struct Challenge {
        uint256 projectId; // ??????id??????
        address challenger; // ?????????
        uint256 time; // ????????????
        string comments; // ????????????
        uint256 challengeFee; // ????????????
    }

    /// @dev ??????????????????
    struct FeeRecord {
        uint256 auditTime; // ????????????
        address auditor; // ?????????
        uint256 value; // ????????????
    }

    /// @dev ????????????
    event AuditProject(
        string indexed name,
        address indexed auditor,
        uint256 auditPrice,
        string comments,
        ISafeMint.Status status
    );

    /// @dev ????????????
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


// File contracts/SafeMintAuditData.sol

pragma solidity ^0.8.11;

contract SafeMintAuditData is ISafeMintAudit {
    /// @dev ??????ID=>??????????????????,????????????
    mapping(uint256 => Audit[]) public auditRecord;
    /// @dev ??????ID=>??????????????????,????????????
    mapping(uint256 => Challenge[]) public challengeRecord;
    /// @dev ??????ID=>????????????(????????????+????????????)
    mapping(uint256 => FeeRecord) public feeRecord;

    /// @dev ERC20 Token address
    address public token;
    /// @dev safeMint????????????
    address public safeMint;
    /// @dev ????????????
    uint256 public auditPrice;
    /// @dev ????????????
    uint256 public challengePrice;
    /// @dev ????????????
    uint256 public duration = 19;

    // Auditor ??????
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    // Arbitrator ??????
    bytes32 public constant ARBITRATOR_ROLE = keccak256("ARBITRATOR_ROLE");
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.6.0

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File contracts/SafeMintAudit.sol

pragma solidity ^0.8.11;



contract SafeMintAudit is AccessControl, SafeMintAuditData {
    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "sender doesn't have admin role"
        );
        _;
    }

    /// @dev ????????????
    constructor(address _token, address _safeMint) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        token = _token;
        safeMint = _safeMint;
    }

    /**
     * @dev ????????????
     * @param name ????????????
     * @param comments ????????????
     * @param status ????????????
     */
    function audit(
        string calldata name,
        string calldata comments,
        ISafeMint.Status status
    ) public {
        // ?????????????????????
        require(
            hasRole(AUDITOR_ROLE, msg.sender),
            "sender doesn't have auditor role"
        );
        // ????????????????????????
        require(
            status == ISafeMint.Status.passed ||
                status == ISafeMint.Status.reject ||
                status == ISafeMint.Status.locked,
            "Status error!"
        );
        // ??????ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // ??????????????????
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // ????????????????????????
        require(
            _project.status == ISafeMint.Status.pending,
            "Project status error!"
        );

        uint256 _auditFee;
        if (feeRecord[_projectId].auditTime == 0) {
            _auditFee = auditPrice;
            // ??????????????????
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
        // ??????????????????
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
        // ????????????
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
        // ????????????
        emit AuditProject(name, msg.sender, auditPrice, comments, status);
    }

    /**
     * @dev ????????????
     * @param name ????????????
     * @param comments ????????????
     */
    function challenge(string calldata name, string calldata comments) public {
        // ??????????????????
        IERC20(token).transferFrom(msg.sender, address(this), challengePrice);
        // ??????ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // ????????????????????????
        require(
            feeRecord[_projectId].auditTime + duration > block.timestamp,
            "expired!"
        );
        // ????????????????????????
        challengeRecord[_projectId].push(
            Challenge({
                projectId: _projectId,
                challenger: msg.sender,
                time: block.timestamp,
                challengeFee: challengePrice,
                comments: comments
            })
        );
        // ????????????
        ISafeMint(safeMint).projectStatus(name, ISafeMint.Status.challenge);
        emit ChallengeProject(name, msg.sender, challengePrice, comments);
    }

    /**
     * @dev ????????????
     * @param name ????????????
     * @param status ????????????
     */
    function arbitrate(string calldata name, ISafeMint.Status status) public {
        // ?????????????????????
        require(
            hasRole(ARBITRATOR_ROLE, msg.sender),
            "sender doesn't have arbitrator role"
        );
        // ????????????????????????
        require(
            status == ISafeMint.Status.passed ||
                status == ISafeMint.Status.locked,
            "Status error!"
        );
        // ??????ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // ??????????????????
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // ????????????????????????
        require(
            _project.status == ISafeMint.Status.challenge,
            "Project status error!"
        );

        // ?????????????????????
        if (status == ISafeMint.Status.passed) {
            // ????????????
            uint256 _challengeFee;
            // ????????????????????????
            for (uint256 i; i < challengeRecord[_projectId].length; ++i) {
                _challengeFee += challengeRecord[_projectId][i].challengeFee;
                challengeRecord[_projectId][i].challengeFee = 0;
            }
            // ????????????????????????????????????
            feeRecord[_projectId].value += _challengeFee;
        }
        // ?????????????????????
        if (status == ISafeMint.Status.locked) {
            // ????????????????????????
            uint256 chellengeLength = challengeRecord[_projectId].length;
            // ???????????? = ?????????????????? * 1e18 / ??????????????????
            uint256 chellengeReward = (feeRecord[_projectId].value * 1e18) /
                chellengeLength;
            // ????????????????????????
            for (uint256 i; i < chellengeLength; ++i) {
                // ???????????????????????????????????????
                challengeRecord[_projectId][i].challengeFee +=
                    chellengeReward /
                    1e18;
            }
            feeRecord[_projectId].value = 0;
        }
        // ??????????????????
        ISafeMint(safeMint).projectStatus(name, status);
        emit ArbitrateProject(name, msg.sender, status);
    }

    /// @dev ??????????????????
    function claimAuditReward(string calldata name) public {
        // ??????ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // ????????????????????????
        require(
            feeRecord[_projectId].auditTime + duration < block.timestamp,
            "auditTime < duration!"
        );
        // ??????????????????
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // ???????????????????????????????????????????????????
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

    /// @dev ??????????????????
    function claimChellengeReward(string calldata name) public {
        // ??????ID
        uint256 _projectId = ISafeMint(safeMint).projectId(name);
        // ????????????????????????
        require(
            feeRecord[_projectId].auditTime + duration < block.timestamp,
            "auditTime < duration!"
        );
        ISafeMint.Project memory _project = ISafeMint(safeMint).getProjectById(
            _projectId
        );
        // ???????????????????????????????????????
        require(_project.status == ISafeMint.Status.locked, "Starus error");
        // ????????????
        uint256 challengeFee;
        // ??????????????????
        for (uint256 i = 0; i < challengeRecord[_projectId].length; i++) {
            // ??????????????????????????????,????????????>0
            if (challengeRecord[_projectId][i].challenger == msg.sender) {
                challengeFee += challengeRecord[_projectId][i].challengeFee;
            }
        }
        if (challengeFee > 0) {
            IERC20(token).transfer(msg.sender, challengeFee);
        }
    }

    /// @dev ???????????????????????????
    function adminSetAuditPrice(uint256 _price) public onlyAdmin {
        auditPrice = _price;
    }

    /// @dev ???????????????????????????
    function adminSetChellengePrice(uint256 _price) public onlyAdmin {
        challengePrice = _price;
    }

    /// @dev ???????????????????????????
    function adminSetDuration(uint256 _duration) public onlyAdmin {
        duration = _duration;
    }

    /// @dev ???????????????
    function adminWithdraw(address payable to) public onlyAdmin {
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    }
}
