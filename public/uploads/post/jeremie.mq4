#property copyright "Copyright © 2017, Il Anokhin"
#property description ""
#property link "http://www.mql5.com/en/users/ilanokhin"
#property strict
//-------------------------------------------------------------------------               
enum cmode {Current,Closed};
enum bmode {Balance,Equity};
enum rmode {Off,Single,One_per_Candle,No_Limits};
enum rdmode {According_LT,Buy,Sell,First_Order_Inverted,Second_Order_Inverted,First_Order_Same,Second_Order_Same};
//-------------------------------------------------------------------------               
input int Magic = 90328;                           //Magic Number
//------------------------------------------------------------------------- 
extern ENUM_TIMEFRAMES RSI_TimeFrame  = PERIOD_M15;
//------------------------------------------------------------------------- 
input cmode CM = 1;                                //Candle Mode
input double Lot = 0.01;                           //Lot Size
input bool LTC = false;                            //Close All at Opposite Signal of LT
input double TP1 = 30;                             //1st Order Take Profit (pips)
input int BO1 = 30;                                //1st Buy Order Open Level  
input int SO1 = 70;                                //1st Sell Order Open Level  
input bool U2 = true;                              //Use 2nd Order
input double TP2 = 40;                             //2nd Order Take Profit (pips)
input int BO2 = 35;                                //2nd Buy Order Open Level  
input int SO2 = 65;                                //2nd Sell Order Open Level

//------------------------------------------------------------------------- 
input rmode RM0 = 2;                                //Recovery Order Mode
input rdmode RDM0 = 0;                              //Recovery Order Diretion
input bmode BM0 = 0;                                //Balance Mode
input bool URL0 = false;                            //Use Recovery Order RSI Open Levels
input int BOR0 = 40;                                //Recovery Buy Order Open Level  
input int SOR0 = 60;                                //Recovery Sell Order Open Level
input double DD0 = 20;                              //Drawdown for Recovery Order (%)
input double R0 = 5;                                //Recovery Lot Size Risk (%)
input double RSL0 = 70;                             //Recovery Order Stop Loss (pips)
input double XTP0 = 50;                             //Take Profit for Close All (pips) 
//------------------------------------------------------------------------- 
input rmode RM1 = 2;                                //Recovery Order Mode
input rdmode RDM1 = 0;                              //Recovery Order Diretion
input bmode BM1 = 0;                                //Balance Mode
input bool URL1 = false;                            //Use Recovery Order RSI Open Levels
input int BOR1 = 40;                                //Recovery Buy Order Open Level  
input int SOR1 = 60;                                //Recovery Sell Order Open Level
input double DD1 = 20;                              //Drawdown for Recovery Order (%)
input double R1 = 5;                                //Recovery Lot Size Risk (%)
input double RSL1 = 70;                             //Recovery Order Stop Loss (pips)
input double XTP1 = 50;                             //Take Profit for Close All (pips) 
//------------------------------------------------------------------------- 
input int RP = 14;                                  //RSI Period
input int I1 = 2;                                   //Amplitude (LT)
//-------------------------------------------------------------------------
input bool EC = true;                               //Enable Equity Cut
input double ECP = 20;                              //EC % Value
input bool PEC = false;                             //Progressive EC
//---------------------------
//-------------------------------------------------------------------------

int i, n, r[4], lr[4];

double Lots=Lot, rlot, b, s;

bool rc;


bool rc1;
//-------------------------------------------------------------------------

void OnTick()
   {
   
   r[1]=RSI(r[1],RP,0,BO1,SO1,CM,RSI_TimeFrame);
      
   r[2]=RSI(r[2],RP,0,BO2,SO2,CM,RSI_TimeFrame);
   
    
   r[0]=RSI(r[0],RP,0,BOR0,SOR0,CM,RSI_TimeFrame);
   
   r[0]=RSI(r[0],RP,0,BOR1,SOR1,CM,RSI_TimeFrame);
      
   b=iCustom(NULL,0,"LT",I1,0,1);
   
   s=iCustom(NULL,0,"LT",I1,1,1);
   
//-------------------------------------------------------------------------
    
   if(LTC && Total(1)>0 && IC(s)) CloseAll(1);
   
   if(LTC && Total(-1)>0 && IC(b)) CloseAll(-1);
   
    
   if(n>0 && Profit(0,1,NULL,-1,"-1")>=XTP0) CloseAll();
   
   if(n>0 && Profit(0,1,NULL,-1,"-1")>=XTP1) CloseAll();

   // EQUITY CUT
if(EC && GetProfit() < -AccountBalance()*ECP/100) {CloseAll();}  

//Rajouter le Progressive EC 
//-------------------------------------------------------------------------

   if(Total()==0) n=0;

//-------------------------------------------------------------------------

  
   
   if(BM0==0) rlot=MoneyManagement(R0,100,0,NULL,1,1);
   
   if(BM0==1) rlot=MoneyManagement(R0,100,0,NULL,1,0);
   
   
   
   // A revoir pour ne pas ecraser le rlot global
   //if(BM1==0) rlot=MoneyManagement(R1,100,0,NULL,1,1);
   //if(BM1==1) rlot=MoneyManagement(R1,100,0,NULL,1,0);
   
   
   rlot=LotCheck(rlot);
   
//-------------------------------------------------------------------------
   
  
  //-------------------------------------------------------------------------
   
     rc=false;          
  
   if(BM0==0 && Profit()>-AccountBalance()*DD0*0.01) rc=true;
   
   if(BM0==1 && Profit()>-AccountEquity()*DD0*0.01) rc=true;
   
   if(RM0>0 && rc && pow(n<=0,RM0==1) && RDM0!=2 && (pow(IC(b),RDM0==0) || RDM0==1) && pow(r[0]==-1 && lr[0]==-2,URL0) && pow(Time[0]>LOC(0,NULL,-1,"-1"),RM0==2) && pow(Order(1,NULL,-1,"1")==-1,RDM0==3) && pow(Order(1,NULL,-1,"2")==-1,RDM0==4) && pow(Order(1,NULL,-1,"1")==1,RDM0==5) && pow(Order(1,NULL,-1,"2")==1,RDM0==6)) n=Trade(1,rlot,RSL0,0,0,0,-1);
    
   if(RM0>0 && rc && pow(n<=0,RM0==1) && RDM0!=1 && (pow(IC(s),RDM0==0) || RDM0==2) && pow(r[0]==1 && lr[0]==2,URL0) && pow(Time[0]>LOC(0,NULL,-1,"-1"),RM0==2) && pow(Order(1,NULL,-1,"1")==1,RDM0==3) && pow(Order(1,NULL,-1,"2")==1,RDM0==4) && pow(Order(1,NULL,-1,"1")==-1,RDM0==5) && pow(Order(1,NULL,-1,"2")==-1,RDM0==6)) n=Trade(-1,rlot,RSL0,0,0,0,-1);


 //-------------------------------------------------------------------------
     rc1=false;          
  
   if(BM1==0 && Profit()>-AccountBalance()*DD1*0.01) rc1=true;
   
   if(BM1==1 && Profit()>-AccountEquity()*DD1*0.01) rc1=true;
   
   if(RM1>0 && rc1 && pow(n>=0,RM1==1) && RDM1!=2 && (pow(IC(b),RDM1==0) || RDM1==1) && pow(r[0]==-1 && lr[0]==-2,URL1) && pow(Time[0]>LOC(0,NULL,-1,"-1"),RM1==2) && pow(Order(1,NULL,-1,"1")==-1,RDM1==3) && pow(Order(1,NULL,-1,"2")==-1,RDM1==4) && pow(Order(1,NULL,-1,"1")==1,RDM1==5) && pow(Order(1,NULL,-1,"2")==1,RDM1==6)) n=Trade(1,rlot,RSL1,0,0,0,-1);
    
   if(RM1>0 && rc1 && pow(n>=0,RM1==1) && RDM1!=1 && (pow(IC(s),RDM1==0) || RDM1==2) && pow(r[0]==1 && lr[0]==2,URL1) && pow(Time[0]>LOC(0,NULL,-1,"-1"),RM1==2) && pow(Order(1,NULL,-1,"1")==1,RDM1==3) && pow(Order(1,NULL,-1,"2")==1,RDM1==4) && pow(Order(1,NULL,-1,"1")==-1,RDM1==5) && pow(Order(1,NULL,-1,"2")==-1,RDM1==6)) n=Trade(-1,rlot,RSL1,0,0,0,-1);













//-------------------------------------------------------------------------
               
   if(Total(0,NULL,-1,"1")==0 && r[1]==-1 && lr[1]==-2 && IC(b) && Time[0]>LOC(0,NULL,-1,"1")) Trade(1,Lots,0,TP1,0,0,1);
   
   if(Total(0,NULL,-1,"1")==0 && r[1]==1 && lr[1]==2 && IC(s) && Time[0]>LOC(0,NULL,-1,"1")) Trade(-1,Lots,0,TP1,0,0,1);
      
   if(U2 && Total(0,NULL,-1,"2")==0 && r[2]==-1 && lr[2]==-2 && IC(b) && Time[0]>LOC(0,NULL,-1,"2")) Trade(1,Lots,0,TP2,0,0,2);
   
   if(U2 && Total(0,NULL,-1,"2")==0 && r[2]==1 && lr[2]==2 && IC(s) && Time[0]>LOC(0,NULL,-1,"2")) Trade(-1,Lots,0,TP2,0,0,2);
           
//-------------------------------------------------------------------------

   if(r[1]!=lr[1]) lr[1]=r[1];
      
   if(r[2]!=lr[2]) lr[2]=r[2];
   
   if(r[0]!=lr[0]) lr[0]=r[0];
   
//-------------------------------------------------------------------------
                
   Text("Current Time: "+TimeToStr(TimeCurrent(),TIME_SECONDS),1);
   
   Text("Account Equity: "+DoubleToStr(AccountEquity(),2),2);
   
   Text("Orders Total: "+(string)Total(),3);
   
   Text("Total Profit: "+DoubleToStr(Profit(),2),4);
                                                                          
   }

//-------------------------------------------------------------------------

void deinit() {Comment(""); ObjectsDeleteAll(0,OBJ_LABEL);}

//-------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------

double Good(double value, int digits=2)
   {
   
   double res=value;
   
   res=(double)DoubleToString(res,digits);
         
   return(res);
   
   }

//-------------------------------------------------------------------------

