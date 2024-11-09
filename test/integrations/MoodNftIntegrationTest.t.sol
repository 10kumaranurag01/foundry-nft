// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "src/MoodNft.sol";
import {DeployMoodNft} from "script/DeployMoodNft.s.sol";
import {MintBasicNft, MintMoodNft, FlipMoodNft} from "script/Interactions.s.sol";

contract MoodNftIntegrationTest is Test {
    MoodNft moodNft;
    string public constant HAPPY_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PHN2ZyBpZD0iZW1vamkiIHZpZXdCb3g9IjAgMCA3MiA3MiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZyBpZD0iY29sb3IiPgogICAgPGNpcmNsZSBjeD0iMzYiIGN5PSIzNiIgcj0iMjMiIGZpbGw9IiNmY2VhMmIiLz4KICAgIDxwYXRoIGZpbGw9IiNmZmYiIGQ9Ik01MC41OTUsNDEuNjRhMTEuNTU1NCwxMS41NTU0LDAsMCwxLS44Nyw0LjQ5Yy0xMi40OSwzLjAzLTI1LjQzLjM0LTI3LjQ5LS4xM2ExMS40MzQ3LDExLjQzNDcsMCwwLDEtLjgzLTQuMzZoLjExczE0LjgsMy41OSwyOC44OS4wN1oiLz4KICAgIDxwYXRoIGZpbGw9IiNlYTVhNDciIGQ9Ik00OS43MjUxLDQ2LjEzYy0xLjc5LDQuMjctNi4zNSw3LjIzLTEzLjY5LDcuMjMtNy40MSwwLTEyLjAzLTMuMDMtMTMuOC03LjM2QzI0LjI5NTEsNDYuNDcsMzcuMjM1LDQ5LjE2LDQ5LjcyNTEsNDYuMTNaIi8+CiAgPC9nPgogIDxnIGlkPSJoYWlyIi8+CiAgPGcgaWQ9InNraW4iLz4KICA8ZyBpZD0ic2tpbi1zaGFkb3ciLz4KICA8ZyBpZD0ibGluZSI+CiAgICA8Y2lyY2xlIGN4PSIzNiIgY3k9IjM2IiByPSIyMyIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS13aWR0aD0iMiIvPgogICAgPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS13aWR0aD0iMiIgZD0iTTUwLjU5NSw0MS42NGExMS41NTU0LDExLjU1NTQsMCwwLDEtLjg3LDQuNDljLTEyLjQ5LDMuMDMtMjUuNDMuMzQtMjcuNDktLjEzYTExLjQzNDcsMTEuNDM0NywwLDAsMS0uODMtNC4zNmguMTFzMTQuOCwzLjU5LDI4Ljg5LjA3WiIvPgogICAgPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS13aWR0aD0iMiIgZD0iTTQ5LjcyNTEsNDYuMTNjLTEuNzksNC4yNy02LjM1LDcuMjMtMTMuNjksNy4yMy03LjQxLDAtMTIuMDMtMy4wMy0xMy44LTcuMzZDMjQuMjk1MSw0Ni40NywzNy4yMzUsNDkuMTYsNDkuNzI1MSw0Ni4xM1oiLz4KICAgIDxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbWl0ZXJsaW1pdD0iMTAiIHN0cm9rZS13aWR0aD0iMiIgZD0iTTMxLjY5NDEsMzIuNDAzNmE0LjcyNjIsNC43MjYyLDAsMCwwLTguNjM4MiwwIi8+CiAgICA8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiMwMDAiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBzdHJva2Utd2lkdGg9IjIiIGQ9Ik00OC45NDQxLDMyLjQwMzZhNC43MjYyLDQuNzI2MiwwLDAsMC04LjYzODIsMCIvPgogIDwvZz4KPC9zdmc+Cg==";
    string public constant SAD_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PHN2ZyBpZD0iZW1vamkiIHZpZXdCb3g9IjAgMCA3MiA3MiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZyBpZD0iY29sb3IiPgogICAgPHBhdGggZmlsbD0iI0ZDRUEyQiIgZD0iTTM2LDEzYy0xMi42ODIzLDAtMjMsMTAuMzE3Ny0yMywyM2MwLDEyLjY4MjIsMTAuMzE3NywyMywyMywyM2MxMi42ODIyLDAsMjMtMTAuMzE3OCwyMy0yMyBDNTksMjMuMzE3Nyw0OC42ODIyLDEzLDM2LDEzeiIvPgogIDwvZz4KICA8ZyBpZD0iaGFpciIvPgogIDxnIGlkPSJza2luIi8+CiAgPGcgaWQ9InNraW4tc2hhZG93Ii8+CiAgPGcgaWQ9ImxpbmUiPgogICAgPGNpcmNsZSBjeD0iMzYiIGN5PSIzNiIgcj0iMjMiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwMDAwMCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBzdHJva2Utd2lkdGg9IjIiLz4KICAgIDxwYXRoIGQ9Ik0zMCwzMWMwLDEuNjU2OC0xLjM0NDgsMy0zLDNjLTEuNjU1MywwLTMtMS4zNDMzLTMtM2MwLTEuNjU1MiwxLjM0NDctMywzLTNDMjguNjU1MiwyOCwzMCwyOS4zNDQ4LDMwLDMxIi8+CiAgICA8cGF0aCBkPSJNNDgsMzFjMCwxLjY1NjgtMS4zNDQ3LDMtMywzcy0zLTEuMzQzMy0zLTNjMC0xLjY1NTIsMS4zNDQ3LTMsMy0zUzQ4LDI5LjM0NDgsNDgsMzEiLz4KICAgIDxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwMDAwMCIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBzdHJva2UtbWl0ZXJsaW1pdD0iMTAiIHN0cm9rZS13aWR0aD0iMiIgZD0iTTI4LDQ2YzEuNTgwNS0yLjU1NzUsNC45MDQzLTQuMTM0OSw4LjQyMTEtNC4wMDM4QzM5LjY0OTksNDIuMTE2Niw0Mi41NjIyLDQzLjY1OTUsNDQsNDYiLz4KICA8L2c+Cjwvc3ZnPgo=";
    string public constant SAD_SVG_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUJwWkQwaVpXMXZhbWtpSUhacFpYZENiM2c5SWpBZ01DQTNNaUEzTWlJZ2VHMXNibk05SW1oMGRIQTZMeTkzZDNjdWR6TXViM0puTHpJd01EQXZjM1puSWo0S0lDQThaeUJwWkQwaVkyOXNiM0lpUGdvZ0lDQWdQSEJoZEdnZ1ptbHNiRDBpSTBaRFJVRXlRaUlnWkQwaVRUTTJMREV6WXkweE1pNDJPREl6TERBdE1qTXNNVEF1TXpFM055MHlNeXd5TTJNd0xERXlMalk0TWpJc01UQXVNekUzTnl3eU15d3lNeXd5TTJNeE1pNDJPREl5TERBc01qTXRNVEF1TXpFM09Dd3lNeTB5TXlCRE5Ua3NNak11TXpFM055dzBPQzQyT0RJeUxERXpMRE0yTERFemVpSXZQZ29nSUR3dlp6NEtJQ0E4WnlCcFpEMGlhR0ZwY2lJdlBnb2dJRHhuSUdsa1BTSnphMmx1SWk4K0NpQWdQR2NnYVdROUluTnJhVzR0YzJoaFpHOTNJaTgrQ2lBZ1BHY2dhV1E5SW14cGJtVWlQZ29nSUNBZ1BHTnBjbU5zWlNCamVEMGlNellpSUdONVBTSXpOaUlnY2owaU1qTWlJR1pwYkd3OUltNXZibVVpSUhOMGNtOXJaVDBpSXpBd01EQXdNQ0lnYzNSeWIydGxMVzFwZEdWeWJHbHRhWFE5SWpFd0lpQnpkSEp2YTJVdGQybGtkR2c5SWpJaUx6NEtJQ0FnSUR4d1lYUm9JR1E5SWswek1Dd3pNV013TERFdU5qVTJPQzB4TGpNME5EZ3NNeTB6TEROakxURXVOalUxTXl3d0xUTXRNUzR6TkRNekxUTXRNMk13TFRFdU5qVTFNaXd4TGpNME5EY3RNeXd6TFRORE1qZ3VOalUxTWl3eU9Dd3pNQ3d5T1M0ek5EUTRMRE13TERNeElpOCtDaUFnSUNBOGNHRjBhQ0JrUFNKTk5EZ3NNekZqTUN3eExqWTFOamd0TVM0ek5EUTNMRE10TXl3emN5MHpMVEV1TXpRek15MHpMVE5qTUMweExqWTFOVElzTVM0ek5EUTNMVE1zTXkwelV6UTRMREk1TGpNME5EZ3NORGdzTXpFaUx6NEtJQ0FnSUR4d1lYUm9JR1pwYkd3OUltNXZibVVpSUhOMGNtOXJaVDBpSXpBd01EQXdNQ0lnYzNSeWIydGxMV3hwYm1WallYQTlJbkp2ZFc1a0lpQnpkSEp2YTJVdGJHbHVaV3B2YVc0OUluSnZkVzVrSWlCemRISnZhMlV0YldsMFpYSnNhVzFwZEQwaU1UQWlJSE4wY205clpTMTNhV1IwYUQwaU1pSWdaRDBpVFRJNExEUTJZekV1TlRnd05TMHlMalUxTnpVc05DNDVNRFF6TFRRdU1UTTBPU3c0TGpReU1URXROQzR3TURNNFF6TTVMalkwT1Rrc05ESXVNVEUyTml3ME1pNDFOakl5TERRekxqWTFPVFVzTkRRc05EWWlMejRLSUNBOEwyYytDand2YzNablBnbz0ifQ==";
    DeployMoodNft deployer;

    address public USER = makeAddr("USER");
    address public USER2 = makeAddr("USER2");

    function setUp() public {
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testViewTokenURIIntegartion() public {
        vm.prank(USER);
        moodNft.mintNft();
        console.log(moodNft.tokenURI(0));
    }

    function testFlipTokenToSad() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.prank(USER);
        moodNft.flipMood(0);
        assert(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))) ==
                keccak256(abi.encodePacked(SAD_SVG_URI))
        );
    }

    function testOnlyOwnerCanFlipMoodOfToken() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        vm.prank(USER2);
        moodNft.flipMood(0);
    }

    function testMintedNftMoodIsSadAfterFlipping() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.prank(USER);
        moodNft.flipMood(0);
        assert(moodNft.getMood(0) == MoodNft.Mood.SAD);
    }

    function testMintNftMintsNftToUser() public {
        vm.prank(USER);
        moodNft.mintNft();
        assert(moodNft.ownerOf(0) == USER);
    }

    function testMintedNftMoodIsHappyByDefault() public {
        vm.prank(USER);
        moodNft.mintNft();
        assert(moodNft.getMood(0) == MoodNft.Mood.HAPPY);
    }

    function testSadSvgImageUriIsSet() public view {
        assert(
            keccak256(abi.encodePacked(moodNft.getSadSvgImageUri())) ==
                keccak256(abi.encodePacked(SAD_SVG_IMAGE_URI))
        );
    }

    function testHappySvgImageUriIsSet() public view {
        assert(
            keccak256(abi.encodePacked(moodNft.getHappySvgImageUri())) ==
                keccak256(abi.encodePacked(HAPPY_SVG_IMAGE_URI))
        );
    }

    function testTokenCounterIsIncrementedOnMint() public {
        vm.prank(USER);
        moodNft.mintNft();
        assert(moodNft.getTokenCounter() == 1);
    }

    /*//////////////////////////////////////////////////////////////
                              INTERACTIONS
    //////////////////////////////////////////////////////////////*/

    function testMintBasicNft() public {
        vm.prank(USER);
        MintBasicNft mintBasicNft = new MintBasicNft();
        mintBasicNft.run();
    }
}
