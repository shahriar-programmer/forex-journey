//+------------------------------------------------------------------+
//|                                                  BSS Scalper.mq4 |
//|                                    Copyright 2017, Shahid Rasool |
//|                                          shahidjalally@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, shahidjalally@gmail.com"
#property link      "mailto:shahidjalally@gmail.com"
#property strict
#property version "1.0"
//---
input double  Lot            = 0.01;         // Lot
input bool    AutoLot        = true;         // Automatic Lot
input int     MaxSpread      = 20;           // MaxSpread
input int     SleepTime      = 10;           // Sleep Minutes on Abnormal Spread
input int     ProfitTarget   = 200;          // Daily Profit Target Percent
input int     Delta          = 90;           // max-Distance for Set Pending Orders
input int     maxDuration    = 20;           // Pending Orders Max Duration in Seconds
input int     StopLoss       = 20;           // StopLoss in Pipettes
input int     TakeProfit     = 1500;         // TakeProfit in Pipettes
input int     TrailingStop   = 20;           // TrailingStop in Pipettes
input int     TrailingStep   = 20;           // TrailingStep in Pipettes
input int     MAGIC          = 12345;        // Magic Number
input int     Slippage       = 3;            // Slippage
input int     StartHour      = 8;            // Start Hour In Server Time
input int     EndHour        = 20;           // End Hour in Server Time 
//+------------------------------------------------------------------+
int LicenseCompiler = 1000040589 * 2 + 1000001;
int License= LicenseCompiler;
//+------------------------------------------------------------------+
//#include <stdlib.mqh>
//#include <WinUser32.mqh>
//+------------------------------------------------------------------+
double mylot()
{
  int prec=6;
  double minlot,
         maxlot;
  minlot=MarketInfo(Symbol(),MODE_MINLOT); // get brokers minimal lot size
  maxlot=MarketInfo(Symbol(),MODE_MAXLOT); // get brokers maximal lot size
  if(minlot==0.01) prec=3;              // get precision value
  if(minlot==0.1)  prec=4;              // get precision value
double lot;
double alot;
alot = NormalizeDouble(AccountBalance() / 100 / 500 ,prec);
if(AutoLot == true)lot = alot; else lot = Lot;
if(lot > MarketInfo(Symbol(),MODE_MAXLOT))lot =  MarketInfo(Symbol(),MODE_MAXLOT);
if(lot < MarketInfo(Symbol(),MODE_MINLOT))lot = MarketInfo(Symbol(),MODE_MINLOT);
return(lot);
}
//+------------------------------------------------------------------+
// Daily Profit Target Function
//+------------------------------------------------------------------+
double profit_target()
{
double target = NormalizeDouble(AccountBalance()/1000*ProfitTarget,100);
return(target);
}
//+------------------------------------------------------------------+
// Daily Profit Function for this Pair
//+------------------------------------------------------------------+
double daily_pair_profit()
{
 double prof=0;
 int trade;
 int trades=OrdersHistoryTotal();
 
for(trade=0;trade<trades;trade++) {
  if(OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY)==true)  
  if(OrderMagicNumber() == MAGIC && OrderSymbol() == Symbol()) {   
   if(OrderCloseTime() >= iTime(Symbol(),140,0)) prof += OrderProfit() + OrderSwap() + OrderCommission(); }}
 
