// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VoteNFT is ERC721, Ownable, EIP712, ERC721Votes {
    constructor() ERC721("VoteNFT", "VNFT") EIP712("VoteNFT", "1") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://github.com/Camsaka?tab=repositories";
    }


    struct proposal{
        string description;
        uint256 counter_vote;
    }

    proposal[] public proposals;

    mapping(address => bool) hasVoted;

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

    //Function to add a proposal
    function createProposal(string calldata _description) public onlyOwner{
        proposals.push(proposal(_description, 0));
    }

    //function to get all proposals
    function getProposals() public view returns(proposal[] memory){
        return proposals;
    }

    //function to get winning proposal
    function getWinningProposal() public view returns(string memory){
        uint256 winningIndex;
        uint256 maxVoteCount = 0;
        for(uint256 i; i<proposals.length; i++){
            if(proposals[i].counter_vote > maxVoteCount){
                maxVoteCount = proposals[i].counter_vote;
                winningIndex = i;
            }
        }
        return proposals[winningIndex].description;
    }
    
    //vote function 
    function vote(uint256 index) public {
        require(!hasVoted[msg.sender], "You have already voted");
        require(index < proposals.length, "invalid proposal");

        uint256 tokenCount = balanceOf(msg.sender);
        proposals[index].counter_vote += tokenCount;
        hasVoted[msg.sender] = true;
    }
}