// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    function setUp() external {
        // This is where we deploy our contract
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // Address found on : https://docs.chain.link/data-feeds/api-reference (Google: `chainlink aggregatorv3interface address`)
        
        //* Use deploy script in test
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();    // Returns a new Fundme() contract, which is set to contract variable above.
    }

    function testMinimumDollarIsFive() public {
        // This is where we test our contract
        assertEq(fundMe.MINIMUM_USD(), 5e18, "Minimum USD should be 5");
    }

    function testOwnerIsMsgSender() public {
        // This is where we test our contract
        console.log("msg.sender", msg.sender);
        console.log("i_owner", fundMe.i_owner());
        console.log("address(this)", address(this));
        //? We call setup -> setup calls contract Fundme, so instead of 'us' calling FundMe, we have the test contract call FundMe.
        //? So, the ownder is the test contract, not us.
        // ! assertEq(fundMe.i_owner(), msg.sender, "Minimum USD should be 5");
        // assertEq(fundMe.i_owner(), address(this), "Minimum USD should be 5");

        assertEq(fundMe.i_owner(), msg.sender, "Minimum USD should be 5");
        // We can go back to msg.sender now as we're using deploy script to initialize the tests now, instead of doing so manually

    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4, "Version should be 4");
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert("You need to spend more ETH!"); //! Should Fail
        fundMe.fund(); // Send 0 value
    }

    function testFundUpdatesFundDataStructure() public {
        fundMe.fund{value: 10e18}(); // Send 10 ETH (Definitely greater than MINIMUM_USD)
    }
}
