//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2017, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017 RODRIGO"
#property link      "http://www.rodrigo.com"

extern string Trade="---------- Trade ----------";
extern int MagicNumber=4763;
extern string TradeComment="ATRCandle";
extern double StopLoss=2.3;
extern double Limit=2.3;
extern double Distance=3;

extern string Indicators="---------- Indicators ----------";

extern double ATRLimit=0.0005;
extern int ATRPeriod= 15;
extern int ATRFrame = 1;
extern int CandleFrame=30;

extern string MoneyManagement="---------- MM ----------";
extern bool UseMM=TRUE;
extern double MinLots = 0.01;
extern double MaxLots = 100000.0;
extern double Risk=3;
extern double FixedLots=0.01;


//=================================================================================================================================================

double point=0.0;
int lotstep1;
double minlots;
double maxlots;
double risk;
double limit;
double distance;
double filter;
int slippage=2;
int OrderCount;

//=================================================================================================================================================
int init()
  {

   ObjectsDeleteAll();

   if(Digits==3 || Digits==5) point=10*Point;
   else point=Point;

   double lotstep=MarketInfo(Symbol(),MODE_LOTSTEP);
   lotstep1= MathLog(lotstep)/MathLog(0.1);
   minlots = MathMax(MinLots, MarketInfo(Symbol(), MODE_MINLOT));
   maxlots = MathMin(MaxLots, MarketInfo(Symbol(), MODE_MAXLOT));
   risk=Risk/100.0;
   limit=NormalizeDouble(Limit*point,Digits);
   distance=NormalizeDouble(Distance*point,Digits);

   return (INIT_SUCCEEDED);
  }
//=================================================================================================================================================
int deinit()
  {

   ObjectsDeleteAll();
   Comment("");
   return (0);
  }
//=================================================================================================================================================
void OnTick()
  {

   double Dir=0;

   double ATR=iATR(Symbol(),ATRFrame,ATRPeriod,0);
   
   string dr= "===";

     

      if(iClose(Symbol(),CandleFrame,0)>iClose(Symbol(),CandleFrame,1))

        {

         Dir=iClose(Symbol(),CandleFrame,0)-iClose(Symbol(),CandleFrame,1);
         dr = "BUY";

        }

      

      else if(iClose(Symbol(),CandleFrame,0)<iClose(Symbol(),CandleFrame,1))

        {

         Dir=iClose(Symbol(),CandleFrame,0)-iClose(Symbol(),CandleFrame,1);
         dr = "SELL";

        }

    

   OrderCount=CountPending();

   if(ATR>ATRLimit) PlaceOrder(Dir);

   ModifyAll();
   
   
   
   
   
   ObjectCreate("ATR",OBJ_LABEL,0,0,0);
   ObjectSet("ATR",OBJPROP_CORNER,4);
   ObjectSet("ATR",OBJPROP_XDISTANCE,10);
   ObjectSet("ATR",OBJPROP_YDISTANCE,40);
   if(ATR>ATRLimit)ObjectSetText("ATR","ATR = "+DoubleToStr(ATR,Digits),12,"Tahoma Bold",Lime);
   if(ATR<=ATRLimit)ObjectSetText("ATR","ATR = "+DoubleToStr(ATR,Digits),12,"Tahoma Bold",Yellow);
   
   ObjectCreate("DR",OBJ_LABEL,0,0,0);
   ObjectSet("DR",OBJPROP_CORNER,4);
   ObjectSet("DR",OBJPROP_XDISTANCE,10);
   ObjectSet("DR",OBJPROP_YDISTANCE,80);
   if(Dir>0)ObjectSetText("DR","DIR BUY= "+DoubleToStr(Dir,Digits),12,"Tahoma Bold",Lime);
   if(Dir<0)ObjectSetText("DR","DIR SELL= "+DoubleToStr(Dir,Digits),12,"Tahoma Bold",Red);

   return;
  }
//=================================================================================================================================================

//=================================================================================================================================================

//Modify All Orders

