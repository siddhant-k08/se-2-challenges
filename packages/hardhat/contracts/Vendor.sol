pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);
  
  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  uint256 public constant tokensPerEth = 100;

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public payable onlyOwner {
    require(msg.sender == owner(), "not owner");
    payable(msg.sender).transfer(address(this).balance);
  }
  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 amount) public{
    yourToken.transferFrom(msg.sender, address(this), amount);
    uint256 ethToSend = amount/100;
    (bool sent, bytes memory data) = msg.sender.call{value: ethToSend}("");
    require(sent, "Failed to send Ether");
    emit SellTokens(msg.sender,amount,ethToSend);
  }
}
