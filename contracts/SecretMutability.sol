pragma solidity 0.8.10;

import "./SecretUser.sol";

contract SecretMutability is SecretUser
{
    /// @notice Create a new secret, assigning the creator as the owner
    /// @param _ownerPublicKey Name of the secret, stored in an unencrypted state
    /// @param _ownerPublicKey Public key of the owner
    /// @param _encryptedSecret Secret encrypted with the owner's public key
    function createSecret(string memory _secretName, string memory _ownerPublicKey, string memory _encryptedSecret) public
    {
        secrets.push();
        uint id = secrets.length - 1;
        
        secrets[id].secretName = _secretName;
        secrets[id].publicKeys[msg.sender] = _ownerPublicKey;
        secrets[id].encryptedSecrets[msg.sender] = _encryptedSecret;
        secrets[id].permissions[msg.sender] = 3; // set created to be the owner
        
        secretToOwner[id] = msg.sender;
        
        ownerSecretCount[msg.sender] ++;
    }
    
    /// @notice Lets someone request access to a secret
    /// @param _secretId Id of the secret
    /// @param _publicKey Public key of the user requesting access
    /// @param _requestedPermission Requested permissions
    function requestAccess(uint _secretId, string memory _publicKey, uint8 _requestedPermission) public
    {
        uint id = secrets[_secretId].accessRequests.length;
        secrets[_secretId].accessRequests.push();
        
        secrets[_secretId].accessRequests[id].user = msg.sender;
        secrets[_secretId].accessRequests[id].publicKey = _publicKey;
        secrets[_secretId].accessRequests[id].requestedPermission = _requestedPermission;
    }
     
    /// @notice Lets someone request to change a secret
    /// @param _secretId Id of the secret
    /// @param _newSecret New value of the secret, encoded with the owner's public key
    function requestChange(uint _secretId, string memory _newSecret) public
    {
        uint id = secrets[_secretId].changeRequests.length;
        secrets[_secretId].changeRequests.push();
        
        secrets[_secretId].changeRequests[id].user = msg.sender;
        secrets[_secretId].changeRequests[id].newSecret = _newSecret;
    }
    
    /// @notice Lets the owner of a secret change it
    /// @param _secretId ID of the secret
    /// @param _newEncryptedSecrets List of secrets encrypted for each user
    function changeSecret(uint _secretId, string[] memory _newEncryptedSecrets) public onlySecretOwner(_secretId)
    {
        require (_newEncryptedSecrets.length ==  secrets[_secretId].addresses.length, "The number of encrypted secrets must match the number of addresses with access to this secret.");
        
        for (uint i = 0; i < secrets[_secretId].addresses.length; i ++)
        {
            secrets[_secretId].encryptedSecrets[secrets[_secretId].addresses[i]] = _newEncryptedSecrets[i];
        }
    }
}