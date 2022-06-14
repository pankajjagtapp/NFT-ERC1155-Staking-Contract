//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Staking is ERC1155Holder {
    using SafeERC20 for IERC20;

    IERC1155 public NFT;
    IERC20 private token;

    uint256 constant month = 30 * 24 * 60 * 60;
    uint256 constant denominator = 100;

    event NFTstaked(
        address indexed owner,
        uint256 id,
        uint256 amount,
        uint256 time
    );
    event NFTunstaked(
        address indexed owner,
        uint256 id,
        uint256 amount,
        uint256 time,
        uint256 rewardTokens
    );

    struct Staker {
        uint256 tokenId;
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => Staker) public stakesMapping;

    constructor(address _token, address _NFT) {
        token = IERC20(_token);
        NFT = IERC1155(_NFT);
    }

    // Function to stake NFTs.

    function stakeNFT(uint256 _tokenId, uint256 _amount) external {
        require(
            stakesMapping[msg.sender].tokenId == 0,
            "You have already staked!"
        );
        require(
            NFT.balanceOf(msg.sender, _tokenId) >= _amount,
            "Insufficient Balance!"
        );

        stakesMapping[msg.sender] = Staker(_tokenId, _amount, block.timestamp);
        NFT.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            "0x00"
        );

        emit NFTstaked(msg.sender, _tokenId, _amount, block.timestamp);
    }

    // Function to unstake the NFTs and distribute JagguTokens are rewards.
    // Reward Tokens = Staked Amount * Reward Rate * Elapsed Time / RewardInterval

    function unstakeNFT(uint256 _tokenId, uint256 _amount) external {
        require(
            stakesMapping[msg.sender].tokenId == _tokenId,
            "TokenId does not match!"
        );
        require(
            stakesMapping[msg.sender].amount >= _amount,
            "Staked Amount is not sufficient!"
        );

        stakesMapping[msg.sender].amount -= _amount;
        NFT.safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId,
            _amount,
            "0x00"
        );

        uint256 timeElapsed = block.timestamp -
            stakesMapping[msg.sender].timestamp;
        uint256 rewardTokens = (_calculateRate() *
            timeElapsed *
            _amount *
            10**18) / (month * 12 * denominator);

        token.safeTransfer(msg.sender, rewardTokens);

        emit NFTunstaked(
            msg.sender,
            _tokenId,
            _amount,
            block.timestamp,
            rewardTokens
        );
    }

    // Function to calculate Reward Rate in percentage

    function _calculateRate() internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp -
            stakesMapping[msg.sender].timestamp;

        if (timeElapsed < month) {
            return 0;
        } else if (timeElapsed < month * 6) {
            return 5;
        } else if (timeElapsed < month * 12) {
            return 10;
        } else {
            return 15;
        }
    }
}
