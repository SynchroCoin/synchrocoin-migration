pragma solidity ^0.4.23;

// File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: node_modules/zeppelin-solidity/contracts/ownership/Claimable.sol

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {
    // solium-disable-next-line security/no-block-members
    require(_releaseTime > block.timestamp);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }
}

// File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: contracts/Burnable.sol

/**
 * @title Burnable
 * @dev Token that can be irreversibly burned (destroyed).
 * @dev Edited zeppelin-solidity/contracts/ERC20/BurnableToken.sol for onlyOwner
 */

contract Burnable is BasicToken, Ownable {
    event Burn(address indexed burner, uint256 value);
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public onlyOwner {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}

// File: contracts/Initializable.sol

contract Initializable {
    bool public initialized = false;

    modifier afterInitialized {
        require(initialized);
        _;
    }

    modifier beforeInitialized {
        require(!initialized);
        _;
    }

    function endInitialization() internal beforeInitialized returns (bool) {
        initialized = true;
        return true;
    }
}

// File: node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/ERC223.sol

contract ERC223 is ERC20 {
    function transfer(address to, uint256 value, bytes data) public returns (bool);
    function transferFrom(address from, address to, uint256 value, bytes data) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

// File: contracts/ERC223Receiver.sol

/*
  * @title Contract that will work with ERC223 tokens.
  */
 
contract ERC223Receiver { 
/*
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

// File: contracts/PausableERC223Token.sol

/**
 * @title ERC223 token implementation.
 * @dev Standard ERC223 implementation with capability of deactivating ERC223 functionalities.
 *      Contracts that are known to support ERC20 tokens can be whitelisted to bypass tokenfallback call.
 *      Also has Pausable feature.
 */
contract PausableERC223Token is ERC223, StandardToken, Ownable, Pausable {
    using SafeMath for uint256;

    // If true will invoke token fallback else it will act as an ERC20 token
    bool public erc223Activated;
    // List of contracts which are known to have support for ERC20 tokens.
    // Needed to maintain compatibility with contracts that support ERC20 tokens but not ERC223 tokens.                      
    mapping (address => bool) public supportedContracts;
    // List of contracts which users allowed to bypass tokenFallback.
    // Needed in case user wants to send tokens to contracts that do not support ERC223 tokens, i.e. multisig wallets.
    mapping (address => mapping (address => bool)) public userAcknowledgedContracts;

    function setErc223Activated(bool _activated) external onlyOwner {
        erc223Activated = _activated;
    }

    function setSupportedContract(address _address, bool _supported) external onlyOwner {
        supportedContracts[_address] = _supported;
    }

    function setUserAcknowledgedContract(address _address, bool _acknowledged) external {
        userAcknowledgedContracts[msg.sender][_address] = _acknowledged;
    }

    /**
     * @dev Checks if target address is a contract.
     * @param _address The address to check.
     */
    function isContract(address _address) internal returns (bool) {
        uint256 codeLength;
        assembly {
            // Retrieve the size of the code on target address
            codeLength := extcodesize(_address)
        }
        return codeLength > 0;
    }

    /**
     * @dev Calls the tokenFallback function of the token receiver.
     * @param _address  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function invokeTokenReceiver(address _address, uint256 _value, bytes _data) internal {
        ERC223Receiver receiver = ERC223Receiver(_address);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _address, _value, _data);
    }

    /**
     * @dev Transfer specified amount of tokens to the specified address.
     *      Added to maintain ERC20 compatibility.
     * @param _to Receiver address.
     * @param _value Amount of tokens to be transferred.
     */
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        bytes memory emptyData;
        return transfer(_to, _value, emptyData);
    }

    /**
     * @dev Transfer specified amount of tokens to the specified address.
     *      Invokes tokenFallback if the recipient is a contract.
     *      Transaction to contracts without implementation of tokenFallback will revert.
     * @param _to Receiver address.
     * @param _value Amount of tokens to be transferred.
     * @param _data Transaction metadata.
     */
    function transfer(address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {
        bool status = super.transfer(_to, _value);

        // Invoke token receiver only when erc223 is activate, not listed on the whitelist and is a contract.
        if (erc223Activated 
            && isContract(_to)
            && supportedContracts[_to] == false 
            && userAcknowledgedContracts[msg.sender][_to] == false) {
            invokeTokenReceiver(_to, _value, _data);
        }
        return status;
    }

    /**
     * @dev Transfer specified amount of tokens from one address to another.
     *      Added to maintain ERC20 compatibility.
     * @param _from Sender address.
     * @param _to Receiver address.
     * @param _value Amount of tokens to be transferred.
     */
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        bytes memory emptyData;
        return transferFrom(_from, _to, _value, emptyData);
    }

    /**
     * @dev Transfer specified amount of tokens from one address to another.
     *      Invokes tokenFallback if the recipient is a contract.
     *      Transaction to contracts without implementation of tokenFallback will revert.
     * @param _from Sender address.
     * @param _to Receiver address.
     * @param _value Amount of tokens to be transferred.
     * @param _data Transaction metadata.
     */
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {
        bool status = super.transferFrom(_from, _to, _value);

        if (erc223Activated 
            && isContract(_to)
            && supportedContracts[_to] == false 
            && userAcknowledgedContracts[msg.sender][_to] == false) {
            invokeTokenReceiver(_to, _value, _data);
        }
        return status;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

// File: contracts/SynchroCoin.sol

/* @title SynchroCoin SYC Token
 * @dev New SynchroCoin SYC Token migration from legacy contract.
 */

contract SynchroCoin is PausableERC223Token, Claimable, Initializable, Burnable {
    string public constant name = "SynchroCoin";
    string public constant symbol = "SYC";
    uint256 public constant decimals = 18;

    ERC20 public legacySycContract; // Previous SYC Contract
    uint256 public targetSupply;    // Target supply amount to meet (total supply of the legacy contract)

    uint256 private constant TIMELOCK_RELEASE_TIME = 1540047600;    // Timelocked token release date set to October 20, 2018 15:00 GMT
    TokenTimelock public tokenTimelock;                             // TokenTimelock for Synchrolife team, advisors and partners

    event Migrate(address indexed holder, uint256 balance);

    function SynchroCoin(address _legacySycAddress) public {
        require(_legacySycAddress != address(0));

        // The previous SynchroCoin contract;
        legacySycContract = ERC20(_legacySycAddress);
        // Set the target supply to the total supply of previous SynchroCoin contract
        targetSupply = legacySycContract.totalSupply();

        pause();
    }

    /**
     * @dev Create a new timelock to replace the old one.
     * @param _legacyVaultAddress Address of the vault contract from previous SynchroCoin contract.
     */
    function migrateVault(address _legacyVaultAddress) onlyOwner beforeInitialized external {
        require(_legacyVaultAddress != address(0));

        // Lock up the tokens for the team/advisors/partners.
        uint256 timelockAmount = legacySycContract.balanceOf(_legacyVaultAddress);
        tokenTimelock = new TokenTimelock(this, msg.sender, TIMELOCK_RELEASE_TIME);
        balances[tokenTimelock] = balances[tokenTimelock].add(timelockAmount);
        totalSupply_ = totalSupply_.add(timelockAmount);
    }

    /**
     * @dev Migrate balances from on address to another.
     *      Intended use is for addresses that may lock up the funds (i.e. DEX contracts)
     * @param _from The address to migrate balance from
     * @param _to The address to migrate balance to
     */
    function migrateTo(address _from, address _to) onlyOwner beforeInitialized external returns (bool) {
        require(_from != address(0));
        require(_to != address(0));

        uint256 balance = legacySycContract.balanceOf(_from);
        require(balance > 0);

        balances[_to] = balance;
        totalSupply_ = totalSupply_.add(balance);
        emit Migrate(_to, balance);
        
        // End migration process once target supply is met
        if (shouldEndMigration()) {
            endMigrationProcess();
        }
    }

    /**
     * @dev Copies the balance of given addresses from the legacy contract
     * @param _tokenHolders Array of addresses to migrate balance from the legacy contract
     * @return True if operation was completed
     */
    function migrateBalances(address[] _tokenHolders) onlyOwner beforeInitialized public returns (bool) {
        for (uint256 i = 0; i < _tokenHolders.length; i++) {
            migrateBalance(_tokenHolders[i]);
        }
        return true;
    }

    /*
     * @dev Copies the balance of a given address from the legacy contract
     * @param _tokenHolder Address to migrate balance from the legacy contract
     * @return True if balance was copied. False if balance had already been migrated or if address has zero balance in the legacy contract
     */
    function migrateBalance(address _tokenHolder) onlyOwner beforeInitialized public returns (bool) {
        if (balances[_tokenHolder] > 0) {
            return false;   // Already migrated, therefore do nothing.
        }

        uint256 balance = legacySycContract.balanceOf(_tokenHolder);
        if (balance == 0) {
            return false;   // Has no balance in legacy contract, therefore do nothing.
        }

        // Copy balance
        balances[_tokenHolder] = balance;
        totalSupply_ = totalSupply_.add(balance);
        emit Migrate(_tokenHolder, balance);

        // End migration process once target supply is met
        if (shouldEndMigration()) {
            endMigrationProcess();
        }

        return true;
    }

    /**
     * @dev Check if total supply has met the target supply
     * @return True if the total supply has met the target supply
     */
    function shouldEndMigration() internal returns (bool) {
        return targetSupply == totalSupply_;
    }

    /**
     * @dev Set contract as initialized and unpause contract.
     */
    function endMigrationProcess() internal {
        endInitialization();
        unpause();
    }

    /**
     * @dev Do not accept incoming ether
     */
    function() public payable {
        revert();
    }
}
