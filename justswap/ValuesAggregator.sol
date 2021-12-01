pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../interfaces/ITRC20.sol";
import "../interfaces/IJustswapFactory.sol";
import "../utils/SafeMath.sol";



contract ValuesAggregator  {
    using SafeMath for uint256;
    address public factory;
    constructor(address _factory) public{
        factory = _factory;
    }

    struct userInfos{
        address exchange;
        uint256 token_amount;
        uint256 trx_amount;
        uint256 uni_amount;
        uint256 totalSupply;
    }

    struct tokenBalance{
        address token_addr;
        uint256 token_amount;
    }

    function getToken(address _exchangeAddr) public view returns (address) {
        return IJustswapFactory(factory).getToken(_exchangeAddr);
    }

    function getPool(address _user ,address[] memory  _exchange) public view
    returns(uint256[] memory _token,uint256[] memory _trx,uint256[] memory _uniToken,uint256[] memory _totalsupply){
        uint256 _exchangeCount = _exchange.length;
        _token =  new uint256[](_exchangeCount);
        _trx = new uint256[](_exchangeCount);
        _uniToken = new uint256[](_exchangeCount);
        _totalsupply = new uint256[](_exchangeCount);

        for(uint256 i = 0; i< _exchangeCount; i++){
            address token = getToken(_exchange[i]);
            uint256 uni_amount = ITRC20(_exchange[i]).balanceOf(_user);
            uint256 token_reserve = ITRC20(token).balanceOf(_exchange[i]);
            uint256 total_liquidity =  ITRC20(_exchange[i]).totalSupply();
            uint256 trx_amount = 0;
            uint256 token_amount = 0;
            if(total_liquidity > 0){
                trx_amount = uni_amount.mul(_exchange[i].balance) / total_liquidity;
                token_amount = uni_amount.mul(token_reserve) / total_liquidity;
            }
            _token[i] = token_amount;
            _trx[i] = trx_amount;
            _uniToken[i] = uni_amount;
            _totalsupply[i] = total_liquidity;
        }
    }

    function getPool2(address _user ,address[] memory  _exchange) public view returns(userInfos[] memory info){
        uint256 _exchangeCount = _exchange.length;
        info = new userInfos[](_exchangeCount);
        for(uint256 i = 0; i< _exchangeCount; i++){
            address token = getToken(_exchange[i]);
            // _exchange.balanceOf(user)
            uint256 uni_amount = ITRC20(_exchange[i]).balanceOf(_user);
            // token.balanceOf(_exchange)
            uint256 token_reserve = ITRC20(token).balanceOf(_exchange[i]);
            // _exchange.totalSupply
            uint256 total_liquidity =  ITRC20(_exchange[i]).totalSupply();
            uint256 trx_amount = 0;
            uint256 token_amount = 0;
            if(total_liquidity > 0){
                trx_amount = uni_amount.mul(_exchange[i].balance) / total_liquidity;
                token_amount = uni_amount.mul(token_reserve) / total_liquidity;
            }
            info[i] = userInfos(address(_exchange[i]),token_amount,trx_amount,uni_amount, total_liquidity);
        }

    }

    function getBalance2(address _user , address[] memory _tokens) public view returns(tokenBalance[] memory info){
        uint256 _tokenCount = _tokens.length;
        info = new tokenBalance[](_tokenCount);
        for(uint256 i = 0; i< _tokenCount; i++){
            uint256 token_amount = ITRC20(_tokens[i]).balanceOf(_user);
            info[i] = tokenBalance(_tokens[i],token_amount);
        }
    }

    function getBalance(address _user , address[] memory _tokens) public view returns(uint256[] memory info){
        uint256 _tokenCount = _tokens.length;
        info = new uint256[](_tokenCount);
        for(uint256 i = 0; i< _tokenCount; i++){
            uint256 token_amount = 0;
            if(address(0) == _tokens[i]){
                token_amount = address(_user).balance;
            }else{
                ( bool success, bytes memory data) = _tokens[i].staticcall(abi.encodeWithSelector(0x70a08231, _user));
                token_amount = 0;
                if(data.length != 0){
                    token_amount = abi.decode(data,(uint256));
                }
            }
            info[i] = uint256(token_amount);
        }
    }
}
