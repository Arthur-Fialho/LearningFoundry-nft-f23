// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BasicNft} from "../../src/BasicNft.sol";
import {DeployBasicNft} from "../../script/DeployBasicNft.s.sol";

contract BasicNftTest is Test {
    DeployBasicNft public deployer;
    BasicNft public basicNft;
    address public USER = makeAddr("User");
    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "Dogie";
        string memory actualName = basicNft.name();
        // assert(expectedName == actualName);
        // It is not possible to compare two strings in Solidity, so their hashes are compared instead
        assert(
            keccak256(abi.encodePacked(expectedName)) ==
                keccak256(abi.encodePacked(actualName))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        assert(basicNft.balanceOf(USER) == 1);
        assert(
            keccak256(abi.encodePacked(PUG)) ==
                keccak256(abi.encodePacked(basicNft.tokenURI(0)))
        );
    }

    // test above need to change the s_tokenCounter for "public"
    function testTokenCounterIncremented() public {
        uint256 initialCounter = basicNft.s_tokenCounter();
        vm.prank(USER);
        basicNft.mintNft(PUG);

        uint256 newCounter = basicNft.s_tokenCounter();
        assertEq(
            newCounter,
            initialCounter + 1,
            "Token counter should be incremented after minting"
        );
    }

    function testMintedTokenExists() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        uint256 tokenId = 0;
        address tokenOwner = basicNft.ownerOf(tokenId);

        assertEq(tokenOwner, USER, "Token should be owned by the minter");
    }

    function testMintedTokenURI() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        string memory tokenURI = basicNft.tokenURI(0);
        assertEq(tokenURI, PUG, "Token URI should match the provided URI");
    }

    function testNonExistentTokenURI() public {
        string memory nonExistentURI = basicNft.tokenURI(999);
        assertEq(
            nonExistentURI,
            "",
            "Token URI for non-existent token should be empty"
        );
    }
}
