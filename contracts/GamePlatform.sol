// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Creator {
        function royalties(uint256 price) public pure returns (uint256){
            return((price * 10) / 100); //10% de commission
        }
}

contract GamePlatform is ERC1155, Ownable {

    struct MarketplaceItem {
        uint256 id;
        uint256 price;
        uint256 quantity;
        address payable seller;
        address payable buyer;
        bool isSold;
    }

    MarketplaceItem[] public marketplace;
    
    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    
    function mint(uint256 id, uint256 quantity, bytes memory data) public onlyOwner{
        _mint(msg.sender, id, quantity, data);
    }


    function sell(uint256 id, uint price, uint256 quantity) public {
        //on demande si l'utilisateur à bien suffisemment de NFT pour les vendre
        require(balanceOf(msg.sender, id) >= quantity, "You do not own enough NFTs to sell.");
        //address(this) correspond à l'adresse de ce smart contract
        safeTransferFrom(msg.sender, address(this), id, quantity, "");
        marketplace.push(MarketplaceItem(id, price, quantity, payable(msg.sender), payable(address(0)), false));
    }


    function buy(uint256 index, uint256 quantity) public payable{
        require(marketplace[index].quantity >= quantity, "not enough quantity available");
        require(msg.value == marketplace[index].price * quantity, "Invalid price ");
        safeTransferFrom(address(this), msg.sender, marketplace[index].id, quantity, "");
        marketplace[index].seller.transfer(msg.value);
        marketplace[index].buyer = payable(msg.sender);
        marketplace[index].isSold = true;    
    }

    function getMarketplaceItems() public view returns(MarketplaceItem[] memory){
        return marketplace;
    }

    function getRoyalties(uint256 index) public returns (uint256){
        require(marketplace[index].isSold == true, "Item has not neen sold yet");
        Creator creator = new Creator();
        return creator.royalties(marketplace[index].price);
    }
 
}