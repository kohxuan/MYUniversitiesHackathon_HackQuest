# <img src="https://github.com/user-attachments/assets/ac889622-af09-4910-baca-10f1d3f296e2" width="75px" height="45px" > 🌟 Trustify - Decentralized Reputation System
The **Trustify** platform is a decentralized reputation system designed for local businesses, utilizing blockchain technology to ensure transparent and reliable customer-business interactions.
<br><br>

### ✨ Features
- **Customer Registration**: Seamless registration using MetaMask wallet.
- **Genuine Reviews**: Share authentic reviews and earn tokens as rewards.
- **Token Redemption**: Redeem tokens for vouchers to use during physical purchases.
- **Business Management**: Tools for managing business information and verifying customer reviews.
- **Decentralized Ecosystem**: Secure and transparent interactions for building credible reputations.
<br>

### 🛠️ Technical Overview
- **Solidity**: Smart contracts for blockchain interactions.
  - **UserRegistration Contract**: Manages customer and owner registrations, review submissions, and voucher redemptions.
- **JavaScript**: Core logic for application functionality.
  - **app.js**: Handles MetaMask integration, role selection, and business registration.
  - **Key Functions**:
    - `init()`: Initializes the app and connects to the smart contract.
    - `registerBusiness()`: Registers a new business owner.
    - `selectCustomerRole()`: Registers a user as a customer.
    - `selectRole()`: Handles role selection for users.
- **MetaMask**: Wallet integration for user authentication.
- **Hardhat**: Development environment for deploying and testing smart contracts.
  - **deploy.js**: Script for deploying the `UserRegistration` contract.
<br>

### 📁 Key Files
- **contracts/Lock.sol**: Smart contract for handling user registration, reviews, and voucher logic.
- **scripts/deploy.js**: Deploys the `UserRegistration` contract to the blockchain.
- **index.html**: Main entry point for the web application.
- **app.js**: Handles frontend logic and interactions.
<br>

### 🚀 Getting Started

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   ```
2. **Navigate to the Project Directory**:
   ```bash
   cd <your-project-directory>
   ```
3. **Install Dependencies**:
   ```bash
   npm install
   ```
4. **Compile Contracts**:
   Compile your smart contracts:
   ```bash
   npx hardhat compile
   ```
5. **Deploy Contracts**:
   Deploy your contracts to the Sepolia testnet:
   ```bash
   npx hardhat run scripts/deploy.js --network sepolia
   ```
   *Note the contract address printed in the console, and update `contractAddress` in `app.js` and any other related files.*

6. **Run the Application**:
   Open `index.html` directly in your browser.

Replace `<repository-url>` with your actual repository URL and `<your-project-directory>` with the actual name of your project directory.
<br><br>

### 📝 Note
- Ensure your MetaMask is connected to the Sepolia network.
- If you’re using Sepolia, make sure you have some test ETH in your MetaMask wallet.
<br>
