pragma solidity 0.8.10;

import "./SecretTemplate.sol";

contract SecretUser is SecretTemplate
{
    /// @notice adds a user to a secret with no access.  Must be run before trying to change an address' permissions
    /// @param _secretId ID of the secret
    /// @param _address Address of the new user
    /// @param _name Name of the new user, selected by the owner
    /// @param _publicKey Public key of the new user
    /// @param _encryptedSecret Address-specific encrypted version of the secret
    function addNewUser(uint _secretId, address _address, string memory _name, string memory _publicKey, string memory _encryptedSecret) public onlySecretOwner(_secretId)
    {
        require(secrets[_secretId].permissions[_address] != 0, "Cannot add an address that already knows this secret");
        
        secrets[_secretId].addresses.push(_address);
        secrets[_secretId].names[_address] = _name; // An applying user can't suggest a name, which might otherwise be used to try and trick someone (IE 'your doctor' applying)
        secrets[_secretId].publicKeys[_address] = _publicKey;
        secrets[_secretId].encryptedSecrets[_address] = _encryptedSecret;
        secrets[_secretId].permissions[_address] = 0;
    }
    
    /// @notice Lets the owner of a secret make an address a viewer
    /// @param _secretId ID of the secret
    /// @param _address address of the new viewer
    function makeAddressViewer(uint _secretId, address _address) public onlySecretOwner(_secretId)
    {
        secrets[_secretId].permissions[_address] = 1;
    }
    
    /// @notice Lets the owner of a secret make an address an editor
    /// @param _secretId ID of the secret
    /// @param _address address of the new editor
    function makeAddressEditor(uint _secretId, address _address) public onlySecretOwner(_secretId)
    {
        secrets[_secretId].permissions[_address] = 2;
    }
    
    /// @notice Lets the owner of a secret transfer ownership
    /// @param _secretId ID of the secret
    /// @param _address Address of the new owner
    function makeAddressOwner(uint _secretId, address _address) public onlySecretOwner(_secretId)
    {
        secrets[_secretId].permissions[msg.sender] = 2; // we know the sender is the owner because of the onlySecretOwner modifier
        secrets[_secretId].permissions[_address] = 3;
        
        secretToOwner[_secretId] = _address;
    }
    
    /// @notice Lets the owner of a secret remove a user from the secret
    /// @param _secretId ID of the secret
     /// @param _address Address of the old user
    /// @param _userId ID of the old user, given by getIndexOfAddress(address _address)
    function removeUserFromSecret(uint _secretId, address _address, uint _userId) public onlySecretOwner(_secretId)
    {
        secrets[_secretId].permissions[_address] = 0;
        secrets[_secretId].encryptedSecrets[_address] = "";
        secrets[_secretId].publicKeys[_address] = "";
        
        // The order of the addresses in the Secret.addresses list won't be preserved, but that's alright I think
        secrets[_secretId].addresses[_userId] = secrets[_secretId].addresses[secrets[_secretId].addresses.length-1];
        secrets[_secretId].addresses.pop();
    }
    
    /// @notice Gets the index of an address
    /// @dev returns -1 if the address does not have access to this secret
    /// @param _secretId ID of the secret
    /// @param _address Address for which an index will be provided
    function getIndexOfAddress(uint _secretId, address _address) public view onlySecretOwner(_secretId) returns (int)
    {
        Secret storage secret = secrets[_secretId];
        
        for(uint i = 0; i < secret.addresses.length; i ++)
        {
            if (secret.addresses[i] == _address)
            {
                return int(i);
            }
        }
        
        return -1;
    }
    
    /// @notice Gets all the secrets the sender knows
    /// @return Array of all the secret IDs
    function getUserSecrets() public view returns (uint[] memory)
    {
        uint[] memory results = new uint[](ownerSecretCount[msg.sender]);
        uint counter = 0;
        for (uint i = 0; i < secrets.length; i ++)
        {
            if (secrets[i].permissions[msg.sender] != 0)
            {
                results[counter] = i;
                counter ++;
            }
        }
        
        return results;
        
    }
}