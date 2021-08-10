pragma solidity ^0.4.24;

 

import "./safemath.sol";

 

contract Register {
    
    using SafeMath8 for uint8;
    using SafeMath for uint16;
    
    address public owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    /**
     * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner,'You are not the owner');
        _;
    }
    
    // Store the address of a registerable account
    address[] addresspool = [0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
                             0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c];
                             
    mapping(address => bool) RightofRegister; 
    
    // Giving accounts the permission to register.
    constructor() public onlyOwner(){
        
        uint256 count = addresspool.length;
        for(uint256 i=0; i<count; i++){
            
            RightofRegister[addresspool[i]] = true;
            
        }
    }
    
    enum Usertype{
        
        Consumer,
        Prosumer
        
    }
    
    struct Customer{
        
        address customerAddress;
        string customerId;
        uint8 bid;
        uint16 StoragedEnergy;
        uint16 noncontrolableEnergy;
        uint16 flexibleEnergy;
        bool isRegistered; // check if the account has been registered
        Usertype condition;
        
    }
    mapping(address => Customer) customerInfo;
    

 

    
    function userRegister(address _address, string _customerId, uint8 _bid, uint16 _storagedEnergy) public{
        require(msg.sender == _address, 'Wrong Address');
        require(RightofRegister[_address] == true,'You have not permission to register');
        require(customerInfo[_address].isRegistered == false, 'Your account has been registered');
        customerInfo[_address] = Customer(_address, _customerId, _bid, _storagedEnergy, 0, 0, true, Usertype.Consumer);
    
    }

 

    struct NoncontrolabeAppliance{
        
        uint8 TV;
        uint8 Heater;
        uint8 WashingMachine;
        uint8 Dryer;
        uint8 Friger;
        uint8 Aircondotioner;
        uint8 InductionCooker;
        
    }
    mapping(string => NoncontrolabeAppliance) non_controlable;
    mapping(string => mapping(uint => uint8)) non_controlableIndex;
    
    struct FlexibleAppliance{
        
        uint8 TV;
        uint8 Heater;
        uint8 WashingMachine;
        uint8 Dryer;
        uint8 Friger;
        uint8 Aircondotioner;
        uint8 InductionCooker;
        
    }
    mapping(string => FlexibleAppliance) flexible;
    mapping(string => mapping(uint => uint8)) flexibleIndex;
    
    function choose_non_controllable_loads(string _customerId, uint8 _TV, uint8 _Heater, uint8 _WashingMachine,
    uint8 _Dryer, uint8 _Friger, uint8 _Aircondotioner, uint8 _InductionCooker) external{
        
        require(keccak256(customerInfo[msg.sender].customerId) == keccak256(_customerId), "Wrong customerId");
        
        require((_TV == 0 || _TV == 1) && (SafeMath8.add(non_controlable[_customerId].TV,_TV) <= 1), 'Be Turned on at the same time');
        require((_Heater == 0 || _Heater == 1) && (SafeMath8.add(non_controlable[_customerId].Heater, _Heater) <= 1), 'Be Turned on at the same time');
        require((_WashingMachine == 0 || _WashingMachine == 1) && (SafeMath8.add(non_controlable[_customerId].WashingMachine, _WashingMachine) <= 1), 'Be Turned on at the same time');
        require((_Dryer == 0 || _Dryer == 1) && (SafeMath8.add(non_controlable[_customerId].Dryer, _Dryer) <= 1), 'Be Turned on at the same time');
        require((_Friger == 0 || _Friger == 1) && (SafeMath8.add(non_controlable[_customerId].Friger, _Friger) <= 1), 'Be Turned on at the same time');
        require((_Aircondotioner == 0 || _Aircondotioner == 1) && (SafeMath8.add(non_controlable[_customerId].Aircondotioner,_Aircondotioner) <= 1), 'Be Turned on at the same time');
        require((_InductionCooker == 0 || _InductionCooker == 1) && (SafeMath8.add(non_controlable[_customerId].InductionCooker,_InductionCooker) <= 1), 'Be Turned on at the same time');
        
        non_controlable[_customerId].TV = _TV;
        non_controlable[_customerId].Heater = _Heater;
        non_controlable[_customerId].WashingMachine = _WashingMachine;
        non_controlable[_customerId].Dryer = _Dryer;
        non_controlable[_customerId].Friger = _Friger;
        non_controlable[_customerId].Aircondotioner = _Aircondotioner;
        non_controlable[_customerId].InductionCooker = _InductionCooker;
        
        non_controlableIndex[_customerId][1] = _TV;
        non_controlableIndex[_customerId][2] = _Heater;
        non_controlableIndex[_customerId][3] = _WashingMachine;
        non_controlableIndex[_customerId][4] = _Dryer;
        non_controlableIndex[_customerId][5] = _Friger;
        non_controlableIndex[_customerId][6] = _Aircondotioner;
        non_controlableIndex[_customerId][7] = _InductionCooker;
        
    }
    
    
    function choose_flexible_loads(string _customerId, uint8 _TV, uint8 _Heater, uint8 _WashingMachine,
    uint8 _Dryer, uint8 _Friger, uint8 _Aircondotioner, uint8 _InductionCooker) external{
        
        require(keccak256(customerInfo[msg.sender].customerId) == keccak256(_customerId), "Wrong customerId");
        require((_TV == 0 || _TV == 1) && (SafeMath8.add(non_controlable[_customerId].TV,_TV) <= 1), 'Be Turned on at the same time');
        require((_Heater == 0 || _Heater == 1) && (SafeMath8.add(non_controlable[_customerId].Heater, _Heater) <= 1), 'Be Turned on at the same time');
        require((_WashingMachine == 0 || _WashingMachine == 1) && (SafeMath8.add(non_controlable[_customerId].WashingMachine, _WashingMachine) <= 1), 'Be Turned on at the same time');
        require((_Dryer == 0 || _Dryer == 1) && (SafeMath8.add(non_controlable[_customerId].Dryer, _Dryer) <= 1), 'Be Turned on at the same time');
        require((_Friger == 0 || _Friger == 1) && (SafeMath8.add(non_controlable[_customerId].Friger, _Friger) <= 1), 'Be Turned on at the same time');
        require((_Aircondotioner == 0 || _Aircondotioner == 1) && (SafeMath8.add(non_controlable[_customerId].Aircondotioner,_Aircondotioner) <= 1), 'Be Turned on at the same time');
        require((_InductionCooker == 0 || _InductionCooker == 1) && (SafeMath8.add(non_controlable[_customerId].InductionCooker,_InductionCooker) <= 1), 'Be Turned on at the same time');
        
        flexible[_customerId].TV = _TV;
        flexible[_customerId].Heater = _Heater;
        flexible[_customerId].WashingMachine = _WashingMachine;
        flexible[_customerId].Dryer = _Dryer;
        flexible[_customerId].Friger = _Friger;
        flexible[_customerId].Aircondotioner = _Aircondotioner;
        flexible[_customerId].InductionCooker = _InductionCooker;
        
        flexibleIndex[_customerId][1] = _TV;
        flexibleIndex[_customerId][2] = _Heater;
        flexibleIndex[_customerId][3] = _WashingMachine;
        flexibleIndex[_customerId][4] = _Dryer;
        flexibleIndex[_customerId][5] = _Friger;
        flexibleIndex[_customerId][6] = _Aircondotioner;
        flexibleIndex[_customerId][7] = _InductionCooker;        
    }
    
    struct RatedPower{
        
        uint8 TV;
        uint8 Heater;
        uint8 WashingMachine;
        uint8 Dryer;
        uint8 Friger;
        uint8 Aircondotioner;
        uint8 InductionCooker;
        
    }
    mapping(string => RatedPower) power;
    mapping(string => mapping(uint => uint8)) powerIndex;
    
    function setEnergyConsumption(string _customerId, uint8 _TV, uint8 _Heater, uint8 _WashingMachine,
    uint8 _Dryer, uint8 _Friger, uint8 _Aircondotioner, uint8 _InductionCooker) external{ 
        
        require(keccak256(customerInfo[msg.sender].customerId) == keccak256(_customerId), "Wrong customerId");
         
        power[_customerId].TV = _TV;
        power[_customerId].Heater = _Heater;
        power[_customerId].WashingMachine = _WashingMachine;
        power[_customerId].Dryer = _Dryer;
        power[_customerId].Friger = _Friger;
        power[_customerId].Aircondotioner = _Aircondotioner;
        power[_customerId].InductionCooker = _InductionCooker;
        
        //string[] appliance = ['TV'];
        
        powerIndex[_customerId][1] = _TV;
        powerIndex[_customerId][2] = _Heater;
        powerIndex[_customerId][3] = _WashingMachine;
        powerIndex[_customerId][4] = _Dryer;
        powerIndex[_customerId][5] = _Friger;
        powerIndex[_customerId][6] = _Aircondotioner;
        powerIndex[_customerId][7] = _InductionCooker;        
        
    }
    
    
    function non_controllableEnergy(string _customerId) external returns(uint16){
        
        require(keccak256(customerInfo[msg.sender].customerId) == keccak256(_customerId), "Wrong customerId");
       
        for(uint256 i = 1; i <= 7; i++){
            
            customerInfo[msg.sender].noncontrolableEnergy = 
            SafeMath.add(customerInfo[msg.sender].noncontrolableEnergy, uint16(SafeMath8.mul(powerIndex[_customerId][i], non_controlableIndex[_customerId][i])));
            
        }
        
        return customerInfo[msg.sender].noncontrolableEnergy;
        
    }
    
    function flexibleEnergy(string _customerId) external returns(uint16){
        
        require(keccak256(customerInfo[msg.sender].customerId) == keccak256(_customerId), "Wrong customerId");
       
        for(uint256 i = 1; i <= 7; i++){
            
            customerInfo[msg.sender].flexibleEnergy = 
            SafeMath.add(customerInfo[msg.sender].flexibleEnergy, uint16(SafeMath8.mul(powerIndex[_customerId][i], flexibleIndex[_customerId][i])));
            
        }
        
        return customerInfo[msg.sender].flexibleEnergy;
        
    }
        
    function classification() public onlyOwner {
        
        uint256 count = addresspool.length;
        for(uint256 i=0; i<count; i++){
            
            if(customerInfo[addresspool[i]].StoragedEnergy >
            (customerInfo[addresspool[i]].noncontrolableEnergy + customerInfo[addresspool[i]].flexibleEnergy)){
                
                customerInfo[addresspool[i]].condition = Usertype.Prosumer;
                
            }
            
        }
            
        
    }
    
    function test(address _address) public view returns(Usertype){
        
        return customerInfo[_address].condition;
        
    }
    
    
}