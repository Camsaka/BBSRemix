// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";


contract Creator {
        function royalties(uint256 price) public pure returns (uint256){
            return((price * 10) / 100); //10% de commission
        }
}

contract GamePlatform is ERC1155, Ownable, ERC1155Receiver {

    //Items structure
    struct MarketplaceItem {
        uint256 id;
        uint256 price;
        uint256 quantity;
        address payable seller;
        address payable buyer;
        bool isSold;
    }

    //Array represent all items in sell (normally using mapping! to much gas with array)
    MarketplaceItem[] public marketplace;
    
    //mandatory constructor for ERC-1155 standard
    constructor() ERC1155("") {}

    //All those function are mandatories to authorized transfer to this contract
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    //mandatory function for ERC-1155 standard
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    
    //mint function only by contract owner
    function mint(uint256 id, uint256 quantity, bytes memory data) public onlyOwner{
        _mint(msg.sender, id, quantity, data);
    }

    //selle function assign NFT to contract address and push it in the array
    function sell(uint256 id, uint price, uint256 quantity) public {
        //on demande si l'utilisateur à bien suffisemment de NFT pour les vendre
        require(balanceOf(msg.sender, id) <= quantity, "You do not own enough NFTs to sell.");
        //address(this) correspond à l'adresse de ce smart contract
        safeTransferFrom(msg.sender, address(this), id, quantity, "0x6d6168616d000000000000000000000000000000000000000000000000000000");
        //push item in  array, notice that first buyer address is initiate at "0"
        marketplace.push(MarketplaceItem(id, price, quantity, payable(msg.sender), payable(address(0)), false));
    }

    //buy function DEPRECATED
    function buy(uint256 index, uint256 quantity) public payable{
        //tests for validity of transactions
        require(marketplace[index].quantity <= quantity, "not enough quantity available");
        require(msg.value == marketplace[index].price * quantity, "Invalid price ");
        //transfer item to buyer address
        safeTransferFrom(address(this), msg.sender, marketplace[index].id, quantity, "0x6d6168616d000000000000000000000000000000000000000000000000000000");
        //transfer assets to seller
        marketplace[index].seller.transfer(msg.value);
        //complete item informations (buyer address and isSold boolean)&
        marketplace[index].buyer = payable(msg.sender);
        marketplace[index].isSold = true;    
    }

    //function returns marketplace array
    function getMarketplaceItems() public view returns(MarketplaceItem[] memory){
        return marketplace;
    }

    //return royalties for an item DEPRECATED
    function getRoyalties(uint256 index) public returns (uint256){
        require(marketplace[index].isSold == true, "Item has not neen sold yet");
        Creator creator = new Creator();
        return creator.royalties(marketplace[index].price);
    }

    //bytes format : 0x6d6168616d000000000000000000000000000000000000000000000000000000
 
}