double Pips(string symbol=NULL)
   {
   
   int digits=(int)MarketInfo(symbol,MODE_DIGITS);
   
   double res=MarketInfo(symbol,MODE_POINT);
         
   if(digits==5 || digits==3 || digits==1) res=res*10;
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double Spread(string symbol=NULL)
   {
   
   int digits=(int)MarketInfo(symbol,MODE_DIGITS);
   
   double res=MarketInfo(symbol,MODE_SPREAD);
         
   if(digits==5 || digits==3 || digits==1) res=res*0.1;
      
   return(res);
   
   }

//-------------------------------------------------------------------------

int Total(int mode=0, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v, res=0;
   
      
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
         
            if((mode==0 || mode==8 || mode==12 || mode==1) && OrderType()==OP_BUY) res++; 
               
            if((mode==0 || mode==8 || mode==6 || mode==-1) && OrderType()==OP_SELL) res++;
               
            if((mode==0 || mode==-8 || MathAbs(mode)==12 || mode==2) && OrderType()==OP_BUYSTOP) res++; 
               
            if((mode==0 || mode==-8 || MathAbs(mode)==6 || mode==-2) && OrderType()==OP_SELLSTOP) res++;
               
            if((mode==0 || mode==-8 || MathAbs(mode)==12 || mode==3) && OrderType()==OP_BUYLIMIT) res++; 
               
            if((mode==0 || mode==-8 || MathAbs(mode)==6 || mode==-3) && OrderType()==OP_SELLLIMIT) res++;
            
            }
                                                                     
         }
                                             
      }
         
      
   return(res);
   
   }

//-------------------------------------------------------------------------

int Trade(int type, double lots, double stoploss=0, double takeprofit=0, double price=0, double distance=0, double ncomment=0, string symbol=NULL, string tcomment=NULL, int magic=-1)
   {
   
   int res=-1, digits=(int)MarketInfo(symbol,MODE_DIGITS), magicnumber;
   
   double opr, ask=MarketInfo(symbol,MODE_ASK), bid=MarketInfo(symbol,MODE_BID);
   
   string comment;
   
   
   if(tcomment==NULL) comment=(string)ncomment; else comment=tcomment;
   
   if(magic==-1) magicnumber=Magic; else magicnumber=magic;
     
   if(price>0) bid=price;
         
   if(type==1 && comment=="0") {opr=ask; res=OrderSend(symbol,OP_BUY,lots,opr,90,opr-stoploss*Pips(symbol)-opr*pow(0,stoploss),opr+takeprofit*Pips(symbol)-opr*pow(0,takeprofit),DoubleToStr(opr,digits),magicnumber);} 
   
   if(type==1 && comment!="0") {opr=ask; res=OrderSend(symbol,OP_BUY,lots,opr,90,opr-stoploss*Pips(symbol)-opr*pow(0,stoploss),opr+takeprofit*Pips(symbol)-opr*pow(0,takeprofit),comment,magicnumber);} 
   
   if(type==-1 && comment=="0") {opr=bid; res=OrderSend(symbol,OP_SELL,lots,opr,90,opr+stoploss*Pips(symbol)-opr*pow(0,stoploss),opr-takeprofit*Pips(symbol)-opr*pow(0,takeprofit),DoubleToStr(opr,digits),magicnumber);} 
     
   if(type==-1 && comment!="0") {opr=bid; res=OrderSend(symbol,OP_SELL,lots,opr,90,opr+stoploss*Pips(symbol)-opr*pow(0,stoploss),opr-takeprofit*Pips(symbol)-opr*pow(0,takeprofit),comment,magicnumber);} 
      
   if(type==2 && comment=="0") {opr=Good(bid+distance*Pips(symbol),digits); res=OrderSend(symbol,OP_BUYSTOP,lots,opr,90,opr-stoploss*Pips(symbol)-opr*pow(0,stoploss),opr+takeprofit*Pips(symbol)-opr*pow(0,takeprofit),DoubleToStr(opr,digits),magicnumber);} 
   
   if(type==2 && comment!="0") {opr=Good(bid+distance*Pips(symbol),digits); res=OrderSend(symbol,OP_BUYSTOP,lots,opr,90,opr-stoploss*Pips(symbol)-opr*pow(0,stoploss),opr+takeprofit*Pips(symbol)-opr*pow(0,takeprofit),comment,magicnumber);} 
   
   if(type==-2 && comment=="0") {opr=Good(bid-distance*Pips(symbol),digits); res=OrderSend(symbol,OP_SELLSTOP,lots,opr,90,opr+stoploss*Pips(symbol)-opr*pow(0,stoploss),opr-takeprofit*Pips(symbol)-opr*pow(0,takeprofit),DoubleToStr(opr,digits),magicnumber);} 
   
   if(type==-2 && comment!="0") {opr=Good(bid-distance*Pips(symbol),digits); res=OrderSend(symbol,OP_SELLSTOP,lots,opr,90,opr+stoploss*Pips(symbol)-opr*pow(0,stoploss),opr-takeprofit*Pips(symbol)-opr*pow(0,takeprofit),comment,magicnumber);} 
      
   if(type==3 && comment=="0") {opr=Good(bid-distance*Pips(symbol),digits); res=OrderSend(symbol,OP_BUYLIMIT,lots,opr,90,opr-stoploss*Pips(symbol)-opr*pow(0,stoploss),opr+takeprofit*Pips(symbol)-opr*pow(0,takeprofit),DoubleToStr(opr,digits),magicnumber);} 
   
   if(type==3 && comment!="0") {opr=Good(bid-distance*Pips(symbol),digits); res=OrderSend(symbol,OP_BUYLIMIT,lots,opr,90,opr-stoploss*Pips(symbol)-opr*pow(0,stoploss),opr+takeprofit*Pips(symbol)-opr*pow(0,takeprofit),comment,magicnumber);} 
   
   if(type==-3 && comment=="0") {opr=Good(bid+distance*Pips(symbol),digits); res=OrderSend(symbol,OP_SELLLIMIT,lots,opr,90,opr+stoploss*Pips(symbol)-opr*pow(0,stoploss),opr-takeprofit*Pips(symbol)-opr*pow(0,takeprofit),DoubleToStr(opr,digits),magicnumber);} 
   
   if(type==-3 && comment!="0") {opr=Good(bid+distance*Pips(symbol),digits); res=OrderSend(symbol,OP_SELLLIMIT,lots,opr,90,opr+stoploss*Pips(symbol)-opr*pow(0,stoploss),opr-takeprofit*Pips(symbol)-opr*pow(0,takeprofit),comment,magicnumber);} 
   
        
   return(res);
   
   }

//-------------------------------------------------------------------------

void Bets(double breakeven, double trailstop=0, double trailstep=0, double profit=0, bool oldmode=false, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   bool w;
   
   double ask, bid;
   
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
                     
            ask=MarketInfo(OrderSymbol(),MODE_ASK);
               
            bid=MarketInfo(OrderSymbol(),MODE_BID);
               
            if(breakeven>0 && OrderProfit()>0 && OrderType()==OP_BUY && OrderOpenPrice()+breakeven*Pips(OrderSymbol())<=bid && OrderStopLoss()<OrderOpenPrice()+profit*Pips(OrderSymbol())) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+profit*Pips(OrderSymbol()),OrderTakeProfit(),0);
            
            if(breakeven>0 && OrderProfit()>0 && OrderType()==OP_SELL && OrderOpenPrice()-breakeven*Pips(OrderSymbol())>=ask && (OrderStopLoss()>OrderOpenPrice()-profit*Pips(OrderSymbol()) || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-profit*Pips(OrderSymbol()),OrderTakeProfit(),0);
                                   
            if(!oldmode && trailstop>0 && trailstep>=0 && OrderProfit()>0 && OrderType()==OP_BUY && OrderOpenPrice()+trailstop*Pips(OrderSymbol())<=bid && OrderStopLoss()<OrderOpenPrice()+profit*Pips(OrderSymbol())) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+profit*Pips(OrderSymbol()),OrderTakeProfit(),0);
            
            if(!oldmode && trailstop>0 && trailstep>=0 && OrderProfit()>0 && OrderType()==OP_SELL && OrderOpenPrice()-trailstop*Pips(OrderSymbol())>=ask && (OrderStopLoss()>OrderOpenPrice()-profit*Pips(OrderSymbol()) || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-profit*Pips(OrderSymbol()),OrderTakeProfit(),0);
                           
            if(!oldmode && trailstop>0 && trailstep>=0 && OrderProfit()>0 && OrderType()==OP_BUY && OrderStopLoss()+(trailstop+trailstep)*Pips(OrderSymbol())<=bid && OrderStopLoss()>=OrderOpenPrice()+profit*Pips(OrderSymbol())) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+trailstep*Pips(OrderSymbol()),OrderTakeProfit(),0);
            
            if(!oldmode && trailstop>0 && trailstep>=0 && OrderProfit()>0 && OrderType()==OP_SELL && OrderStopLoss()-(trailstop+trailstep)*Pips(OrderSymbol())>=ask && OrderStopLoss()<=OrderOpenPrice()-profit*Pips(OrderSymbol())) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-trailstep*Pips(OrderSymbol()),OrderTakeProfit(),0);
                    
            if(oldmode && trailstop>0 && OrderProfit()>0 && OrderType()==OP_BUY && OrderOpenPrice()+trailstop*Pips(OrderSymbol())<=bid && OrderStopLoss()<bid-trailstop*Pips(OrderSymbol())) w=OrderModify(OrderTicket(),OrderOpenPrice(),bid-trailstop*Pips(OrderSymbol()),OrderTakeProfit(),0);
            
            if(oldmode && trailstop>0 && OrderProfit()>0 && OrderType()==OP_SELL && OrderOpenPrice()-trailstop*Pips(OrderSymbol())>=ask && (OrderStopLoss()>ask+trailstop*Pips(OrderSymbol()) || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),ask+trailstop*Pips(OrderSymbol()),OrderTakeProfit(),0);
            
            }
                                                                         
         }
                                             
      }
         
   }
     
//-------------------------------------------------------------------------

void CloseAll(int mode=0, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   bool w;
   
   double ask, bid;
   
   
   for(v=OrdersTotal()-1;v>=0;v--)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
                     
            ask=MarketInfo(OrderSymbol(),MODE_ASK);
               
            bid=MarketInfo(OrderSymbol(),MODE_BID);
                           
            if((mode==0 || mode==8 || mode==12 || mode==1) && OrderType()==OP_BUY) w=OrderClose(OrderTicket(),OrderLots(),bid,90); 
               
            if((mode==0 || mode==8 || mode==6 || mode==-1) && OrderType()==OP_SELL) w=OrderClose(OrderTicket(),OrderLots(),ask,90);
               
            if((mode==0 || mode==-8 || MathAbs(mode)==12 || mode==2) && OrderType()==OP_BUYSTOP) w=OrderDelete(OrderTicket()); 
               
            if((mode==0 || mode==-8 || MathAbs(mode)==6 || mode==-2) && OrderType()==OP_SELLSTOP) w=OrderDelete(OrderTicket());
               
            if((mode==0 || mode==-8 || MathAbs(mode)==12 || mode==3) && OrderType()==OP_BUYLIMIT) w=OrderDelete(OrderTicket()); 
               
            if((mode==0 || mode==-8 || MathAbs(mode)==6 || mode==-3) && OrderType()==OP_SELLLIMIT) w=OrderDelete(OrderTicket());
            
            }
                                          
         }
         
      }
     
   }

//-------------------------------------------------------------------------

