pragma solidity ^0.4.0;

contract TestContract {
    address public account;
    int public value;
    string public description;
    bool public enabled;
    mapping(uint256 => Label[]) public labels;
    bytes32 public name;
    uint[] public numbers;
    mapping(address => int[]) public register;
    mapping(uint256 => Data) public requirements;

    struct Data {
        uint time;
        string ref;
        string info;
    }

    struct Label {
        string name;
        string company;
    }

    function TestContract() {
    }

    // In Remix IDE: enter address between double quotes and prefix with 0x
    // Setter: "0x583031d1113ad414f02576bd6afabfb302140225"
    function setAccount(address _account){
        account = _account;
    }


    // In Remix IDE: enter value between double quotes.
    // The string is converted into hex values
    // String must be <= 32 bytes otherwise conversion will not be ok.
    // Use http://string-functions.com/hex-string.aspx to convert to string
    // Setter: "12345678901234567890123456789012"   <== value is 32 bytes, OK
    // Setter: "123456789012345678901234567890123"  <== value is 33 bytes, NOT OK
    function setName(bytes32 _name){
        name = _name;
    }

    // In Remix IDE: enter value without double quotes
    // Setter: 12345 or 2e5
    function setValue(int _value){
        value = _value;
    }

    // In Remix IDE: enter key without double quotes.
    // _ref and _info must be entered with double quotes
    // Setter: 456, "aaa", "bbb"
    // Getter: 456
    function setRequirements(uint256 _idx, string _ref, string _info) {
        requirements[_idx] = Data(now, _ref, _info);
    }

    // In Remix IDE: enter address between double quotes and prefix with 0x
    // The array of numbers must be placed between []
    // Setter: "0x583031d1113ad414f02576bd6afabfb302140225", [1,2,3]
    // Getter: "0x583031d1113ad414f02576bd6afabfb302140225", 0  <= array index number
    function setRegister(address _account, int[] _ids) {
        register[_account] = _ids;
    }

    // In Remix IDE: The array of numbers must be placed between []
    // Setter: [1,2,3]
    // Getter: 0 <= array index number
    function setNumbers(uint[] _numbers){
        numbers = _numbers;
    }

    // In Remix IDE: enter boolean without double quotes.
    // Setter: true
    function setEnabled(bool _enabled) {
        enabled = _enabled;
    }

    // In Remix IDE: enter string between double quotes
    // Setter: "Hello World"
    function setDescription(string _description){
        description = _description;
    }

    /* THIS IS NOT ALLOWED
        TypeError: Internal type is not allowed for public or external functions
        function setLabels(uint256 _idx, Label[] _labelList) {
            labels[_idx] = _labelList;
        }
    */
}