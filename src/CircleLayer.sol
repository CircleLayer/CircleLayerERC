// SPDX-License-Identifier: MIT
/*

    ██████╗██╗██████╗  ██████╗██╗     ███████╗    ██╗      █████╗ ██╗   ██╗███████╗██████╗ 
   ██╔════╝██║██╔══██╗██╔════╝██║     ██╔════╝    ██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗
   ██║     ██║██████╔╝██║     ██║     █████╗      ██║     ███████║ ╚████╔╝ █████╗  ██████╔╝
   ██║     ██║██╔══██╗██║     ██║     ██╔══╝      ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗
   ╚██████╗██║██║  ██║╚██████╗███████╗███████╗    ███████╗██║  ██║   ██║   ███████╗██║  ██║
    ╚═════╝╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚══════╝    ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝

    Circle Layer Token (CLAYER)
    Total Supply: 1,000,000,000 CLAYER
    
    Advanced tokenomics with anti-bot protection
    
    Official Links:
    Website: https://circlelayer.com/
    Explorer: https://explorer-testnet.circlelayer.com/
    Faucet: https://faucet.circlelayer.com/
    GitHub: https://github.com/CircleLayer
    Telegram: https://t.me/circlelayer
    Twitter: https://x.com/circlelayer
*/

pragma solidity ^0.8.28;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract CircleLayer is ERC20, Ownable, ReentrancyGuard {
    uint256 public immutable MAX_SUPPLY;
    address public immutable pair;
    address public treasury1;
    address public treasury2;

    IUniswapV2Router02 private constant _router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address private immutable _weth;
    address private immutable _deployer;

    uint256 public startBlock;
    uint256 public startBlockTime;
    uint256 public raiseAmount;

    mapping(address account => bool) public isExcludedFromFees;
    mapping(address account => bool) public isExcludedFromMaxWallet;
    mapping(address origin => mapping(uint256 blockNumber => uint256 txCount))
        public maxBuyTxsPerBlockPerOrigin;
    uint256 private _maxBuyTxsPerBlockPerOrigin = 10;
    mapping(uint256 blockNumber => uint256 txCount) public maxBuyTxsPerBlock;
    uint256 private _maxBuyTxsPerBlock = 100;

    constructor() ERC20("Circle Layer", "CLAYER") Ownable(msg.sender) {
        MAX_SUPPLY = 1_000_000_000 * 10 ** 18; // 1 billion CLAYER tokens
        _weth = _router.WETH();

        pair = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            _weth
        );

        treasury1 = 0x8e26678c8811C2c04982928fe3148cBCBb435ad8;
        treasury2 = 0x9b2522710450a26719A09753A0534B0c33682Fe4;

        isExcludedFromFees[msg.sender] = true;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[pair] = true;
        isExcludedFromFees[treasury1] = true;
        isExcludedFromFees[treasury2] = true;

        isExcludedFromMaxWallet[msg.sender] = true;
        isExcludedFromMaxWallet[address(this)] = true;
        isExcludedFromMaxWallet[pair] = true;
        isExcludedFromMaxWallet[treasury1] = true;
        isExcludedFromMaxWallet[treasury2] = true;

        _mint(msg.sender, MAX_SUPPLY);
        _approve(msg.sender, address(_router), type(uint256).max);

        _deployer = msg.sender;
        _approve(address(this), address(_router), type(uint256).max);
    }

    function setTreasury1(address newTreasury1) external {
        require(newTreasury1 != address(0), "treasury1-is-0");
        require(
            msg.sender == _deployer || msg.sender == owner(),
            "only-deployer-or-owner"
        );
        treasury1 = newTreasury1;
        isExcludedFromFees[treasury1] = true;
        isExcludedFromMaxWallet[treasury1] = true;
    }

    function setTreasury2(address newTreasury2) external {
        require(newTreasury2 != address(0), "treasury2-is-0");
        require(
            msg.sender == _deployer || msg.sender == owner(),
            "only-deployer-or-owner"
        );

        treasury2 = newTreasury2;

        isExcludedFromFees[treasury2] = true;
        isExcludedFromMaxWallet[treasury2] = true;
    }

    function enableTrading() external onlyOwner {
        require(startBlock == 0, "trading-already-enabled");
        startBlock = block.number;
        startBlockTime = block.timestamp;
    }

    function setExcludedFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function setExcludedFromMaxWallet(
        address account,
        bool excluded
    ) external onlyOwner {
        isExcludedFromMaxWallet[account] = excluded;
    }

    function setCexAddressExcludedFromFees(
        address account,
        bool excluded
    ) external {
        require(
            msg.sender == _deployer || msg.sender == owner(),
            "only-deployer-or-owner"
        );
        isExcludedFromFees[account] = excluded;
    }

    function feesAndMaxWallet()
        external
        view
        returns (uint256 _feeBps, uint256 _maxWallet)
    {
        return _feesAndMaxWallet();
    }

    function _feesAndMaxWallet()
        internal
        view
        returns (uint256 _feeBps, uint256 _maxWallet)
    {
        if (startBlockTime == 0) {
            return (0, 0);
        }
        uint256 _diffSeconds = block.timestamp - startBlockTime;

        if (_diffSeconds < 3600) {
            // 1 min
            if (_diffSeconds < 60) {
                _feeBps = 3000; // 30%
                _maxWallet = MAX_SUPPLY / 1000; // 0.1%
                return (_feeBps, _maxWallet);
            }
            // 2-5 min
            if (_diffSeconds < 300) {
                _feeBps = 2500; // 25%
                _maxWallet = MAX_SUPPLY / 666; // 0.15%
                return (_feeBps, _maxWallet);
            }
            // 6-8 min
            if (_diffSeconds < 480) {
                _feeBps = 2000; // 20%
                _maxWallet = MAX_SUPPLY / 500; // 0.2%
                return (_feeBps, _maxWallet);
            }

            if (_diffSeconds < 900) {
                // 9-15 min
                _feeBps = 1000; // 10%
                _maxWallet = MAX_SUPPLY / 333; // 0.3%
                return (_feeBps, _maxWallet);
            }

            _feeBps = 500; // 5%
            _maxWallet = MAX_SUPPLY / 200; // 0.5%
            return (_feeBps, _maxWallet);
        }

        if (raiseAmount < 300 ether) {
            _feeBps = 500; // 5%;
        } else if (raiseAmount < 500 ether) {
            _feeBps = 400; // 4%;
        } else if (raiseAmount < 2000 ether) {
            _feeBps = 300; // 3%;
        } else {
            _feeBps = 0; // 0%;
        }
        _maxWallet = MAX_SUPPLY; // no limit
        return (_feeBps, _maxWallet);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        (uint256 _feeBps, uint256 _maxWallet) = _feesAndMaxWallet();

        bool isBuy = from == pair;
        if (isBuy || to == pair) {
            require(
                startBlock > 0 || isExcludedFromFees[to],
                "trading-not-enabled"
            );

            if (_feeBps != 0) {
                if (isBuy && !isExcludedFromFees[to]) {
                    if (
                        startBlockTime > 0 &&
                        block.timestamp - startBlockTime < 180
                    ) {
                        require(
                            maxBuyTxsPerBlockPerOrigin[tx.origin][
                                block.number
                            ] < _maxBuyTxsPerBlockPerOrigin,
                            "max-buy-txs-per-block-per-origin-exceeded"
                        );
                        maxBuyTxsPerBlockPerOrigin[tx.origin][block.number]++;

                        require(
                            maxBuyTxsPerBlock[block.number] <
                                _maxBuyTxsPerBlock,
                            "max-buy-txs-per-block-exceeded"
                        );
                        maxBuyTxsPerBlock[block.number]++;
                    }

                    uint256 fee = (value * _feeBps) / 10000;
                    value -= fee;
                    super._update(from, address(this), fee);
                }

                if (!isBuy && !isExcludedFromFees[from]) {
                    uint256 fee = (value * _feeBps) / 10000;
                    value -= fee;
                    super._update(from, address(this), fee);
                    _swapTokensForEth();
                }
            } else {
                if (!isBuy && !isExcludedFromFees[from]) {
                    _swapTokensForEth();
                }
            }
        }

        require(
            isExcludedFromMaxWallet[to] || value + balanceOf(to) <= _maxWallet,
            "max-wallet-size-exceeded"
        );
        super._update(from, to, value);
    }

    function _swapTokensForEth() internal nonReentrant {
        uint256 startDiff = block.timestamp - startBlockTime;
        if (startDiff < 300) {
            return;
        }

        uint256 _tokenAmount = balanceOf(address(this));

        if (_tokenAmount == 0) {
            return;
        }

        address[] memory _path = new address[](2);
        _path[0] = _weth;
        _path[1] = address(this);

        // sell max 0.2 eth worth of tokens
        uint256 _maxTokenAmount = _router.getAmountsOut(0.2 ether, _path)[1];

        if (_tokenAmount > _maxTokenAmount) {
            _tokenAmount = _maxTokenAmount;
        }

        _path[0] = address(this);
        _path[1] = _weth;
        uint256 _treasuryBalanceBefore1 = address(treasury1).balance;
        uint256 _treasuryBalanceBefore2 = address(treasury2).balance;

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            _path,
            address(this),
            block.timestamp
        );

        uint256 ethReceived = address(this).balance;

        if (ethReceived > 0) {
            // Split ETH 50/50 between treasury1 and treasury2
            uint256 treasury1Share = ethReceived / 2;
            uint256 treasury2Share = ethReceived - treasury1Share;
            bool success;

            if (treasury1Share > 0) {
                (success, ) = treasury1.call{value: treasury1Share}("");
            }

            if (treasury2Share > 0) {
                (success, ) = treasury2.call{value: treasury2Share}("");
            }

            uint256 _treasuryBalanceAfter1 = address(treasury1).balance;
            uint256 _treasuryBalanceAfter2 = address(treasury2).balance;

            raiseAmount +=
                (_treasuryBalanceAfter1 - _treasuryBalanceBefore1) +
                (_treasuryBalanceAfter2 - _treasuryBalanceBefore2);
        }
    }

    receive() external payable {}
}
