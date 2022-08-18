// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AFStaking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256[] stakedTokens;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC721 nftCollection; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. AF to distribute per block.
        uint256 lastRewardBlock; // Last block number that AF distribution occurs.
        uint256 accAFPerShare; // Accumulated AF per share, times 1e12. See below.
    }

    // The REWARD TOKEN
    IERC20 public immutable rewardToken;

    // AF tokens created per block.
    uint256 public rewardPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when AF mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        IERC721 _nftCollection,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(
            PoolInfo({
                nftCollection: _nftCollection,
                allocPoint: 1000,
                lastRewardBlock: startBlock,
                accAFPerShare: 0
            })
        );

        totalAllocPoint = 1000;
    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[_user];
        uint256 accAFPerShare = pool.accAFPerShare;
        uint256 nftCollectionSupply = pool.nftCollection.balanceOf(
            address(this)
        );
        if (block.number > pool.lastRewardBlock && nftCollectionSupply != 0) {
            uint256 cakeReward = (rewardPerBlock * pool.allocPoint) /
                totalAllocPoint;
            accAFPerShare =
                accAFPerShare +
                (cakeReward * (1e12)) /
                (nftCollectionSupply);
        }
        return
            (user.stakedTokens.length * (accAFPerShare)) /
            (1e12) -
            (user.rewardDebt);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 nftCollectionSupply = pool.nftCollection.balanceOf(
            address(this)
        );
        if (nftCollectionSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 cakeReward = (rewardPerBlock * (pool.allocPoint)) /
            (totalAllocPoint);
        pool.accAFPerShare =
            pool.accAFPerShare +
            (cakeReward * (1e12)) /
            (nftCollectionSupply);
        pool.lastRewardBlock = block.number;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Stake nft
    function deposit(uint256 _tokenId) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        updatePool(0);
        user.stakedTokens.push(_tokenId);
        pool.nftCollection.transferFrom(msg.sender, address(this), _tokenId);
        if (user.stakedTokens.length > 0) {
            uint256 pending = (user.stakedTokens.length *
                (pool.accAFPerShare)) /
                (1e12) -
                (user.rewardDebt);
            if (pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }
        user.rewardDebt =
            (user.stakedTokens.length * (pool.accAFPerShare)) /
            (1e12);

        emit Deposit(msg.sender, user.stakedTokens.length);
    }

    function findNFTIndex(uint256 _tokenId)
        internal
        view
        returns (uint256 _index)
    {
        UserInfo storage user = userInfo[msg.sender];
        uint256 index = 0;
        for (uint256 i = 0; i < user.stakedTokens.length; i++) {
            if (user.stakedTokens[i] == _tokenId) {
                index = i;
                break;
            }
        }
        return index;
    }

    // Withdraw tokens from STAKING.
    function withdraw(uint256 _tokenId) public nonReentrant {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        require(user.stakedTokens.length >= 1, "withdraw: not good");

        uint256 nftIndex = findNFTIndex(_tokenId);
        require(user.stakedTokens[nftIndex] != 0, "nft doesn't exist");

        updatePool(0);

        uint256 pending = (user.stakedTokens.length * (pool.accAFPerShare)) /
            (1e12) -
            (user.rewardDebt);

        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        // Remove element from array while also ensuring the length of the stakedtokens stays the same
        user.stakedTokens[nftIndex] = user.stakedTokens[
            user.stakedTokens.length - 1
        ];
        user.stakedTokens.pop();

        pool.nftCollection.transferFrom(address(this), msg.sender, _tokenId);

        user.rewardDebt =
            (user.stakedTokens.length * (pool.accAFPerShare)) /
            (1e12);

        emit Withdraw(msg.sender, 1);
    }
}
