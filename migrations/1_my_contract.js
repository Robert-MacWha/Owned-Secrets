const SecretManager = artifacts.require("./SecretMutability.sol");

module.exports = function (deployer) {
  deployer.deploy(SecretManager);
};
