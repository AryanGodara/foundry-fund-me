// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether; // 1 ether = 10^18 wei = 1e18 wei
    uint256 constant START_BALANCE = 10 ether;

    function setUp() external {
        // This is where we deploy our contract
        
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();    // Returns a new Fundme() contract, which is set to contract variable above.
        vm.deal(USER, START_BALANCE);   // Give USER 10 ETH (to fund the contract, for running tests)
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
        vm.prank(USER); // The next transaction will be from USER (instead of msg.sender, or address(this))

        fundMe.fund{value: SEND_VALUE}(); // Send 10 ETH (Definitely greater than MINIMUM_USD)
        uint256 amountFunded = fundMe.getAddressToAmoundfunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should be 10");
    }
    
    function testAddsFunderToArrayOfFunders() public {
        //* Each test first runs setup(), so the funders array will be new and empty before this test runs ;)
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); // This should be user, as this the first amount being added
        assertEq(funder, USER, "Funder should be USER");
    }
}