void Text(string text, int number=1, int size=9, bool bold=true, color colour=clrDodgerBlue, int corner=0, string textname="Text")
   {
               
   ObjectCreate(textname+DoubleToStr(number,0),OBJ_LABEL,0,0,0); 
      
   if(bold==true) ObjectSetText(textname+DoubleToStr(number,0),text,size,"Arial Black",colour);
   
   if(bold==false) ObjectSetText(textname+DoubleToStr(number,0),text,size,"Arial",colour);
   
   ObjectSet(textname+DoubleToStr(number,0),OBJPROP_CORNER,corner);
   
   ObjectSet(textname+DoubleToStr(number,0),OBJPROP_XDISTANCE,5);
         
   ObjectSet(textname+DoubleToStr(number,0),OBJPROP_YDISTANCE,15+size*2*(number-1));
      
   }

//-------------------------------------------------------------------------

double Profit(int mode=0, bool pipsmode=false, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   double res=0;
   
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
         
            if(!pipsmode && mode==0) res=res+OrderProfit();
                     
            if(!pipsmode && mode==1 && OrderType()==OP_BUY) res=res+OrderProfit();
            
            if(!pipsmode && mode==-1 && OrderType()==OP_SELL) res=res+OrderProfit();
            
            if(!pipsmode && mode==100) res=res+OrderProfit()+OrderCommission()+OrderSwap();
                     
            if(!pipsmode && mode==101 && OrderType()==OP_BUY) res=res+OrderProfit()+OrderCommission()+OrderSwap();
            
            if(!pipsmode && mode==-101 && OrderType()==OP_SELL) res=res+OrderProfit()+OrderCommission()+OrderSwap();
                       
            if(pipsmode && (mode==1 || mode==0) && OrderType()==OP_BUY) res=res+(MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice())/Pips(OrderSymbol());
         
            if(pipsmode && (mode==-1 || mode==0) && OrderType()==OP_SELL) res=res+(OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))/Pips(OrderSymbol());
                      
            }
                                                        
         }
         
      }
  
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double TotalLots(int mode=0, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   double res=0;
   
      
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
                  
            if(mode==0) res=res+OrderLots();
                     
            if((mode==12 || mode==8 || mode==1) && OrderType()==OP_BUY) res=res+OrderLots();
            
            if((mode==6 || mode==8 || mode==-1) && OrderType()==OP_SELL) res=res+OrderLots();
                           
            if((mode==-12 || mode==-8 || mode==2) && OrderType()==OP_BUYSTOP) res=res+OrderLots();
               
            if((mode==-12 || mode==-8 || mode==3) && OrderType()==OP_BUYLIMIT) res=res+OrderLots();
                     
            if((mode==-6 || mode==-8 || mode==-2) && OrderType()==OP_SELLSTOP) res=res+OrderLots();
               
            if((mode==-6 || mode==-8 || mode==-3) && OrderType()==OP_SELLLIMIT) res=res+OrderLots();
            
            }
                                                     
         }
         
      }
  
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double Order(int mode=0, string symbol=NULL, int magic=-1, string comment=NULL)
   {
   
   int v;
   
   double res=0;
   
   datetime lasttime=0;
      
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL))
            {
                  
            if((OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderOpenTime()>lasttime)
               {
            
               lasttime=OrderOpenTime();
               
               if(mode==0) res=OrderTicket();
               
               if(mode==1 && OrderType()==OP_BUY) res=1;
               
               if(mode==1 && OrderType()==OP_SELL) res=-1;
               
               if(mode==2) res=OrderProfit();
               
               if(mode==3) res=OrderStopLoss();
               
               if(mode==4) res=OrderTakeProfit();
               
               if(mode==5) res=OrderOpenPrice();
               
               if(mode==6) res=OrderClosePrice();
               
               if(mode==7) res=OrderLots();
               
               if(mode==8) res=(int)OrderOpenTime();
               
               if(mode==9) res=(int)OrderCloseTime();
               
               if(mode==10) res=StrToDouble(OrderComment());
               
               if(mode==11) res=OrderCommission();
               
               if(mode==12) res=OrderSwap();
               
               if(mode==13) res=OrderProfit()+OrderCommission()+OrderSwap();
               
               }
                                    
            }
            
         }
                 
      }
  
   
   return(res);
     
   }

//-------------------------------------------------------------------------

double Last(int mode=0, string symbol=NULL, int magic=-1, string comment=NULL)
   {
   
   int v;
   
   double res=0;
      
   
   for(v=OrdersHistoryTotal()-1;v>=0;v--)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_HISTORY)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL))
            {
                  
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
               {
            
               if(mode==0) res=OrderTicket();
               
               if(mode==1 && OrderType()==OP_BUY) res=1;
               
               if(mode==1 && OrderType()==OP_SELL) res=-1;
                           
               if(mode==2) res=OrderProfit();
               
               if(mode==3) res=OrderStopLoss();
               
               if(mode==4) res=OrderTakeProfit();
               
               if(mode==5) res=OrderOpenPrice();
               
               if(mode==6) res=OrderClosePrice();
               
               if(mode==7) res=OrderLots();
               
               if(mode==8) res=(int)OrderOpenTime();
               
               if(mode==9) res=(int)OrderCloseTime();
               
               if(mode==10) res=StrToDouble(OrderComment());
               
               if(mode==11) res=OrderCommission();
               
               if(mode==12) res=OrderSwap();
               
               if(mode==13) res=OrderProfit()+OrderCommission()+OrderSwap();
               
               v=-1;
               
               }
                                    
            }
            
         }
                 
      }
  
   
   return(res);
     
   }

//-------------------------------------------------------------------------

datetime LOC(int timeframe=0, string symbol=NULL, int magic=-1, string comment=NULL)
   {
      
   datetime res=0;
   
   
   if(Total(8)==0) res=iTime(symbol,timeframe,iBarShift(symbol,timeframe,(int)Last(8,symbol,magic,comment)));
   
   if(Total(8)>0) res=iTime(symbol,timeframe,iBarShift(symbol,timeframe,(int)Order(8,symbol,magic,comment)));
   
   
   return(res);
     
   }

//-------------------------------------------------------------------------

double MoneyManagement(double risk, double stoploss=100, bool spread=false, string symbol=NULL, bool goodround=true, bool balancemode=false)
   {
   
   double res=0.01, amount=AccountEquity();
   
   
   if(balancemode) amount=AccountBalance();
   
   if(spread==false && stoploss>0) res=amount*risk*0.001/stoploss;
      
   if(stoploss>0) res=amount*risk*0.001/(stoploss+Spread(symbol));
   
   if(res<MarketInfo(symbol,MODE_MINLOT)) res=MarketInfo(symbol,MODE_MINLOT);
   
   if(res>MarketInfo(symbol,MODE_MAXLOT)) res=MarketInfo(symbol,MODE_MAXLOT);
   
   if(goodround) res=Good(res,2); else res=DigitsCut(res,2);
   
    
   return(res);
   
   }

//-------------------------------------------------------------------------

int TimeFilter(string starttime, string stoptime="23:59", int mode=0)
   {
   
   int res=0, starthour, stophour;
   
   
   starthour=TimeHour(StrToTime(starttime));
   
   stophour=TimeHour(StrToTime(stoptime));
      
   
   if(starthour<=stophour)
      {
       
      if(mode==0 && TimeCurrent()>=StrToTime(starttime) && TimeCurrent()<StrToTime(stoptime)) res=0;
      
      if(mode==0 && (TimeCurrent()<StrToTime(starttime) || TimeCurrent()>=StrToTime(stoptime))) res=1;
      
      if(mode==1 && TimeCurrent()>=StrToTime(starttime) && TimeCurrent()<StrToTime(stoptime)) res=1;
      
      if(mode==1 && (TimeCurrent()<StrToTime(starttime) || TimeCurrent()>=StrToTime(stoptime))) res=0;
         
      if(mode==100 && TimeGMT()>=StrToTime(starttime) && TimeGMT()<StrToTime(stoptime)) res=0;
      
      if(mode==100 && (TimeGMT()<StrToTime(starttime) || TimeGMT()>=StrToTime(stoptime))) res=1;
      
      if(mode==101 && TimeGMT()>=StrToTime(starttime) && TimeGMT()<StrToTime(stoptime)) res=1;
      
      if(mode==101 && (TimeGMT()<StrToTime(starttime) || TimeGMT()>=StrToTime(stoptime))) res=0;
      
      }
   
   
   if(starthour>stophour)
      {
       
      if(mode==0 && (TimeCurrent()>=StrToTime(starttime) || TimeCurrent()<StrToTime(stoptime))) res=0;
      
      if(mode==0 && TimeCurrent()<StrToTime(starttime) && TimeCurrent()>=StrToTime(stoptime)) res=1;
      
      if(mode==1 && (TimeCurrent()>=StrToTime(starttime) || TimeCurrent()<StrToTime(stoptime))) res=1;
      
      if(mode==1 && TimeCurrent()<StrToTime(starttime) && TimeCurrent()>=StrToTime(stoptime)) res=0;
         
      if(mode==100 && (TimeGMT()>=StrToTime(starttime) || TimeGMT()<StrToTime(stoptime))) res=0;
      
      if(mode==100 && TimeGMT()<StrToTime(starttime) && TimeGMT()>=StrToTime(stoptime)) res=1;
      
      if(mode==101 && (TimeGMT()>=StrToTime(starttime) || TimeGMT()<StrToTime(stoptime))) res=1;
      
      if(mode==101 && TimeGMT()<StrToTime(starttime) && TimeGMT()>=StrToTime(stoptime)) res=0;
      
      }
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double Martingale(double currentlot, double startlot, double multiplier=2, double summand=0, bool zeroreset=false, string symbol=NULL, int magic=-1, string comment=NULL)
   {
   
   double res=currentlot;
   
   
   if(multiplier>0 && Last(2,symbol,magic,comment)<0) res=currentlot*multiplier+summand;
     
   if(Last(2,symbol,magic,comment)>0) res=startlot;
   
   if(Last(2,symbol,magic,comment)==0 && zeroreset==true) res=startlot;
   
   res=Good(res,2);
      
    
   return(res);
   
   }

//-------------------------------------------------------------------------

void HLine(int number, double price, int width=1, int style=0, color colour=clrDarkViolet)
   {
   
   ObjectDelete("HLine "+DoubleToStr(number,Digits));
            
   ObjectCreate("HLine "+DoubleToStr(number,Digits),OBJ_HLINE,0,0,price);
   
   ObjectSet("HLine "+DoubleToStr(number,Digits),OBJPROP_COLOR,colour);
      
   ObjectSet("HLine "+DoubleToStr(number,Digits),OBJPROP_STYLE,style);
   
   ObjectSet("HLine "+DoubleToStr(number,Digits),OBJPROP_WIDTH,width);
      
   }

//-------------------------------------------------------------------------

void VLine(int number, datetime time, int width=1, int style=0, color colour=clrDarkViolet)
   {
   
   ObjectDelete("VLine "+DoubleToStr(number,0));
            
   ObjectCreate("VLine "+DoubleToStr(number,0),OBJ_VLINE,0,time,0);
   
   ObjectSet("VLine "+DoubleToStr(number,0),OBJPROP_COLOR,colour);
      
   ObjectSet("VLine "+DoubleToStr(number,0),OBJPROP_STYLE,style);
   
   ObjectSet("VLine "+DoubleToStr(number,0),OBJPROP_WIDTH,width);
      
   }

//-------------------------------------------------------------------------

void TLine(string name, datetime time1, double price1, datetime time2, double price2, int width=1, int style=0, color colour=clrDarkViolet, int ray=0)
   {
   
   ObjectDelete("TLine "+name);
            
   ObjectCreate("TLine "+name,OBJ_TREND,0,time1,price1,time2,price2);
   
   ObjectSet("TLine "+name,OBJPROP_COLOR,colour);
      
   ObjectSet("TLine "+name,OBJPROP_STYLE,style);
   
   ObjectSet("TLine "+name,OBJPROP_WIDTH,width);
   
   ObjectSet("TLine "+name,OBJPROP_RAY,ray);
      
   }

//-------------------------------------------------------------------------

int SpreadFilter(double maxvalue, string symbol=NULL)
   {
   
   int res=0;
      
   if(Spread(symbol)>maxvalue) res=1;
      
   return(res);
   
   }

//-------------------------------------------------------------------------

void Send(string message, string title=NULL, bool alerts=true, bool email=false, bool push=false)
   {
      
   if(alerts==true) Alert(message);
         
   if(email==true) SendMail(title,message);
         
   if(push==true) SendNotification(message);
   
   }

//-------------------------------------------------------------------------

double MinLot(int mode=0, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
      
   double res=INT_MAX;
   
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
                  
            if(mode==0 && OrderLots()<res) res=OrderLots();
                     
            if(mode==1 && OrderType()==OP_BUY && OrderLots()<res) res=OrderLots();
            
            if(mode==-1 && OrderType()==OP_SELL && OrderLots()<res) res=OrderLots();
         
            }
                                                            
         }
         
      }
  
      
   return(res);
   
   }

