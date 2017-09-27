pragma solidity ^0.4.16;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract usingESportsConstants {
    uint constant TOKEN_DECIMALS = 18;
    uint8 constant TOKEN_DECIMALS_UINT8 = 18;
    uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;
}

contract ESportsBonusProviderI {
    address public bonusWallet;
    Token public token;
    
    function addBonus(
        address _buyer, 
        uint _totalSold,
        uint _amountTokens,
        uint32 _crowdsaleStartTime
    ) public constant returns (uint);

    function addDelayedBonus(
        address _buyer, 
        uint _totalSold,
        uint _amountTokens,
        uint32 _crowdsaleStartTime
    ) public returns (uint);

    function sendBonus(address _buyer, uint _amountBonusTokens) public returns (uint) {
        require(token.balanceOf(bonusWallet) >= _amountBonusTokens);

        bool result = token.transfer(_buyer, _amountBonusTokens);
        if (!result) return 0;

        return _amountBonusTokens;
    }

    function releaseBonus(address _buyer, uint _totalSold) public returns (uint);
}

contract ESportsBonusProvider is usingESportsConstants, ESportsBonusProviderI {
    // 1) 10% on your investment during first week
    // 2) 10% to all investors during ICO ( not presale) if we reach 5 000 000 euro investments
    // 3) 5% on the investments with the referal link
    
    using SafeMath for uint;

    mapping (address => uint256) investorBonuses;
    uint constant FIRST_WEEK = 7 * 1 days;
    uint constant BONUS_THRESHOLD_ETR = 1 * TOKEN_DECIMAL_MULTIPLIER; // 20000 * 240 // 5 000 000 EUR -> 20 000 ETH -> ETR
    
    function ESportsBonusProvider(Token _token) { //address _bonusWallet
        //bonusWallet = _bonusWallet;
        token = _token;
    }
    
    function setBonusWallet(address _bonusWallet) {
        bonusWallet = _bonusWallet;
    }
    
    function addBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) public constant returns (uint) {
        uint bonus = 0;
        
        // apply bonus for amount
        if (now < _startTime + FIRST_WEEK) {
            bonus = bonus.add(_amountTokens.mul(10).div(100)); // 1
        }

        return bonus;
    }

    function addDelayedBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) public returns (uint) {
        uint bonus = 0;

        if (_totalSold < BONUS_THRESHOLD_ETR) {
            uint amountThresholdBonus = _amountTokens.mul(10).div(100); // 2
            investorBonuses[_buyer] = investorBonuses[_buyer].add(amountThresholdBonus); 
            bonus = bonus.add(amountThresholdBonus);
        }

        return bonus;
    }

    function releaseBonus(address _buyer, uint _totalSold) public returns (uint) {
        require(_totalSold >= BONUS_THRESHOLD_ETR);
        require(investorBonuses[_buyer] > 0);

        uint amountBonusTokens = investorBonuses[_buyer];
        bool result = token.transfer(_buyer, amountBonusTokens);
        if (!result) return 0;
        investorBonuses[_buyer] = 0;

        return amountBonusTokens;
    }
}

contract Crowdsale is usingESportsConstants {
    using SafeMath for uint;
    
    // The token being sold
    Token public token;
    uint32 public startTime;
    uint32 public endTime;
    uint public rate;
    uint public weiRaised;
    uint public soldTokens;
    uint public hardCap;
    address public wallet;
    ESportsBonusProviderI public bonusProvider;
    
    uint constant TEAM_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00% // Founders
    uint constant BUFFER_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 10.00%
    
    //address constant TEAM_ADDRESS_KOVAN = 0x0065ee8FB8697C686C27C0cE79ec6FA1f395D27e;
    address constant TEAM_ADDRESS_KOVAN = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
    
    function Crowdsale(
        uint32 _startTime,
        uint32 _endTime,
        uint _softCapWei,
        uint _hardCapTokens,
        address _wallet,
        address _token,
        uint _rate,
        address _bonusProvider
    ) {
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        hardCap = _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER;
        wallet = _wallet;
        
        token = Token(_token);
        token.mint(TEAM_ADDRESS_KOVAN, TEAM_TOKENS);
        token.mint(this, BUFFER_TOKENS);
        
        bonusProvider = ESportsBonusProvider(_bonusProvider);
    }
    
    function() payable {
        buyTokens(msg.sender, msg.value);
    }
    
    
    function buyTokens(address beneficiary, uint amountWei) internal {
        require(beneficiary != 0x0);

        // total minted tokens
        uint totalSupply = token.totalSupply();

        // actual token minting rate (with considering bonuses and discounts)
        uint actualRate = 240 * 10000;
        uint rateScale = 10000;

        require(validPurchase(amountWei, actualRate, totalSupply));

        // calculate token amount to be created
        // uint tokens = rate.mul(msg.value).div(1 ether);
        uint tokens = amountWei.mul(actualRate).div(rateScale);

        // change, if minted token would be less
        uint change = 0;

        // if hard cap reached
        if (tokens.add(totalSupply) > hardCap) {
            // rest tokens
            uint maxTokens = hardCap.sub(totalSupply);
            uint realAmount = maxTokens.mul(rateScale).div(actualRate);

            // rest tokens rounded by actualRate
            tokens = realAmount.mul(actualRate).div(rateScale);
            change = amountWei - realAmount;
            amountWei = realAmount;
        }

        // bonuses
        uint bonuses = addBonus(tokens);
        addDelayedBonus(tokens);

        // update state
        weiRaised = weiRaised.add(amountWei);
        soldTokens = soldTokens.add(tokens);

        token.mint(beneficiary, tokens);
        //TokenPurchase(msg.sender, beneficiary, amountWei, tokens);

        if (bonuses > 0) {
            sendBonus(beneficiary, bonuses);
        }

        if (change != 0) {
            msg.sender.transfer(change);
        }
        //forwardFunds(amountWei);
        wallet.transfer(amountWei);
    }
    
    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap.sub(_actualRate);

        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }
    
    function addBonus(uint _amountTokens) internal returns(uint) {
        return bonusProvider.addBonus(msg.sender, soldTokens, _amountTokens, startTime);
    }

    function addDelayedBonus(uint _amountTokens) internal returns(uint) {
        return bonusProvider.addBonus(msg.sender, soldTokens, _amountTokens, startTime);
    }

    function releaseBonus() returns(uint) {
        return bonusProvider.releaseBonus(msg.sender, soldTokens);
    }

    function sendBonus(address _beneficiary, uint _amountBonusTokens) internal returns(uint) {
        return bonusProvider.sendBonus(_beneficiary, _amountBonusTokens);
    }

    function setBonusProvider(address _bonusProviderAddress) {
        require(_bonusProviderAddress != 0);

        bonusProvider = ESportsBonusProviderI(_bonusProviderAddress);
    }
}

contract Token {
    using SafeMath for uint;
    event Transfer(address indexed from, address indexed to, uint256 value);
    mapping (address => uint256) public balances;
    uint256 public totalSupply;
    
    mapping(address => bool) excluded;
    
    function mint(address _to, uint256 _amount) returns (bool) { 
        totalSupply = totalSupply+_amount;
        balances[_to] = balances[_to]+_amount;
        return true;
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        //address test = msg.sender;
        balances[msg.sender] = balances[msg.sender]-_value;
        balances[_to] = balances[_to] +_value;
        //Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(_to != address(0));

        //var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        //allowed[_from][msg.sender] = _allowance.sub(_value);
        //Transfer(_from, _to, _value);
        return true;
    }
    
    function addExcludedInternal(address _toExclude) internal {
        excluded[_toExclude] = true;
    }
}