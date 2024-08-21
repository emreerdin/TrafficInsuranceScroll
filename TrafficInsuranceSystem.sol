// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // Importing the ERC20 standard from OpenZeppelin

contract TrafficInsuranceSystem is ERC20 {

    // Struct for storing the details of a traffic insurance policy
    struct TrafficPolicy {
        uint128 policyID; // Unique ID for each policy
        address policyOwner; // The owner of the policy
        uint256 policyGuaranteeAmount; // Amount guaranteed by the policy
        uint256 policyStartDate; // Start date of the policy
        uint256 policyEndDate; // End date of the policy
        uint256 policyPaymentAmount; // Payment amount required to activate the policy
        uint32 carEngineVolume; // Engine volume of the car (in cc)
        uint8 carAge; // Age of the car
        bool isValid; // Whether the policy is currently active
        uint256 vehicleValue;  // Value of the vehicle
        bytes8 carLicensePlate; // License plate stored as bytes8 for space efficiency
    }

    mapping(address => TrafficPolicy[]) private userPolicies; // Mapping of user addresses to their policies
    mapping(bytes8 => TrafficPolicy) private policyByLicensePlate; // Mapping of license plates to policies
    mapping(bytes8 => bool) private alreadyPolicied; // Tracks whether a policy already exists for a given license plate
    uint128 public nextPolicyID = 1; // Incremental ID for new policies
    //uint256 public exchangeRate = 10000; // Exchange rate for TPS tokens (1 ETH = 10,000 TPS e.g)
    address ownerAddress; // Address of the contract owner

    constructor() ERC20("TrafficPolicySystem", "TPS") {
        _mint(msg.sender, 5000000 * 10 ** decimals()); // Mint initial supply of TPS tokens to the contract owner
        ownerAddress = msg.sender; // Set the owner address
    }

        // Calculate the guarantee amount based on the vehicle's value, engine volume, and age
    function calculateGuaranteeAmount(uint256 vehicleValue, uint32 carEngineVolume, uint8 carAge) internal pure returns (uint256) {
        return (vehicleValue * (1000 + carEngineVolume) / (carAge + 1))/1000;  // Guarantee amount decreases with age
    }

    // Calculate the policy payment amount based on the vehicle's value, engine volume, and age
    function calculatePolicyPaymentAmount(uint256 vehicleValue, uint32 carEngineVolume, uint8 carAge) internal pure returns (uint256) {
        return (vehicleValue * carEngineVolume / (carAge + 1))/1000; // Payment decreases as the car gets older
    }

    // Function to create a new policy
    function CreatePolicy(
        address _policyOwner,
        uint256 vehicleValue,
        string memory _carLicensePlateStr,
        uint8 _carAge,
        uint32 _carEngineVolume,
        uint32 _policyValidTimeInterval
    ) public onlyOwner{
        bytes8 _carLicensePlate = stringToBytes8(_carLicensePlateStr); // Convert license plate string to bytes8

        require(!alreadyPolicied[_carLicensePlate], "Still valid policy exists"); // Check if a valid policy already exists

        // Calculate the policy payment amount and guarantee amount based on vehicle characteristics
        uint256 policyPaymentAmount = calculatePolicyPaymentAmount(vehicleValue, _carEngineVolume, _carAge);
        uint256 policyGuaranteeAmount = calculateGuaranteeAmount(vehicleValue, _carEngineVolume, _carAge);

        // Create a new TrafficPolicy struct and add it to the mappings
        TrafficPolicy memory policy = TrafficPolicy({
            policyID: nextPolicyID++,
            policyGuaranteeAmount: policyGuaranteeAmount,
            policyOwner: _policyOwner,
            carLicensePlate: _carLicensePlate,
            carAge: _carAge,
            carEngineVolume: _carEngineVolume,
            vehicleValue: vehicleValue,  // Vehicle value is added to the struct
            policyStartDate: block.timestamp,
            policyEndDate: block.timestamp + (uint256(_policyValidTimeInterval) * 1 days),
            isValid: false,
            policyPaymentAmount: policyPaymentAmount
        });

        userPolicies[_policyOwner].push(policy); // Add the policy to the user's policies
        policyByLicensePlate[_carLicensePlate] = policy; // Map the license plate to the policy
        alreadyPolicied[_carLicensePlate] = true; // Mark the license plate as having an active policy
    }


    // Function to activate a policy
    function ActivatePolicy(string memory _carLicensePlate) external {
        bytes8 carLicensePlate8Bits = stringToBytes8(_carLicensePlate); // Convert license plate to bytes8
        TrafficPolicy storage policy = policyByLicensePlate[carLicensePlate8Bits]; // Retrieve the policy

        require(policy.policyOwner == msg.sender, "You cannot activate someone else's policy"); // Check ownership
        require(!policy.isValid, "Policy is already active"); // Check if the policy is already active
        require(balanceOf(msg.sender) >= policy.policyPaymentAmount, "Insufficient balance"); // Check if the user has enough balance

        // Transfer the payment and mark the policy as active
        _transfer(msg.sender, address(ownerAddress), policy.policyPaymentAmount*10**decimals());
        policy.isValid = true;

        // Update the policy status in the user's policies
        for (uint i = 0; i < userPolicies[policy.policyOwner].length; i++) {
            if (userPolicies[policy.policyOwner][i].carLicensePlate == carLicensePlate8Bits) {
                userPolicies[policy.policyOwner][i].isValid = true;
                break;
            }
        }
    }

    // Function to cancel a policy by license plate
    function CancelPolicyByPlate(string memory _carLicensePlate) external {
        bool policyFound = false;
        uint policyIndex;
        bytes8 _carLicensePlate8Bytes = stringToBytes8(_carLicensePlate); // Convert license plate to bytes8
        
        // Find the policy in the user's policies
        for (uint i = 0; i < userPolicies[msg.sender].length; i++) {
            if (userPolicies[msg.sender][i].carLicensePlate == _carLicensePlate8Bytes) {
                policyIndex = i;
                policyFound = true;
                break;
            }
        }
        
        require(policyFound, "Policy with this license plate does not exist"); // Check if the policy exists
        
        TrafficPolicy storage policy = userPolicies[msg.sender][policyIndex]; // Retrieve the policy
        //require(!policy.isValid, "Cannot cancel an active policy"); // Ensure the policy is not active

        // Mark the policy as no longer valid
        alreadyPolicied[policy.carLicensePlate] = false;
        userPolicies[msg.sender][policyIndex] = userPolicies[msg.sender][userPolicies[msg.sender].length - 1]; // Move the last policy to the current index
        userPolicies[msg.sender].pop(); // Remove the last policy
        
        // Issue a refund for the canceled policy
        RefundCancellationAmount(msg.sender,_carLicensePlate);
    }

    // Private function to refund the cancellation amount
    function RefundCancellationAmount(address policyOwner, string memory _carLicensePlate) private {
        bytes8 _carLicensePlate8Bytes = stringToBytes8(_carLicensePlate); // Convert the license plate to bytes8 format
        
        // Retrieve the policy associated with the given license plate
        TrafficPolicy storage policy = policyByLicensePlate[_carLicensePlate8Bytes];
        
        require(policy.policyOwner == policyOwner, "Policy owner mismatch"); // Ensure the caller is the policy owner
        require(policy.isValid, "Policy is not active"); // Ensure the policy is currently active
        // require(block.timestamp - policy.policyStartDate > 7, "You cannot cancel a policy before 7 days"); // To enable restriction for a certain date to be cancelled

        // Calculate the number of days passed since the policy start date
        uint256 daysPassed = (block.timestamp - policy.policyStartDate) / 1 days;

        // Calculate the remaining days for the policy
        uint256 totalPolicyDays = (policy.policyEndDate - policy.policyStartDate) / 1 days;
        uint256 remainingDays = totalPolicyDays > daysPassed ? totalPolicyDays - daysPassed : 0;

        // If the policy is canceled on the same day, at least one day's payment is refunded
        if (daysPassed == 0) {
            remainingDays = totalPolicyDays;
        }

        // Calculate the prorated refund amount based on the remaining days
        uint256 proratedRefundAmount = (policy.policyPaymentAmount * remainingDays) / totalPolicyDays;

        // If the refund amount is greater than 0, process the refund
        if (proratedRefundAmount > 0) {
            _transfer(address(ownerAddress), policyOwner, proratedRefundAmount * 10 ** decimals());
        }

        // Cancel the policy (it is no longer valid)
        policy.isValid = false;
        alreadyPolicied[_carLicensePlate8Bytes] = false;
    }


    // Function for the contract owner to pay the guarantee amount to the policyholder
    function PayGuaranteeAmountByPlate(string memory _carLicensePlate) external onlyOwner {
        bytes8 carLicensePlate8Bits = stringToBytes8(_carLicensePlate); // Convert license plate to bytes8
        TrafficPolicy storage policy = policyByLicensePlate[carLicensePlate8Bits]; // Retrieve the policy

        require(policy.policyOwner != address(0), "Policy with this license plate does not exist"); // Check if the policy exists
        require(policy.isValid, "Policy is not active"); // Ensure the policy is active

        // Transfer the guarantee amount to the policy owner
        _transfer(address(ownerAddress), policy.policyOwner, policy.policyGuaranteeAmount*10**decimals());

        // Mark the policy as no longer valid
        policy.isValid = false;

        // Update the policy status in the user's policies
        for (uint i = 0; i < userPolicies[policy.policyOwner].length; i++) {
            if (userPolicies[policy.policyOwner][i].carLicensePlate == carLicensePlate8Bits) {
                userPolicies[policy.policyOwner][i].isValid = false;

                // Move the last element into the place to be removed
                userPolicies[policy.policyOwner][i] = userPolicies[policy.policyOwner][userPolicies[policy.policyOwner].length - 1];

                // Remove the last element
                userPolicies[policy.policyOwner].pop();
                break;
            }
        }
    }

    // Function to view policy details by license plate
    function ViewPolicyByPlate(string memory _carLicensePlate) external view returns (
        uint128 policyID,
        address policyOwner,
        uint256 policyGuaranteeAmount,
        uint256 policyStartDate,
        uint256 policyEndDate,
        uint256 policyPaymentAmount,
        uint32 carEngineVolume,
        uint8 carAge,
        bool isValid,
        bytes8 carLicensePlate
    ) {
        bytes8 carLicensePlate8Bits = stringToBytes8(_carLicensePlate); // Convert license plate to bytes8
        TrafficPolicy storage policy = policyByLicensePlate[carLicensePlate8Bits]; // Retrieve the policy

        require(policy.policyOwner != address(0), "Policy with this license plate does not exist"); // Check if the policy exists

        return (
            policy.policyID,
            policy.policyOwner,
            policy.policyGuaranteeAmount,
            policy.policyStartDate,
            policy.policyEndDate,
            policy.policyPaymentAmount,
            policy.carEngineVolume,
            policy.carAge,
            policy.isValid,
            policy.carLicensePlate
        );
    }

    // Modifier to restrict access to certain functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Only the contract owner can perform this action");
        _;
    }

    // Utility function to convert a string to bytes8
    function stringToBytes8(string memory source) internal pure returns (bytes8 result) {
        bytes memory temp = bytes(source);
        require(temp.length <= 8, "String too long");

        assembly {
            result := mload(add(temp, 8))
        }
    }

    // Utility function to convert bytes8 back to a string
    function bytes8ToString(bytes8 _bytes8) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(8);
        for (uint i = 0; i < 8; i++) {
            bytesArray[i] = _bytes8[i];
        }
        return string(bytesArray);
    }

    // Function to exchange ETH for TPS tokens
    function ExchangeTPS() external payable {
        require(msg.value > 0, "No ETH sent");

        // Use msg.value multiplied by 10^decimals() to convert wei to TPS tokens
        uint256 tokenAmount = msg.value * 10 ** decimals();

        // Ensure the contract owner has enough tokens to transfer
        require(balanceOf(address(ownerAddress)) >= tokenAmount, "Insufficient tokens in contract");

        // Transfer the tokens to the sender
        _transfer(address(ownerAddress), msg.sender, tokenAmount);

        // Transfer the received ETH to the contract owner
        payable(ownerAddress).transfer(msg.value);
    }



}
