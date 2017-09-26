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

contract Crowdsale is usingESportsConstants {
    using SafeMath for uint;
    
    // The token being sold
    Token public token;
    
    uint constant TEAM_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00% // Founders
    //address constant TEAM_ADDRESS_KOVAN = 0x0065ee8FB8697C686C27C0cE79ec6FA1f395D27e;
    address constant TEAM_ADDRESS_KOVAN = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
    
    function Crowdsale(address _addr, uint32 _startTime) {
        token = Token(_addr);
        //token.mint(0xdD870fA1b7C4700F2BD7f44238821C26f7392148, 12000000);
        token.mintTimelocked(TEAM_ADDRESS_KOVAN, TEAM_TOKENS.mul(20).div(100), _startTime + 10 seconds);
        token.mintTimelocked(TEAM_ADDRESS_KOVAN, TEAM_TOKENS.mul(30).div(100), _startTime + 3 minutes);
        token.mintTimelocked(TEAM_ADDRESS_KOVAN, TEAM_TOKENS.mul(30).div(100), _startTime + 5 minutes);
        token.mint(TEAM_ADDRESS_KOVAN, TEAM_TOKENS.mul(20).div(100));
    }
    
    function getFrozenFundsTotalAmount(address _beneficiary) constant public returns (uint) {
        //return token.getVoterTokenCount(_beneficiary);
        //return token.voterStructs[_beneficiary].tokenIndex.length;
        return token.getFrozenFundsTotalAmount(_beneficiary);
    }
    
    function returnFrozenFreeFunds(address _beneficiary) public returns (uint) {
        return token.returnFrozenFreeFunds(_beneficiary);
    }
    
    function tokenFreezePart(address _beneficiary, uint _freezingAmount, uint64 _releaseTime) //uint8 _freezingPercent
         returns (bool) {
        return token.freezePart(_beneficiary, _freezingAmount, _releaseTime);
    }
}

contract Token {
    using SafeMath for uint;
    event Transfer(address indexed from, address indexed to, uint256 value);
    mapping (address => uint256) public balances;
    uint256 public totalSupply;
    
    struct Foo {
        address x;
    }
    struct FrozenFund {
        //address voterAddress;
        //uint256 tokensBought;
        //mapping (bytes32 => uint256) tokensUsed;
        //bytes32[] index; // a list of mapping keys that exist for the voter
        address voterAddress;
        uint64 releaseTime;
    }
    mapping (address => ESportsFreezingStorage[]) public frozenFunds;
    //mapping(uint => Foo[]) foo;
    //mapping (address => address[]) public frozen;
    
    mapping(address => bool) excluded;
    
    function mint(address _to, uint256 _amount) returns (bool) { 
        totalSupply = totalSupply+_amount;
        balances[_to] = balances[_to]+_amount;
        return true;
    }
    
    function mintTimelocked(address _to, uint _amount, uint64 _releaseTime)
              returns (ESportsFreezingStorage) {
        ESportsFreezingStorage timelock = new ESportsFreezingStorage(this, _releaseTime);
        mint(timelock, _amount);

        //frozen[_to].push(timelock);
        frozenFunds[_to].push(timelock);

        return timelock;
    }
    
   function getFrozenFundsTotalAmount(address _beneficiary) constant returns(uint) {
        uint total = 0;
        for (uint x = 0; x < frozenFunds[_beneficiary].length; x++) {
            total = total + balances[frozenFunds[_beneficiary][x]];
        }
        return total;
    }
    
    function getLength(address _beneficiary) constant returns(uint) {
        return frozenFunds[_beneficiary].length;
    }
    
    function getAmountTest(address _beneficiary) constant returns(address) {
        return frozenFunds[_beneficiary][0];
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function returnFrozenFreeFunds(address _beneficiary) public returns (uint) {
        uint total = 0;
        ESportsFreezingStorage[] storage frozen = frozenFunds[_beneficiary];
        for (uint x = 0; x < frozen.length; x++) {
            //address frozenContract = frozen[x];
            uint ft = frozen[x].release(_beneficiary);
            total = total + ft;
        }
        return total;
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
    
    function test(address _to) constant returns(bool) {
        balances[_to] = balances[_to] - 1;
        return true;
    }
    
    function addExcludedInternal(address _toExclude) internal {
        excluded[_toExclude] = true;
    }
    
    function freezePart(address _beneficiary, uint _freezingAmount, uint64 _releaseTime) //uint8 _freezingPercent
             returns (bool) {
        //require(excluded[_beneficiary]);
        //require(_freezingPercent <= 100);

        //uint256 freezingAmount = balances[_beneficiary].mul(_freezingPercent).div(100);
        ESportsFreezingStorage timelock = new ESportsFreezingStorage(this, _releaseTime);
        frozenFunds[_beneficiary].push(timelock);
        addExcludedInternal(address(timelock));
        
        transferFrom(_beneficiary, address(timelock), _freezingAmount);

        return true;
    }
}

contract ESportsFreezingStorage {
	// timestamp when token release is enabled
    uint64 public releaseTime;
    Token token;

    function ESportsFreezingStorage(Token _token, uint64 _releaseTime) {
        require(_releaseTime > now);
   		
        releaseTime = _releaseTime;
        token = _token;
    }
    
    function release(address _beneficiary) returns(uint) { //onlyOwner
        //require(now >= releaseTime);
        if (now < releaseTime) return 0;

        uint256 amount = token.balanceOf(this);
        //require(amount > 0);
        if (amount <= 0)  return 0;

        // token.safeTransfer(beneficiary, amount);
        bool res = token.transfer(_beneficiary, amount);
        if (!res) return 0;
        
        return amount;
    }
}