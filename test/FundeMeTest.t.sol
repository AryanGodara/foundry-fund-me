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
        console.log("i_owner", fundMe.getOwner());
        console.log("address(this)", address(this));
        //? We call setup -> setup calls contract Fundme, so instead of 'us' calling FundMe, we have the test contract call FundMe.
        //? So, the ownder is the test contract, not us.
        // ! assertEq(fundMe.i_owner(), msg.sender, "Minimum USD should be 5");
        // assertEq(fundMe.i_owner(), address(this), "Minimum USD should be 5");

        assertEq(fundMe.getOwner(), msg.sender, "Minimum USD should be 5");
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

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _; // Run the test function
    }

    function testFundUpdatesFundDataStructure() public funded {
        // vm.prank(USER); // The next transaction will be from USER (instead of msg.sender, or address(this))
        // fundMe.fund{value: SEND_VALUE}(); // Send 10 ETH (Definitely greater than MINIMUM_USD)
        
        uint256 amountFunded = fundMe.getAddressToAmoundfunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should be 10");
    }
    
    function testAddsFunderToArrayOfFunders() public funded {
        //* Each test first runs setup(), so the funders array will be new and empty before this test runs ;)
        // vm.prank(USER);//! --> Use Modifier instead
        // fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); // This should be user, as this the first amount being added
        assertEq(funder, USER, "Funder should be USER");
    }


    function testOnlyOwnerCanWithdraw() public funded {
        /* 
        TODO: 1. Fund the contract (as USER)
        TODO: 2. Try to withdraw funds (as USER) and not the owner, //!this should fail
        */

    //    vm.prank(USER); --> //! User modifier instead
    //    fundMe.fund{value: SEND_VALUE}();

       vm.expectRevert(); // Should fail
       vm.prank(USER);
       fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // TODO: Arrage
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // TODO: Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // Withdraw all funds from the contract as the owner

        // TODO: Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance - startingOwnerBalance, startingFundMeBalance, "Owner should have received all funds");
        assertEq(endingFundMeBalance, 0, "FundMe contract should have 0 balance"); 
    }

    function testWithDrawWithMultipleFunders() public funded {
        // TODO: Arrage
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // Start at 1, as we already have 1 funder (USER)

        for (uint160 i = startingFunderIndex ; i < numberOfFunders ; i++) { // Send 10 ETH to the contract, from 10 different funders
            //TODO: Prank new address
            //TODO: vm.deal new address
            //* hoax works as prank and deal combined ;)
            hoax(address(i), SEND_VALUE); // address has 160 bits, so it is directly type casted to address
            //TODO: Fund the contract
            fundMe.fund{value: SEND_VALUE}(); 
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;   // Initial owner balance
        uint256 startingFundMeBalance = address(fundMe).balance;    // Total current amount from all senders in the contract
        
        // TODO: Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw(); // Withdraw all funds from the contract as the owner
        vm.stopPrank();

        // TODO: Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;   // Final owner balance
        uint256 endingFundMeBalance = address(fundMe).balance;    // Total current amount from all senders in the contract

        assertEq(endingOwnerBalance - startingOwnerBalance, startingFundMeBalance, "Owner should have received all funds");
        assertEq(endingFundMeBalance, 0, "FundMe contract should have 0 balance"); 
    }
}

/*
 * NOTE:
 ? vm cheatcodes work on the very next statement, and ignore other vm cheatcodes below them
 ? vm cheatcodes are reset after each test

 * vm cheatcodes:
    ? vm.expectRevert() - Expect the next transaction to revert
    ? vm.prank(address) - Pretend to be the address for the next transaction
    ? vm.deal(address, amount) - Send amount ETH to address
    ? vm.startBroadcast() - Start a broadcast, which will ignore all vm cheatcodes below it
    ? vm.stopBroadcast() - Stop a broadcast, which will ignore all vm cheatcodes below it
    ? vm.reset() - Reset the vm, which will ignore all vm cheatcodes below it
    ? vm.log(string) - Log a string to the console
    ? vm.log(string, uint256) - Log a string and a uint256 to the console
    ? vm.log(string, address) - Log a string and an address to the console
    ? vm.log(string, bytes32) - Log a string and a bytes32 to the console
    ? vm.log(string, bytes) - Log a string and a bytes to the console
    ? vm.log(string, bool) - Log a string and a bool to the console
    ? vm.log(string, int256) - Log a string and an int256 to the console
    ? vm.log(string, uint256, uint256) - Log a string and two uint256s to the console
    ? vm.log(string, uint256, uint256, uint256) - Log a string and three uint256s to the console
    ? vm.log(string, uint256, uint256, uint256, uint256) - Log a string and four uint256s to the console
*/