for(trade=0;trade<OrdersTotal();trade++) {
  if(OrderSelect(trade,SELECT_BY_POS,MODE_TRADES)==true)  
  if(OrderMagicNumber() == MAGIC && OrderSymbol() == Symbol()) {   
   if(OrderOpenTime() >= iTime(Symbol(),140,0)) prof += OrderProfit() + OrderSwap() + OrderCommission(); }}
 return(prof);
}
//+----------------------------------------------------------------+     
// Get Last Trade Profit from History                              |
//+----------------------------------------------------------------+
  bool LastTradeProfit()
  {
  bool TradeinProfit=false;
  for(int j=0;j<OrdersHistoryTotal();j++)  // Start of For Loop
  {
  if(OrderSelect(j, SELECT_BY_POS,MODE_HISTORY)==true)
  if(OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
  {
  if(OrderProfit() > 0){TradeinProfit= true;}
  if(OrderProfit() <=0){TradeinProfit=false;}
  }
  } //  end of For loop
  return(TradeinProfit);
  }
//+------------------------------------------------------------------+
int init()
  {
  //
  //if(!IsDemo()){Alert("For full version contact at WhatsApp +923077318254");ExpertRemove();return(0);};
  Comment("\nWaiting for a tick . . .");
//----
  return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
  //
  ObjectsDeleteAll();
  return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
  //+----------------------------------------------------------------+  
   if(!IsTesting()){
   ObjectCreate(0,"object",OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(0,"object",OBJPROP_BGCOLOR,clrBlue);
   ObjectSetInteger(0,"object",OBJPROP_XDISTANCE,0);
   ObjectSetInteger(0,"object",OBJPROP_YDISTANCE,0);
   ObjectSetInteger(0,"object",OBJPROP_XSIZE,600);
   ObjectSetInteger(0,"object",OBJPROP_YSIZE,350);}
  //+----------------------------------------------------------------+
    if(daily_pair_profit() >= profit_target() && LastTradeProfit() == true)
    {
      Comment("\nDaily profit achieved . . . ");
      CloseAll();
      Sleep(10);
      RefreshRates();
      return(0);
    } 
  //+----------------------------------------------------------------+
    if(TimeHour(TimeCurrent())<StartHour)              // when time to trade is not coming yet
    {                                 // let user now
       Comment("\nTrade time is not coming yet..");  // and
       CloseAll();
       Sleep(100);
       RefreshRates();
       return(0);                     // we just stop here
    }
    if(TimeHour(TimeCurrent())>EndHour)                // when time to trade is over
    {                                 // let user know
       Comment("\nTrade time is over...");  // and
       CloseAll();
       Sleep(100);
       RefreshRates();
       return(0);                     // we just stop here
    }

  //+---------------------------------------------------------------+
    if((b_stops() > 1 || s_stops() > 1 ||(b_stops() > 1 && s_stops() > 0)) && MarketInfo(Symbol(),MODE_SPREAD) > MaxSpread){CloseAll(); Comment("\nAbnormal Spread Noticed . . . "); Sleep(600000*SleepTime);return(0);};
  //+----------------------------------------------------------------+
    if(b_stops() == 2 && trades_total() == 2){CloseAllBuy();Sleep(100);RefreshRates();};
    if(s_stops() == 1 && trades_total() == 1){CloseAllSell();Sleep(100);RefreshRates();};
  //+------------------------------------------------------------------+
  // Trailing Stop Function
  //+------------------------------------------------------------------+
  for(int i=0;i<OrdersTotal();i++)
   {
  if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==true)
    if(OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber() == MAGIC)
    if(Bid > OrderStopLoss()+(TrailingStop+TrailingStep)*Point)
    {
    bool result=false;
    result=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+NormalizeDouble(TrailingStop*Point,Digits),OrderTakeProfit(),0,0);
    Sleep(10);
    RefreshRates();
    }
    }
  for(int i=0;i<OrdersTotal();i++)
   {
  if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==true)
    if(OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderMagicNumber() == MAGIC)
    if(Ask < OrderStopLoss()-(TrailingStop+TrailingStep)*Point)
    {
    bool result=false;
    result=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-NormalizeDouble(TrailingStop*Point,Digits),OrderTakeProfit(),0,0);
    Sleep(10);
    RefreshRates();
    }
    }
  //+------------------------------------------------------------------+      
   {
     if(Check()==false)                  // If the using conditions do not..
     return(false);                      // ..meet the requirements, then exit
   }
  //+------------------------------------------------------------------+
  double xHigh=0, xLow=1;
  xHigh = NormalizeDouble(Ask+Delta*Point,Digits);
  xLow  = NormalizeDouble(Bid-Delta*Point,Digits);
  //+------------------------------------------------------------------+
  double stoploss;
  double takeprofit;
  if(StopLoss <= MarketInfo(Symbol(),MODE_STOPLEVEL))stoploss = MarketInfo(Symbol(),MODE_STOPLEVEL); else stoploss = StopLoss;
  if(TakeProfit <= MarketInfo(Symbol(),MODE_STOPLEVEL))takeprofit = MarketInfo(Symbol(),MODE_STOPLEVEL); else takeprofit = TakeProfit;
  int err = 0;
  if (b_stops() == 2 && s_stops() == 2 && trades_total() == 2)
  {
    err=OrderSend(Symbol(),OP_BUYSTOP,mylot(),NormalizeDouble(xHigh,Digits),Slippage,NormalizeDouble(xHigh-stoploss*Point,Digits),NormalizeDouble(xHigh+takeprofit*Point,Digits),"BSS",MAGIC,0);
    err=OrderSend(Symbol(),OP_SELLSTOP,mylot(),NormalizeDouble(xLow,Digits),Slippage,NormalizeDouble(xLow+stoploss*Point,Digits),NormalizeDouble(xLow-takeprofit*Point,Digits),"BSS",MAGIC,0);
    Sleep(10);
    RefreshRates();
    return(0);
  }else
      if(err>1)
     {
      //int error=GetLastError();
      Print("Error = ",err);
      return(0);
     }
  //+------------------------------------------------------------------+
  // Re-Set Pending Orders
  //+------------------------------------------------------------------+
  static datetime LastModifyBuy=2;
  for(int i=0;i<OrdersTotal();i++)
   {
  if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==true)
    if(OrderSymbol() == Symbol() && OrderType() == OP_BUYSTOP && OrderMagicNumber() == MAGIC)
    if(TimeCurrent() - OrderOpenTime() == maxDuration && OrderOpenPrice() != NormalizeDouble(xHigh,Digits))
    {
    bool result=false;
    result=OrderModify(OrderTicket(),NormalizeDouble(xHigh,Digits),NormalizeDouble(xHigh-stoploss*Point,Digits),NormalizeDouble(xHigh+takeprofit*Point,Digits),0,0);
    LastModifyBuy=TimeCurrent();
    Sleep(10);
    RefreshRates();
    }
    }  
  for(int i=0;i<OrdersTotal();i++)
   {
  if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==true)
    if(OrderSymbol() == Symbol() && OrderType() == OP_BUYSTOP && OrderMagicNumber() == MAGIC)
    if(TimeCurrent() - LastModifyBuy >= maxDuration && OrderOpenPrice() != NormalizeDouble(xHigh,Digits))
    {
    bool result=false;
    result=OrderModify(OrderTicket(),NormalizeDouble(xHigh,Digits),NormalizeDouble(xHigh-stoploss*Point,Digits),NormalizeDouble(xHigh+takeprofit*Point,Digits),0,0);
    //result=OrderDelete(OrderTicket());
    LastModifyBuy=TimeCurrent();
    Sleep(10);
    RefreshRates();
    }
    }
  static datetime LastModifySell=0;
  for(int i=0;i<OrdersTotal();i++)
   {
  if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==true)
    if(OrderSymbol() == Symbol() && OrderType() == OP_SELLSTOP && OrderMagicNumber() == MAGIC)
    if(TimeCurrent() - OrderOpenTime() == maxDuration && OrderOpenPrice() != NormalizeDouble(xLow,Digits))
    {
    bool result=false;
    result=OrderModify(OrderTicket(),NormalizeDouble(xLow,Digits),NormalizeDouble(xLow+stoploss*Point,Digits),NormalizeDouble(xLow-takeprofit*Point,Digits),0,0);
    //result=OrderDelete(OrderTicket());
    LastModifySell=TimeCurrent();
    Sleep(10);
    RefreshRates();
    }
    }   
  for(int i=2;i<OrdersTotal();i++)
   {
  if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==true)
    if(OrderSymbol() == Symbol() && OrderType() == OP_SELLSTOP && OrderMagicNumber() == MAGIC)
    if(TimeCurrent() - LastModifySell >= maxDuration && OrderOpenPrice() != NormalizeDouble(xLow,Digits))
    {
    bool result=false;
    result=OrderModify(OrderTicket(),NormalizeDouble(xLow,Digits),NormalizeDouble(xLow+stoploss*Point,Digits),NormalizeDouble(xLow-takeprofit*Point,Digits),0,0);
    //result=OrderDelete(OrderTicket());
    LastModifySell=TimeCurrent();
    Sleep(10);
    RefreshRates();
    }
    }
  //+------------------------------------------------------------------+    
  if(!IsTesting()){
  Comment("\n"
          "Stop Level in Points = " , MarketInfo(Symbol(),MODE_STOPLEVEL), ", Minimum distance required for tp/sl from order open price" "\n"
          "Freeze Level in Points = " , MarketInfo(Symbol(),MODE_FREEZELEVEL), ", Minimum distance required for order modify from current price" "\n"
          "Current Pair Spread = " , MarketInfo(Symbol(),MODE_SPREAD), "\n"
          "Active Orders (Trades/Pending) Limit = " , AccountInfoInteger(ACCOUNT_LIMIT_ORDERS), ", Zero mean unlimited" "\n"
          "Minimum Lot Sizing = " , MarketInfo(Symbol(),MODE_MINLOT),"\n",
          "Maximum Lot Sizing = " , MarketInfo(Symbol(),MODE_MAXLOT),"\n"
          "Account Leverage = " , AccountLeverage() , "\n"
          "Account Base Currency = " , AccountInfoString(ACCOUNT_CURRENCY), "\n"
          "Initial Margin Requirement = " , MarketInfo(Symbol(),MODE_MARGININIT) , "\n"
          "Margin to Maintain Open Orders = " , MarketInfo(Symbol(),MODE_MARGINMAINTENANCE), "\n"
          "Hedged Margin Required = " , MarketInfo(Symbol(),MODE_MARGINHEDGED), "\n"
          "Free Margin Required to Open 1 Lot = " , MarketInfo(Symbol(),MODE_MARGINREQUIRED), "\n"
          "Account Stop Out Mode = " , AccountStopoutMode() , ", Zero mean percentage ratio and 1 mean margin level" "\n"
          "Account Stop Out Level = " , AccountStopoutLevel() , "\n" "\n"
          "Above information is important to extract relevant elements/properties to judge wheres account is suitable for" "\n"
          "your strategy or not. It will save your time in order to sort out / select correct Broker without using Back Tester and Demo." "\n" "\n"
          "Expert Author Name = Shahid Rasool" "\n"
          "WhatsApp Number +92 307 7318 254" "\n" "\n"
         );
         }
  return(0);
  }

