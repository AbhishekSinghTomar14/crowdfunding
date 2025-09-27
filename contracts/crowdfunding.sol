// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Crowdfunding
 * @dev A decentralized crowdfunding platform smart contract
 */
contract Project {
    struct Campaign {
        address payable creator;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        bool withdrawn;
        mapping(address => uint256) contributions;
        address[] contributors;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed creator,
        string title,
        uint256 target,
        uint256 deadline
    );

    event ContributionMade(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );

    event FundsWithdrawn(
        uint256 indexed campaignId,
        address indexed creator,
        uint256 amount
    );

    event RefundIssued(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );

    modifier onlyCreator(uint256 _id) {
        require(
            msg.sender == campaigns[_id].creator,
            "Only campaign creator can perform this action"
        );
        _;
    }

    modifier campaignExists(uint256 _id) {
        require(_id < numberOfCampaigns, "Campaign does not exist");
        _;
    }

    /**
     * @dev Core Function 1: Create a new crowdfunding campaign
     * @param _title Campaign title
     * @param _description Campaign description
     * @param _target Funding target in wei
     * @param _deadline Campaign deadline (timestamp)
     */
    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline
    ) public returns (uint256) {
        require(_target > 0, "Target amount must be greater than 0");
        require(_deadline > block.timestamp, "Deadline must be in the future");
        require(bytes(_title).length > 0, "Title cannot be empty");

        Campaign storage campaign = campaigns[numberOfCampaigns];
        campaign.creator = payable(msg.sender);
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.withdrawn = false;

        emit CampaignCreated(
            numberOfCampaigns,
            msg.sender,
            _title,
            _target,
            _deadline
        );

        numberOfCampaigns++;
        return numberOfCampaigns - 1;
    }

    /**
     * @dev Core Function 2: Contribute to a campaign
     * @param _id Campaign ID
     */
    function donateToCampaign(uint256 _id) public payable campaignExists(_id) {
        require(msg.value > 0, "Contribution must be greater than 0");
        require(
            block.timestamp < campaigns[_id].deadline,
            "Campaign has ended"
        );

        Campaign storage campaign = campaigns[_id];

        // If this is the first contribution from this address, add to contributors list
        if (campaign.contributions[msg.sender] == 0) {
            campaign.contributors.push(msg.sender);
        }

        campaign.contributions[msg.sender] += msg.value;
        campaign.amountCollected += msg.value;

        emit ContributionMade(_id, msg.sender, msg.value);
    }

    /**
     * @dev Core Function 3: Withdraw funds (if target reached) or get refund (if target not reached)
     * @param _id Campaign ID
     */
    function withdrawFunds(uint256 _id)
        public
        campaignExists(_id)
        onlyCreator(_id)
    {
        Campaign storage campaign = campaigns[_id];
        
        require(
            block.timestamp >= campaign.deadline,
            "Campaign is still active"
        );
        require(!campaign.withdrawn, "Funds already withdrawn");
        require(
            campaign.amountCollected >= campaign.target,
            "Funding target not reached"
        );

        campaign.withdrawn = true;
        uint256 amount = campaign.amountCollected;
        campaign.creator.transfer(amount);

        emit FundsWithdrawn(_id, campaign.creator, amount);
    }

    /**
     * @dev Allow contributors to get refund if campaign failed
     * @param _id Campaign ID
     */
    function getRefund(uint256 _id) public campaignExists(_id) {
        Campaign storage campaign = campaigns[_id];
        
        require(
            block.timestamp >= campaign.deadline,
            "Campaign is still active"
        );
        require(
            campaign.amountCollected < campaign.target,
            "Campaign was successful, no refunds"
        );
        require(
            campaign.contributions[msg.sender] > 0,
            "No contribution to refund"
        );

        uint256 refundAmount = campaign.contributions[msg.sender];
        campaign.contributions[msg.sender] = 0;
        campaign.amountCollected -= refundAmount;

        payable(msg.sender).transfer(refundAmount);

        emit RefundIssued(_id, msg.sender, refundAmount);
    }

    /**
     * @dev Get campaign details
     * @param _id Campaign ID
     */
    function getCampaign(uint256 _id)
        public
        view
        campaignExists(_id)
        returns (
            address creator,
            string memory title,
            string memory description,
            uint256 target,
            uint256 deadline,
            uint256 amountCollected,
            bool withdrawn
        )
    {
        Campaign storage campaign = campaigns[_id];
        return (
            campaign.creator,
            campaign.title,
            campaign.description,
            campaign.target,
            campaign.deadline,
            campaign.amountCollected,
            campaign.withdrawn
        );
    }

    /**
     * @dev Get all campaigns
     */
    function getAllCampaigns() public view returns (uint256[] memory) {
        uint256[] memory allCampaigns = new uint256[](numberOfCampaigns);
        
        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            allCampaigns[i] = i;
        }
        
        return allCampaigns;
    }

    /**
     * @dev Get contributor's contribution amount for a campaign
     * @param _id Campaign ID
     * @param _contributor Contributor address
     */
    function getContribution(uint256 _id, address _contributor)
        public
        view
        campaignExists(_id)
        returns (uint256)
    {
        return campaigns[_id].contributions[_contributor];
    }

    /**
     * @dev Get all contributors for a campaign
     * @param _id Campaign ID
     */
    function getContributors(uint256 _id)
        public
        view
        campaignExists(_id)
        returns (address[] memory)
    {
        return campaigns[_id].contributors;
    }

    /**
     * @dev Check if campaign is active
     * @param _id Campaign ID
     */
    function isCampaignActive(uint256 _id)
        public
        view
        campaignExists(_id)
        returns (bool)
    {
        return block.timestamp < campaigns[_id].deadline;
    }

    /**
     * @dev Check if campaign target is reached
     * @param _id Campaign ID
     */
    function isTargetReached(uint256 _id)
        public
        view
        campaignExists(_id)
        returns (bool)
    {
        return campaigns[_id].amountCollected >= campaigns[_id].target;
    }
}
