pragma solidity ^0.4.0
contract SimpleStorage{
    uint storageData;
    function set(uint x) public {
        storageData = x;
    }
    function get() public view return (uint){
        return storageData;
    }
}