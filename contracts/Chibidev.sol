//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Chibidevs is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    uint256 public constant MINT_PRICE = 20000000000000000; // 0.02 ETH
    uint256 public constant MAX_SUPPLY = 2222;
    uint256 public constant PREMINT_PRICE = 10000000000000000; // 0.01 ETH
    uint256 public constant MAX_MINT_AMT = 5;
    bool private _isActive = false;
    string private _tokenBaseURI = "";

    Counters.Counter private _CHIBIDEV_COUNT;

    constructor() ERC721("ChibiDevs", "ChibiDevs") {}

    function setActive(bool isActive) external onlyOwner {
        _isActive = isActive;
    }

    function setBaseURI(string memory URI) external onlyOwner {
        _tokenBaseURI = URI;
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function mint(uint256 numberOfTokens) external payable {
        require(_isActive, "Contract is not active");
        require(numberOfTokens <= MAX_MINT_AMT, "Can only mint up to 5 tokens");
        require(
            _CHIBIDEV_COUNT.current() < MAX_SUPPLY,
            "Purchase would exceed max supply"
        );
        require(
            MINT_PRICE * numberOfTokens <= msg.value,
            "ETH amount is not sufficient"
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 tokenId = _CHIBIDEV_COUNT.current();

            if (_CHIBIDEV_COUNT.current() < MAX_SUPPLY) {
                _CHIBIDEV_COUNT.increment();
                _safeMint(msg.sender, tokenId);
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(_exists(tokenId), "Token does not exist");
        return
            string(
                abi.encodePacked(
                    _tokenBaseURI,
                    Strings.toString(tokenId),
                    ".json"
                )
            );
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        payable(msg.sender).transfer(balance);
    }
}