//-------------------------------------------------------------------------

void GhostMain(string symbol=NULL, int magic=-1, string comment=NULL)
   {
   
   int v;
   
   double bid, ask;
   
   bool w;
      
   string namesl, nametp;
   
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL))
            {
         
            bid=MarketInfo(OrderSymbol(),MODE_BID);
            
            ask=MarketInfo(OrderSymbol(),MODE_ASK);
                        
            namesl="SL"+IntegerToString(OrderTicket());
               
            nametp="TP"+IntegerToString(OrderTicket());
               
            if(OrderType()==OP_BUY && bid>=GlobalVariableGet(nametp) && GlobalVariableGet(nametp)>0) w=OrderClose(OrderTicket(),OrderLots(),bid,90);
               
            if(OrderType()==OP_BUY && bid<=GlobalVariableGet(namesl) && GlobalVariableGet(namesl)>0) w=OrderClose(OrderTicket(),OrderLots(),bid,90);
                                    
            if(OrderType()==OP_SELL && ask<=GlobalVariableGet(nametp) && GlobalVariableGet(nametp)>0) w=OrderClose(OrderTicket(),OrderLots(),ask,90);
               
            if(OrderType()==OP_SELL && ask>=GlobalVariableGet(namesl) && GlobalVariableGet(namesl)>0) w=OrderClose(OrderTicket(),OrderLots(),ask,90);
            
            }
                                           
         }
         
      }
     
   }

//-------------------------------------------------------------------------

void GhostClear(string symbol=NULL, int magic=-1, string comment=NULL)
   {
   
   int v;
               
   string namesl, nametp, nametpa;
   
   
   for(v=0;v<OrdersHistoryTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_HISTORY)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL))
            {
                        
            namesl="SL"+IntegerToString(OrderTicket());
               
            nametp="TP"+IntegerToString(OrderTicket());
            
            nametpa="TPA"+IntegerToString(OrderTicket());
               
            if(GlobalVariableGet(namesl)!=0) GlobalVariableDel(namesl);
               
            if(GlobalVariableGet(nametp)!=0) GlobalVariableDel(nametp);
            
            if(GlobalVariableGet(nametpa)!=0) GlobalVariableDel(nametpa);
            
            }
                                            
         }
         
      }
     
   }

//-------------------------------------------------------------------------

void Ghost(double stoploss, double takeprofit, double breakeven=0, double trailstop=0, double trailstep=0, double profit=0, string symbol=NULL, int magic=-1, string comment=NULL)
   {
   
   int v;
   
   double bid, ask;
      
   string namesl, nametp;
   
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL))
            {
                  
            bid=MarketInfo(OrderSymbol(),MODE_BID);
            
            ask=MarketInfo(OrderSymbol(),MODE_ASK);
                       
            namesl="SL"+IntegerToString(OrderTicket());
               
            nametp="TP"+IntegerToString(OrderTicket());
                           
            if(GlobalVariableGet(namesl)==0 && OrderType()==OP_BUY && stoploss>0) GlobalVariableSet(namesl,OrderOpenPrice()-stoploss*Pips(OrderSymbol()));
               
            if(GlobalVariableGet(nametp)==0 && OrderType()==OP_BUY && takeprofit>0) GlobalVariableSet(nametp,OrderOpenPrice()+takeprofit*Pips(OrderSymbol()));
                           
            if(GlobalVariableGet(namesl)==0 && OrderType()==OP_SELL && stoploss>0) GlobalVariableSet(namesl,OrderOpenPrice()+stoploss*Pips(OrderSymbol()));
               
            if(GlobalVariableGet(nametp)==0 && OrderType()==OP_SELL && takeprofit>0) GlobalVariableSet(nametp,OrderOpenPrice()-takeprofit*Pips(OrderSymbol()));
                           
            if(breakeven>0 && OrderProfit()>0 && OrderType()==OP_BUY && OrderOpenPrice()+breakeven*Pips(OrderSymbol())<=bid && (GlobalVariableGet(namesl)<OrderOpenPrice() || GlobalVariableGet(namesl)==0)) GlobalVariableSet(namesl,OrderOpenPrice()+profit*Pips(OrderSymbol()));
            
            if(breakeven>0 && OrderProfit()>0 && OrderType()==OP_SELL && OrderOpenPrice()-breakeven*Pips(OrderSymbol())>=ask && (GlobalVariableGet(namesl)>OrderOpenPrice() || GlobalVariableGet(namesl)==0)) GlobalVariableSet(namesl,OrderOpenPrice()-profit*Pips(OrderSymbol()));
                           
            if(trailstop>0 && trailstep>0 && OrderProfit()>0 && OrderType()==OP_BUY && OrderOpenPrice()+trailstop*Pips(OrderSymbol())<=bid && (GlobalVariableGet(namesl)<OrderOpenPrice() || GlobalVariableGet(namesl)==0)) GlobalVariableSet(namesl,OrderOpenPrice()+profit*Pips(OrderSymbol()));
            
            if(trailstop>0 && trailstep>0 && OrderProfit()>0 && OrderType()==OP_SELL && OrderOpenPrice()-trailstop*Pips(OrderSymbol())>=ask && (GlobalVariableGet(namesl)>OrderOpenPrice() || GlobalVariableGet(namesl)==0)) GlobalVariableSet(namesl,OrderOpenPrice()-profit*Pips(OrderSymbol()));
                           
            if(trailstop>0 && trailstep>0 && OrderProfit()>0 && OrderType()==OP_BUY && GlobalVariableGet(namesl)+(trailstop+trailstep)*Pips(OrderSymbol())<=bid && GlobalVariableGet(namesl)>=OrderOpenPrice()) GlobalVariableSet(namesl,GlobalVariableGet(namesl)+trailstep*Pips(OrderSymbol()));
            
            if(trailstop>0 && trailstep>0 && OrderProfit()>0 && OrderType()==OP_SELL && GlobalVariableGet(namesl)-(trailstop+trailstep)*Pips(OrderSymbol())>=ask && GlobalVariableGet(namesl)<=OrderOpenPrice()) GlobalVariableSet(namesl,GlobalVariableGet(namesl)-trailstep*Pips(OrderSymbol()));
            
            }
                                             
         }
         
      }
   
   GhostMain(symbol,magic,comment);
                
   }

//-------------------------------------------------------------------------

void TrailingProfit(double trailprofit, double trailstep=1, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   double gv, bid, ask;
   
   bool w1, w2;
   
   string name;
   
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
                           
            bid=MarketInfo(OrderSymbol(),MODE_BID);
            
            ask=MarketInfo(OrderSymbol(),MODE_ASK);
                                
            name="TPA"+IntegerToString(OrderTicket());
               
            gv=GlobalVariableGet(name);
               
            w1=false; w2=false;
                          
            if(trailprofit>0 && trailstep>0 && OrderType()==OP_BUY && OrderOpenPrice()+trailprofit*Pips(OrderSymbol())<=bid) GlobalVariableSet(name,OrderOpenPrice()+trailprofit*Pips(OrderSymbol()));
                       
            if(trailprofit>0 && trailstep>0 && OrderType()==OP_SELL && OrderOpenPrice()-trailprofit*Pips(OrderSymbol())>=ask) GlobalVariableSet(name,OrderOpenPrice()-trailprofit*Pips(OrderSymbol()));
                                      
            if(trailprofit>0 && trailstep>0 && OrderType()==OP_BUY && gv>0 && bid<=gv-trailprofit*Pips(OrderSymbol()) && (OrderTakeProfit()>gv || OrderTakeProfit()==0)) w1=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),gv,0);
                    
            if(trailprofit>0 && trailstep>0 && OrderType()==OP_SELL && gv>0 && ask>=gv+trailprofit*Pips(OrderSymbol()) && (OrderTakeProfit()<gv || OrderTakeProfit()==0)) w2=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),gv,0);
               
            if(w1==true) GlobalVariableSet(name,gv-trailstep*Pips(OrderSymbol()));
               
            if(w2==true) GlobalVariableSet(name,gv+trailstep*Pips(OrderSymbol()));
            
            }
                                            
         }
         
      }
         
   }

//-------------------------------------------------------------------------

string TextTF(int period)
   {
   
   string res;
   
   
   if(period<60) res="M"+DoubleToStr(period,0);  
   
   if(period==60) res="H1";
   
   if(period==60*4) res="H4";
   
   if(period==60*24) res="D1";
   
   if(period==60*24*7) res="W1";
   
   if(period==60*24*30) res="MN";
   
   
   return(res);
   
   }

//-------------------------------------------------------------------------

int Combo(int direction, datetime starttime, int timeframe=0, string symbol=NULL, bool currentbar=false)
   {
   
   int v, res=0;
   
   double can;
        
   
   for(v=MathAbs(currentbar-1);v<128;v++)
      {
      
      if(iTime(symbol,timeframe,v)<starttime) break;
      
      can=iClose(symbol,timeframe,v)-iOpen(symbol,timeframe,v);
           
      if(can>0 && direction==12) res++;
      
      if(can<0 && direction==6) res++;
      
      if(can>0 && direction==6) break;
      
      if(can<0 && direction==12) break;
             
      }
  
     
   return(res);
   
   }

