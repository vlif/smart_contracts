pragma solidity ^0.4.16;

import "./zeppelin/token/MintableToken.sol";
// import "./zeppelin/token/TokenTimelock.sol";
import './zeppelin/math/SafeMath.sol';

import "./ESportsConstants.sol";
import "./ESportsFreezingStorage.sol";

contract ESportsToken is usingESportsConstants, MintableToken {
    /**
     * @dev Pause token transfer. After successfully finished crowdsale it becomes true.
     */
    bool public paused = true;
    /**
     * @dev Accounts who can transfer token even if paused. Works only during crowdsale.
     */
    mapping(address => bool) excluded;

    // mapping (address => address[]) public frozen;
    mapping (address => ESportsFreezingStorage[]) public frozenFunds;

    function name() constant public returns (string _name) {
        return "ESports Token";
    }

    function symbol() constant public returns (bytes32 _symbol) {
        return "ERT";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
    

    function crowdsaleFinished() onlyOwner {
        paused = false;
    }

    function addExcluded(address _toExclude) onlyOwner {
        excluded[_toExclude] = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[_from]);

        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[msg.sender]);

        return super.transfer(_to, _value);
    }

    /**
     * @dev Mint timelocked tokens
     */
    // function mintTimelocked(address _to, uint256 _amount, uint64 _releaseTime)
    //         onlyOwner canMint returns (TokenTimelock) {
    //     TokenTimelock timelock = new TokenTimelock(this, _to, _releaseTime);
    //     mint(timelock, _amount);

    //     return timelock;
    // }
    function mintTimelocked(address _to, uint _amount, uint64 _releaseTime)
            onlyOwner canMint returns (ESportsFreezingStorage) {
        ESportsFreezingStorage timelock = new ESportsFreezingStorage(_releaseTime);
        mint(timelock, _amount);

        frozenFunds[_to].push(timelock);

        return timelock;
    }

    /**
     * @dev Mint tokens and freeze some of them
     */
    // function mintAndFreezePart(address _to, uint256 _totalAmount, uint8 _freezingPercent, uint64 _releaseTime)
    //         onlyOwner canMint returns (bool) {
    //     require(excluded[_to]);
    //     require(_freezingPercent <= 100);

    //     uint256 freezingAmount = _totalAmount.mul(_freezingPercent).div(100);
    //     mint(_to, _totalAmount.sub(freezingAmount));
    //     mintTimelocked(_to, freezingAmount, _releaseTime);
        
    //     return true;
    // }

    /**
     * @dev To freeze part of the token holder
     */
    // function freezePart(address _beneficiary, uint8 _freezingPercent, uint64 _releaseTime) 
    //         onlyOwner returns (bool) {
    //     require(excluded[_beneficiary]);
    //     require(_freezingPercent <= 100);
    //     require(balances[_beneficiary] > 0);

    //     uint256 freezingAmount = balances[_beneficiary].mul(_freezingPercent).div(100);
    //     balances[_beneficiary] = balances[_beneficiary].sub(freezingAmount);
    //     mintTimelocked(_beneficiary, freezingAmount, _releaseTime);

    //     return true;
    // }

    function getFrozenFundsTotalAmount(address _beneficiary) onlyOwner constant returns(uint) {
        uint total = 0;
        for (uint x = 0; x < frozenFunds[_beneficiary].length; x++) {
            // total = total + balances[frozenFunds[_beneficiary][x]];
            total = total + balanceOf(frozenFunds[_beneficiary][x]);
        }

        return total;
    }

    function returnFrozenFreeFunds(address _beneficiary) constant public returns (uint64) {
        for (uint x = 0; x < frozenFunds[_beneficiary].length; x++) {
            if (now >= frozenFunds[_beneficiary][x].releaseTime()) {
                uint256 amount = token.balanceOf(this);
                require(amount > 0);

                // token.safeTransfer(beneficiary, amount);
                token.transfer(beneficiary, amount);
            }
        }
    }
}
