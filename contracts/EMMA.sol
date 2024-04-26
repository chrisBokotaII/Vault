// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
 
contract EMMA is ERC20, ERC20Burnable, ERC20Pausable,AccessControl, ERC20Permit, ReentrancyGuard {
    //    bytes32 public constant MINTER= keccak256("MINTER_ROLE");
    // bytes32 public constant BURNER = keccak256("BURNER_ROLE");

    constructor()
        ERC20("EMMA", "ETK")

        ERC20Permit("EMMA")
    {
     _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(msg.sender, 10 * 10 ** decimals());
    }
function minterReward() internal {
        _mint(block.coinbase, 1 * 10 ** decimals());
    }
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
    function changeRole(address _newRole) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE,_newRole);
       
        revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    

    function mint(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused nonReentrant {
        _mint(to, amount);
    }
    function burn(address from, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused nonReentrant {
        _burn(from, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        if(!(from == address(0) || to == block.coinbase)) {
            minterReward();
        }
        super._update(from, to, value);
    }
}