void ModifyAll()
  {

   int type;
   double orderstoploss;
   double NewStopLoss;
   double NewOpenPrice;
   bool res;

   double orderopenprice;

   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==MagicNumber)
           {
            type=OrderType();
            if(type==OP_BUYLIMIT || type==OP_SELLLIMIT) continue;
            if(OrderSymbol()==Symbol())
              {

               switch(type)

                 {
                  case OP_BUY:

                     if(Distance<0) break;

                     orderstoploss=NormalizeDouble(OrderStopLoss(),Digits);

                     NewStopLoss=NormalizeDouble(Bid-distance,Digits);

                     if(!((orderstoploss==0.0 || NewStopLoss>orderstoploss))) break;

                     res=OrderModify(OrderTicket(),OrderOpenPrice(),NewStopLoss,OrderTakeProfit(),0,Lime);

                     break;

                  case OP_SELL:

                     if(Distance<0) break;

                     orderstoploss=NormalizeDouble(OrderStopLoss(),Digits);

                     NewStopLoss=NormalizeDouble(Ask+distance,Digits);

                     if(!((orderstoploss==0.0 || NewStopLoss<orderstoploss))) break;

                     res=OrderModify(OrderTicket(),OrderOpenPrice(),NewStopLoss,OrderTakeProfit(),0,Orange);

                     break;

                  case OP_BUYSTOP:

                     orderopenprice=NormalizeDouble(OrderOpenPrice(),Digits);

                     NewOpenPrice=NormalizeDouble(Ask+limit,Digits);

                     if(!((NewOpenPrice<orderopenprice))) break;

                     NewStopLoss=NormalizeDouble(NewOpenPrice-StopLoss*point,Digits);

                     res=OrderModify(OrderTicket(),NewOpenPrice,NewStopLoss,OrderTakeProfit(),0,Lime);

                     break;

                  case OP_SELLSTOP:

                     orderopenprice=NormalizeDouble(OrderOpenPrice(),Digits);

                     NewOpenPrice=NormalizeDouble(Bid-limit,Digits);

                     if(!((NewOpenPrice>orderopenprice))) break;

                     NewStopLoss=NormalizeDouble(NewOpenPrice+StopLoss*point,Digits);

                     res=OrderModify(OrderTicket(),NewOpenPrice,NewStopLoss,OrderTakeProfit(),0,Orange);

                     break;
                 }
              }
           }
        }
     }

   return;

  }
//+------------------------------------------------------------------+

// Place Stop Pending Orders
void PlaceOrder(double dir)

  {

   int ticket;
   double OpenPrice;
   double PendingSL;

   if(OrderCount==0 && dir!=0)
     {
      if(dir>0)

        {
         OpenPrice=NormalizeDouble(Ask+limit,Digits);

         PendingSL=NormalizeDouble(OpenPrice-StopLoss*point,Digits);

         ticket=OrderSend(Symbol(),OP_BUYSTOP,GetLots(),OpenPrice,slippage,PendingSL,0,TradeComment+" BUY",MagicNumber,0,Lime);

        }
      else if(dir<0)

        {
         OpenPrice=NormalizeDouble(Bid-limit,Digits);

         PendingSL=NormalizeDouble(OpenPrice+StopLoss*point,Digits);

         ticket=OrderSend(Symbol(),OP_SELLSTOP,GetLots(),OpenPrice,slippage,PendingSL,0,TradeComment+" SELL",MagicNumber,0,Orange);

        }
     }

   return;

  }
//+------------------------------------------------------------------+

//Get Lot Size
double GetLots()

  {
   double lotfactor;
   double ilots;

   lotfactor=AccountBalance()*AccountLeverage()*risk;

   if(UseMM==FALSE) lotfactor=FixedLots;

   ilots=NormalizeDouble(lotfactor/MarketInfo(Symbol(),MODE_LOTSIZE),lotstep1);

   ilots=MathMax(minlots,ilots);

   ilots=MathMin(maxlots,ilots);

   return(ilots);

  }
//+------------------------------------------------------------------+

int CountPending()

  {
   int count=0;
   int type;
   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==MagicNumber)
           {
            type=OrderType();

            if(type==OP_BUYSTOP || type==OP_SELLSTOP)

               if(OrderSymbol()==Symbol())

                 {
                  count++;
                 }
           }

        }
     }

   return(count);
  }
//+------------------------------------------------------------------+
