Project Structure
crowdfunding/
├── Project.sol          # Main smart contract
└── README.md           # Project documentation
Smart Contract Features
The Project.sol contract includes these 3 core functions:

createCampaign() - Allows users to create new crowdfunding campaigns with title, description, target amount, and deadline
donateToCampaign() - Enables contributors to donate cryptocurrency to campaigns they want to support
withdrawFunds() - Allows campaign creators to withdraw funds if target is reached, or contributors to get refunds if campaign fails

Additional Functionality
The contract also includes several utility functions for:

Retrieving campaign details and statistics
Checking campaign status (active, target reached)
Managing contributor lists and contribution amounts
Comprehensive event logging for transparency

Key Security Features

Modifier-based access control ensuring only authorized actions
Automatic refund mechanism for failed campaigns
Time-based validation for campaign deadlines
Comprehensive input validation to prevent invalid data
Event emission for complete transparency and tracking

contract details: 0xAd6996b565C2EF44ed40b35a27530606A885bAEB
<img width="1440" height="900" alt="Screenshot 2025-09-27 at 12 02 31 PM" src="https://github.com/user-attachments/assets/49878f15-9539-4756-8bcf-298b5a1bb522" />
