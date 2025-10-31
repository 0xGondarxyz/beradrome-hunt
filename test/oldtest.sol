// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "../contracts/Voter.sol";
// import "../contracts/GaugeFactory.sol";
// import "../contracts/BribeFactory.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// // import {TOKEN} from "../contracts/TOKEN.sol";
// import {VaultToken, VTOKEN} from "../contracts/VTOKENFactory.sol";
// import {OTOKEN, OTOKENFactory} from "../contracts/OTOKENFactory.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract VoterTest is Test {
//     // IERC20 public oToken;
//     // IERC20 public vToken;
//     Voter public voter;
//     GaugeFactory public gaugeFactory;
//     BribeFactory public bribeFactory;

//     OTOKEN public oToken;
//     VaultToken public vaultToken;

//     OTOKENFactory public oTokenFactory;
//     VTOKEN public vTokenFactory;

//     address public owner = address(1);
//     address public user1 = address(2);
//     address public user2 = address(3);

//     function setUp() public {
//         // Deploy tokens
//         //deploy oToken
//         oToken = new OTOKEN(owner);
//         oTokenFactory = new OTOKENFactory();

//         //deploy vaultToken
//         vaultToken = new VaultToken();
//         // vTokenFactory = new VTOKENFactory();

//         // // Deploy factories with temporary address
//         // address temporaryVoter = address(0x123); // any address
//         // gaugeFactory = new GaugeFactory(temporaryVoter);
//         // bribeFactory = new BribeFactory(temporaryVoter);

//         // // Deploy actual Voter
//         // voter = new Voter(address(vToken), address(gaugeFactory), address(bribeFactory));

//         // // Update factories with real voter address
//         // gaugeFactory.setVoter(address(voter));
//         // bribeFactory.setVoter(address(voter));

//         // // Distribute tokens to test users
//         // vToken.transfer(user1, 1000 * 10 ** 18);
//         // vToken.transfer(user2, 1000 * 10 ** 18);
//     }

//     // Add your test cases here

//     function test_Setup() public {
//         // // assertEq(voter.VTOKEN(), address(vToken));
//         // assertEq(voter.gaugefactory(), address(gaugeFactory));
//         // assertEq(voter.bribefactory(), address(bribeFactory));
//         //test otoken deployment
//         assertEq(oToken.balanceOf(owner), 2000000 * 10 ** 18);
//     }
// }
