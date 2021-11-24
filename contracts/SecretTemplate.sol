pragma solidity 0.8.10;

/// @title A contract which lets users store and access secrets in the blockchain
contract SecretTemplate
{
    struct AccessRequest
    {
        address user;
        string publicKey;
        uint8 requestedPermission;
    }
    
    struct ChangeRequest
    {
        address user;
        string newSecret; // encrypted with the owner's public key
    }
    
    struct Secret
    {
        string secretName; // unencrypted - saves storage
        
        //! I feel like there must be a better way to loop over all addresses with access, but I can't think of one
        address[] addresses;                         // list of all addresses with access to the secret.  Used by the owner for large-scale changes
        
        mapping(address => string) names;            // names coresponding to each address, set by the owner
        mapping(address => string) publicKeys;       // public keys for each user
        mapping(address => string) encryptedSecrets; // secrets encrypted with each user's public key
        mapping(address => uint8) permissions;       // 0 = no access (default), 1 = viewer, 2 = editor, 3 = owner
        
        AccessRequest[] accessRequests;
        ChangeRequest[] changeRequests;
    }
    
    Secret[] internal secrets;
    
    mapping (uint => address) secretToOwner;
    mapping (address => uint) ownerSecretCount;
    
    // modifier to check if the caller is the owner of the secret.  Used for admin functions
    modifier onlySecretOwner(uint _secretId)
    {
        require (secretToOwner[_secretId] == msg.sender, "Only owners can call this function");
        _;
    }
    
    /// @notice Gets a secret by its ID
    /// @return _encryptedSecret Sender-specific encrypted version of the secret
    ///@return _permission Permission level of the owner
    function getSecret(uint _secretId) public view returns (string memory _encryptedSecret, uint8 _permission)
    {
        Secret storage mySecret = secrets[_secretId];
        require(mySecret.permissions[msg.sender] != 0, "Sender is not allowed to view this secret");
        
        return (mySecret.encryptedSecrets[msg.sender], mySecret.permissions[msg.sender]);
    }
    
    /// @notice Gets all information on a secret
    /// @return _encryptedSecret Sender-specific encrypted version of the secret
    /// @return _names Names for each address
    /// @return _addresses Addresses for each user allowed access to the secret
    /// @return _permission Permissions for each address
    function ownerGetSecret(uint _secretId) public view onlySecretOwner(_secretId) returns (
        string memory _encryptedSecret, 
        string[] memory _names, 
        address[] memory _addresses, 
        uint8[] memory _permission,
        AccessRequest[] memory _accessRequests,
        ChangeRequest[] memory _changeRequests
    )
    {
        // I know that this isn't technically secure, but it seems like the kind of thing that could be helpfull - regular users just don't need this kind of information
        Secret storage mySecret = secrets[_secretId];
        
        uint maxUserCount = mySecret.addresses.length; // can be higher than the number of current users, but never lower
        string[] memory names = new string[](maxUserCount);
        address[] memory addresses = new address[](maxUserCount);
        uint8[] memory permissions = new uint8[](maxUserCount);
        
        uint counter = 0;
        for(uint i = 0; i < mySecret.addresses.length; i ++)
        {
            address addr = mySecret.addresses[i];
            if (mySecret.permissions[addr] != 0)
            {
                // address has some form of access
                names[counter] = mySecret.names[addr];
                addresses[counter] = addr;
                permissions[counter] = mySecret.permissions[addr];
                
                counter ++;
            }
        }
        
        return (
            mySecret.encryptedSecrets[msg.sender], 
            names, 
            addresses, 
            permissions,
            mySecret.accessRequests,
            mySecret.changeRequests
        );
    }
}