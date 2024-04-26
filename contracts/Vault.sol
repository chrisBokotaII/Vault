// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EMMA.sol";

contract Vault is Ownable, ReentrancyGuard {
    EMMA public token;
    uint256 public depotrate = 10;
    uint256 public withdrawRate= 8;

    mapping(address => uint256) public points;
    address[] public customers;

    event Deposit(address indexed from, uint256 amount, uint256 points, uint256 tokens);
    event Withdraw(address indexed to, uint256 amount, uint256 tokensBurned);

    constructor(address _token) Ownable(msg.sender) {
        token = EMMA(_token);
    }

    receive() external payable {
        depositEther();
    }

    function depositEther() public payable nonReentrant {
        require(msg.value > 0, "Amount must be greater than 0");
         
        if (points[msg.sender] == 0) {
            customers.push(msg.sender);
        }

        points[msg.sender] += 5;

        uint256 tokenAmount = msg.value * depotrate;
        token.mint(msg.sender, tokenAmount);

        emit Deposit(msg.sender, msg.value, points[msg.sender], tokenAmount);
    }
//TODO: add onclain verification for reward claim

    function withdraw(uint256 tokenAmount) public  nonReentrant {
        require(token.balanceOf(msg.sender) >= tokenAmount, "Not enough tokens in the vault");

        uint256 ethAmount = tokenAmount / withdrawRate;
        require(ethAmount > 0, "Amount must be greater than 0");

        token.burn(msg.sender, tokenAmount);
        payable(msg.sender).transfer(ethAmount);

        emit Withdraw(msg.sender, ethAmount, tokenAmount);
    }

    function changeRate(uint256 _rate,uint256 _withdrawRate) public onlyOwner {
        depotrate = _rate;
        withdrawRate=_withdrawRate;
    }
}
