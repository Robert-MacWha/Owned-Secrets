# Owned-Secrets
Etherium smart contract which allows people to create owned secrets stored on the blockchain.

## Summary
A blockchain application that lets people upload encrypted messages to the chain, share their messages with others, and change the message.  This was created as a learning project and is in no way thoroughly tested or properly secure.

### Secrets
Secrets can be created by addresses and are then owned by that address.  Owners of a secret can share the secret with others, giving our viewer & editor permissions.  Secrets can also be changed with the permission of the owner.

### Permissions
There exist three permissions: Viewer, Editor, & Owner.

- Viewers can view a secret.
- Editors can view a secret and suggest edits to the owner
- Owners can view a secret, implement edits, change permissions for other users, and give users access to the secret.

Ownership can also be transferred by the owner

## TODO
- Finish Frontend Interface (React, Tailwind, Metamask's web3 API)
- Host on a test network
- Run official tests
- Create documentation for the API

## Observations
There is a major security flaw in the fact that once you've given someone permission to view a secret you can never stop them from viewing that iteration of the secret.  If this kind of technology were to be used for larger-scape or sensitive information then there would be no recourse for data breaches.  You can't ban a user from accessing the data bank if the data's all stored publicly.
