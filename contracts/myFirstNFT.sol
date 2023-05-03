// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyFirstNFT is ERC721, Ownable {
    constructor() ERC721("MyFirstNFT", "BBS") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://doors3.io";
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}