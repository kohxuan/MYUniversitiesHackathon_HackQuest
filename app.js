// Ensure MetaMask is installed
if (!window.ethereum) {
    alert('MetaMask is not installed. Please install it to interact with this page.');
}

let reputationSystemContract;
let signer;
let roleSelected = false; // Track if a role has been selected

// Initialize the app and connect to the smart contract
async function init() {
    try {
        // Request account access from MetaMask
        await window.ethereum.request({ method: 'eth_requestAccounts' });

        // Connect to the blockchain provider
        const provider = new ethers.BrowserProvider(window.ethereum);

        // Get the signer (the user who is currently connected to MetaMask)
        signer = await provider.getSigner();

        // Address of the deployed ReputationSystem contract
        const contractAddress = "0xb0d498Cd2D0EDE81c5857fd38837f3F5409FE385";  // Replace with your contract address

        // ABI (Application Binary Interface) of the ReputationSystem contract
        const contractABI = [
            "function registerBusiness(string _fullName, string _storeName, string _storeAddress, string _contactNumber) public",
            "function selectRoleAsCustomer() public"
        ];

        // Connect to the ReputationSystem contract
        reputationSystemContract = new ethers.Contract(contractAddress, contractABI, signer);
    } catch (error) {
        console.error("Error connecting to the contract:", error);
    }
}

// Function to register a business owner
async function registerBusiness(event) {
    event.preventDefault();
    
    const fullName = document.getElementById('fullName').value;
    const storeName = document.getElementById('storeName').value;
    const storeAddress = document.getElementById('storeAddress').value;
    const contactNumber = document.getElementById('contactNumber').value;

    try {
        // Call the `registerBusiness` function from the smart contract
        const tx = await reputationSystemContract.registerBusiness(fullName, storeName, storeAddress, contactNumber);

        // Wait for the transaction to be mined
        await tx.wait();

        alert('Business successfully registered on the blockchain!');

        // Disable the form to prevent further submissions
        document.getElementById('registerForm').reset();
        document.getElementById('owner-form').classList.add('hidden');
        roleSelected = true; // Set roleSelected to true
    } catch (error) {
        console.error("Error registering business:", error);
        alert('Error registering business. Please check the console for details.');
    }
}

// Function to select the role as a customer
async function selectCustomerRole() {
    try {
        const tx = await reputationSystemContract.selectRoleAsCustomer();
        await tx.wait();
        alert('You have been registered as a customer!');
        roleSelected = true; // Set roleSelected to true
    } catch (error) {
        console.error("Error selecting role as customer:", error);
        alert('Error selecting customer role. Please check the console for details.');
    }
}

// Function to handle role selection
function selectRole(role) {
    if (roleSelected) {
        alert("You have already selected a role. Please refresh the page to start over.");
        return; // Prevent role selection if one has already been made
    }

    document.getElementById('role-selection').classList.add('hidden');
    
    if (role === 'owner') {
        document.getElementById('owner-form').classList.remove('hidden');
    } else if (role === 'customer') {
        selectCustomerRole();
        document.getElementById('customer-welcome').classList.remove('hidden');
    }
}

// Initialize the app when the page loads
window.onload = init;