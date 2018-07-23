pragma solidity ^0.4.0;
contract voteDemo {
    
    //定义投票人的结构
    struct Voter{
        uint weight; //投票人的权重
        bool voted ;// 是否已经投票
        address delegate; //委托代理人投票
        uint vote; // 投票主题的序号
    }
    
    //定义投票主题的结构
    struct Posposal{
        bytes8 name ;  //投票主题的名字
        uint voteCount; //主题的得到的票数
    }

    //定义投票的发起者
    address public chairperson;
    
    //所有人的投票人
    mapping(address=>Voter) public voters;
    
    //具体的投票主题
    Posposal[] public posposals;
    
    
    //构造函数
    constructor (bytes8[] peposposalName)public{
        //初始化投票的发起人，就是当前合约的部署者
        chairperson = msg.sender;
        //给发起人投票权
        voters[chairperson].weight = 1;
        
        //初始化投票的主题
        for(uint i = 0; i <peposposalName.length ;i++ ){
            posposals.push(Posposal({name:peposposalName[i],voteCount:0}));
        }
    }
    
    //添加投票者
    function  giveRightToVote(address _voter)public{
        //只有投票的发起人才能够添加投票者
        //添加的投票者不能是已经参加过投票了
        
        require(    voters[_voter].voted == false);
        require( msg.sender==chairperson  );
        //赋予合格的投票者投票权重
        voters[_voter].weight = 1;
    }
    
    //将自己的票委托给to来投
    function  delegate(address dele)public{
        //检查当前交易的发起者是不是已经投过票了
        Voter sender = voters[msg.sender];
        //如果是的话，则程序终止
        require(sender.voted == false);
        
        //检查委托人是不是也委托人其他人来投票
        while(voters[dele].delegate != address(0)){
            //如果是的话，则把委托人设置成委托人的委托人
            address add = voters[dele].delegate;
            //如果发现最终的委托人是自己，则终止程序
            require(add != msg.sender);
        }
        
        //交易的发起者不能再投票了
        sender.voted = true;
        //设置交易的发起者的投票代理人
        sender.delegate = add;
        //找到代理人
        Voter delegate = voters[add];
        //检测代理人是否已经投票
        if(delegate.voted){
            //如果是：则把票直接投给代理人投的那个主题
            posposals[delegate.vote].voteCount +=sender.weight;
        }else{
            //如果不是：则把投票的权重给予代理人
            delegate.weight +=sender.weight;
        }
    }
    //投票
    function vote(uint pid)public{
        //找到投票者
        Voter sender = voters[msg.sender];
        //检查是不是已经投过票
        require(sender.voted==false);
            //如果否：则投票
        sender.voted = true;  //设置当前用户已投票
        sender.vote = pid;    //设置当前用户的投的主题的编号
        posposals[pid].voteCount +=sender.weight;  //把当前用户的投票权重给予对应的主题
    }
   
    
    //计算票数最多的主题
    function winid() constant public returns(uint winningid){
        //声明一个临时变量，用来比大小
        uint winningCount = 0;
        //编列主题，找到投票数最大的主题
        for(uint i = 0; i<posposals.length; i++ ){
            if(posposals[i].voteCount > winningCount ){
                winningCount = posposals[i].voteCount;
                winningid = i;
            }
        }
    }
    
    
    function winname() view public returns(bytes8 winnername){
        winnername = posposals[winid()].name;
    }
    
    
    
}