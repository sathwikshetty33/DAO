// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract DAO{

    struct Proposal{
        uint id;
        string desc;
        uint amt;
        address payable recepient;
        uint votes;
        uint end;
        bool isExecuted;
    }
    mapping(address=>bool) private isInvestor;
    mapping(address=>uint) public numOfShares;
    mapping(address=>mapping(uint=>bool)) public isVoted;
    mapping(address=>mapping(address=>bool)) public withdrawlStatus;
    address[] public investorList;
    mapping (uint=>Proposal) public proposals;
    uint public totalShares;
    uint public availableFunds;
    uint public contributionTimeEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public manager;

    constructor(uint _contributionTimeEnd, uint _voteTime, uint _qorum){
        require(_qorum>0 && _qorum < 100, "Not a Valid ");
        contributionTimeEnd = _contributionTimeEnd;
        voteTime = _voteTime;
        quorum = _qorum;
        manager = msg.sender;
    }

    modifier onlyInvestor(){
        require(isInvestor[msg.sender]==true, "You are not an Investor!");
    _;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"You are not a manager");
        _;
    }
    
}