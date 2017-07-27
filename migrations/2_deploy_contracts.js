var HodlToken = artifacts.require("./HodlToken.sol");

module.exports = function(deployer) {
  deployer.deploy(HodlToken);
};
