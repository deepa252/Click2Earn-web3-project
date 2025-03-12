// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ClickToEarn is ERC20, Ownable {
    struct User {
        uint256 lastClickTime;
        uint256 clickCount;
    }

    mapping(address => User) public users;
    uint256 public rewardPerClick = 1 * 10**18; // 1 Token per click
    uint256 public clickCooldown = 5 seconds; // Prevent spamming
    address public nftContract; // NFT contract address

    event Clicked(address indexed user, uint256 amountEarned);

    constructor() ERC20("ClickToken", "CLK") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10**18); // Initial supply
    }

    function setNFTContract(address _nftContract) external onlyOwner {
        nftContract = _nftContract;
    }

    function click() external {
        require(block.timestamp >= users[msg.sender].lastClickTime + clickCooldown, "Wait for cooldown");

        uint256 reward = rewardPerClick;
        if (nftContract != address(0)) {
            uint256 nftBalance = IERC721(nftContract).balanceOf(msg.sender);
            if (nftBalance > 0) {
                reward = reward * 2; // Double rewards if user owns NFT
            }
        }

        _mint(msg.sender, reward);
        users[msg.sender].lastClickTime = block.timestamp;
        users[msg.sender].clickCount++;

        emit Clicked(msg.sender, reward);
    }

    function setRewardPerClick(uint256 _reward) external onlyOwner {
        rewardPerClick = _reward;
    }

    function setClickCooldown(uint256 _cooldown) external onlyOwner {
        clickCooldown = _cooldown;
    }
}
