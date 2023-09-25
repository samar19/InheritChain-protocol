// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract InChainERC20 is AutomationCompatibleInterface {
    
    enum Status {
        active,
        inactive,
        executed,
        failed
    }

    struct will {
        Status status;
        string tokenName;
        uint id;
        uint timeRemaining;
        uint dedline;
        uint amt;
        string message;
        string video;
        address from;
        address to;
        address contractAddress;
        string info;
    }

    uint public willCount;
    mapping(address => uint[]) public beneficiary;
    mapping(address => uint[]) public testator;
    mapping(uint => will) public idToWill;
    will[] public willList;

    function signWill(string memory _tokenName,uint _dedline, uint _amt, address _to, address _contractAddress, string memory _message, string memory _video) public {
        will memory temp;
        temp.status = Status.active;
        temp.tokenName = _tokenName;
        temp.id = willCount;
        temp.timeRemaining = _dedline;
        temp.dedline = block.timestamp + _dedline;
        temp.amt = _amt;
        temp.from = msg.sender;
        temp.to = _to;
        temp.contractAddress = _contractAddress;
        temp.message = _message;
        temp.video = _video;
        willList.push(temp);
        idToWill[willCount] = temp;
        testator[msg.sender].push(willCount);
        beneficiary[_to].push(willCount);
        willCount++;
    }

    function extendtWill(uint _id, uint _dedline) public {
        require(willList[_id].from == msg.sender, "You Can't Edit others will");
        require(willList[_id].status == Status.active , "Your Will is inactive");
        will storage temp = willList[_id];
        temp.timeRemaining = _dedline;
        temp.dedline = block.timestamp + _dedline;
    }

    function stopWill(uint _id) public {
        require(willList[_id].from == msg.sender, "You Can't Edit others will");
        require(willList[_id].status == Status.active , "will is not active");
        willList[_id].status = Status.inactive;
    }

    function resumeWill(uint _id) public {
        require(willList[_id].from == msg.sender, "You Can't Edit others will");
        require(willList[_id].status == Status.inactive , "will is already active");
        willList[_id].status = Status.active;
    }

    function executeWill(uint _id) public {
        uint aaa = 0;
        require(willList[_id].status == Status.active , "will should be active");
        will storage temp = willList[_id];
        require(temp.dedline < block.timestamp , "time is pending");

        uint examt = temp.amt;

        bytes4 BLNC_OF = bytes4(keccak256("balanceOf(address)"));
        bytes4 TRF_FROM = bytes4(keccak256("transferFrom(address,address,uint256)"));

        (bool success1, bytes memory data1) = address(temp.contractAddress).call(abi.encodeWithSelector(BLNC_OF,temp.from));
        if(data1.length == 32){
            uint balance = abi.decode(data1, (uint256));
            if(balance < temp.amt){
                examt = balance;
                aaa = 1;
            }
            (bool success2, bytes memory data2) = address(temp.contractAddress).call(abi.encodeWithSelector(TRF_FROM,temp.from,temp.to,examt));
            if(success2){
                temp.status = Status.executed;
                if(aaa == 1) temp.info = "Success but Testator had low balance than Request amount and you got all of it.";
            } else {
                temp.status = Status.failed;
                // allowance was not enough for amount
            }
        } else {
            temp.status = Status.failed;
            // contract was not ERC20
        }
    } 

    function execution() public {
        require(willList.length != 0, "No Will yet come");
        for(uint i = 0 ; i < willList.length; i++){
            if(willList[i].dedline < block.timestamp){
                if(willList[i].status == Status.active){
                    executeWill(i);
                }
            }
        }
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded
