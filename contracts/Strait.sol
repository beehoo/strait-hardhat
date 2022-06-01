//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Strait is ERC721URIStorage, ERC721Enumerable, Ownable {
  using Counters for Counters.Counter;
  using SafeMath for uint256;
  Counters.Counter private _tokenIds;

  // Platform commission rate
  uint256 public constant RATIO = 10;

  // Mapping owner address to number of minted
  mapping(address => uint256) private _numberMinted;

  constructor() ERC721("StraitMinter", "SMT") {}

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  /**
   * Mint NFT
   *
   * Requirements:
   *
   * - quantity > 0
   */
  function mint(uint256 quantity, string memory _tokenURI) external {
    require(quantity > 0, "StraitMinter: quantity must be greater than 0");

    for (uint i = 0; i < quantity; i++) {
      _tokenIds.increment();
      uint256 newItemId = _tokenIds.current();

      _safeMint(msg.sender, newItemId);
      _setTokenURI(newItemId, _tokenURI);
    }
    _numberMinted[msg.sender] += quantity;
  }

  /**
   * Return number of minted
   */
  function numberMinted() external view returns (uint256) {
    return uint256(_numberMinted[msg.sender]);
  }

  /**
   * Get all tokens of owner
   */
  function tokensOfOwner(address owner) external view returns (uint256[] memory) {
    uint256 totalSupply = totalSupply();
    uint256 tokenIdsLength = balanceOf(owner);
    uint256[] memory tokens = new uint256[](totalSupply);
    uint256[] memory ownerTokens = new uint256[](tokenIdsLength);
    uint index;

    for (uint i = 0; i < totalSupply; i++) {
      tokens[i] = tokenByIndex(i);
    }

    while (index < tokenIdsLength) {
      for (uint n = 0; n < tokens.length; n++) {
        if (ownerOf(tokens[n]) == owner) {
          ownerTokens[index] = tokens[n];
          index++;
        }
      }
      break;
    }

    return ownerTokens;
  }

  /**
   * Transfer ETH and mint NFT
   */
  function transferMint(address payable _to, uint256 _amount, uint256 quantity, string memory _tokenURI) payable public {
    require(msg.value >= _amount, "StraitMinter: Insufficient eth");
    require(msg.sender != _to, "StraitMinter: Can not transfer to yourself");
    require(quantity > 0, "StraitMinter: quantity must be greater than 0");

    if (_amount > 0) {
      uint256 amount = SafeMath.mul(SafeMath.div(msg.value, 100), SafeMath.sub(100, RATIO));
      (bool success, ) = _to.call{value: amount}("");

      require(success, "StraitMinter: transfer failed");
    }

    for (uint i = 0; i < quantity; i++) {
      _tokenIds.increment();
      uint256 newItemId = _tokenIds.current();

      _safeMint(msg.sender, newItemId);
      _setTokenURI(newItemId, _tokenURI);
    }
    _numberMinted[msg.sender] += quantity;
  }

  /**
   * Withdraw
   */
  function withdraw(address payable recipient) external onlyOwner {
    uint256 balance = address(this).balance;
    (bool success, ) = recipient.call{value: balance}("");
    require(success, "StraitMinter: withdraw failed");
  }
}