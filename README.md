# TrafficInsuranceScroll

## Project Visual


![Traffic Insurance System Visual](https://github.com/emreerdin/TrafficInsuranceScroll/blob/main/4322a190-3b93-42ee-a171-7797d17e8fed.webp)

## About Me

Emre Erdin, a 2023 graduate from Istanbul Aydın University, earned top honors in Software Engineering with a GPA of 3.63. Throughout his academic journey, he served as a student assistant, teaching master students and contributing to over 10 projects. Emre swiftly transitioned into the professional world, where he developed a strong expertise in blockchain, AI, and game development. He has worked on smart contract development, AI-driven projects, and P2E games, blending his deep theoretical knowledge with practical applications. Driven by perfectionism and a passion for innovation, Emre continually pushes the boundaries of technology, contributing to cutting-edge advancements in his field.

## Description

The Traffic Insurance System is a smart contract built on the Scroll blockchain, leveraging the ERC20 standard for token management. This contract facilitates the creation, activation, and management of traffic insurance policies for vehicles, offering a decentralized, transparent, and secure approach to vehicle insurance.

### Key Features:

- **Policy Creation and Management**: Users can create insurance policies tailored to their vehicle’s specifications, including vehicle value, engine volume, and age. Policies are uniquely identified by a policy ID and are tied to the vehicle's license plate for easy reference.

- **Tokenized Payments with TPS**: The system uses its own ERC20 token, TrafficPolicySystem (TPS), to handle all policy payments. Integrating TPS tokens instead of using ETH or other coins helps reduce transaction fees, especially during periods of network congestion. By controlling the token supply and pricing, the system ensures more predictable and lower costs for policyholders, making it more accessible and cost-effective.

- **Guarantee and Refund Mechanism**: The contract calculates the guarantee amount based on the vehicle’s characteristics and includes a fair refund mechanism for canceled policies. This ensures that users are treated fairly and can reclaim a portion of their payments if they choose to cancel their policy.

- **Policy Activation**: Policies can only be activated by their respective owners, who must make the required payment in TPS tokens. This ensures that only the rightful owner can activate and utilize the insurance policy, enhancing security and user control.

- **Owner Control**: The contract owner has administrative capabilities, such as paying out guarantee amounts and ensuring the smooth operation of the system. This centralized control is necessary for maintaining the integrity and functionality of the system while providing a balance of decentralization.

- **Transparency and Security**: All policies and transactions are stored on-chain, ensuring they are immutable and transparent. The use of blockchain technology not only secures the process but also builds trust among users by providing a verifiable and tamper-proof record of all activities.

Developed on the Scroll blockchain, this project could significantly impact the traditional insurance industry by introducing a decentralized alternative that is more transparent, cost-effective, and user-friendly. By leveraging Scroll's efficient and scalable infrastructure, the Traffic Insurance System can offer lower fees and faster transactions, making insurance more accessible to a broader audience.

The use of TPS tokens enhances the system's efficiency, ensuring that even during times of high network traffic, policyholders can enjoy lower costs and reliable service. This project has the potential to set a new standard in the insurance industry, where trust is built on code rather than on intermediaries, leading to a more efficient and equitable insurance ecosystem.

## Vision

Our vision is to revolutionize the insurance industry by creating a decentralized, transparent, and accessible traffic insurance system on the Scroll blockchain. By leveraging blockchain technology and the TPS token, we aim to reduce costs, increase efficiency, and provide a secure platform for managing vehicle insurance. Our goal is to empower individuals with greater control over their policies, eliminate the need for intermediaries, and democratize access to insurance services globally. We believe that this project can set a new standard in the industry, making insurance more equitable and trustworthy for everyone.

## Techs Used

- Solidity
- Remix IDE
- Python
- web3.py
- Metamask

## Setup Environment

This project is a Flask-based API that interacts with a smart contract deployed on the Scroll Sepolia Testnet. It allows users to retrieve information about their traffic insurance policies and their token balance.

**Note**: Before running this API, ensure that the smart contract is deployed on the Scroll Sepolia Testnet. The contract's address and ABI should be available for interaction with the API.

### Features

- **Policy and Balance Retrieval**: Fetch details of a traffic insurance policy by providing the car's license plate and the user's address.
- **Blockchain Integration**: Connected to the Scroll Sepolia Testnet using Web3 to interact with the deployed smart contract.

### Prerequisites

Before you begin, ensure you have met the following requirements:

- Python 3.8 or higher installed.
- `pip` (Python package installer) installed.
- Node.js and npm installed (if needed for contract interaction, not covered here).

### Installation

1. **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/traffic-insurance-system.git
    cd traffic-insurance-system
    ```

2. **Create a virtual environment (optional but recommended):**

    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

3. **Install the required Python packages:**

    ```bash
    pip install -r requirements.txt
    ```

4. **Set up the environment:**

    Ensure that your smart contract's ABI is saved as `contract_abi.json` in the root of the project directory.

5. **Configure the Flask app:**

    No additional configuration is required if you are using the Scroll Sepolia RPC URL and the smart contract address provided. If you're using a different RPC URL or contract address, update the corresponding variables in the code.

## Running the API

1. **Start the Flask application:**

    ```bash
    python app.py
    ```

    You should see an output indicating the connection status to the Scroll Sepolia Testnet, followed by the message indicating that the server is running.

2. **Access the API:**

    The API will be running locally on `http://127.0.0.1:5000/`. You can access the `policy_and_balance` endpoint by sending a GET request with the following parameters:

    - `address`: The user's wallet address.
    - `plate`: The car's license plate.

    Example request:

    ```bash
    curl "http://127.0.0.1:5000/policy_and_balance?address=0xYourAddressHere&plate=YourCarPlate"
    ```

3. **Response Format:**

    The API will return a JSON object containing the policy details and the user's token balance. In case of an error, a JSON object with an error message will be returned.

## Project Structure

- **`app.py`**: The main Flask application.
- **`contract_abi.json`**: ABI file for the deployed smart contract.
- **`requirements.txt`**: Python dependencies.

## Future Work

Although this project has made significant progress in creating a decentralized traffic insurance system, there are some aspects that could not be completed due to technical restrictions or future improvements:

- **Expanded Policy Features**: Additional features such as dynamic premium adjustments based on real-time data or integration with IoT devices in vehicles for more accurate policy management are planned for future versions.

- **Oracle Integration for Activation and Payments**: The system was designed with the intent to use an oracle for data retrieval and payment assurance. The activation process, while feasible through methods like QuickNode, was not implemented using a simple API call because the goal was to rely on an oracle for more complex validation. The envisioned system would involve sending a photo of the damage, detailing it using OCR (Optical Character Recognition), and returning a true or false for payment approval, along with calculating the payment percentage based on the analysis. This functionality could not be completed due to the Scroll Blockchain not being powered by any Oracle.

- **Cross-Chain Compatibility**: Currently, the project is limited to the Scroll Sepolia Testnet. Future iterations aim to explore cross-chain compatibility, allowing policies to be valid and interactable across multiple blockchains.

- **Enhanced Security Measures**: While the project employs standard blockchain security practices, further enhancements, including multi-signature requirements and advanced encryption methods, will be explored to ensure even greater security.

These future improvements are intended to push the boundaries of what blockchain-based insurance can achieve, making the system more versatile, secure, and user-friendly.

## Contributing

Contributions are welcome! Please fork this repository, make your changes, and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