//-------------------------------------------------------------------------

int Count(datetime timepoint, bool inversion=false)
   {
   
   int res=0;
   
   
   if(inversion==true) res=(int)(timepoint-TimeCurrent());
   
   if(inversion==false) res=(int)(TimeCurrent()-timepoint);
   
    
   return(res);
   
   }

//-------------------------------------------------------------------------

int PartClose(int status, double targetprice1, double targetprice2, double closepercent1, double closepercent2, double breakeven=0)
   {

   int v, res=status;
   
   bool w1, w2;
           
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(OrderMagicNumber()==Magic && OrderSymbol()==Symbol()) 
            {
                                    
            if(OrderType()==OP_BUY && res==0 && Bid>=targetprice1) 
               {
               
               w1=false; w2=false;
               
               if(breakeven>=0) w1=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+breakeven*Pips(),OrderTakeProfit(),0);
               
               w2=OrderClose(OrderTicket(),Good(OrderLots()*0.01*closepercent1,2),Bid,90);
               
               if(w2==true) res=1;
               
               }
            
            
            if(OrderType()==OP_SELL && res==0 && Bid<=targetprice1) 
               {
               
               w1=false; w2=false;
               
               if(breakeven>=0) w1=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-breakeven*Pips(),OrderTakeProfit(),0);
               
               w2=OrderClose(OrderTicket(),Good(OrderLots()*0.01*closepercent1,2),Ask,90);
               
               if(w2==true) res=1;
               
               }
            
            
            if(OrderType()==OP_BUY && res==1 && Bid>=targetprice2) 
               {
               
               w2=false;
                             
               w2=OrderClose(OrderTicket(),Good(OrderLots()*0.01*closepercent2,2),Bid,90);
               
               if(w2==true) res=2;
               
               }
            
            
            if(OrderType()==OP_SELL && res==1 && Bid<=targetprice2)
               {
               
               w2=false;
               
               w2=OrderClose(OrderTicket(),Good(OrderLots()*0.01*closepercent2,2),Ask,90);
                              
               if(w2==true) res=2;
               
               }
         
            }
                  
         }
         
      }


   return(res);

   }
   
//-------------------------------------------------------------------------

int XHour(string time)
   {
   
   int res=TimeHour(StrToTime(time));
     
   return(res);
   
   }

//-------------------------------------------------------------------------

int XMinute(string time)
   {
   
   int res=TimeMinute(StrToTime(time));
     
   return(res);
   
   }

//-------------------------------------------------------------------------

int XSecond(string time)
   {
   
   int res=TimeSeconds(StrToTime(time));
     
   return(res);
   
   }

//-------------------------------------------------------------------------

double Candle(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res;
   
   res=(iClose(symbol,timeframe,bar)-iOpen(symbol,timeframe,bar))/Pips(symbol);
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double Range(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res;
   
   res=(iHigh(symbol,timeframe,bar)-iLow(symbol,timeframe,bar))/Pips(symbol);
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double Head(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res;
   
   res=(iHigh(symbol,timeframe,bar)-MathMax(iClose(symbol,timeframe,bar),iOpen(symbol,timeframe,bar)))/Pips(symbol);
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double Tail(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res;
   
   res=(MathMin(iClose(symbol,timeframe,bar),iOpen(symbol,timeframe,bar))-iLow(symbol,timeframe,bar))/Pips(symbol);
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double Body(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res;
   
   res=MathAbs(Candle(bar,timeframe,symbol));
   
   return(res);
   
   }

//-------------------------------------------------------------------------

datetime LCC(int timeframe=0, string symbol=NULL, int magic=-1, string comment=NULL)
   {
      
   datetime res=0;
         
   res=iTime(symbol,timeframe,iBarShift(symbol,timeframe,(int)Last(9,symbol,magic,comment)));
     
   return(res);
     
   }

//-------------------------------------------------------------------------

void TesterArrows(color buyline=clrLimeGreen, color sellline=clrRed, color closearrow=clrGoldenrod)
   {

   color colx=clrWhite;
     
   
   if(Last(1)==1) colx=buyline;
   
   if(Last(1)==-1) colx=sellline;
            
         
   ObjectCreate("Order Line "+IntegerToString((int)Last(0)),OBJ_TREND,0,(int)Last(8),Last(5),(int)Last(9),Last(6));
         
   ObjectSet("Order Line "+IntegerToString((int)Last(0)),OBJPROP_RAY,0);
         
   ObjectSet("Order Line "+IntegerToString((int)Last(0)),OBJPROP_STYLE,STYLE_DOT);
         
   ObjectSet("Order Line "+IntegerToString((int)Last(0)),OBJPROP_COLOR,colx);
   
         
   ObjectCreate("Order Start Arrow "+IntegerToString((int)Last(0)),OBJ_ARROW,0,(int)Last(8),Last(5));
         
   ObjectSet("Order Start Arrow "+IntegerToString((int)Last(0)),OBJPROP_ARROWCODE,1);
         
   ObjectSet("Order Start Arrow "+IntegerToString((int)Last(0)),OBJPROP_COLOR,colx);
   
         
   ObjectCreate("Order Stop Arrow "+IntegerToString((int)Last(0)),OBJ_ARROW,0,(int)Last(9),Last(6));
         
   ObjectSet("Order Stop Arrow "+IntegerToString((int)Last(0)),OBJPROP_ARROWCODE,3);
         
   ObjectSet("Order Stop Arrow "+IntegerToString((int)Last(0)),OBJPROP_COLOR,closearrow);

   }

//-------------------------------------------------------------------------

void Button(string name, string text, int xpos, int ypos, int width, int height, color textcolor, int fontsize, bool bold, color bgcolor, color bordercolor)
   {
   
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xpos);
   
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,ypos);
   
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetString(0,name,OBJPROP_TEXT,text);
   
   if(bold==true) ObjectSetString(0,name,OBJPROP_FONT,"Arial Black");
   
   if(bold==false) ObjectSetString(0,name,OBJPROP_FONT,"Arial");

   ObjectSetInteger(0,name,OBJPROP_COLOR,textcolor);
   
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bgcolor);
   
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,bordercolor);
   
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   
   ObjectSetInteger(0,name,OBJPROP_STATE,false);
   
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
     
   }

//-------------------------------------------------------------------------

void TextField(string name, string text, int xpos, int ypos, int width, int height, color textcolor=clrBlack, int fontsize=8, bool bold=false, color bgcolor=clrWhite, color bordercolor=clrBlack, int align=0, bool readonly=false)
   {
   
   ObjectCreate(0,name,OBJ_EDIT,0,0,0);
   
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xpos);
   
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,ypos);
   
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetString(0,name,OBJPROP_TEXT,text);
   
   if(bold==true) ObjectSetString(0,name,OBJPROP_FONT,"Arial Black");
   
   if(bold==false) ObjectSetString(0,name,OBJPROP_FONT,"Arial");

   ObjectSetInteger(0,name,OBJPROP_COLOR,textcolor);
   
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bgcolor);
   
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,bordercolor);
      
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   
   ObjectSetInteger(0,name,OBJPROP_ALIGN,align);
   
   ObjectSetInteger(0,name,OBJPROP_READONLY,readonly);
       
   }

//-------------------------------------------------------------------------

double LotClose(int direction, double lotsize)
   {

   int v; 
   
   double res=lotsize, lotdifference;
   
   bool w1, w2;
           
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && res>0) 
            {
            
            w1=false; w2=false;
            
            lotdifference=res-OrderLots();
                                    
            if(OrderType()==OP_BUY && direction==1 && OrderLots()>=res) w1=OrderClose(OrderTicket(),res,Bid,90); 
            
            if(OrderType()==OP_BUY && direction==1 && OrderLots()<res) w2=OrderClose(OrderTicket(),OrderLots(),Bid,90);
            
            if(OrderType()==OP_SELL && direction==-1 && OrderLots()>=res) w1=OrderClose(OrderTicket(),res,Ask,90); 
            
            if(OrderType()==OP_SELL && direction==-1 && OrderLots()<res) w2=OrderClose(OrderTicket(),OrderLots(),Ask,90);
            
            if(w1==true) res=0;
            
            if(w2==true) res=lotdifference;
            
            }
                  
         }
         
      }


   return(res);

   }
   
//-------------------------------------------------------------------------

double Ticket(int ticket, int mode=0)
   {
   
   int v;
   
   double res=0;
      
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(OrderTicket()==ticket)
            {
            
            if(mode==0) res=OrderTicket();
            
            if(mode==1 && OrderType()==OP_BUY) res=1;
            
            if(mode==1 && OrderType()==OP_SELL) res=-1;
            
            if(mode==1 && OrderType()==OP_BUYSTOP) res=2;
            
            if(mode==1 && OrderType()==OP_SELLSTOP) res=-2;
            
            if(mode==1 && OrderType()==OP_BUYLIMIT) res=3;
            
            if(mode==1 && OrderType()==OP_SELLLIMIT) res=-3;
            
            if(mode==2) res=OrderProfit();
            
            if(mode==3) res=OrderStopLoss();
            
            if(mode==4) res=OrderTakeProfit();
            
            if(mode==5) res=OrderOpenPrice();
            
            if(mode==6) res=OrderClosePrice();
            
            if(mode==7) res=OrderLots();
            
            if(mode==8) res=(int)OrderOpenTime();
            
            if(mode==9) res=(int)OrderCloseTime();
            
            if(mode==10) res=StrToDouble(OrderComment());
            
            if(mode==11) res=OrderCommission();
            
            if(mode==12) res=OrderSwap();
            
            if(mode==13) res=OrderProfit()+OrderCommission()+OrderSwap();
                                    
            }
            
         }
                 
      }
  
   
   return(res);
     
   }

//-------------------------------------------------------------------------

void Arrow(datetime time, double price, int type=159, int width=1, int style=0, color colour=clrDarkOrange)
   {
   
   ObjectDelete("Arrow "+TimeToStr(time));
            
   ObjectCreate("Arrow "+TimeToStr(time),OBJ_ARROW,0,time,price);
   
   ObjectSet("Arrow "+TimeToStr(time),OBJPROP_ARROWCODE,type);
   
   ObjectSet("Arrow "+TimeToStr(time),OBJPROP_COLOR,colour);
      
   ObjectSet("Arrow "+TimeToStr(time),OBJPROP_STYLE,style);
   
   ObjectSet("Arrow "+TimeToStr(time),OBJPROP_WIDTH,width);
      
   }

//-------------------------------------------------------------------------

void BrickH(int number, int xpos, int ypos, int size, int width, double multiplier, color colour)
   {
   
   int v;
   
   
   for(v=0;v<width;v++)
      {
           
      ObjectCreate("BrickH"+DoubleToStr(number*pow(10,4)+v,0),OBJ_LABEL,0,0,0);
   
      ObjectSetText("BrickH"+DoubleToStr(number*pow(10,4)+v,0),"g",size,"Webdings",colour);
      
      ObjectSet("BrickH"+DoubleToStr(number*pow(10,4)+v,0),OBJPROP_XDISTANCE,xpos+(int)(size*multiplier)*v);
         
      ObjectSet("BrickH"+DoubleToStr(number*pow(10,4)+v,0),OBJPROP_YDISTANCE,ypos);
      
      }
            
   }

