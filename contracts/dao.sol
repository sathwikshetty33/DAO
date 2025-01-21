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
        contributionTimeEnd = block.timestamp + _contributionTimeEnd;
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
    function Contribution() public payable {
    require(block.timestamp <= contributionTimeEnd,"Contribution Time ended");
    require(msg.value > 0, "Send more then 0");
    isInvestor[msg.sender]=true;
    numOfShares[msg.sender] += msg.value;
    totalShares += msg.value;
    availableFunds+=msg.value;
    investorList.push(msg.sender);
    }
    function redeemshare(uint amt) public onlyInvestor() {
        require(amt<=numOfShares[msg.sender],"You shares are less than the amount");
        require(amt > 0, "Send more then 0");
        require(availableFunds >= amt,"Not enough funds");
        totalShares -= amt;
        numOfShares[msg.sender]-=amt;
        if(numOfShares[msg.sender]==0)
        {
            isInvestor[msg.sender]=false;
        }
        availableFunds -= amt;
        payable(msg.sender).transfer(amt);
    }
    function transferShare(uint amt, address _to) public {
        require(amt > 0, "Send more then 0");
        require(availableFunds >= amt,"Not enough funds");
        require(amt<=numOfShares[msg.sender],"You shares are less than the amount");
        totalShares -= amt;
        numOfShares[msg.sender]-=amt;
        numOfShares[_to]+=amt;
        if(numOfShares[msg.sender]==0)
        {
            isInvestor[msg.sender]=false;
        }
        isInvestor[_to]=true;
        investorList.push(_to);
    }
    function createProposal(string calldata _desc, uint _amt,address payable _recepient) public onlyManager {
        require(availableFunds >= _amt,"Not enough funds currently");
        proposals[nextProposalId] = Proposal(nextProposalId,_desc,_amt,_recepient,0,block.timestamp + voteTime,false);
        nextProposalId++;
    }
    function voteProposal(uint _pid) public onlyInvestor() {
        require(_pid >= 0 && _pid < nextProposalId,"Invalid Proposal id");
        require(isVoted[msg.sender][_pid]==false,"Already Voted");
        Proposal storage propsal = proposals[_pid];
        require(propsal.end >= block.timestamp,"Voting period Over");
        require(propsal.isExecuted==false,"Already Executed");
        propsal.votes+=numOfShares[msg.sender];
        isVoted[msg.sender][_pid]=true;
    }
    function executeProposal(uint _pid) public onlyManager(){
        require(_pid >= 0 && _pid < nextProposalId,"Invalid Proposal id");
        Proposal storage propsal = proposals[_pid];
        require((propsal.votes*100/totalShares)>=51,"No Majority votes");
        require(propsal.isExecuted==false,"Already Executed");
        require(availableFunds >= propsal.amt,"Not enough funds currently");
        propsal.recepient.transfer(propsal.amt);
        propsal.isExecuted==true;
        availableFunds-=propsal.amt;
    }
    function PoposalList() public view returns(Proposal[] memory){
        Proposal[] memory arr = new Proposal[](nextProposalId-1);
        for(uint i=0;i<nextProposalId;i++)
        {
            arr[i]=(proposals[i]);
        }
        return arr;
    }
}