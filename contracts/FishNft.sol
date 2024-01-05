// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Random} from "./libraries/Random.sol";

interface IFISH {
    function mint(address account_, uint256 amount_) external returns (bool);
}

contract FishNft is
    Initializable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMath for uint256;

    mapping(address => bool) public executor; //允许usdcbuyNFTLogic.sol合约调用

    // Optional mapping for token URIs
    // mapping(uint256 => string) private _tokenURIs;
    uint256 public tokenIdIndex; //销毁的时候用，指定销毁哪一个
    string public _baseURI_;
    // uint256 public tokenLimit;
    address public FISH; //FISH地址
    uint256 public maxPreSale; //最大销售量
    uint256 public preSaleEnd; //销售结束时间
    bool public stateOpen; //合约状态  false:合约还未开始，预售期  NFT可以卖，奖励先不发
    /**
    userInfo
     */
    struct UserInfo {
        uint256 lastClaimTimestamp; //上一次领取奖励的时间
        uint256 releaseSecond; //释放时间
        uint256 claimble; //可领的奖励
    }

    /**
    nft 
     */
    struct NftInfo {
        string fishStr; //鱼的形状
        uint256 remainingReward; //释放对应的奖励
        uint256 lv; //0  1  2
        uint256 random; //随机数，可以用作种子随机数
    }

    mapping(uint256 => uint256) public releaseCycle; //释放周期
    mapping(uint256 => NftInfo) internal _nftInfo;
    mapping(address => UserInfo) internal _userInfo;

    // constructor(){}
    //代理合约不需要构造函数，需要用初始化函数
    function initialize(
        string memory _name,
        string memory _symbol,
        address _FISH //平台币地址
    ) external initializer {
        FISH = _FISH;
        maxPreSale = 1000;
        stateOpen = false;
        __ERC721_init(_name, _symbol);
        __Ownable_init(); //只要是代理合约且有OwnableUpgradeable，必须加这句代码
        executor[msg.sender] = true; //合约部熟人设置为最高级
        releaseCycle[0] = 14 days;
        releaseCycle[1] = 10 days;
        releaseCycle[2] = 5 days;
    }

    modifier onlyExecutor() {
        require(executor[msg.sender], "executor: caller is not the executor");
        _;
    }

    function nftInfo(uint256 _id) external view returns (NftInfo memory) {
        return _nftInfo[_id];
    }

    function setNftInfo(
        uint256 i,
        string memory str,
        uint256 _remainingReward,
        uint256 _lv,
        uint256 _random
    ) public onlyExecutor returns (bool) {
        //onlyExecutor：只有执行者可以调用
        return _setNftInfo(i, str, _remainingReward, _lv, _random);
    }

    function _setNftInfo(
        uint256 i,
        string memory str,
        uint256 _remainingReward,
        uint256 _lv,
        uint256 _random
    ) internal returns (bool) {
        //internal：内部调用
        _nftInfo[i] = NftInfo({
            fishStr: str,
            remainingReward: _remainingReward,
            lv: _lv,
            random: _random
        });
        return true;
    }

    function userInfo(address _user) external view returns (UserInfo memory) {
        return _userInfo[_user];
    }

    function setUserInfo(
        address _user,
        uint256 _lastClaimTimestamp,
        uint256 _releaseSecond,
        uint256 _claimble
    ) public onlyExecutor returns (bool) {
        return
            _setUserInfo(_user, _lastClaimTimestamp, _releaseSecond, _claimble);
    }

    function _setUserInfo(
        address _user,
        uint256 _lastClaimTimestamp,
        uint256 _releaseSecond,
        uint256 _claimble
    ) internal returns (bool) {
        _userInfo[_user] = UserInfo({
            lastClaimTimestamp: _lastClaimTimestamp,
            releaseSecond: _releaseSecond,
            claimble: _claimble
        });
        return true;
    }

    function setReleaseCycle(
        uint256 _lv,
        uint256 _releaseSecond
    ) public onlyOwner returns (bool) {
        releaseCycle[_lv] = _releaseSecond;
        return true;
    }

    function setStateOpen(bool _bool) public onlyOwner returns (bool) {
        stateOpen = _bool;
        return true;
    }

    function setBaseURI(string memory _str) public onlyOwner returns (bool) {
        _baseURI_ = _str;
        return true;
    }

    function setMaxPreSale(uint256 _val) public onlyOwner returns (bool) {
        maxPreSale = _val;
        return true;
    }

    function setPreSaleEnd(uint256 _val) public onlyOwner returns (bool) {
        preSaleEnd = _val;
        return true;
    }

    function setExecutor(
        address _address,
        bool _type
    ) external onlyOwner returns (bool) {
        executor[_address] = _type;
        return true;
    }

    function getLvPoint(uint256 seed) internal view returns (uint256 lv) {
        bytes32[] memory pool = Random.initLatest(3, seed);

        uint256 RNG = uint256(Random.uniform(pool, 1, 100));

        if (RNG <= 60) {
            lv = 0;
        } else if (RNG <= 90) {
            lv = 1;
        } else {
            lv = 2;
        }
    }

    function getFishBodyPoint(
        uint256 seed
    ) internal view returns (uint256 ret) {
        bytes32[] memory pool = Random.initLatest(10, seed);

        uint256 RNG = uint256(Random.uniform(pool, 1, 100));

        if (RNG <= 10) {
            ret = 0;
        } else if (RNG <= 20) {
            ret = 1;
        } else if (RNG <= 30) {
            ret = 2;
        } else if (RNG <= 40) {
            ret = 3;
        } else if (RNG <= 50) {
            ret = 4;
        } else if (RNG <= 60) {
            ret = 5;
        } else if (RNG <= 70) {
            ret = 6;
        } else if (RNG <= 80) {
            ret = 7;
        } else if (RNG <= 90) {
            ret = 8;
        } else {
            ret = 9;
        }
    }

    function createFish(
        address _to,
        uint256 seed,
        uint256 _remainingReward
    ) internal returns (bool) {
        //internal:内部调用，只限于本合约内部调用，不能浍河与进行调用
        string[10] memory fishBodys = [
            "|",
            "#",
            "(",
            ")",
            "!",
            "]",
            "$",
            "[",
            "+",
            "&"
        ];

        uint256 fishBodysID1 = getFishBodyPoint(seed + 1 + totalSupply()); //随机点
        uint256 fishBodysID2 = getFishBodyPoint(seed + 2 + totalSupply());
        uint256 fishBodysID3 = getFishBodyPoint(seed + 3 + totalSupply());
        uint256 fishBodysID4 = getFishBodyPoint(seed + 4 + totalSupply());
        uint256 fishBodysID5 = getFishBodyPoint(seed + 5 + totalSupply());

        string memory fishAssembly = string(
            abi.encodePacked(
                "<",
                "\u00b0", //"°"
                fishBodys[fishBodysID1],
                fishBodys[fishBodysID2],
                fishBodys[fishBodysID3],
                fishBodys[fishBodysID4],
                fishBodys[fishBodysID5],
                "\u2264" //"≤"
            )
        );

        bytes32[] memory pool = Random.initLatest(8, seed);
        uint256 backupPoint = uint256(Random.uniform(pool, 1, 10000)); //备用的随机数

        uint256 lv = getLvPoint(seed);
        _registerToken(_to, fishAssembly, _remainingReward, lv, backupPoint);
        return true;
    }

    function _registerToken(
        address _to,
        string memory _fishAssembly,
        uint256 _remainingReward,
        uint256 _lv,
        uint256 _backupPoint
    ) internal returns (bool) {
        _setNftInfo(
            tokenIdIndex,
            _fishAssembly,
            _remainingReward,
            // releaseCycle[_lv],
            _lv,
            _backupPoint
        );

        super._safeMint(_to, tokenIdIndex); //铸造NFT
        tokenIdIndex = tokenIdIndex.add(1);
        return true;
    }

    function mintFromExecutor(
        //给usdcBuy合约调用
        address _to, //给谁创建
        uint256 _seed, //随机数种子，生成随机数
        uint256 _remainingReward //算好nft有多少奖励
    ) external onlyExecutor returns (bool) {
        require(executor[msg.sender], "executor no good");
        return createFish(_to, _seed, _remainingReward);
    }

    function integerToString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 temp = _i;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_i != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_i % 10)));
            _i /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        return string(abi.encodePacked(_baseURI_, integerToString(tokenId)));
    }

    function burn(uint256 _id) external returns (bool) {
        require(msg.sender == ownerOf(_id), "No approved");
        checkState();
        UserInfo storage user = _userInfo[msg.sender];
        user.lastClaimTimestamp = block.timestamp;
        user.releaseSecond = releaseCycle[_nftInfo[_id].lv];
        user.claimble = user.claimble.add(_nftInfo[_id].remainingReward);

        super._burn(_id);
        return true;
    }

    function burnFrom(
        address _user,
        uint256 _id
    ) external onlyExecutor returns (bool) {
        require(_user == ownerOf(_id), "No approved");
        checkState();
        UserInfo storage user = _userInfo[_user];
        user.lastClaimTimestamp = block.timestamp;
        user.releaseSecond = releaseCycle[_nftInfo[_id].lv];
        user.claimble = user.claimble.add(_nftInfo[_id].remainingReward);

        super._burn(_id);
        return true;
    }

    function claim() external returns (bool) {
        UserInfo storage user = _userInfo[msg.sender];
        require(user.claimble > 0, "claimble is 0");
        uint256 diffTimestamp = block.timestamp.sub(user.lastClaimTimestamp);
        if (diffTimestamp >= user.releaseSecond) {
            IFISH(FISH).mint(msg.sender, user.claimble);
            user.lastClaimTimestamp = block.timestamp;
            user.claimble = 0;
            user.releaseSecond = 0;
        } else {
            uint256 _pending = diffTimestamp.mul(user.claimble).div(
                user.releaseSecond
            );
            IFISH(FISH).mint(msg.sender, _pending);
            user.lastClaimTimestamp = block.timestamp;
            user.claimble = user.claimble.sub(_pending);
            user.releaseSecond = user.releaseSecond.sub(diffTimestamp);
        }
        return true;
    }

    function pending() external view returns (uint256) {
        UserInfo storage user = _userInfo[msg.sender];
        uint256 diffTimestamp = block.timestamp.sub(user.lastClaimTimestamp);
        if (diffTimestamp >= user.releaseSecond) {
            return user.claimble;
        } else {
            return diffTimestamp.mul(user.claimble).div(user.releaseSecond);
        }
    }

    function checkState() internal view returns (bool) {
        require(stateOpen, "Please wait for the agreement to start");
        if (maxPreSale <= totalSupply() || block.timestamp >= preSaleEnd) {
            return true;
        } else {
            require(
                false,
                "The sales time has not ended or the totalSupply quantity has not reached the target"
            );
        }
        return false;
    }
}
