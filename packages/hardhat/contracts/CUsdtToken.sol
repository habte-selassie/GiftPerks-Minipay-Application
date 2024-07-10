// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CUSDT is ERC20 {
    constructor() ERC20("Celo USDT Token", "cusdt"){

    }

    function mintCusdToken(address _recipient, uint256 _amount) public {
        _mint(_recipient,_amount*10**18);
    }
    
    function getTokenAddress() public view returns(address){
        return address(this);
    }
    
}