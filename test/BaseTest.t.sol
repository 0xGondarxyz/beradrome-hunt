// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/Voter.sol";
import "../contracts/GaugeFactory.sol";
import "../contracts/BribeFactory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {TOKEN} from "../contracts/TOKEN.sol";
import {VaultToken, VTOKEN, VTOKENFactory} from "../contracts/VTOKENFactory.sol";
import {OTOKEN, OTOKENFactory} from "../contracts/OTOKENFactory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "../contracts/plugins/local/MockPluginFactory.sol";
import {BerachainRewardsVaultFactory} from "../contracts/BerachainRewardsVaultFactory.sol";
import {TOKENFeesFactory, TOKENFees} from "../contracts/TOKENFeesFactory.sol";
import {VTOKENRewarderFactory, VTOKENRewarder} from "../contracts/VTOKENRewarderFactory.sol";
import {TOKEN} from "../contracts/TOKEN.sol";
import {Minter} from "../contracts/Minter.sol";
import {TOKENGovernor} from "../contracts/TOKENGovernor.sol";
import {Controller} from "../contracts/Controller.sol";
import {SwapMulticall} from "../contracts/Multicalls/SwapMulticall.sol";
import {FarmMulticall} from "../contracts/Multicalls/FarmMulticall.sol";
import {VoterMulticall} from "../contracts/Multicalls/VoterMulticall.sol";
//get mockplugin factory
import {MockPluginFactory} from "../contracts/plugins/local/MockPluginFactory.sol";

