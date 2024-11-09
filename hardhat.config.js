require("@nomicfoundation/hardhat-toolbox");
module.exports = {
    solidity: "0.8.0",
    networks: {
        sepolia: {
            url: "https://linea-sepolia.infura.io/v3/3556c30ffd194e499a5fef172e44b3c4",
            accounts: ["120517da0287b9dd1c35a8f35303fc4854ebc92ea9ed5820bb42da1df41d56c6"]
        }
    }
};
