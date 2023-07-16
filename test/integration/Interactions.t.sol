// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from 'forge-std/Test.sol';
import {FundMe} from '../../src/FundMe.sol';
import {FundFundMe, WithdrawFundMe} from '../../script/Interactions.s.sol';
import {DeployFundMe} from '../../script/DeployFundMe.s.sol';

contract InteractionsTest is Test {
    FundMe fundMe;
    
    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
    }

    function testUserCanFundAndOwerCanWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}