//-------------------------------------------------------------------------

void BrickV(int number, int xpos, int ypos, int size, int height, double multiplier, color colour)
   {
   
   int v;
   
   
   for(v=0;v<height;v++)
      {
           
      ObjectCreate("BrickV"+DoubleToStr(number*pow(10,6)+v,0),OBJ_LABEL,0,0,0);
   
      ObjectSetText("BrickV"+DoubleToStr(number*pow(10,6)+v,0),"g",size,"Webdings",colour);
      
      ObjectSet("BrickV"+DoubleToStr(number*pow(10,6)+v,0),OBJPROP_XDISTANCE,xpos);
         
      ObjectSet("BrickV"+DoubleToStr(number*pow(10,6)+v,0),OBJPROP_YDISTANCE,ypos+(int)(size*multiplier)*v);
      
      }
            
   }

//-------------------------------------------------------------------------

void TextPos(string text, int number, int xpos, int ypos, int size=9, bool bold=true, color colour=clrDodgerBlue)
   {
            
   ObjectCreate("TextX"+DoubleToStr(number,0),OBJ_LABEL,0,0,0); 
      
   if(bold==true) ObjectSetText("TextX"+DoubleToStr(number,0),text,size,"Arial Black",colour);
   
   if(bold==false) ObjectSetText("TextX"+DoubleToStr(number,0),text,size,"Arial",colour);
      
   ObjectSet("TextX"+DoubleToStr(number,0),OBJPROP_XDISTANCE,xpos);
         
   ObjectSet("TextX"+DoubleToStr(number,0),OBJPROP_YDISTANCE,ypos);
      
   }

//-------------------------------------------------------------------------

double GetFibo(string fiboname, double fibolevel)
   { 
      
   double res=0, price1, price2;
   
   
   price1=ObjectGet(fiboname,OBJPROP_PRICE1);
   
   price2=ObjectGet(fiboname,OBJPROP_PRICE2);
      
   if(price1>price2) res=fibolevel*0.01*MathAbs(price1-price2)+price2;
   
   if(price1<price2) res=(1-fibolevel*0.01)*MathAbs(price1-price2)+price1;
   
   res=round(res*pow(10,Digits))*Point;
   
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double ClosedTicket(int ticket, int mode=0)
   {
   
   int v;
   
   double res=0;
      
   
   for(v=OrdersHistoryTotal()-1;v>=0;v--)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_HISTORY)==true) 
         {
         
         if(OrderTicket()==ticket)
            {
            
            if(mode==0) res=OrderTicket();
            
            if(mode==1 && OrderType()==OP_BUY) res=1;
            
            if(mode==1 && OrderType()==OP_SELL) res=-1;
            
            if(mode==1 && OrderType()==OP_BUYSTOP) res=2;
            
            if(mode==1 && OrderType()==OP_SELLSTOP) res=-2;
            
            if(mode==1 && OrderType()==OP_BUYLIMIT) res=3;
            
            if(mode==1 && OrderType()==OP_SELLLIMIT) res=-3;
            
            if(mode==2) res=OrderProfit();
            
            if(mode==3) res=OrderStopLoss();
            
            if(mode==4) res=OrderTakeProfit();
            
            if(mode==5) res=OrderOpenPrice();
            
            if(mode==6) res=OrderClosePrice();
            
            if(mode==7) res=OrderLots();
            
            if(mode==8) res=(int)OrderOpenTime();
            
            if(mode==9) res=(int)OrderCloseTime();
            
            if(mode==10) res=StrToDouble(OrderComment());
            
            if(mode==11) res=OrderCommission();
            
            if(mode==12) res=OrderSwap();
            
            if(mode==13) res=OrderProfit()+OrderCommission()+OrderSwap();
            
            v=-1;
                                    
            }
            
         }
                 
      }
  
   
   return(res);
     
   }

//-------------------------------------------------------------------------

void Modify(double stoploss, double takeprofit, int mode=0, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   bool w;
   
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(OrderMagicNumber()==Magic && OrderSymbol()==Symbol())
            {
            
            if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
               {
            
               if((mode==1 || mode==12) && stoploss>=0 && takeprofit<0 && OrderType()==OP_BUY && OrderStopLoss()!=stoploss && OrderStopLoss()<OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0);
               
               if((mode==1 || mode==12) && takeprofit>=0 && stoploss<0 && OrderType()==OP_BUY && OrderTakeProfit()!=takeprofit) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
               
               if((mode==1 || mode==12) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_BUY && (OrderStopLoss()!=stoploss || OrderTakeProfit()!=takeprofit) && OrderStopLoss()<OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0);
               
               if((mode==1 || mode==12) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_BUY && OrderTakeProfit()!=takeprofit && OrderStopLoss()>=OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                                      
               if((mode==-1 || mode==6) && stoploss>=0 && takeprofit<0 && OrderType()==OP_SELL && OrderStopLoss()!=stoploss && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0);
               
               if((mode==-1 || mode==6) && takeprofit>=0 && stoploss<0 && OrderType()==OP_SELL && OrderTakeProfit()!=takeprofit) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                          
               if((mode==-1 || mode==6) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_SELL && (OrderStopLoss()!=stoploss || OrderTakeProfit()!=takeprofit) && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0);
               
               if((mode==-1 || mode==6) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_SELL && OrderTakeProfit()!=takeprofit && OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()!=0) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                                   
               if((mode==2 || mode==12) && stoploss>=0 && takeprofit<0 && OrderType()==OP_BUYSTOP && OrderStopLoss()!=stoploss && OrderStopLoss()<OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0);
               
               if((mode==2 || mode==12) && takeprofit>=0 && stoploss<0 && OrderType()==OP_BUYSTOP && OrderTakeProfit()!=takeprofit) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
               
               if((mode==2 || mode==12) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_BUYSTOP && (OrderStopLoss()!=stoploss || OrderTakeProfit()!=takeprofit) && OrderStopLoss()<OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0);
               
               if((mode==2 || mode==12) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_BUYSTOP && OrderTakeProfit()!=takeprofit && OrderStopLoss()>=OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                          
               if((mode==-2 || mode==6) && stoploss>=0 && takeprofit<0 && OrderType()==OP_SELLSTOP && OrderStopLoss()!=stoploss && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0);
               
               if((mode==-2 || mode==6) && takeprofit>=0 && stoploss<0 && OrderType()==OP_SELLSTOP && OrderTakeProfit()!=takeprofit) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                          
               if((mode==-2 || mode==6) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_SELLSTOP && (OrderStopLoss()!=stoploss || OrderTakeProfit()!=takeprofit) && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0);
               
               if((mode==-2 || mode==6) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_SELLSTOP && OrderTakeProfit()!=takeprofit && OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()!=0) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                          
               if((mode==3 || mode==12) && stoploss>=0 && takeprofit<0 && OrderType()==OP_BUYLIMIT && OrderStopLoss()!=stoploss && OrderStopLoss()<OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0);
               
               if((mode==3 || mode==12) && takeprofit>=0 && stoploss<0 && OrderType()==OP_BUYLIMIT && OrderTakeProfit()!=takeprofit) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
               
               if((mode==3 || mode==12) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_BUYLIMIT && (OrderStopLoss()!=stoploss || OrderTakeProfit()!=takeprofit) && OrderStopLoss()<OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0);
               
               if((mode==3 || mode==12) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_BUYLIMIT && OrderTakeProfit()!=takeprofit && OrderStopLoss()>=OrderOpenPrice()) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                                     
               if((mode==-3 || mode==6) && stoploss>=0 && takeprofit<0 && OrderType()==OP_SELLLIMIT && OrderStopLoss()!=stoploss && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0);
               
               if((mode==-3 || mode==6) && takeprofit>=0 && stoploss<0 && OrderType()==OP_SELLLIMIT && OrderTakeProfit()!=takeprofit) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
                          
               if((mode==-3 || mode==6) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_SELLLIMIT && (OrderStopLoss()!=stoploss || OrderTakeProfit()!=takeprofit) && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0);
               
               if((mode==-3 || mode==6) && stoploss>=0 && takeprofit>=0 && OrderType()==OP_SELLLIMIT && OrderTakeProfit()!=takeprofit && OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()!=0) w=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeprofit,0);
               
               }
                                                     
            }
                                             
         }
         
      }
     
   }

//-------------------------------------------------------------------------

int GMT()
   {
   
   int res=0;
   
   double offset;
      
     
   offset=(int)TimeCurrent()-(int)TimeGMT();
   
   res=(int)round(offset/3600)*3600;
   
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double Xtremum(int buffer, int firstbar, int lastbar=0, bool minimum=false, string name=NULL, int timeframe=0, string symbol=NULL)
   {
   
   int v;
   
   double res=99999*minimum, indi=0;
   
   
   for(v=firstbar;v>=lastbar;v--)
      {
      
      if(name!=NULL) indi=iCustom(symbol,timeframe,name,buffer,v);
      
      if(name==NULL && buffer==0) indi=iOpen(symbol,timeframe,v);
      
      if(name==NULL && buffer==8) indi=iClose(symbol,timeframe,v);
      
      if(name==NULL && buffer==12) indi=iHigh(symbol,timeframe,v);
      
      if(name==NULL && buffer==6) indi=iLow(symbol,timeframe,v);
            
      if(minimum==false) res=MathMax(indi,res);
      
      if(minimum==true) res=MathMin(indi,res);
      
      }
   
 
   return(res);
   
   }

//-------------------------------------------------------------------------

int Pending(int type, double lots, double stoploss=0, double takeprofit=0, double price=0, double ncomment=0, string symbol=NULL, string tcomment=NULL, int magic=-1)
   {
   
   int res=-1;
   
   
   if(type==2 && iHigh(symbol,0,0)+Spread(symbol)>=price) res=Trade(1,lots,stoploss,takeprofit,price,0,ncomment,symbol,tcomment,magic); 
   
   if(type==-3 && iHigh(symbol,0,0)>=price) res=Trade(-1,lots,stoploss,takeprofit,price,0,ncomment,symbol,tcomment,magic);
   
   if(type==-2 && iLow(symbol,0,0)<=price) res=Trade(-1,lots,stoploss,takeprofit,price,0,ncomment,symbol,tcomment,magic);
   
   if(type==3 && iLow(symbol,0,0)+Spread(symbol)<=price) res=Trade(1,lots,stoploss,takeprofit,price,0,ncomment,symbol,tcomment,magic);
      
   
   return(res);
   
   }

//-------------------------------------------------------------------------

bool SLTP(int ticket, double stoploss, double takeprofit)
   {
      
   bool res=false;
   
            
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==true) 
      {
      
      if(OrderType()==OP_BUY || OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT) res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-stoploss*Pips(OrderSymbol())-OrderOpenPrice()*pow(0,stoploss),OrderOpenPrice()+takeprofit*Pips(OrderSymbol())-OrderOpenPrice()*pow(0,takeprofit),0);
      
      if(OrderType()==OP_SELL || OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT) res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+stoploss*Pips(OrderSymbol())-OrderOpenPrice()*pow(0,stoploss),OrderOpenPrice()-takeprofit*Pips(OrderSymbol())-OrderOpenPrice()*pow(0,takeprofit),0);
               
      }
   
   return(res);
     
   }

