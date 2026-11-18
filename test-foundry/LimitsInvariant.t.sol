// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma abicoder v2;

import "./omnibridge/HomeOmnibridge.t.sol";

contract LimitsInvariantTest is HomeOmnibridgeTest {
    function test_maxAvailablePerTx_never_exceeds_maxPerTx() public {
        _afterInit();
        for (uint256 i = 0; i < 200; i++) {
            uint256 maxPer = 1 ether + (i * 7919) % 1_000_000;
            // daily must exceed current maxPerTx (so setDailyLimit passes), then we lower maxPerTx.
            uint256 curMax = mediator.maxPerTx(address(0));
            uint256 daily = (curMax > maxPer ? curMax : maxPer) + 1 + ((i * 104729) % 1_000_000);
            vm.prank(owner); mediator.setDailyLimit(address(0), daily);
            vm.prank(owner); mediator.setMaxPerTx(address(0), maxPer);
            uint256 avail = mediator.maxAvailablePerTx(address(0));
            assert(avail <= maxPer);
        }
    }

    function test_withinLimit_respects_maxPerTx_on_fresh_day() public {
        _afterInit();
        vm.prank(owner); mediator.setDailyLimit(address(0), 10 ether);
        vm.prank(owner); mediator.setMaxPerTx(address(0), 1.5 ether);
        assert(mediator.withinLimit(address(0), 1 ether));
        assert(!mediator.withinLimit(address(0), 2 ether));
    }
}
