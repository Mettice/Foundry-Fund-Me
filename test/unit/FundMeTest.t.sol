// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;

    address USER =  makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 wei
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp () external {
        // us -> FundMeTest -> FundMe
       //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
         DeployFundMe deployFundMe = new DeployFundMe();
         fundMe = deployFundMe.run();
         vm.deal(USER, STARTING_BALANCE);
}

    function testMinimumuDollarIsFive() public view {
       assertEq(fundMe.MINIMUM_USD (), 5e18);
    }
    function testOwnerIsSender() public  {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // what can we do to work with addresses outside our system?
    // 1. Unit
     //    - Testing a specific part of our code 
     // 2. Integration
     //    - test how our code works with other part of our code 
     // 3. Forked
     //    - test how our code works with other part of the blockchain
     //4 . Staging
     //    - test how our code works with other part of the blockchain that is not production

    function testPriceFeedVersionIsAccurate() public {
       uint256 version = fundMe.getVersion();
       assertEq(version, 4);
    }
    function testFailsWithoutEnoughETH() public {
    // This setup expects a revert with a specific error message.
    vm.expectRevert();

    // Attempt to fund with an insufficient amount (0 in this case).
    fundMe.fund(); // This should fail as it's not sending any ETH.
}

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The Next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
   }
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // The Next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

       address funder = fundMe.getFunder(0);
       assertEq(funder, USER);
    }

     modifier funded() {
            vm.prank(USER);
            fundMe.fund{value: SEND_VALUE}();
            _;
     }


    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); // the user is not the owner
        vm.expectRevert();
        fundMe.withdraw(); 
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); 


        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMebalance = address(fundMe).balance;
        assertEq(endingFundMebalance, 0);
        assertEq(
            startingFundMebalance + startingOwnerBalance,
             endingOwnerBalance);

    }



    function testwithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal  new address
            //address(0)
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        
        
        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMebalance + startingOwnerBalance ==
            fundMe.getOwner().balance
            );
    }

 function testwithdrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal  new address
            //address(0)
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        
        
        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMebalance + startingOwnerBalance ==
            fundMe.getOwner().balance
            );
    }


}
