pragma solidity ^0.4.24;

import "./safemath.sol";

contract transfer {
    
// prosumer account elements
    struct prosumer{
        
        address prosumerAddress;
        uint16 storageEnergy;
        uint16 prosumerAccount;
        uint8 ApproveIndex;
        
    } 


// consumer account elements    
    struct consumer{
        
        address consumerAddress;
        uint16 goalEnergy;
        uint16 collection;
        uint8 prosumerid;
        uint8 bid;
        uint16 gridEnergy;
        uint16 gridAccount;
        mapping(uint8 => prosumer) mapPr0;
        
    }
    
// grid account address
    address grid = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;


// consumer account register    
    uint8 consumerID = 0;
    mapping(address => consumer) mapConsumer;
    
    function consumerRegister(address _prosumerAddress, uint16 _goalEnergy, uint8 _bid) public {
        
        // consumerID++;
        mapConsumer[_prosumerAddress] = consumer(_prosumerAddress, _goalEnergy, 0, 0, _bid, 0, 0);
        
    }


// prosumer account register
    uint8 prosumerID = 0;
    mapping(address => prosumer) mapProsumer;
    
    function prosumerRegister(address _address, uint16 _storageEnergy) public {
        
        // prosumerID++;
        mapProsumer[_address] = prosumer(_address, _storageEnergy, 0, 0);
        
    }
    

    function paytoContract() external payable{
        
    }
    
    function checkContractAccount() external view returns(uint16){
        
        return uint16(address(this).balance);
        
    }

//  Calculation of the charges to be paid by the consumer to the prosumer or to the grid.
    function transferBalance(address _prosumerAddress, address _consumerAddress) public returns(uint16, uint16){
        
        consumer storage _consumer = mapConsumer[_consumerAddress];
        prosumer storage _prosumer = mapProsumer[_prosumerAddress];
        if(_consumer.goalEnergy <= _prosumer.storageEnergy){
            _consumer.collection = SafeMath.add(_consumer.goalEnergy, _consumer.collection);
            _consumer.goalEnergy = 0;
            _prosumer.storageEnergy = _prosumer.storageEnergy - _consumer.collection;
            uint16 balance = SafeMath.mul(_consumer.bid, _consumer.collection);
            _prosumer.prosumerAccount = SafeMath.add(balance, _prosumer.prosumerAccount);
            // _consumer.prosumerid = _prosumerID;
            return (_prosumer.prosumerAccount, 0);
            
        }
        
        else{
            
            _consumer.goalEnergy = SafeMath.sub(_consumer.goalEnergy, _prosumer.storageEnergy);
            _consumer.gridEnergy = _consumer.goalEnergy;
            _prosumer.prosumerAccount = SafeMath.mul(_consumer.bid, _prosumer.storageEnergy);
            _prosumer.storageEnergy = 0;
            // _consumer.prosumerid = _prosumerID;
            _consumer.gridAccount = SafeMath.mul(6, _consumer.goalEnergy);
            _consumer.goalEnergy = 0;
            return (_prosumer.prosumerAccount, _consumer.gridAccount);
            
        }
        
    }
    
//  pay to prosumer    
    function balancetoProsumer(address _prosumerAddress) external payable{
        
        prosumer storage _prosumer = mapProsumer[_prosumerAddress];
        
        if(_prosumer.prosumerAccount > 0){
            _prosumer.prosumerAddress.transfer(_prosumer.prosumerAccount);
        }
        _prosumer.prosumerAccount = 0;
        
    }
    
    
//  pay to grid
    function balancetoGrid(address _consumerAddress) external payable{
        
        consumer storage _consumer = mapConsumer[_consumerAddress];
        
        if(_consumer.gridAccount > 0){
            grid.transfer(_consumer.gridAccount);
            _consumer.gridAccount = 0;
        }
        
    }
    
//  prosumer agree to sell energy to the grid

    function approvetoGrid(address _prosumerAddress) external {
        
        prosumer storage _prosumer = mapProsumer[_prosumerAddress];
        // require(msg.sender == _prosumer.prosumerAddress);
        _prosumer.ApproveIndex = 1;
        
    }    
    
//  sell energy to grid
    function selltoGrid(address _prosumerAddress) external payable{
        
        prosumer storage _prosumer = mapProsumer[_prosumerAddress];
        uint balanceto = _prosumer.storageEnergy * 20;
        _prosumerAddress.transfer(balanceto);
        
    }
     
     
    
    
//  Users check account energy remaining and account balance
    function checkbalance(address _prosumerAddress) public view returns(uint){
        
        return (_prosumerAddress.balance);
    }


//  Check the consumer's goalenergy, and the collected energy 
     function testconsumer(uint8 _consumerID) public view returns(uint, uint, uint){
        
        return (mapConsumer[_consumerID].goalEnergy, mapConsumer[_consumerID].collection, mapConsumer[_consumerID].prosumerid);
    }
    
//  check the balance of prosumeraccount
    function testbalanceProsumer(uint8 _prosumerID) public view returns(uint){
        
        return mapProsumer[_prosumerID].prosumerAddress.balance;
        
    }
    
//  check the balance of gridaccount    
    function testbalanceGrid() public view returns(uint){
       
        return grid.balance;
    }
        
}
    
