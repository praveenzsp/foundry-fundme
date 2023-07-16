// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from '../../lib/forge-std/src/Test.sol';
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address public constant USER = address(0);
    uint256 public constant STARTING_USER_BALANCE = 20 ether;
    

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testMinimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwner() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundGettingEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testAddressToAmountFunded() public {  // testing the amount funded is equal to the amount which is getting stored in the data structure
        vm.startPrank(USER);
        fundMe.fund{value:10 ether}();
        vm.stopPrank();
        uint256 amountFunded = fundMe.s_addressToAmountFunded(USER);

        assertEq(amountFunded, 10 ether); 
    }

    function testFundersArrayISUpdatingOrNot() public {
        vm.startPrank(USER);
        fundMe.fund{value : 10 ether}();
        address funder = fundMe.s_funders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public {
        uint256 ownerBalanceBefore = address(fundMe.i_owner()).balance;
        uint256 contractBalanceBefore = address(fundMe).balance;

        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 ownerBalanceAfter = address(fundMe.i_owner()).balance;
        uint256 contractBalanceAfter = address(fundMe).balance;

        assertEq(contractBalanceAfter,0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore+contractBalanceBefore);
        
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10 ether}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: 10 ether}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.i_owner().balance;

        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.i_owner().balance);
        assert((numberOfFunders + 1) * 10 ether == fundMe.i_owner().balance - startingOwnerBalance);
    }


}
