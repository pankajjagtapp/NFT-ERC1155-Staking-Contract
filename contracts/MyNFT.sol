// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract MyNFT is ERC1155, Ownable, ERC1155Burnable {
    constructor() ERC1155("") {}

    function setURI(string memory _newURI) public onlyOwner {
        _setURI(_newURI);
    }

    function mint(
        address _account,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public onlyOwner {
        _mint(_account, _id, _amount, _data);
    }
}
