pragma solidity ^0.4.0;
contract ERC20 {

    string public name;             //代币名称
    string public symbol;           //代币单位
    uint8 public decimals;          //小数点位数
    uint public  _totalSupply;      //总供应数
    address public owner;                                       //合约拥有者
    mapping(address => uint256) balances;                       //代币帐本
    mapping(address => mapping (address => uint256)) allowed;   //
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Destroy(address indexed addr);

    function ERC20(string _name, string _symbol, uint8 _decimals, uint quantity) public {
        owner = msg.sender;       //合约拥有者
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = quantity * 10**uint(decimals);            //代币总供应量
        balances[owner] = _totalSupply;                         //将代币全部转给创建者
        emit Transfer(address(0), owner, _totalSupply);              //记录事件
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];     //总供应商=总数-销毁数量;
    }
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
       
    function transfer(address to, uint tokens) public returns (bool success) {
        if(to == 0x0) return false;                         //不允许自己转入销毁地址
        if(balances[msg.sender] < tokens) return false;     //必须有足够的转出代币
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function approve(address spender, uint tokens) public returns (bool success) {
        if(balances[msg.sender]<tokens) return false;

        allowed[msg.sender][spender] += tokens;

        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        if(tokens>allowed[from][msg.sender]) return false;  //代币不能大于允许的数量

        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;

        emit Transfer(from, to, tokens);
        return true;
    }
    
    //自定义方法
    //销毁指定地址的代币
    function destroy(address addr) public returns (bool success) {
        if(msg.sender != owner) return false;
        if(addr == 0x0) return false;           // 不能锁定 owner
        if(addr == owner) return false;         // 不能锁定 0x 地址
        if(balances[addr] <= 0) return false;    // 销毁地址的代币数量必须>0    

        balances[address(0)] += balances[addr]; //将要销毁的代币转入销毁地址
        balances[addr] = 0;                     //销毁地址上的全部代币
        emit Destroy(addr);
        return true;
    }
}