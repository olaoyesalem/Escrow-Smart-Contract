//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract Escrow{
    address  public buyer;
    address public seller;
    uint256 public costPrice;
    State  currentState;


    enum State{AWAITING_PAYMENT,AWAITING_DELIVERY,TIP,COMPLETE}

    constructor(address _buyer, address _seller, uint256 _costPrice){ 
        buyer = _buyer;
        seller= _seller;
        costPrice=_costPrice;
        require(buyer!=seller,"Buyer's Address cannot be equals to Seller's Address");   
    }

    modifier onlyBuyer(){
        require(msg.sender==buyer,"Only Buyer can buy/pay");
        _;
    }
 
    modifier inState(State expectedState){
        require(currentState == expectedState);
        _;
    }

     function cancelDelivery()public{
      (bool sent ,)= buyer.call{value:address(this).balance}("");
      require(sent, "Unsuccessful Transfer");
      currentState = State.COMPLETE;
    }

    function confirmPayment()public payable onlyBuyer inState(State.AWAITING_PAYMENT){
        require(msg.value >= costPrice, "Insufficient Funds");
        // require for the price and put it in a modifier 
        //try to get the amount of gas 
        currentState = State.AWAITING_DELIVERY;

    }
    

    function confirmDelivery()public onlyBuyer  inState(State.AWAITING_DELIVERY){
      (bool sent ,)= seller.call{value:address(this).balance}("");
      require(sent, "Unsuccessful Transfer");
        currentState =State.COMPLETE;
    }
    function giveSellerTip() public payable inState(State.COMPLETE){
        currentState = State.TIP;
    }
   
    function Tip()public inState(State.TIP) {
      
         (bool sent ,)= seller.call{value:address(this).balance}("");
         require(sent, "Unsuccessful Transfer");
         currentState = State.COMPLETE;
    
    }
    function getBalance()public view returns(uint256){
       uint256 balance = address(this).balance;
       return balance;
    }
  
}




