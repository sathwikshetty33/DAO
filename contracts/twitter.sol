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
        tweets[nextId]=Tweet({id:nextId,author:_from,content:_content,createdAt:block.timestamp});
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
}