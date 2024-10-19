// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 
 
contract UserRegistration { 
    struct Owner { 
        string name; 
        string location; 
        string contactNumber;
        string registrationNo;
        string ipfsHash;
        bool isRegistered;
        uint256 totalRating; // Total accumulated rating
        uint256 reviewCount; // Count of reviews for average calculation 
    } 
 
    struct Review {
        address reviewer; // Address of the customer who left the review
        uint256 rating; // Rating from 0 to 5
        string description; // Review description
        uint256 reviewTime; // Time when the review was submitted
    }

    struct Customer {
        uint256 points; // Points default to 0
        bool isRegistered;
    }

    struct VerificationCode {
        string code;
        uint256 issuedAt; // Timestamp when the code was issued
        bool isIssued;
    }

    struct Voucher {
        string code;         // Voucher code
        uint256 voucherType; // Type of voucher
        uint256 redeemedAt;  // Time when voucher was redeemed
        bool isUsed;         // Boolean flag to track if the voucher is used
    }

    uint256 constant CODE_EXPIRY_TIME = 24 hours; // Expiry time set to 24 hours
    uint256 constant POINTS_PER_REVIEW = 2; // Points given per review
    // Voucher point costs
    uint256 constant VOUCHER_ONE_COST = 10;
    uint256 constant VOUCHER_TWO_COST = 28;
    uint256 constant VOUCHER_THREE_COST = 46;
    uint256 constant VOUCHER_FOUR_COST = 92;
    address[] private ownersArray;

    mapping(address => address[]) private customerToOwners;
    mapping(address => mapping(address => uint256)) private lastReviewTime; // customer => owner => last review timestamp    
    mapping(address => Review[]) private ownerReviews;
    mapping(address => Voucher[]) private customerVouchers;
    mapping(address => Owner) public registeredOwners;
    mapping(address => Customer) public registeredCustomers; // Map customer addresses to Customer structs
    mapping(address => mapping(address => VerificationCode)) public issuedCodes; // owner => customer => verification code

    event UserRegistered(address indexed user, string role);
    event VerificationCodeIssued(address indexed owner, address indexed customer, string code);
    event ReviewSubmitted(address indexed customer, address indexed owner, uint256 rating, string description, uint256 reviewTime);
    event VoucherRedeemed(address indexed customer, string voucherCode, uint256 pointsUsed, uint256 voucherType);
 
    function registerCustomer() public {
        require(!registeredCustomers[msg.sender].isRegistered, "Customer already registered");
        registeredCustomers[msg.sender] = Customer(0, true); // Initialize with 0 points and registered status
        emit UserRegistered(msg.sender, "Customer");
    } 
 
    function registerOwner(string memory name, string memory location, string memory contactNumber, string memory registrationNo, string memory _ipfsHash) public {
        require(!registeredOwners[msg.sender].isRegistered, "Owner already registered");
        registeredOwners[msg.sender] = Owner(name, location, contactNumber, registrationNo, _ipfsHash, true, 0, 0);
        ownersArray.push(msg.sender);
        emit UserRegistered(msg.sender, "Owner");
    } 

    function getAllRegisteredOwners() public view returns (address[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < ownersArray.length; i++) {
            if (registeredOwners[ownersArray[i]].isRegistered) {
                count++;
            }
        }

        address[] memory registeredOwnersList = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < ownersArray.length; i++) {
            if (registeredOwners[ownersArray[i]].isRegistered) {
                registeredOwnersList[index] = ownersArray[i];
                index++;
            }
        }

        return registeredOwnersList;
    }

    function issueVerificationCode(address customer) public {
        require(registeredOwners[msg.sender].isRegistered, "Only registered owners can issue codes");
        require(registeredCustomers[customer].isRegistered, "Customer must be registered");

        VerificationCode storage verificationCode = issuedCodes[msg.sender][customer];

        // Check if the customer already received a code from this owner
        if (verificationCode.isIssued) {
            require(!isCodeExpired(msg.sender, customer), "Existing verification code is expired");
            // Renew the expiration time by updating the issued timestamp
            verificationCode.issuedAt = block.timestamp;
        } else {
            // Generate a new verification code and store it
            string memory code = generateVerificationCode();
            issuedCodes[msg.sender][customer] = VerificationCode(code, block.timestamp, true);
            emit VerificationCodeIssued(msg.sender, customer, code);

            bool ownerExists = false;
            for (uint i = 0; i < customerToOwners[customer].length; i++) {
                if (customerToOwners[customer][i] == msg.sender) {
                    ownerExists = true;
                    break;
                }
            }
            // If the owner isn't in the list, add them
            if (!ownerExists) {
                customerToOwners[customer].push(msg.sender);
            }
        }
    }

    function generateVerificationCode() private view returns (string memory) {
        // Use the current block timestamp as a unique identifier for the code
        return uint2str(block.timestamp);
    }

    function uint2str(uint _i) private pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            bstr[--k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
 
    function isCustomerRegistered(address user) public view returns (bool) {
        return registeredCustomers[user].isRegistered;
    }

    function isOwnerRegistered(address user) public view returns (bool) {
        return registeredOwners[user].isRegistered;
    } 
 
    function getOwnerDetails(address user) public view returns (string memory name, string memory location, string memory contactNumber,
    string memory registrationNo, string memory ipfsHash) {
        require(registeredOwners[user].isRegistered, "Owner not registered");
        Owner memory owner = registeredOwners[user];
        return (owner.name, owner.location, owner.contactNumber, owner.registrationNo, owner.ipfsHash);
    }

    function getVerificationCode(address owner) public view returns (string memory) {
        require(issuedCodes[owner][msg.sender].isIssued, "No verification code issued to this customer");
        require(!isCodeExpired(owner, msg.sender), "Verification code has expired"); // Check if the code is expired
        return issuedCodes[owner][msg.sender].code;
    }

    // Check if the code has expired (24 hours)
    function isCodeExpired(address owner, address customer) public view returns (bool) {
        uint256 issuedAt = issuedCodes[owner][customer].issuedAt;
        return block.timestamp > issuedAt + CODE_EXPIRY_TIME;
    }

    function leaveReview(address ownerAddress, uint256 rating, string memory description) public {
        require(registeredCustomers[msg.sender].isRegistered, "Only registered customers can leave a review");
        require(registeredOwners[ownerAddress].isRegistered, "Owner not registered");
        require(rating >= 0 && rating <= 5, "Rating must be between 0 and 5");
        require(issuedCodes[ownerAddress][msg.sender].isIssued, "No valid verification code issued to this customer");
        require(!isCodeExpired(ownerAddress, msg.sender), "Verification code has expired");
        // Record the review
        Review memory newReview = Review(msg.sender, rating, description, block.timestamp);
        ownerReviews[ownerAddress].push(newReview);
        registeredOwners[ownerAddress].totalRating += rating;
        registeredOwners[ownerAddress].reviewCount += 1;
        registeredCustomers[msg.sender].points += POINTS_PER_REVIEW;
        emit ReviewSubmitted(msg.sender, ownerAddress, rating, description, block.timestamp);
        issuedCodes[ownerAddress][msg.sender].isIssued = false; // Mark as used
    // Remove the owner from the customer's list of owners who issued verification codes
        address[] storage owners = customerToOwners[msg.sender]; // Get the list of owners for this customer
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == ownerAddress) {
                owners[i] = owners[owners.length - 1]; // Replace with last element
                owners.pop(); // Remove last element to avoid gaps in the array
                break; // Exit loop after removing the owner
            }
        }
    }

    function getOwnerReviews(address ownerAddress) public view returns (Review[] memory) {
        require(registeredOwners[ownerAddress].isRegistered, "Owner not registered");
        return ownerReviews[ownerAddress];
    }

    function getAverageRating(address ownerAddress) public view returns (uint256) {
        require(registeredOwners[ownerAddress].isRegistered, "Owner not registered");
        Owner memory owner = registeredOwners[ownerAddress];
        if (owner.reviewCount == 0) {
            return 0; // or return a specific value indicating no reviews
        }
        // Multiply by 10 to keep one decimal place
        return (owner.totalRating * 10) / owner.reviewCount;
    }

    function getCustomerPoints(address customer) public view returns (uint256) {
        require(registeredCustomers[customer].isRegistered, "Customer not registered");
        return registeredCustomers[customer].points;
    }

    function getVerificationCodeExpiry(address owner) public view returns (uint256) {
        VerificationCode storage verificationCode = issuedCodes[owner][msg.sender];
        require(verificationCode.isIssued, "No verification code issued");
        return verificationCode.issuedAt + CODE_EXPIRY_TIME;
    }

    function getOwnersForCustomer(address customer) public view returns (address[] memory) {

        return customerToOwners[customer]; // Return the list of owners

    }
    
     // Redeem voucher using points
    function redeemVoucher(uint256 voucherType) public {
        require(registeredCustomers[msg.sender].isRegistered, "Customer not registered");

        uint256 pointsRequired;
        if (voucherType == 1) {
            pointsRequired = VOUCHER_ONE_COST;
        } else if (voucherType == 2) {
            pointsRequired = VOUCHER_TWO_COST;
        } else if (voucherType == 3) {
            pointsRequired = VOUCHER_THREE_COST;
        } else if (voucherType == 4) {
            pointsRequired = VOUCHER_FOUR_COST;
        } else {
            revert("Invalid voucher type");
        }

        require(registeredCustomers[msg.sender].points >= pointsRequired, "Not enough points");

        // Deduct points
        registeredCustomers[msg.sender].points -= pointsRequired;

        // Generate voucher code (alphanumeric)
        string memory voucherCode = generateVoucherCode();

        // Store the voucher
        customerVouchers[msg.sender].push(Voucher(voucherCode, voucherType, block.timestamp, false));

        emit VoucherRedeemed(msg.sender, voucherCode, pointsRequired, voucherType);
    }

    // Generate a random alphanumeric voucher code
    function generateVoucherCode() private view returns (string memory) {
        bytes memory charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        uint256 length = 8; // Voucher code length

        bytes memory voucherCode = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i))) % charset.length;
            voucherCode[i] = charset[randomIndex];
        }

        return string(voucherCode);
    }

    function useVoucher(string memory voucherCode) public {
    require(registeredCustomers[msg.sender].isRegistered, "Customer not registered");

    bool voucherFound = false; // Flag to track if the voucher was found

    // Loop through the user's vouchers to find the one with the matching code
    for (uint256 i = 0; i < customerVouchers[msg.sender].length; i++) {
        Voucher storage voucher = customerVouchers[msg.sender][i];
        if (keccak256(bytes(voucher.code)) == keccak256(bytes(voucherCode))) {
            require(!voucher.isUsed, "Voucher already used");
            
            // Mark the voucher as used
            voucher.isUsed = true;
            voucherFound = true;
            break;
        }
    }

    require(voucherFound, "Voucher not found");
}

function getRedeemedVouchers() public view returns (Voucher[] memory) {
    require(registeredCustomers[msg.sender].isRegistered, "Customer not registered");

    Voucher[] memory allVouchers = new Voucher[](customerVouchers[msg.sender].length);
    for (uint256 i = 0; i < customerVouchers[msg.sender].length; i++) {
        allVouchers[i] = customerVouchers[msg.sender][i];
    }

    return allVouchers;
}

    function ownerReviewsCount(address owner) public view returns (uint256) {
        return ownerReviews[owner].length;
    }
}
