// 1. Pragma
pragma solidity ^0.8.17;

// 2. Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// 3. Contracts, Interfaces and Libs

error FundMe__NotOwner();

contract FundMe {
    // Type declarations
    using PriceConverter for uint;

    // state variables
    address[] private s_funders;
    address private immutable i_owner;
    uint public constant MINIUM_FUND = 10 * 10 ** 18;

    mapping(address => uint) private s_AddressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    constructor(address feed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(feed);
    }
    // modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // func definitions
    function fund() public payable {
        require(
            msg.value.getConvertionRate(s_priceFeed) >= MINIUM_FUND,
            "you need to supply minimum allowable funds"
        );
        s_AddressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_AddressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getFundByAddress(
        address fundingAddress
    ) public view returns (uint256) {
        return s_AddressToAmountFunded[fundingAddress];
    }

    function getPriceFeedVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunderAtIndex(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeedInstance()
        public
        view
        returns (AggregatorV3Interface)
    {
        return s_priceFeed;
    }
}