//-------------------------------------------------------------------------

bool IC(double value)
   {
   
   bool res=false;
      
   if(value!=0 && value!=INT_MAX) res=true;
            
   return(res);
   
   }

//-------------------------------------------------------------------------

double IgnoreEmpty(string name, int buffer=0, int number=1, int bars=256, bool usetime=false, int timeframe=0, string symbol=NULL)
   {
   
   int v, w=0;
   
   double res=0;
   
   
   for(v=0;v<bars;v++)
      {
      
      if(IC(iCustom(symbol,timeframe,name,buffer,v)))
         {
         
         w++;
         
         if(w==number && usetime==false) {res=iCustom(symbol,timeframe,name,buffer,v); break;}
         
         if(w==number && usetime==true) {res=(int)iTime(symbol,timeframe,v); break;}
            
         }
            
      }
   
      
   return(res);
   
   }

//-------------------------------------------------------------------------

void Write(string filename, string content, bool csvfile=false)
   {
   
   int v=0;
   
      
   if(csvfile==false) v=FileOpen(filename+".txt",FILE_WRITE|FILE_TXT);
   
   if(csvfile==true) v=FileOpen(filename+".csv",FILE_WRITE|FILE_CSV);

   if(v>0) FileWrite(v,content);

   FileClose(v);
   
   }

//-------------------------------------------------------------------------

string Read(string filename, bool csvfile=false)
   {
   
   int v=0;
   
   string res="";
   
      
   if(csvfile==false) v=FileOpen(filename+".txt",FILE_READ|FILE_TXT);
   
   if(csvfile==true) v=FileOpen(filename+".csv",FILE_READ|FILE_TXT);
      
   while(FileIsEnding(v)==false)
      {
   
      if(v>0) res=res+FileReadString(v)+"\n";
      
      }
      
   FileClose(v);
   
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double HAOpen(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res=0;
   
   res=iCustom(symbol,timeframe,"Heiken Ashi",2,bar);
   
   res=Good(res,(int)MarketInfo(symbol,MODE_DIGITS));
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double HAClose(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res=0;
   
   res=iCustom(symbol,timeframe,"Heiken Ashi",3,bar);
   
   res=Good(res,(int)MarketInfo(symbol,MODE_DIGITS));
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double HAHigh(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res=0;
   
   res=MathMax(iCustom(symbol,timeframe,"Heiken Ashi",0,bar),iCustom(symbol,timeframe,"Heiken Ashi",1,bar));
   
   res=Good(res,(int)MarketInfo(symbol,MODE_DIGITS));
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double HALow(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res=0;
   
   res=MathMin(iCustom(symbol,timeframe,"Heiken Ashi",0,bar),iCustom(symbol,timeframe,"Heiken Ashi",1,bar));
   
   res=Good(res,(int)MarketInfo(symbol,MODE_DIGITS));
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double HACandle(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res;
   
   res=(HAClose(bar,timeframe,symbol)-HAOpen(bar,timeframe,symbol))/Pips(symbol);
   
   res=Good(res,1);
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double HARange(int bar=0, int timeframe=0, string symbol=NULL)
   {
   
   double res;
   
   res=(HAHigh(bar,timeframe,symbol)-HALow(bar,timeframe,symbol))/Pips(symbol);
   
   res=Good(res,1);
   
   return(res);
   
   }

//-------------------------------------------------------------------------

string GetComment(int ticket)
   {
      
   string res="";
      
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==true) res=OrderComment();
   
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)==true) res=OrderComment();
     
   return(res);
   
   }

//-------------------------------------------------------------------------

void LinesOnNumber(int level, int levels, int width=1, int style=0, color colour=clrDarkOrange, string symbol=NULL)
   {
   
   int v, p, digits=Dig(level,0);
   
   double w, bid=MarketInfo(symbol,MODE_BID), digs=MarketInfo(symbol,MODE_DIGITS);
   
   
   p=0;
   
   for(v=(int)(bid*pow(10,digs));v<(int)2*(bid*pow(10,digs));v++)
      {
      
      w=v*pow(0.1,digits);
      
      w=w-floor(w);
      
      w=floor(w*pow(10,digits));
      
      
      if(w==level)
         {
         
         ObjectDelete("Number_Level_"+(string)v);
            
         ObjectCreate("Number_Level_"+(string)v,OBJ_HLINE,0,0,v*pow(0.1,digs));
   
         ObjectSet("Number_Level_"+(string)v,OBJPROP_COLOR,colour);
      
         ObjectSet("Number_Level_"+(string)v,OBJPROP_STYLE,style);
   
         ObjectSet("Number_Level_"+(string)v,OBJPROP_WIDTH,width);
         
         p++;
                                         
         }
      
      if(p>=levels) break;   
      
      }
   
   
   p=0;
   
   for(v=(int)(bid*pow(10,digs));v>0;v--)
      {
      
      w=v*pow(0.1,digits);
      
      w=w-floor(w);
      
      w=floor(w*pow(10,digits));
      
      
      if(w==level)
         {
         
         ObjectDelete("Number_Level_"+(string)v);
            
         ObjectCreate("Number_Level_"+(string)v,OBJ_HLINE,0,0,v*pow(0.1,digs));
   
         ObjectSet("Number_Level_"+(string)v,OBJPROP_COLOR,colour);
      
         ObjectSet("Number_Level_"+(string)v,OBJPROP_STYLE,style);
   
         ObjectSet("Number_Level_"+(string)v,OBJPROP_WIDTH,width);
         
         p++;
                                         
         }
      
      if(p>=levels) break;   
      
      }
   
   }

//-------------------------------------------------------------------------

int Dig(double value, int mode=0)
   {
   
   int v, res=0;
   
   
   for(v=1;v<16;v++)
      {
      
      if(mode==0 && value*pow(0.1,v)<1) {res=v; break;}
      
      if(mode==1 && value*pow(10,v)==floor(value*pow(10,v))) {res=v; break;}
      
      }
   
     
   return(res);
   
   }

//-------------------------------------------------------------------------

void Expiration(int seconds, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   double bid, ask;
   
   bool w;
   
   
   for(v=OrdersTotal()-1;v>=0;v--)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
            
            if(TimeCurrent()>OrderOpenTime()+seconds)
               {
                     
               ask=MarketInfo(OrderSymbol(),MODE_ASK);
                  
               bid=MarketInfo(OrderSymbol(),MODE_BID);
               
               if(OrderType()==OP_BUY) w=OrderClose(OrderTicket(),OrderLots(),bid,90); 
               
               if(OrderType()==OP_SELL) w=OrderClose(OrderTicket(),OrderLots(),ask,90);
               
               }
                                                                      
            }
                                             
         }
         
      }
     
   }

//-------------------------------------------------------------------------

double Number(int type, int number=1, int mode=0, string symbol=NULL, int magic=-1, string comment=NULL)
   {
   
   int v, p=0;
   
   double res=0;
         
   
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL))
            {
            
            if(type==1 && OrderType()==OP_BUY) p++;
            
            if(type==-1 && OrderType()==OP_SELL) p++;
            
            if(type==2 && OrderType()==OP_BUYSTOP) p++;
            
            if(type==-2 && OrderType()==OP_SELLSTOP) p++;
            
            if(type==3 && OrderType()==OP_BUYLIMIT) p++;
            
            if(type==-3 && OrderType()==OP_SELLLIMIT) p++;
                     
            
            if(p==number)
               {
                        
               if(mode==0) res=OrderTicket();
               
               if(mode==1 && OrderType()==OP_BUY) res=1;
               
               if(mode==1 && OrderType()==OP_SELL) res=-1;
               
               if(mode==2) res=OrderProfit();
               
               if(mode==3) res=OrderStopLoss();
               
               if(mode==4) res=OrderTakeProfit();
               
               if(mode==5) res=OrderOpenPrice();
               
               if(mode==6) res=OrderClosePrice();
               
               if(mode==7) res=OrderLots();
               
               if(mode==8) res=(int)OrderOpenTime();
               
               if(mode==9) res=(int)OrderCloseTime();
               
               if(mode==10) res=StrToDouble(OrderComment());
               
               if(mode==11) res=OrderCommission();
               
               if(mode==12) res=OrderSwap();
               
               if(mode==13) res=OrderProfit()+OrderCommission()+OrderSwap();
               
               break;
               
               }
                                    
            }
            
         }
                 
      }
  
   
   return(res);
     
   }

//-------------------------------------------------------------------------

double OArrows(int bar, int arrowcode)
   {
   
   int v;
   
   double res=0;
   
   
   for(v=0;v<ObjectsTotal();v++)
      {
      
      if(ObjectType(ObjectName(v))==OBJ_ARROW && ObjectGet(ObjectName(v),OBJPROP_ARROWCODE)==arrowcode)
         {
         
         if(ObjectGet(ObjectName(v),OBJPROP_TIME1)==Time[bar]) res=ObjectGet(ObjectName(v),OBJPROP_PRICE1);
                          
         }
           
      }
   
     
   return(res);
   
   }

//-------------------------------------------------------------------------

double HistoryProfit(bool commswap=false, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   double res=0;
      
   
   for(v=OrdersHistoryTotal()-1;v>=0;v--)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_HISTORY)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
            
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
               {
            
               if(commswap==false) res=res+OrderProfit();
               
               if(commswap==true) res=res+OrderProfit()+OrderCommission()+OrderSwap();
               
               }
                                    
            }
            
         }
                 
      }
  
   
   return(res);
     
   }

//-------------------------------------------------------------------------

int Bar(string time, int timeframe=0, string symbol=NULL)
   {
   
   int res=0;
     
   res=iBarShift(symbol,timeframe,StrToTime(time));
   
   return(res);
   
   }

//-------------------------------------------------------------------------

double DigitsCut(double value, int digits=0)
   {
   
   double res=value;
      
   res=floor(res*pow(10,digits))*pow(0.1,digits);
            
   return(res);
   
   }

//-------------------------------------------------------------------------

double LotCheck(double lotsize, double minlotsize=0.01, double maxlotsize=100)
   {
   
   double res=lotsize;
   
   
   if(minlotsize<=0) minlotsize=MarketInfo(Symbol(),MODE_MINLOT);
   
   if(maxlotsize<=0) maxlotsize=MarketInfo(Symbol(),MODE_MAXLOT);
     
   if(res<minlotsize) res=minlotsize;
   
   if(res>maxlotsize) res=maxlotsize;
   
   res=Good(res,2);
    
            
   return(res);
   
   }

//-------------------------------------------------------------------------

