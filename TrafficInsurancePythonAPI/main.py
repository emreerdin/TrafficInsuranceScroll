from flask import Flask, jsonify, request
from web3 import Web3
import json
import datetime
from collections import OrderedDict
app = Flask(__name__)

# Scroll Sepolia RPC URL
scroll_sepolia_rpc = "https://sepolia-rpc.scroll.io/"

# Web3 connection
web3 = Web3(Web3.HTTPProvider(scroll_sepolia_rpc))

# Connection validation
if web3.is_connected():
    print("Connected to Scroll Sepolia Testnet")
else:
    print("Failed to connect")

# Contract address and ABI
contract_address = web3.to_checksum_address('YOUR CONTRACT ADDRESS')
with open('contract_abi.json') as f:
    contract_abi = json.load(f)

contract = web3.eth.contract(address=contract_address, abi=contract_abi)

def convert_timestamp_to_date(timestamp):
    return datetime.datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')

@app.route('/policy_and_balance', methods=["GET"])
def policy_and_balance():
    user_address = request.args.get('address')
    car_license_plate = request.args.get('plate')

    try:
        # Ensure the user address is in checksum format
        user_address = web3.to_checksum_address(user_address)

        # Retrieve policy details from the contract
        policy = contract.functions.ViewPolicyByPlate(car_license_plate).call({'from': user_address})

        # Retrieve the user's token balance from the contract
        balance = contract.functions.balanceOf(user_address).call()

        # Get the token decimals to format the balance
        decimals = contract.functions.decimals().call()
        formatted_balance = balance / (10 ** decimals)

        # Convert timestamps to human-readable dates
        policy_data = OrderedDict({
            "policyID": policy[0],
            "policyOwner": policy[1],
            "policyGuaranteeAmount": policy[2],
            "policyStartDate": convert_timestamp_to_date(policy[3]),
            "policyEndDate": convert_timestamp_to_date(policy[4]),
            "policyPaymentAmount": policy[5],
            "carEngineVolume": policy[6],
            "carAge": policy[7],
            "isValid": policy[8],
            "carLicensePlate": car_license_plate,
            "userBalance": formatted_balance
        })

        return jsonify(policy_data)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
