const { ethers } = require("hardhat");

async function main() {
    const UserRegistration = await ethers.getContractFactory("UserRegistration");
    const userRegistration = await UserRegistration.deploy();
    
    await userRegistration.waitForDeployment();
    console.log("UserRegistration deployed to:", userRegistration.target);
}

// Run the main function and handle errors
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
