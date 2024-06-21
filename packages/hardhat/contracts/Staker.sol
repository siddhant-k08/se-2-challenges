// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staker {

  event Stake(address, uint256);

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted(){
    require( exampleExternalContract.completed() == false, "Not completed");
    _;
  }

  modifier onlyStaker(){
    // ensures that the withdraw function is only accessed by those who have staked
    require(balances[msg.sender] > 0);
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

  mapping (address=>uint256) public balances;
  uint256 public constant threshold = 1 ether;

  function stake() public payable{
    require(executed != true, "Deadline over!");
    balances[msg.sender] = msg.value;
    emit Stake(msg.sender,msg.value);
  }
  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  uint256 public deadline = block.timestamp + 72 hours;

  bool public openForWithdraw;
  bool public executed;

  function execute() public notCompleted{
    require(block.timestamp > deadline && address(this).balance >= threshold);
    if(
      address(this).balance >= threshold
    ){
      exampleExternalContract.complete{value: address(this).balance}();
      executed = true;
    }else{
      openForWithdraw = true;
    }
  }
  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public payable notCompleted onlyStaker{
    require(executed != true && address(this).balance <= threshold);
    (bool sent, bytes memory data) = msg.sender.call{value: balances[msg.sender]}("");
    require(sent, "Failed to send Ether");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns(uint256) {
    if(block.timestamp >= deadline){
      return 0;
    }else{
      return deadline-block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