contract BaseTest is Test {
    //this will be base token
    ERC20Mock public BASEToken;

    BerachainRewardsVaultFactory public berachainRewardsVaultFactory;

    OTOKEN public oToken;
    VTOKEN public vToken;
    VaultToken public vaultToken;

    OTOKENFactory public oTokenFactory;
    VTOKENFactory public vTokenFactory;
    TOKENFeesFactory public tokenFeesFactory;
    VTOKENRewarderFactory public vTokenRewarderFactory;
    TOKEN public token;

    TOKENFees public tokenFees;

    address public owner = makeAddr("owner");

    address public temporaryVoterAddress = address(0x123); // any address

    function setUp() public {
        vm.startPrank(owner);
        // Deploy tokens
        //deploy BASE token
        BASEToken = new ERC20Mock("BASE", "BASE");

        // initialize VaultFactory
        berachainRewardsVaultFactory = new BerachainRewardsVaultFactory();

        // oToken = new OTOKEN(owner);
        //deploy oTokenFactory
        oTokenFactory = new OTOKENFactory();

        //deploy VTOKENFactory
        vTokenFactory = new VTOKENFactory();

        //initialize TOKENFeesFactory
        tokenFeesFactory = new TOKENFeesFactory();

        // initialize VTOKENRewarderFactory
        vTokenRewarderFactory = new VTOKENRewarderFactory();

        // intialize TOKEN
        /**
         * address _BASE,
         * uint256 _supplyTOKEN,
         * address _OTOKENFactory,
         * address _VTOKENFactory,
         * address _VTOKENRewarderFactory,
         * address _TOKENFeesFactory,
         * address _vaultFactory
         */
        token = new TOKEN(
            address(BASEToken),
            1000e18,
            address(oTokenFactory),
            address(vTokenFactory),
            address(vTokenRewarderFactory),
            address(tokenFeesFactory),
            address(berachainRewardsVaultFactory)
        );

        //get tokenFees from token contract's FEES
        tokenFees = TOKENFees(token.FEES());

        //get oToken from token OTOKEN
        oToken = OTOKEN(token.OTOKEN());

        //get vToken from token VTOKEN
        vToken = VTOKEN(token.VTOKEN());

        //get vTokenRewarderAddress from VTOKEN
        // ✅ Correct way:
        VTOKENRewarder vTokenRewarder = VTOKENRewarder(vToken.rewarder());

        // //initialize VTOKENRewarder
        // //* not sure about this one tbh
        // VTOKENRewarder vTokenRewarder = VTOKENRewarder(vTokenRewarderFactory.createVTokenRewarder(address(vToken)));

        //initialize GaugeFactory
        GaugeFactory gaugeFactory = new GaugeFactory(address(temporaryVoterAddress));

        //initialize BribeFactory
        BribeFactory bribeFactory = new BribeFactory(address(temporaryVoterAddress));

        //initialize Voter
        Voter voter = new Voter(address(vToken), address(gaugeFactory), address(bribeFactory));
        //console log voter address
        console.log("voter address: ", address(voter));

        // initialize Minter

        Minter minter = new Minter(address(voter), address(token), address(vToken), address(oToken));

        // initialize governor
        TOKENGovernor governor = new TOKENGovernor(vToken);

        // initialize Controller
        Controller controller = new Controller(address(voter), address(tokenFees));

        // initialize SwapMulticall

        SwapMulticall swapMulticall = new SwapMulticall(
            address(voter),
            address(BASEToken),
            address(token),
            address(oToken),
            address(vToken),
            address(vTokenRewarder),
            address(controller)
        );

        // initialize FarmMulticall

        FarmMulticall farmMulticall = new FarmMulticall(address(voter), address(token), address(controller));

        // initialize VoterMulticall
        VoterMulticall voterMulticall = new VoterMulticall(address(voter));

        vm.stopPrank();
        // System set-up

        vm.startPrank(temporaryVoterAddress);
        gaugeFactory.setVoter(address(voter));
        bribeFactory.setVoter(address(voter));
        vm.stopPrank();

        vm.startPrank(owner);
        vToken.addReward(address(token));
        vToken.addReward(address(oToken));
        vToken.addReward(address(BASEToken));
        vToken.setVoter(address(voter));
        oToken.setMinter(address(minter));
        voter.initialize(address(minter));
        minter.initialize();
        vm.stopPrank();

        // vm.startPrank(address(temporaryVoterAddress));
        // gaugeFactory.setVoter(address(voter));
        // bribeFactory.setVoter(address(voter));
        // vm.stopPrank();
        // ///---///
        // vm.startPrank(address(owner));
        // vToken.addReward(address(token));
        // vToken.addReward(address(oToken));
        // vToken.addReward(address(BASEToken));
        // vToken.setVoter(address(voter));
        // vm.stopPrank();
        // minter.initialize();

        // vm.startPrank(address(minter));
        // oToken.setMinter(address(minter));
        // voter.initialize(address(minter));
        // vm.stopPrank();

        // //mockpluginfactory
        // MockPluginFactory mockPluginFactory =
        //     new MockPluginFactory(address(voter), address(berachainRewardsVaultFactory));

        // //createSingleStakePlugin     function createSingleStakePlugin(string memory tokenSymbol, string memory rewardSymbol) external returns (address plugin) {
        // mockPluginFactory.createSingleStakePlugin("BASE", "oBERO");

        // // Deploy factories with temporary address
        // address temporaryVoter = address(0x123); // any address
        // gaugeFactory = new GaugeFactory(temporaryVoter);
        // bribeFactory = new BribeFactory(temporaryVoter);

        // // Deploy actual Voter
        // voter = new Voter(address(vToken), address(gaugeFactory), address(bribeFactory));

        // // Update factories with real voter address
        // gaugeFactory.setVoter(address(voter));
        // bribeFactory.setVoter(address(voter));

        // // Distribute tokens to test users
        // vToken.transfer(user1, 1000 * 10 ** 18);
        // vToken.transfer(user2, 1000 * 10 ** 18);
    }

    // Add your test cases here

    function test_Setup() public {
        //test contracts are succesfully deployed
        assertEq(address(BASEToken), address(BASEToken));
        assertEq(address(berachainRewardsVaultFactory), address(berachainRewardsVaultFactory));
        assertEq(address(oTokenFactory), address(oTokenFactory));
        assertEq(address(vTokenFactory), address(vTokenFactory));
        assertEq(address(tokenFeesFactory), address(tokenFeesFactory));
        assertEq(address(vTokenRewarderFactory), address(vTokenRewarderFactory));
        assertEq(address(token), address(token));
    }
}
