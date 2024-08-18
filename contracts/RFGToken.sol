// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RFGToken is ERC20, Ownable {

    event MinterSet(address indexed minter, bool isPool);
    event Airdroped(address indexed to, uint256 value);
    event LiquidityClaimed(address indexed to, uint256 value);
    event InviteRewardClaimed(address indexed to, uint256 value);
    event InviteContractSet(address indexed inviteRewardContract);

    mapping(address => bool) public minters;

    uint256 public constant TotalSupply        = 100_000_000_000 * 1E18; // 100 billion
    uint256 public constant LiquidityAmount    = TotalSupply * 3 / 10;
    uint256 public constant AirdropAmount      = TotalSupply * 1 / 10;
    uint256 public constant InviteRewardAmount = TotalSupply * 1 / 10;
    uint256 public constant MinableAmount      = TotalSupply * 5 / 10;

    uint256 public miningAmount;
    uint256 public airdropedAmount;
    uint256 public liquidityClaimedAmount;
    uint256 public inviteRewardAmount;

    address public inviteRewardContract;
    address public bossRole;

    modifier onlyMinters() {
        require(minters[msg.sender], "only minters");
        _;
    }

    modifier onlyBoss() {
        require(msg.sender == bossRole, "only boss");
        _;
    }

    modifier onlyInviteRewardContract() {
        require(msg.sender == inviteRewardContract, "only invite reward contract");
        _;
    }

    constructor(address _owner, address _boss) ERC20("Refugee", "RFG") Ownable(_owner) {
        require(_boss != address(0), "RFG: invalid boss address");
        bossRole = _boss;
    }

    function setMinter(address minter, bool asMinter) external onlyOwner {
        require(minter != address(0), "invalid minter");
        minters[minter] = asMinter;
        emit MinterSet(minter, asMinter);
    }

    function setInviteReward(address _inviteRewardContract) external onlyOwner {
        require(_inviteRewardContract != address(0), "invalid invite reward contract");
        inviteRewardContract = _inviteRewardContract;
        emit InviteContractSet(_inviteRewardContract);
    }

    function claimAirdrop(address to, uint256 value) external onlyBoss {
        require(to != address(0), "RFG: invalid to address");
        require(airdropedAmount + value <= AirdropAmount, "RFG: airdrop pool exhausted");
        airdropedAmount += value;

        _mint(to, value);

        emit Airdroped(to, value);
    }

    function claimLiquidity(address to, uint256 value) external onlyBoss {
        require(to != address(0), "RFG: invalid to address");
        require(liquidityClaimedAmount + value <= LiquidityAmount, "RFG: liquidity pool exhausted");
        liquidityClaimedAmount += value;

        _mint(to, value);

        emit LiquidityClaimed(to, value);
    }

    function claimInviteReward(address to, uint256 value) external onlyInviteRewardContract {
        require(to != address(0), "RFG: invalid to address");
        require(inviteRewardAmount + value <= InviteRewardAmount, "RFG: invite reward pool exhausted");
        inviteRewardAmount += value;

        _mint(to, value);

        emit InviteRewardClaimed(to, value);
    }

    function mint(address to, uint256 value) external onlyMinters {
        require(to != address(0), "RFG: invalid to address");
        require(miningAmount + value <= MinableAmount, "RFG: mining pool exhausted");
        miningAmount += value;

        _mint(to, value);
    }
}

