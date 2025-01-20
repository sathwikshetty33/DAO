// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract twitter{
    struct Tweet{
        uint id;
        address author;
        string content;
        uint createdAt;
    }
    struct Message{
        uint id;
        address from;
        address to;
        string content;
        uint createdAt;
    }

    mapping(uint=>Tweet) public tweets;
    mapping(address=>uint[]) public tweetsof;
    mapping(address=>Message[]) public conversations;
    mapping(address=>mapping(address=>bool)) public operators;
    mapping(address=>address[]) public following;
    uint nextId;
    uint nextMessageId;
    function _tweet(address _from, string memory _content) internal {
        require(msg.sender==_from || operators[msg.sender][_from], "Unauthorized");
        tweets[nextId]=Tweet({id:nextId,author:_from,content:_content,createdAt:block.timestamp});
        tweetsof[_from].push(nextId);
        nextId++;
    }
    function _message(address _from, address _to, string memory _content) public {
        conversations[_from].push(Message({id:nextMessageId,from:_from,to:_to,content:_content,createdAt:block.timestamp}));
        nextMessageId++;
    }
    function tweet(string memory _content) public  {
        _tweet(msg.sender, _content);
    }
    function tweet(address _from, string memory _content) internal {
        _tweet(_from, _content);
    }
    function message( address _to, string memory _content) public {
        _message(msg.sender, _to, _content);
    }
    function message(address _from, address _to, string memory _content) public {
        _message(_from, _to, _content);
    }
    function follow(address _tofollow) public {
        following[msg.sender].push(_tofollow);
    }
    function allowaccess(address _user) public{
        operators[msg.sender][_user]=true;
    }
    function removeaccess(address _user) public{
        operators[msg.sender][_user]=false;
    }
    function getLatesTweets(uint count)public view returns(Tweet[] memory) {
        require(count >0 && count < nextId,"Wrong input");
        Tweet[] memory _tweets=new Tweet[](count);
        uint j;
        for(uint i =nextId-count;i<nextId;i++)
        {
            _tweets[j]= tweets[i];
            j ++ ;
        }
        return _tweets;
    }
    function getLatestTweetsOfUser(address _user, uint count) public view returns (Tweet[] memory) {
    uint[] memory indexes = tweetsof[_user];
    require(count > 0 && count <= indexes.length, "Invalid count");

    Tweet[] memory _tweets = new Tweet[](count);
    uint start = indexes.length - count;
    for (uint i = 0; i < count; i++) {
        _tweets[i] = tweets[indexes[start + i]];
    }
    return _tweets;
}
}