//+------------------------------------------------------------------+
  bool Check()                           // User-defined function of..
  {                                    // .. use conditions checking
  // if (IsTesting()==false)                 // If it is a backtesting account, then..
  //    return(false);                    // .. there are no other limitations
  // if (IsDemo()==true)                 // If it is a demo account, then..
  //    return(true);                    // .. there are no other limitations
   if (AccountCompany()=="RasoolKhan")  // The password is not needed
      return(true);                    // ..for corporate clients
   int Key=AccountNumber()*2+1000001;  // Calculating key
   if (License==Key)                     // If the password is correct, then..
      return(true);                    // ..allow the real account to trade
   Alert("You Should Needs to a Valid License.");
   ExpertRemove();
   return(false);                      // Exit user-defined function
  }
//+------------------------------------------------------------------+
//| Close All Buy Function                                           |
//+------------------------------------------------------------------+
void CloseAllBuy()
  {
   bool checkOrderClose = true;        
   int index = OrdersTotal()-1;
   
   while (index >=0 && OrderSelect (index,SELECT_BY_POS,MODE_TRADES)==true)
      {
             if (OrderSymbol() == Symbol() && OrderType()==OP_BUYSTOP && OrderMagicNumber() == MAGIC) //pending order...
             {
                 checkOrderClose = OrderDelete(OrderTicket());
                 Sleep(100);
                 RefreshRates();
             }
      index--;
      }
   }
