pragma solidity ^0.5.8;


/**
 * @title TRC165
 */
interface ITRC165 {

    /**
     * @notice Query if a contract implements an interface
     */
    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}