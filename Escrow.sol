
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

 

  
contract Escrow{
    address  public buyer;
    address public seller;
    State public currentState;


    enum State{AWAITING_PAYMENT,AWAITING_DELIVERY,COMPLETE}

    constructor(address _buyer, address _seller){ 
        buyer = _buyer;
        seller= _seller;
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
    function confirmPayment()public payable onlyBuyer inState(State.AWAITING_PAYMENT){
   
        currentState = State.AWAITING_DELIVERY;
    }
    

    function confirmDelivery()public onlyBuyer  inState(State.AWAITING_DELIVERY){
      (bool sent ,)= seller.call{value:address(this).balance}("");
      require(sent, "Unsuccessful Transfer");
        currentState =State.COMPLETE;

    }
}