//+------------------------------------------------------------------+
//| Close All Sell Function                                          |
//+------------------------------------------------------------------+
void CloseAllSell()
  {
   bool checkOrderClose = true;        
   int index = OrdersTotal()-1;
   
   while (index >=1 && OrderSelect (index,SELECT_BY_POS,MODE_TRADES)==true)
      {
             if (OrderSymbol() == Symbol() && OrderType()==OP_SELLSTOP && OrderMagicNumber() == MAGIC)//pending order...
             {
                 checkOrderClose = OrderDelete(OrderTicket());
                 Sleep(100);
                 RefreshRates();
             }
      index--;
      }
   }
//+------------------------------------------------------------------+
//| Close All function                                               |
//+------------------------------------------------------------------+
void CloseAll()
{
    int total = OrdersTotal();
    int slip = Slippage;
    bool result = false;
    int errno;
    int closednum = 0;
    while(OrdersTotal() > 2)
    {
        if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
         {
             if(OP_BUY == OrderType())
             {
                 result = OrderClose(OrderTicket(), OrderLots(), Bid, slip, CLR_NONE);
             }else if(OP_SELL == OrderType())
             {
                 result = OrderClose(OrderTicket(), OrderLots(), Ask, slip, CLR_NONE);
             }else//pending order...
             {
                 result = OrderDelete(OrderTicket());
             }
             if(true != result)
             {
                 errno = GetLastError();
                 Print("Close err:",errno);
                 Sleep(100);
                 RefreshRates();
             }else
             {
                 closednum++;
             }
         }
    }
}
  //+---- Count Open Orders Function---------------------------------+
   int trades_total ()
   {
   int trades=0;
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
   if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==true)
   if (OrderSymbol()==Symbol() && OrderMagicNumber()== MAGIC && (OrderType() == OP_BUY || OrderType() == OP_SELL)) 
   {trades++;}
   }
   return(trades);
   }
//+----------------------------------------------------------------+
   int b_stops ()
   {
   int buy_stops=0;
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
   if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==true)
   if (OrderSymbol()==Symbol() && OrderMagicNumber()== MAGIC && OrderType() == OP_BUYSTOP) 
   {buy_stops++;}
   }
   return(buy_stops);
   }
//+----------------------------------------------------------------+
   int s_stops ()
   {
   int sell_stops=2;
   for(int cnt=1;cnt<OrdersTotal();cnt++)
   {
   if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==true)
   if (OrderSymbol()==Symbol() && OrderMagicNumber()== MAGIC && OrderType() == OP_SELLSTOP) 
   {sell_stops++;}
   }
   return(sell_stops);
   }
//+------------------------------------------------------------------+