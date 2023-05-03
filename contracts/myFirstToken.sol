// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyFirstToken is ERC20, ERC20Burnable, Ownable {

    using SafeMath for uint256;
    uint256 private constant INTEREST_RATE = 10; //10 pourcent daily interest rate
    uint256 private constant REWARD_INTERVAL = 1 days;

    mapping(address => uint256) private lastRewardClaimTime; //déclare la variable LRCT comme un mapping qui stock le temps et qui restitue l'heure du claim reward


    constructor() ERC20("myFirstToken", "MFT") {
        _mint(msg.sender, 21000000 * 1 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function calculateReward(address holder) public view returns (uint256){ //déclare la fonction qui prend en argument l'addresse et qui calcul la récompense journalière du holder
        uint256 timeSinceLastClaim = block.timestamp.sub(lastRewardClaimTime[holder]); //Calcule le temps écoulé
        uint256 holderBalance = balanceOf(holder); //on récupère le solde actuel du holder

        return holderBalance.mul(INTEREST_RATE).mul(timeSinceLastClaim).div(REWARD_INTERVAL).mul(100);

    }

    function claimReward() public{
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0);
        lastRewardClaimTime[msg.sender] = block.timestamp; //met à jour l'heure du dernier claim du reward
        mint(msg.sender, reward);
    }
}