int DayFilter(bool monday, bool tuesday, bool wednesday, bool thursday, bool friday)
   {
   
   int res=1;
   
   
   if(monday==true && DayOfWeek()==1) res=0;
   
   if(tuesday==true && DayOfWeek()==2) res=0;
   
   if(wednesday==true && DayOfWeek()==3) res=0;
   
   if(thursday==true && DayOfWeek()==4) res=0;
   
   if(friday==true && DayOfWeek()==5) res=0;
    
            
   return(res);
   
   }

//-------------------------------------------------------------------------

double PI(int pipsvalue=5)
   {
      
   double res=pipsvalue;
         
   res=res*Pips();
         
   return(res);
   
   }

//-------------------------------------------------------------------------

void ITS(double value, bool inprofit=true, bool usebuys=true, bool usesells=true, string symbol=NULL, int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v;
   
   double p=value, ask, bid;
   
   bool w;
      
            
   for(v=0;v<OrdersTotal();v++)
      {
         
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES)==true) 
         {
         
         if(pow(OrderSymbol()==symbol,symbol!=NULL && symbol!="All") && pow(OrderSymbol()==Symbol(),symbol==NULL) && pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL) && OrderOpenTime()>=starttime)
            {
            
            ask=MarketInfo(OrderSymbol(),MODE_ASK);
                  
            bid=MarketInfo(OrderSymbol(),MODE_BID);
            
            if(usebuys && pow(OrderProfit()>0,inprofit) && OrderType()==OP_BUY && OrderStopLoss()<p-PI()) w=OrderModify(OrderTicket(),OrderOpenPrice(),p,OrderTakeProfit(),0);
         
            if(usesells && pow(OrderProfit()>0,inprofit) && OrderType()==OP_SELL && (OrderStopLoss()>p+PI() || OrderStopLoss()==0)) w=OrderModify(OrderTicket(),OrderOpenPrice(),p,OrderTakeProfit(),0);
                                                               
            }
                                             
         }
         
      }
     
   }

//-------------------------------------------------------------------------

double MAX(double value1, double value2, double value3=-INT_MAX, double value4=-INT_MAX, double value5=-INT_MAX, double value6=-INT_MAX, double value7=-INT_MAX)
   {
      
   double res;
    
   res=MathMax(value1,value2);
   
   res=MathMax(res,value3);
   
   res=MathMax(res,value4);
   
   res=MathMax(res,value5);
   
   res=MathMax(res,value6);
   
   res=MathMax(res,value7);
         
   return(res);
   
   }

//-------------------------------------------------------------------------

double MIN(double value1, double value2, double value3=INT_MAX, double value4=INT_MAX, double value5=INT_MAX, double value6=INT_MAX, double value7=INT_MAX)
   {
      
   double res;
    
   res=MathMin(value1,value2);
   
   res=MathMin(res,value3);
   
   res=MathMin(res,value4);
   
   res=MathMin(res,value5);
   
   res=MathMin(res,value6);
   
   res=MathMin(res,value7);
         
   return(res);
   
   }

//-------------------------------------------------------------------------

double MaxLot(string symbol=NULL)
   {
   
   double res=INT_MAX;
   
   if(StringLen(symbol)<3) return(res);
      
   res=DigitsCut(AccountFreeMargin()/MarketInfo(symbol,MODE_MARGINREQUIRED),2);
         
   while(AccountFreeMarginCheck(symbol,OP_BUY,res)<=0 || AccountFreeMarginCheck(symbol,OP_SELL,res)<=0) res=res-0.01;
   
   res=DigitsCut(res,2);
      
   return(res);
   
   }

//-------------------------------------------------------------------------

double MTrade(int type, double lots, double lotmaximum=100, double stoploss=0, double takeprofit=0, double price=0, double distance=0, double ncomment=0, string symbol=NULL, string tcomment=NULL, int magic=-1)
   {
   
   int lotlevels, v;
   
   double lotsize[], res=lots-TotalLots(type,symbol,magic);
   
            
   lotlevels=(int)ceil(res/lotmaximum);
   
   ArrayResize(lotsize,lotlevels+1);
        
   for(v=1;v<=lotlevels;v++) lotsize[v]=MathMin(res-lotmaximum*(v-1),lotmaximum);
      
   for(v=1;v<=lotlevels;v++) Trade(type,lotsize[v],stoploss,takeprofit,price,distance,ncomment,symbol,tcomment,magic);
      
   res=lots-TotalLots(type,symbol,magic);
   
   res=DigitsCut(res,2);
        
   
   return(res);
   
   }

//-------------------------------------------------------------------------

int CurS(string currency) 
   {
   
   int p, w=0, v;
   
   double xtremum, value, res=0;
   
   string Pair;
     
   string Symbols[]={"EURUSD","GBPUSD","USDJPY","USDCHF","USDCAD","AUDUSD","NZDUSD","EURGBP","EURJPY",
                     "EURCHF","EURCAD","EURAUD","EURNZD","GBPJPY","GBPCHF","GBPCAD","GBPAUD","GBPNZD",
                     "AUDJPY","AUDCHF","AUDCAD","AUDNZD","CHFJPY","CADJPY","NZDJPY","USDSGD"};
   
   
   for(v=0;v<ArraySize(Symbols);v++)
      {
      
      p=0;
      
      Pair=Symbols[v];
      
      if(currency==StringSubstr(Pair,0,3) || currency==StringSubstr(Pair,3,3)) 
         {
         
         Pair=Pair+"";
         
         xtremum=(MarketInfo(Pair,MODE_HIGH)-MarketInfo(Pair,MODE_LOW))*MarketInfo(Pair,MODE_POINT);
                  
         if(xtremum!=0) 
            {
            
            value=100*((MarketInfo(Pair,MODE_BID)-MarketInfo(Pair,MODE_LOW))/xtremum*MarketInfo(Pair,MODE_POINT));
            
            if (value>3) p=1;
            
            if (value>10) p=2;
            
            if (value>25) p=3;
            
            if (value>40) p=4;
            
            if (value>50) p=5;
            
            if (value>60) p=6;
            
            if (value>75) p=7;
            
            if (value>90) p=8;
            
            if (value>97) p=9;
            
            w++;
            
            if(currency==StringSubstr(Pair,3,3)) p=9-p;
            
            res=res+p;
            
            }
            
         }
      }
      
   
   res=round(10*res/w);
   
   return((int)res);
   
   }

//-------------------------------------------------------------------------

double BEL(color linecolour=clrDarkViolet, int linewidth=2, int linestyle=0, bool showline=true, int magic=-1, string comment=NULL)
   {
   
   int v;
   
   double res=0;
     
   int Total_Buy_Trades=0, Total_Sell_Trades=0, PipAdjust=0, Net_Trades=0;
   
   double Total_Buy_Size=0, Total_Buy_Price=0, Buy_Profit=0, Total_Sell_Size=0, Total_Sell_Price=0, Sell_Profit=0, Net_Lots=0, Net_Result=0, Average_Price=0, distance=0;
      
   if(Digits==5 || Digits==3 || Digits==1) PipAdjust=10;
   
   if(Digits==4 || Digits==2 || Digits==0) PipAdjust=1;
     
   double Pip_Value=MarketInfo(Symbol(),MODE_TICKVALUE)*PipAdjust;
   
   double Pip_Size=MarketInfo(Symbol(),MODE_TICKSIZE)*PipAdjust;


   for(v=0;v<OrdersTotal();v++)
      {
     
      if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
         {
         
         if(pow(OrderMagicNumber()==Magic,magic==-1) && pow(OrderMagicNumber()==magic,magic>=0) && pow(OrderComment()==comment,comment!=NULL))
            {
         
            if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
               {
            
               Total_Buy_Trades++;
               
               Total_Buy_Price=Total_Buy_Price+OrderOpenPrice()*OrderLots();
               
               Total_Buy_Size=Total_Buy_Size+OrderLots();
               
               Buy_Profit=Buy_Profit+OrderProfit()+OrderSwap()+OrderCommission();
               
               }
                 
         
            if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
               {
              
               Total_Sell_Trades++;
              
               Total_Sell_Size=Total_Sell_Size+OrderLots();
              
               Total_Sell_Price=Total_Sell_Price+OrderOpenPrice()*OrderLots();
              
               Sell_Profit=Sell_Profit+OrderProfit()+OrderSwap()+OrderCommission();
              
               }
               
            }
            
         }
         
      }
     
   
   if(Total_Buy_Price>0) Total_Buy_Price=Total_Buy_Price/Total_Buy_Size;
   
   if(Total_Sell_Price>0) Total_Sell_Price=Total_Sell_Price/Total_Sell_Size;
   
   
   Net_Trades=Total_Buy_Trades+Total_Sell_Trades;
   
   Net_Lots=Total_Buy_Size-Total_Sell_Size;
   
   Net_Result=Buy_Profit+Sell_Profit;


   if(Net_Trades>0 && Net_Lots!=0)
      {
      
      distance=(Net_Result/(MathAbs(Net_Lots*MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));
      
      if(Net_Lots>0) Average_Price=Bid-distance;
      
      if(Net_Lots<0) Average_Price=Ask+distance;
      
      }
   
   
   if(Net_Trades>0 && Net_Lots==0)
      {
      
      distance=(Net_Result/((MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));
      
      Average_Price=Bid-distance;
      
      }
   
     
   res=Good(Average_Price,Digits);  
   
   if(showline) HLine(0,res,linewidth,linestyle,linecolour);
   
      
   return(res);
     
   }

//-------------------------------------------------------------------------

int RSI(int status, int period=14, int price=PRICE_CLOSE, int leveldown=30, int levelup=70, int bar=1, int timeframe=0, string symbol=NULL)
   {
   
   int res=status;
   
   double rsi[];
   
   
   ArrayResize(rsi,bar+1);
      
   rsi[bar]=iRSI(symbol,timeframe,period,price,bar);
   
   
   if(rsi[bar]<levelup && status==2) res=1;
   
   if(rsi[bar]>leveldown && status==-2) res=-1;
   
   if(rsi[bar]>levelup) res=2;
   
   if(rsi[bar]<leveldown) res=-2;
   
    
   return(res);
   
   }
//-------------------------------------------------------------------------
int PairsTotal(int magic=-1, string comment=NULL, datetime starttime=0)
   {
   
   int v, res=0;
              
   
   for(v=0;v<SymbolsTotal(true);v++)
      {
      
      if(Total(0,SymbolName(v,true),magic,comment,starttime)>0) res++;
      
      }
   
   
   return(res);
     
   }

//-------------------------------------------------------------------------

double GetProfit()
{
  int mTotal = OrdersTotal();
  double mProfit =0;
  
  for(int iz = mTotal-1; iz>=0; iz--)
  {
    if(OrderSelect(iz, SELECT_BY_POS))
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && (OrderType() == OP_BUY || OrderType() == OP_SELL))
         {
           mProfit = mProfit + OrderProfit() + OrderSwap() + OrderCommission();
   
         }
  } 
  
  return(mProfit);
}