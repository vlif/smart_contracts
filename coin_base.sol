pragma solidity ^0.4.16;

//interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract owned {
    address public owner;
    
    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract MyToken is owned  {
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    //mapping (address => mapping (address => uint256)) public allowance;
    
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals;
    
    uint256 public totalSupply;
    
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    
    uint256 public sellPrice;
    uint256 public buyPrice;
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    //event Burn(address indexed from, uint256 value);

    uint minBalanceForAccounts;

    
    //uint currentChallenge = 1; // Can you figure out the cubic root of this number?

    bytes32 public currentChallenge;                         // The coin starts with a challenge
    uint public timeOfLastProof;                             // Variable to keep track of when rewards were given
    uint public difficulty = 10**32;                         // Difficulty starts reasonably low

    // Initializes contract with initial supply tokens to the creator of the contract
    function MyToken(
        uint256 initialSupply, 
        string tokenName, 
        string tokenSymbol, 
        uint8 decimalUnits,
        address centralMinter
    ) {
        if (centralMinter != 0) owner = centralMinter;
        
        if (initialSupply == 0) initialSupply = 1000000; // by default
        
        //msg.sender
        balanceOf[this] = initialSupply;              // Give the creator all initial tokens
        
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        
        totalSupply = initialSupply;
        
        timeOfLastProof = now;
    }

    // Send coins
    function transfer(address _to, uint _value) { //internal //address _from,
        require(_to != 0x0);                                // Prevent transfer to 0x0 address. Use burn() instead
        
        //require(balanceOf[_from] >= _value);                 // Check if the sender has enough
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // Check for overflows
        
        //require(approvedAccount[msg.sender]);
        //require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
    
        //balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;                           // Add the same to the recipient
    
        // Notify anyone listening that this transfer took place
        //Transfer(_from, _to, _value);
        Transfer(msg.sender, _to, _value);
        
        // This will ensure that no account receiving the token has less than the necessary ether to pay the fees.
        if (msg.sender.balance < minBalanceForAccounts)
            sell((minBalanceForAccounts - msg.sender.balance) / sellPrice);
        //if (_to.balance<minBalanceForAccounts)
        //    _to.send(sell((minBalanceForAccounts - _to.balance) / sellPrice));
    }
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    //approvedAccount 
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    
    // single central buyer and seller
    function buy() payable returns (uint amount) {
        // msg.value : number of wei sent with the message
        amount = msg.value / buyPrice;                    // calculates the amount
        require(balanceOf[this] >= amount);               // checks if it has enough to sell
        
        balanceOf[msg.sender] += amount;                  // adds the amount to buyer's balance
        balanceOf[this] -= amount;                        // subtracts amount from seller's balance
        
        Transfer(this, msg.sender, amount);               // execute an event reflecting the change
        
        return amount;                                    // ends function and returns
    }
    
    function sell(uint amount) returns (uint revenue) {
        require(balanceOf[msg.sender] >= amount);         // checks if the sender has enough to sell
        
        balanceOf[this] += amount;                        // adds the amount to owner's balance
        balanceOf[msg.sender] -= amount;                  // subtracts the amount from seller's balance
        
        revenue = amount * sellPrice;
        require(msg.sender.send(revenue));                // sends ether to the seller: it's important to do this last to prevent recursion attacks
        
        Transfer(msg.sender, this, amount);               // executes an event reflecting on the change
        
        return revenue;                                   // ends function and returns
    }
    
    function setMinBalance(uint minimumBalanceInFinney) onlyOwner {
        minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }
    
    
    /*
    function giveBlockReward() {
        balanceOf[block.coinbase] += 1;
    }

    function rewardMathGeniuses(uint answerToCurrentReward, uint nextChallenge) {
        require(answerToCurrentReward**3 == currentChallenge); // If answer is wrong do not continue
        balanceOf[msg.sender] += 1;         // Reward the player
        currentChallenge = nextChallenge;   // Set the next challenge
    }
    */
    
    function proofOfWork(uint nonce) {
        bytes8 n = bytes8(sha3(nonce, currentChallenge));    // Generate a random hash based on input
        require(n >= bytes8(difficulty));                   // Check if it's under the difficulty

        uint timeSinceLastProof = (now - timeOfLastProof);  // Calculate time since last reward was given
        require(timeSinceLastProof >=  5 seconds);         // Rewards cannot be given too quickly
        balanceOf[msg.sender] += timeSinceLastProof / 60 seconds;  // The reward to the winner grows by the minute

        difficulty = difficulty * 10 minutes / timeSinceLastProof + 1;  // Adjusts the difficulty

        timeOfLastProof = now;                              // Reset the counter
        currentChallenge = sha3(nonce, currentChallenge, block.blockhash(block.number - 1));  // Save a hash that will be used as the next proof
    }
}