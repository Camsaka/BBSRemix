// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GamePlatform is ERC1155, Ownable {

struct MarketPlaceItem {
    uint256 id;
    uint256 price;
    uint256 quantity;
    address payable seller;
    address payable buyer;
    bool isSold;
}



}