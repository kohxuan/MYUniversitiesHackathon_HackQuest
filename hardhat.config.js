require("@nomicfoundation/hardhat-toolbox");

module.exports = {
    solidity: "0.8.0",
    networks: {
     sepolia: {
                url: "https://linea-sepolia.infura.io/v3/4ecc4901d5e44fc6ac9d10b0ac352f24",
                accounts: ["db784486dbc722a9f97464e42eaeded73defb10f320d6c400fa6ad52046cea48"]
            }
    }
};
