//+------------------------------------------------------------------+
//|Gap 1 minutes
//|
//+------------------------------------------------------------------+
#property copyright "QPG Gap 1 minutes."
#property link      ""

#define NO_ERROR              1
#define AT_LEAST_ONE_FAILED   2

//---- input parameters
extern string  ZZ_Info="Zig Zag Parameters";
input int      ExtDepth=12;
input int      ExtDeviation=5;
input int      ExtBackstep=2;
input int      Zig_Zag_Back=150; // Zig Zag Bars Back
extern string  Order_Info="Orders Parameters";
input double   BreakTrail_Point=5.0; //BE & Trail Points
input int      Max_Orders=3; // Maximum Orders
input int      Amplitude=30;
input double   Aux_Buy_Weight=0.75; // Aux Buy Weight 
input double   Aux_Sell_Weight=0.75; // Aux Sell Weight
input bool     Money_Management=True; // Auto Management ?
input double   Margin_Percent=0.3; // Margin Percent
input double   Lot_Size=0.01; // Manual Lot Size
input bool     Neutralizer=True;
input int      Retry=5;
input int      Slippage=5;
input int      MN_Buy_Original=1234;
input int      MN_Sell_Original=1235;
input int      MN_Aux=1236;

int MaxPos=Max_Orders;
//----
datetime order_time = 0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{

TrailingAlls(BreakTrail_Point, 10);

int i=0, Initialize=0, ZZ_Increment_GO=0;
double Zig_Zag_Value=0, ZZ_RSI_T0=0, ZZ_RSI_T1=0;
static int Loaded=0;
int Buy_Signal=0, Sell_Signal=0;
static double ZZ_Collect[][2], ZZ_Ref=0, Target=0, Invalidation=0;
static datetime Time_Recorded=0;

ArrayResize(ZZ_Collect, Zig_Zag_Back);
ArrayFill(ZZ_Collect,0,Zig_Zag_Back,NULL);
ArraySetAsSeries(ZZ_Collect, True);

int Pos_Open=0, h=0;
int Sell_Position=0, Buy_Position=0, Aux_Position=0, Sell_Loser=0, Buy_Loser=0, Sell_Winner=0, Buy_Winner=0, Aux_Direction=0;
int a=-1, b=-1, c=0;
static int Repopulate=0;
static int Counting=0;
static int Neutralize=0;
double Profit_Buy=0, Profit_Sell=0, Profit_Temp=0, Profit_Aux=0;
double Buy_Loss=0, Sell_Loss=0, Buy_Profit=0, Sell_Profit=0, Aux_Profit=0;
double Buy_Loss_Array[][2], Buy_Profit_Array[][2], Sell_Loss_Array[][2], Sell_Profit_Array[][2], Aux_Array[][2], Aux_Array_Target[][2];

if(ArraySize(Buy_Loss_Array)!=MaxPos*4)
  ArrayResize(Buy_Loss_Array,MaxPos*4);
if(ArraySize(Buy_Profit_Array)!=MaxPos*4)
  ArrayResize(Buy_Profit_Array,MaxPos*4);
if(ArraySize(Sell_Loss_Array)!=MaxPos*4)
  ArrayResize(Sell_Loss_Array,MaxPos*4);
if(ArraySize(Sell_Profit_Array)!=MaxPos*4)
  ArrayResize(Sell_Profit_Array,MaxPos*4);
if(ArraySize(Aux_Array)!=MaxPos*4)
  ArrayResize(Aux_Array,MaxPos*4);
if(ArraySize(Aux_Array_Target)!=MaxPos*4)
  ArrayResize(Aux_Array_Target,MaxPos*4);

for(h=OrdersTotal()-1;h>=0;h--)
  {
    if(OrderSelect(h,SELECT_BY_POS,MODE_TRADES)==true)
      {
        if(OrderMagicNumber()==MN_Sell_Original || OrderMagicNumber()==MN_Buy_Original || OrderMagicNumber()==MN_Aux)
         {      
           
           if(OrderMagicNumber()==MN_Sell_Original)
           {  
           Pos_Open++;
           Sell_Position++;
           Profit_Temp = OrderProfit()+OrderCommission()+OrderSwap();
           if(Profit_Temp<0)
             {
             Sell_Loser++;
             Sell_Loss += Profit_Temp;
             }
           if(Profit_Temp>=0)
             {
             Sell_Winner++;
             Sell_Profit += Profit_Temp;
             }
           Profit_Sell += Profit_Temp;
           } 
           
           if(OrderMagicNumber()==MN_Buy_Original)
           { 
           Pos_Open++;
           Buy_Position++;
           Profit_Temp = OrderProfit()+OrderCommission()+OrderSwap();
           if(Profit_Temp<0)
             {
             Buy_Loser++;
             Buy_Loss += Profit_Temp;
             }
           if(Profit_Temp>=0)
             {
             Buy_Winner++;
             Buy_Profit += Profit_Temp;
             }
           Profit_Buy += Profit_Temp;
           }
           
           if(OrderMagicNumber()==MN_Aux)
           {
           Pos_Open++;
           Aux_Position++;
           Profit_Temp = OrderProfit()+OrderCommission()+OrderSwap();
           Profit_Aux += Profit_Temp;
           if(ORDER_TYPE==OP_BUY)
             Aux_Direction=1;
           if(ORDER_TYPE==OP_SELL)
             Aux_Direction=-1;
           }           
           
         }
      }
  }

if(Loaded==1 && Pos_Open==0)
  {
  Loaded=0;
  Buy_Signal=0;
  Sell_Signal=0;
  }

if(Time_Recorded+Zig_Zag_Back*30<Time[0])
{
for(i=1; i<=Zig_Zag_Back; i++)
  {
  Zig_Zag_Value=ZigZag(i);
  if(Zig_Zag_Value==0)
    continue;
  //Print(Zig_Zag_Value);
  if(Zig_Zag_Value!=0 && ZZ_Increment_GO==0)
    {
    ZZ_Collect[0][0]=Zig_Zag_Value;
    ZZ_Collect[0][1]=i;
    ZZ_Increment_GO=1;
    continue;
    }
  if(Zig_Zag_Value!=0 && ZZ_Increment_GO!=0)
    {
    ZZ_Collect[ZZ_Increment_GO][0]=Zig_Zag_Value;
    ZZ_Collect[ZZ_Increment_GO][1]=i;
    ZZ_Increment_GO++;
    continue;
    }
  }
//Print(ZZ_Increment_GO);

//----

for(i=1; i<=ZZ_Increment_GO; i++)
{
if(ZZ_Collect[i][0]>ZZ_Collect[i+1][0] && ZZ_Collect[i+1][0]<ZZ_Collect[i+2][0] && ZZ_Collect[i][0]>ZZ_Collect[i+2][0])
  {
  //Print("Div_Bear");
  ZZ_RSI_T0=iRSI(Symbol() , Period(), 14, PRICE_CLOSE, ZZ_Collect[i][1]);
  ZZ_RSI_T1=iRSI(Symbol() , Period(), 14, PRICE_CLOSE, ZZ_Collect[i+2][1]);
  if(ZZ_RSI_T1>ZZ_RSI_T0 && ZZ_RSI_T1>70)
    {
    Target=ZZ_Collect[i+1][0];
    Invalidation=ZZ_Collect[i][0];
    Sell_Signal++;
    }
  else
    continue;
  }
  
if(ZZ_Collect[i][0]<ZZ_Collect[i+1][0] && ZZ_Collect[i+1][0]>ZZ_Collect[i+2][0] && ZZ_Collect[i][0]<ZZ_Collect[i+2][0])
  {
  //Print("Div_Bull");
  ZZ_RSI_T0=iRSI(Symbol() , Period(), 14, PRICE_CLOSE, ZZ_Collect[i][1]);
  ZZ_RSI_T1=iRSI(Symbol() , Period(), 14, PRICE_CLOSE, ZZ_Collect[i+2][1]);
  if(ZZ_RSI_T1<ZZ_RSI_T0 && ZZ_RSI_T1<30)
    {
    Target=ZZ_Collect[i+1][0];
    Invalidation=ZZ_Collect[i][0];
    Buy_Signal++;
    }
  }
}

Time_Recorded=Time[0];

}

//-- Lot Computation

static double Lot_Size_Adjusted=0;
int LotsDigit=0;
double MinLots=0, MaxLots=0, AcFrMar=0, Step=0, One_Lot=0;

if(Money_Management==0)
   Lot_Size_Adjusted=Lot_Size;

if(Money_Management==1 && Pos_Open==0)
   {
   if(MarketInfo(Symbol(),MODE_MINLOT) == 0.1)
     LotsDigit=1;
   else if(MarketInfo(Symbol(),MODE_MINLOT) == 0.01)
     LotsDigit=2;
     
   One_Lot=MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   
   Step=MarketInfo(Symbol(),MODE_LOTSTEP);
   
   MinLots=NormalizeDouble(MarketInfo(Symbol(),MODE_MINLOT),LotsDigit);
   MaxLots=NormalizeDouble(MarketInfo(Symbol(),MODE_MAXLOT),LotsDigit);
   
   AcFrMar=NormalizeDouble(AccountFreeMargin(),2);
   
   Lot_Size_Adjusted=MathFloor(AcFrMar*Margin_Percent/100/One_Lot/Step)*Step;

   if(Lot_Size_Adjusted>MaxLots)
     Lot_Size_Adjusted=MaxLots;
   if(Lot_Size_Adjusted<MinLots)
     Lot_Size_Adjusted=MinLots; 
   }

int Order_Number=0, Order_Number_2=0;

if(Buy_Signal>Sell_Signal && CheckStopLoss_Takeprofit(OP_BUY, 0, 0) && Pos_Open<Max_Orders)
  {
  for(i=0; i<Retry; i++)
      {
      Order_Number=-1;
      RefreshRates();
      Order_Number=OrderSend(_Symbol,OP_BUY,Lot_Size_Adjusted,MarketInfo(_Symbol,MODE_ASK),Slippage ,0 ,0, NULL,MN_Buy_Original,0,Blue);
      if(Order_Number_2>=0)
        break;
      }
  Print("BUY = ", Buy_Signal, "/ SELL = ", Sell_Signal);
  Buy_Signal=0;
  Sell_Signal=0;
  Loaded=1;
  //Time_Recorded=Time[0];
  }

if(Sell_Signal>Buy_Signal && CheckStopLoss_Takeprofit(OP_SELL, 0, 0) && Pos_Open<Max_Orders)
  {
  for(i=0; i<Retry; i++)
      {
      Order_Number=-1;
      RefreshRates();
      Order_Number=OrderSend(_Symbol,OP_SELL,Lot_Size_Adjusted,MarketInfo(_Symbol,MODE_BID),Slippage ,0 , 0,NULL,MN_Sell_Original,0,Red);
      if(Order_Number_2>=0)
        break;
      }
  Print("BUY = ", Buy_Signal, "/ SELL = ", Sell_Signal);
  Buy_Signal=0;
  Sell_Signal=0;
  Loaded=1;
  //Time_Recorded=Time[0];
  }

if(Counting!=Aux_Position)
  {
  //fPrint("Order cancellation ! Repopulating...");
  //Repopulate=1;
  a=-1;
  b=-1;
  Counting=Aux_Position;
  }

if(Neutralize==0 && Aux_Position!=0)
  {
  Neutralize=1;
  Print("Neutralization starting...");
  }

if(Neutralize>0 && Aux_Position==0)
  {
  Neutralize=0;
  Buy_Signal=0;
  Sell_Signal=0;
  Repopulate=1;
  Print("Neutralization over !");
  }

double Profit=0;
double Buy_Loss_Cached=0, Sell_Loss_Cached=0, Buy_Profit_Cached=0, Sell_Profit_Cached=0;
int Worst_Buy_Position=0, Worst_Sell_Position=0, Best_Buy_Position=0, Best_Sell_Position=0;
double Worst_Buy_Price=0, Worst_Sell_Price=0, Best_Buy_Price=0, Best_Sell_Price=0;
int pos=0, v=-1, w=-1, x=-1, y=-1, z=-1;
int index=0, Aux_Position_Ticket=0;

ResetOrderArray(Buy_Loss_Array, Buy_Profit_Array, Sell_Loss_Array, Sell_Profit_Array, Aux_Array);

static datetime Time_Cached;
static int WSP_Cached=0, WBP_Cached=0;
static int d=0, e=0;
double ATR_Bis=0;

if(iATR(_Symbol, Period(),100,10)!=0)
  ATR_Bis=(MathPow((iATR(_Symbol,Period(),10,0)/iATR(_Symbol,Period(),100,10)/10/_Point), Amplitude));

if(Repopulate==1)
  {
  ResetOrderArrayTarget(Aux_Array_Target);
  while(Aux_Array_Target[c][0]!=0 || Aux_Array_Target[c][1]!=0)
    {
    c++;
    }
  //fPrint("Reinitializing Array... c = " + c);
  d=0;
  e=0;
  Repopulate=0;
  }

Profit = Profit_Buy + Profit_Sell + Profit_Aux;

if(Profit<0 && Neutralizer==True)
{
for(pos=OrdersTotal()-1; pos>=0; pos--)
  {
  if(OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)==True)
    {
    
    if(OrderMagicNumber()==MN_Buy_Original)
    {
    Profit_Temp = OrderProfit()+OrderCommission()+OrderSwap();
    
    if(0>Profit_Temp)
      {
      Buy_Loss_Cached=NormalizeDouble(Profit_Temp,2);
      Worst_Buy_Position=OrderTicket();
      Worst_Buy_Price=OrderOpenPrice();
      w++;
      Buy_Loss_Array[w][0]=Worst_Buy_Position;
      Buy_Loss_Array[w][1]=Buy_Loss_Cached;
      if(Sell_Signal>Buy_Signal && d<Buy_Position && ((CountBuyPips()/CountBuyOrders()<-MathLog10(ATR_Bis)*Aux_Sell_Weight)))
        {
         
        ArraySort(Aux_Array_Target, WHOLE_ARRAY, 0, MODE_DESCEND);
        index=ArrayBsearch(Aux_Array_Target, Worst_Buy_Position, WHOLE_ARRAY, 0, MODE_DESCEND);
        
        if(Aux_Array_Target[index][0]!=Worst_Buy_Position)
        {
        
        //fPrint("Array Results : Index = " + index + " / Array Data = " + Aux_Array_Target[index][0] + " // Submitted = " + Worst_Buy_Position);
        
        a=index;
        
        while(Aux_Array_Target[a][0]!=0 && !IsStopped())
          {
          a++;
          }
        
        d++;
        Counting++;
        
        Aux_Array_Target[a][0]=Worst_Buy_Position;
        Aux_Array_Target[a][1]=0;
        //fPrint("Memorizing...");
        Time_Cached=OrderLaunch("SELL", 2, Aux_Array_Target, a);
        Sell_Signal=0;
        }
        
        }
      
      }
    
    if(0<Profit_Temp)
      {
      Buy_Profit_Cached=NormalizeDouble(Profit_Temp,2);
      Best_Buy_Position=OrderTicket();
      Best_Buy_Price=OrderOpenPrice();
      x++;
      Buy_Profit_Array[x][0]=Best_Buy_Position;
      Buy_Profit_Array[x][1]=Buy_Profit_Cached;

      }
    }
    
    if(OrderMagicNumber()==MN_Sell_Original)
    {
    Profit_Temp = OrderProfit()+OrderCommission()+OrderSwap();
    
    if(0>Profit_Temp)
      {
      Sell_Loss_Cached=NormalizeDouble(Profit_Temp,2);
      Worst_Sell_Position=OrderTicket();
      Worst_Sell_Price=OrderOpenPrice();
      y++;
      Sell_Loss_Array[y][0]=Worst_Sell_Position;
      Sell_Loss_Array[y][1]=Sell_Loss_Cached;
      if(Buy_Signal>Sell_Signal && e<Sell_Position && ((CountSellPips()/CountSellOrders()<-MathLog10(ATR_Bis)*Aux_Buy_Weight)))
        {
        
        ArraySort(Aux_Array_Target, WHOLE_ARRAY, 0, MODE_DESCEND);
        index=ArrayBsearch(Aux_Array_Target, Worst_Sell_Position, WHOLE_ARRAY, 0, MODE_DESCEND);
        
        if(Aux_Array_Target[index][0]!=Worst_Sell_Position)
        {
        
        //fPrint("Array Results : Index = " + index + " / Array Data = " + Aux_Array_Target[index][0] + " // Submitted = " + Worst_Sell_Position);
        
        b=index;
        
        while(Aux_Array_Target[b][0]!=0 && !IsStopped())
          {
          b++;
          }
        
        e++;
        Counting++;
        
        Aux_Array_Target[b][0]=Worst_Sell_Position;
        Aux_Array_Target[b][1]=0;
        //fPrint("Memorizing...");
        Time_Cached=OrderLaunch("BUY", 2, Aux_Array_Target, b);
        Buy_Signal=0;
        }
        
        }

      }
    
    if(0<Profit_Temp)
      {
      Sell_Profit_Cached=NormalizeDouble(Profit_Temp,2);
      Best_Sell_Position=OrderTicket();
      Best_Sell_Price=OrderOpenPrice();
      z++;
      Sell_Profit_Array[z][0]=Best_Sell_Position;
      Sell_Profit_Array[z][1]=Sell_Profit_Cached;

      }
    }
    
    if(OrderMagicNumber()==MN_Aux)
      {
      Profit_Temp = OrderProfit()+OrderCommission()+OrderSwap();
      Aux_Profit=NormalizeDouble(Profit_Temp,2);
      Aux_Position_Ticket=OrderTicket();
      v++;
      Aux_Array[v][0]=Aux_Position_Ticket;
      Aux_Array[v][1]=Aux_Profit;
      Aux_Profit += Profit_Temp;
      }
    
    }
  }
}

int u=0;
string Order_Ticket_Proxy;
double Temp_Loss=0, Temp_Win=0, Temp_Equal=0, Temp_Aux=0;
double Loss_Cached=0, Aux_Cached=0, Loss_Sell_Cached=10000, Loss_Buy_Cached=10000;
string Loss_Buy_Ticket_Cached, Loss_Sell_Ticket_Cached, Loss_Ticket_Cached, Win_Ticket_Cached, Aux_Ticket_Cached;

if(Neutralize==1)// && Lyapunov(1)>0)
  {

  Loss_Buy_Cached=0;
  Loss_Sell_Cached=0;
  Aux_Cached=0;
  
  ArraySort(Buy_Loss_Array, WHOLE_ARRAY, 0, MODE_ASCEND);
  ArraySort(Sell_Loss_Array, WHOLE_ARRAY, 0, MODE_ASCEND);
  ArraySort(Aux_Array, WHOLE_ARRAY, 0, MODE_DESCEND);  
  
  for(u=0; u<MaxPos*4; u++)
    {
    Temp_Loss=Buy_Loss_Array[u][1];
    if(Temp_Loss<Loss_Buy_Cached)
      {
      Loss_Buy_Cached=Temp_Loss;
      Loss_Buy_Ticket_Cached=DoubleToStr(Buy_Loss_Array[u][0],0);
      }

    Temp_Loss=Sell_Loss_Array[u][1];
    if(Temp_Loss<Loss_Sell_Cached)
      {
      Loss_Sell_Cached=Temp_Loss;
      Loss_Sell_Ticket_Cached=DoubleToStr(Sell_Loss_Array[u][0],0);
      }
    
    Temp_Aux=Aux_Array[u][1];
    if(Temp_Aux>Aux_Cached)
      {
      Aux_Cached=Temp_Aux;
      Aux_Ticket_Cached=DoubleToStr(Aux_Array[u][0],0);
      }
    }
    
  if(OrderSelect(StrToInteger(Aux_Ticket_Cached), SELECT_BY_TICKET, MODE_TRADES)==True)
      if(OrderMagicNumber()==MN_Aux)
      {
      Aux_Profit=OrderProfit()+OrderCommission()+OrderSwap();
      Order_Ticket_Proxy=IntegerToString(OrderTicket());
      if(OrderType()==OP_BUY && Aux_Profit+Loss_Sell_Cached>=0)
        {
        //fPrint("Closing Neutralizer... #" + Loss_Sell_Ticket_Cached + " #" + Order_Ticket_Proxy);
        CloseSelected(Loss_Sell_Ticket_Cached, Retry);
        CloseSelected(Order_Ticket_Proxy, Retry);
        return(0);
        }
      if(OrderType()==OP_SELL && Aux_Profit+Loss_Buy_Cached>=0)
        {
        //fPrint("Closing Neutralizer... #" + Loss_Buy_Ticket_Cached + " #" + Order_Ticket_Proxy);
        CloseSelected(Loss_Buy_Ticket_Cached, Retry);
        CloseSelected(Order_Ticket_Proxy, Retry);
        return(0);
        }
      }
  }

if(Neutralize==0 && Sell_Profit!=0 && Buy_Loss!=0 && Sell_Profit>MathAbs(Buy_Loss))// && x>w)
  {
  
  ArraySort(Buy_Loss_Array, WHOLE_ARRAY, 0, MODE_ASCEND);
  ArraySort(Sell_Profit_Array, WHOLE_ARRAY, 0, MODE_DESCEND);
  
  for(u=0; u<MaxPos*4; u++)
    {
      
      if(Buy_Loss_Array[u][0]==0)
        continue;
      Temp_Loss=Buy_Loss_Array[u][1];
      if(Temp_Loss<Loss_Cached)
        {
        Loss_Cached=Temp_Loss;
        Loss_Ticket_Cached=DoubleToStr(Buy_Loss_Array[u][0],0);
        continue;
        }
      
    }
  
  //fPrint(Loss_Ticket_Cached + " " + DoubleToStr(Loss_Cached, 2));
  if(CloseSelected(Loss_Ticket_Cached, Retry)==True)
    Temp_Equal=Loss_Cached;
  
  for(u=0; u<MaxPos*4; u++)
    {
      if(Sell_Profit_Array[u][0]==0)
        continue;
      Temp_Win=Sell_Profit_Array[u][1];
      Win_Ticket_Cached=DoubleToStr(Sell_Profit_Array[u][0],0);
      if(Temp_Equal<0)
        {
        //fPrint("Follow Through... " + DoubleToStr(Temp_Win,2));
        if(CloseSelected(Win_Ticket_Cached, Retry)==True)
          Temp_Equal += Temp_Win;
        else
          Print("Error");
        }
      if(Temp_Equal>=0)
        break;
      
    }
  Temp_Equal=0;
  }

if(Neutralize==0 && Sell_Loss!=0 && Buy_Profit!=0 && MathAbs(Sell_Loss)<Buy_Profit)// && z>y)
  {
  
  ArraySort(Sell_Loss_Array, WHOLE_ARRAY, 0, MODE_ASCEND);
  ArraySort(Buy_Profit_Array, WHOLE_ARRAY, 0, MODE_DESCEND);
  
  for(u=0; u<MaxPos*4; u++)
    {
      
      if(Sell_Loss_Array[u][0]==0)
        continue;
      Temp_Loss=Sell_Loss_Array[u][1];
      if(Temp_Loss<Loss_Cached)
        {
        Loss_Cached=Temp_Loss;
        Loss_Ticket_Cached=DoubleToStr(Sell_Loss_Array[u][0],0);
        continue;
        }
      
    }
  
  //fPrint(Loss_Ticket_Cached + " " + DoubleToStr(Loss_Cached,2));
  if(CloseSelected(Loss_Ticket_Cached, Retry)==True)
    Temp_Equal=Loss_Cached;
  
  for(u=0; u<MaxPos*4; u++)
    {
      if(Buy_Profit_Array[u][0]==0)
        continue;
      Temp_Win=Buy_Profit_Array[u][1];
      Win_Ticket_Cached=DoubleToStr(Buy_Profit_Array[u][0],0);
      if(Temp_Equal<0)
        {
        //fPrint("Follow Through... " + DoubleToStr(Temp_Win,2));
        if(CloseSelected(Win_Ticket_Cached, Retry)==True)
          Temp_Equal += Temp_Win;
        else
          Print("Error");
        }
      if(Temp_Equal>=0)
        break;
      
    }
  Temp_Equal=0;
  }

double Lot_Size_Empowered=0;

if(Neutralize==1 && ((Profit_Buy!=0 && Profit_Aux<Profit_Buy) || (Profit_Sell!=0 && Profit_Aux<Profit_Sell) || (Buy_Position==0 && Sell_Position==0)))
  {
  if(Profit_Buy!=0 && Profit_Aux*2<Profit_Buy/2 && Buy_Signal!=0)
    {
    Lot_Size_Empowered=(Buy_Position+Aux_Position)*4*Lot_Size;
    for(i=0; i<Retry; i++)
          {
          RefreshRates();
          Order_Number=-1;
          Order_Number=OrderSend(_Symbol,OP_BUY,Lot_Size_Empowered,MarketInfo(_Symbol,MODE_ASK),Slippage,0,0,NULL,MN_Aux,0,Gold);
          if(Order_Number>0)
            {
            if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
              {
              //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Buy,TP_Buy,0,Red);
              }
            break;
            }
          }
    Buy_Signal=0;
    Neutralize=2;
    }
  if(Profit_Sell!=0 && Profit_Aux*2<Profit_Sell/2 && Sell_Signal!=0)
    {
    Lot_Size_Empowered=(Sell_Position+Aux_Position)*4*Lot_Size;
    for(i=0; i<Retry; i++)
          {
          RefreshRates();
          Order_Number=-1;
          Order_Number=OrderSend(_Symbol,OP_SELL,Lot_Size_Empowered,MarketInfo(_Symbol,MODE_BID),Slippage,0,0,NULL,MN_Aux,0,Gold);
          if(Order_Number>0)
            {
            if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
              {
              //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Buy,TP_Buy,0,Red);
              }
            break;
            }
          }
    Sell_Signal=0;
    Neutralize=2;
    }
  if(Buy_Position==0 && Sell_Position==0)
   {
   if(Aux_Direction==1)// && Sell_Signal!=0)
     {
     Lot_Size_Empowered=(Aux_Position*4)*Lot_Size;
     for(i=0; i<Retry; i++)
          {
          RefreshRates();
          Order_Number=-1;
          Order_Number=OrderSend(_Symbol,OP_SELL,Lot_Size_Empowered,MarketInfo(_Symbol,MODE_BID),Slippage,0,0,NULL,MN_Aux,0,Gold);
          if(Order_Number>0)
            {
            if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
              {
              //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Buy,TP_Buy,0,Red);
              }
            break;
            }
          }
     Neutralize=2;
     }
   if(Aux_Direction==-1)// && Buy_Signal!=0)
     {
     Lot_Size_Empowered=(Aux_Position*4)*Lot_Size;
     for(i=0; i<Retry; i++)
          {
          RefreshRates();
          Order_Number=-1;
          Order_Number=OrderSend(_Symbol,OP_BUY,Lot_Size_Empowered,MarketInfo(_Symbol,MODE_ASK),Slippage,0,0,NULL,MN_Aux,0,Gold);
          if(Order_Number>0)
            {
            if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
              {
              //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Buy,TP_Buy,0,Red);
              }
            break;
            }
          }
     Neutralize=2;
     }
   }
  }

if(Neutralize>0 && Profit>=0)
  {
  while (CloseAll() == AT_LEAST_ONE_FAILED)
   {
      Sleep(1000);
      //Alert("Order close failed - retrying error#: ", GetLastError());
   }
  }

//----
return(0);
}
//+------------------------------------------------------------------

double ZigZag(int l)
{

   double ExtHighBuffer[];
   double ExtLowBuffer[];
   double ExtZigzagBuffer[];

//----
   int NewSize=Zig_Zag_Back+1;

//---- Set the direct indexing direction in the array 
   ArraySetAsSeries(ExtZigzagBuffer,false);
   ArraySetAsSeries(ExtHighBuffer,false);
   ArraySetAsSeries(ExtLowBuffer,false);
//---- Change the size of the emulated indicator buffers 
   ArrayResize(ExtZigzagBuffer,NewSize);
   ArrayResize(ExtHighBuffer,NewSize);
   ArrayResize(ExtLowBuffer,NewSize);
//---- Set the reverse indexing direction in the array 
   ArraySetAsSeries(ExtZigzagBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);

//--- globals
   int ExtLevel=3; // recounting's depth of extremums
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int    i=0,limit,counterZ,whatlookfor=0;
   int    back,pos,lasthighpos=0,lastlowpos=0;
   double extremum;
   double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;
//--- check for history and inputs
   if(Zig_Zag_Back<ExtDepth || ExtBackstep>=ExtDepth)
      return(0);
//--- first calculations
   ArrayInitialize(ExtZigzagBuffer,0.0);
   ArrayInitialize(ExtHighBuffer,0.0);
   ArrayInitialize(ExtLowBuffer,0.0);
//--- first calculations
   i=counterZ=0;
//--- set start position to found extremum position
   limit=Zig_Zag_Back-ExtDepth;
   if(limit>Bars)
      limit=Bars-1;
//--- main loop      
   for(i=limit; i>=0; i--)
     {
      //--- find lowest low in depth of bars
      extremum=Low[iLowest(NULL,0,MODE_LOW,ExtDepth,i)];
      //--- this lowest has been found previously
      if(extremum==lastlow)
         extremum=0.0;
      else
        {
         //--- new last low
         lastlow=extremum;
         //--- discard extremum if current low is too high
         if(Low[i]-extremum>ExtDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=ExtBackstep; back++)
              {
               pos=i+back;
               if(ExtLowBuffer[pos]!=0 && ExtLowBuffer[pos]>extremum)
                  ExtLowBuffer[pos]=0.0;
              }
           }
        }
      //--- found extremum is current low
      if(Low[i]==extremum)
         ExtLowBuffer[i]=extremum;
      else
         ExtLowBuffer[i]=0.0;
      //--- find highest high in depth of bars
      extremum=High[iHighest(NULL,0,MODE_HIGH,ExtDepth,i)];
      //--- this highest has been found previously
      if(extremum==lasthigh)
         extremum=0.0;
      else
        {
         //--- new last high
         lasthigh=extremum;
         //--- discard extremum if current high is too low
         if(extremum-High[i]>ExtDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=ExtBackstep; back++)
              {
               pos=i+back;
               if(ExtHighBuffer[pos]!=0 && ExtHighBuffer[pos]<extremum)
                  ExtHighBuffer[pos]=0.0;
              }
           }
        }
      //--- found extremum is current high
      if(High[i]==extremum)
         ExtHighBuffer[i]=extremum;
      else
         ExtHighBuffer[i]=0.0;
     }
//--- final cutting 
   if(whatlookfor==0)
     {
      lastlow=0.0;
      lasthigh=0.0;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
   for(i=limit; i>=0; i--)
     {
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if(lastlow==0.0 && lasthigh==0.0)
              {
               if(ExtHighBuffer[i]!=0.0)
                 {
                  lasthigh=High[i];
                  lasthighpos=i;
                  whatlookfor=-1;
                  ExtZigzagBuffer[i]=lasthigh;
                 }
               if(ExtLowBuffer[i]!=0.0)
                 {
                  lastlow=Low[i];
                  lastlowpos=i;
                  whatlookfor=1;
                  ExtZigzagBuffer[i]=lastlow;
                 }
              }
            break;
         case 1: // look for peak
            if(ExtLowBuffer[i]!=0.0 && ExtLowBuffer[i]<lastlow && ExtHighBuffer[i]==0.0)
              {
               ExtZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=i;
               lastlow=ExtLowBuffer[i];
               ExtZigzagBuffer[i]=lastlow;
              }
            if(ExtHighBuffer[i]!=0.0 && ExtLowBuffer[i]==0.0)
              {
               lasthigh=ExtHighBuffer[i];
               lasthighpos=i;
               ExtZigzagBuffer[i]=lasthigh;
               whatlookfor=-1;
              }
            break;
         case -1: // look for lawn
            if(ExtHighBuffer[i]!=0.0 && ExtHighBuffer[i]>lasthigh && ExtLowBuffer[i]==0.0)
              {
               ExtZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=i;
               lasthigh=ExtHighBuffer[i];
               ExtZigzagBuffer[i]=lasthigh;
              }
            if(ExtLowBuffer[i]!=0.0 && ExtHighBuffer[i]==0.0)
              {
               lastlow=ExtLowBuffer[i];
               lastlowpos=i;
               ExtZigzagBuffer[i]=lastlow;
               whatlookfor=1;
              }
            break;
        }
     }
//--- done
   return(ExtZigzagBuffer[l]);
  
}

bool CheckMoneyForTrade(string symb,double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type, lots);
   //-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      //fPrint("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   //--- checking successful
   return(true);
  }

bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type, double SL, double TP)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
//---
   bool SL_check=false,TP_check=false;
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         SL_check=(Bid-SL>stops_level*10*_Point);
         if(SL==0)
           SL_check=True;
         //--- check the TakeProfit
         TP_check=(TP-Bid>stops_level*10*_Point);
         if(TP==0)
           TP_check=True;
         //--- return the result of checking
         return(SL_check&&TP_check);
        }
      //--- Sell operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         SL_check=(SL-Ask>stops_level*10*_Point);
         if(SL==0)
           SL_check=True;
         //--- check the TakeProfit
         TP_check=(Ask-TP>stops_level*10*_Point);
         if(TP==0)
           TP_check=True;
         //--- return the result of checking
         return(TP_check&&SL_check);
        }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
  }
  
void TrailingAlls(int trail, int k)
  {
   if(trail==0)
      return;
//----
   double stopcal=0;
   int trade=0;
   int trades=OrdersTotal();
   double profitcalc=0;
   bool Order_Modif=False;
   
   for(trade=0;trade<trades;trade++)
     {
      if(OrderSelect(trade,SELECT_BY_POS,MODE_TRADES)==False)
        {
        Print("Select Failed");
        continue;
        }
      if(OrderSelect(trade,SELECT_BY_POS,MODE_TRADES)==True)
      {
      if(OrderSymbol()==Symbol())
         {
         //continue;
         //LONG
         if(OrderType()==OP_BUY && (OrderMagicNumber()==MN_Buy_Original))// && OrderStopLoss()>=OrderOpenPrice())
           {
            //Print("Number = " + trade);
            if(OrderStopLoss()<OrderOpenPrice() && Bid>OrderOpenPrice()+(trail*k*_Point) && CheckStopLoss_Takeprofit(OP_BUY,OrderOpenPrice(),OrderTakeProfit()))
              {
              Order_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue);
              Print("BE BUY");
              continue;
              }
            stopcal=NormalizeDouble((OrderStopLoss()+(trail*k*_Point)), _Digits);
            profitcalc=OrderTakeProfit();
               if(OrderStopLoss()>=OrderOpenPrice() && stopcal<Bid && CheckStopLoss_Takeprofit(OP_BUY,stopcal,profitcalc))
                 {
                  Order_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()+(trail/2*k*Point), _Digits),profitcalc,0,Blue);
                  if(Order_Modif==False)
                    Print("Modif failed");
                  //continue;
                 }
           }//LONG
         //Shrt
         if(OrderType()==OP_SELL && (OrderMagicNumber()==MN_Sell_Original))// && OrderStopLoss()<=OrderOpenPrice())
           { 
            //Print("Number = " + trade);
            if(OrderStopLoss()==0 && Ask<OrderOpenPrice()-(trail*k*_Point) && CheckStopLoss_Takeprofit(OP_SELL,OrderOpenPrice(),OrderTakeProfit()))
              {
              Order_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue);
              Print("BE SELL");
              continue;
              }
            stopcal=NormalizeDouble((OrderStopLoss()-(trail*k*_Point)), _Digits);
            profitcalc=OrderTakeProfit();
               if(OrderStopLoss()<=OrderOpenPrice() && stopcal>Ask && CheckStopLoss_Takeprofit(OP_SELL,stopcal,profitcalc))
                 {
                  Order_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()-(trail/2*k*Point), _Digits),profitcalc,0,Red);
                  if(Order_Modif==False)
                    Print("Modif failed");
                  //continue;
                 }
           }
         }
      }  
     }//Shrt

   }
  
void ResetOrderArray(double &Buy_Loss_Array[][],double &Buy_Profit_Array[][],double &Sell_Loss_Array[][],double &Sell_Profit_Array[][], double &Aux_Array[][]) {
   
 for(int h=0; h<2; h++)  
   for(int k=0; k<MaxPos*4; k++)
      {
      Buy_Loss_Array[k][h]=0;
      Buy_Profit_Array[k][h]=0;
      Sell_Loss_Array[k][h]=0;
      Sell_Profit_Array[k][h]=0;
      Aux_Array[k][h]=0;
      }

}
//--

void ResetOrderArrayTarget(double &Aux_Array_Target[][]) {
   
 for(int h=0; h<2; h++)  
   for(int k=0; k<MaxPos*4; k++)
      {
      Aux_Array_Target[k][h]=0;
      }

}

//--

datetime OrderLaunch(string Action, int mode, double &Aux_Array_Target[][], int a)

{

//-- Point Value

int k=0;

if(Digits==5 || Digits==3)
  k=10;
else
  k=1;

//-- Lot Computation

double Lot_Size_Adjusted=0;
int LotsDigit=0, Trade_Allowed=0;
double MinLots=0, MaxLots=0, AcFrMar=0, Step=0, One_Lot=0;

MinLots=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
MaxLots=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);

Lot_Size_Adjusted=Lot_Size;
   
if(Lot_Size_Adjusted>MaxLots)
  Lot_Size_Adjusted=MaxLots;
if(Lot_Size_Adjusted<MinLots)
  Lot_Size_Adjusted=MinLots;

if(mode==2)
  Lot_Size_Adjusted *= 5;

if(Action=="SELL")
  {
  if(CheckMoneyForTrade(_Symbol, Lot_Size_Adjusted, OP_SELL)==True)
    Trade_Allowed=1;
  else
    return(0);
  }

if(Action=="BUY")
  {
  if(CheckMoneyForTrade(_Symbol, Lot_Size_Adjusted, OP_BUY)==True)
    Trade_Allowed=1;
  else
    return(0);
  }

//-- Set Stop Loss

double SL_Value=0;
static double SL_Sell=0, SL_Buy=0;
static double TP_Sell=0, TP_Buy=0;

double SL_Value_Min=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;

  if(Action=="SELL" && mode==1)
    {
    TP_Sell=0;//NormalizeDouble(MarketInfo(_Symbol,MODE_ASK)-SL_Value*1,_Digits);
    SL_Sell=0;//NormalizeDouble(MarketInfo(_Symbol,MODE_ASK)+SL_Value*75,_Digits);
    }
  if(Action=="BUY" && mode==1)
    {
    TP_Buy=0;//NormalizeDouble(MarketInfo(_Symbol,MODE_BID)+SL_Value*1,_Digits);
    SL_Buy=0;//NormalizeDouble(MarketInfo(_Symbol,MODE_BID)-SL_Value*75,_Digits);
    }
    
  if(Action=="SELL" && mode==2)
    {
    TP_Sell=0;
    SL_Sell=0;//NormalizeDouble(MarketInfo(_Symbol,MODE_ASK)+SL_Value*50,_Digits);
    }
  if(Action=="BUY" && mode==2)
    {
    TP_Buy=0;
    SL_Buy=0;//NormalizeDouble(MarketInfo(_Symbol,MODE_BID)-SL_Value*50,_Digits);
    }

//-- Opening Process

int i=0, j=0;
bool Order_Modificator=False;
int Order_Number=0;
datetime Time_Cached=0;

  if(Action=="SELL" && mode==1)
    {
    for(i=0; i<Retry; i++)
      {
      RefreshRates();
      Order_Number=OrderSend(_Symbol,OP_SELL,Lot_Size_Adjusted,MarketInfo(_Symbol,MODE_BID),Slippage,0,0,NULL,MN_Sell_Original,0,Red);
      if(Order_Number>0)
        {
        if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
          {
          //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Sell,TP_Sell,0,Red);
          }
        break;
        }
      }
    }
  if(Action=="SELL" && mode==2)
    {
    for(j=a; j>=0; j--)
      {
      if(Aux_Array_Target[j][1]==0 && Aux_Array_Target[j][0]!=0)
        {
        for(i=0; i<Retry; i++)
          {
          RefreshRates();
          Order_Number=OrderSend(_Symbol,OP_SELL,Lot_Size_Adjusted,MarketInfo(_Symbol,MODE_BID),Slippage,0,0,NULL,MN_Aux,0,Gold);
          if(Order_Number>0)
            {
            if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
              {
              //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Sell,TP_Sell,0,Red);
              }
            break;
            }
          }
        Aux_Array_Target[j][1]=1;
        }
      }
    }  

  if(Action=="BUY" && mode==1)
    {
    for(i=0; i<Retry; i++)
      {
      RefreshRates();
      Order_Number=-1;
      Order_Number=OrderSend(_Symbol,OP_BUY,Lot_Size_Adjusted,MarketInfo(_Symbol,MODE_ASK),Slippage,0,0,NULL,MN_Buy_Original,0,Blue);
      if(Order_Number>0)
        {
        if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
          {
          //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Buy,TP_Buy,0,Red);
          }
        break;
        }
      }
    }
  if(Action=="BUY" && mode==2)
    {
    for(j=a; j>=0; j--)
      {
      if(Aux_Array_Target[j][1]==0 && Aux_Array_Target[j][0]!=0)
        {
        for(i=0; i<Retry; i++)
          {
          RefreshRates();
          Order_Number=-1;
          Order_Number=OrderSend(_Symbol,OP_BUY,Lot_Size_Adjusted,MarketInfo(_Symbol,MODE_ASK),Slippage,0,0,NULL,MN_Aux,0,Gold);
          if(Order_Number>0)
            {
            if(OrderSelect(Order_Number,SELECT_BY_TICKET)==True)
              {
              //Order_Modificator=OrderModify(OrderTicket(),OrderOpenPrice(),SL_Buy,TP_Buy,0,Red);
              }
            break;
            }
          }
        Aux_Array_Target[j][1]=1;
        }
      }
    }
    
  Time_Cached=iTime(_Symbol, _Period, 0);
  return(Time_Cached);
  
}

//--

bool CloseSelected(string ticket, int _Retry)
  {
  
  bool Closing_Order=False;
  int i=0;
  RefreshRates();
  
  if(OrderSelect(StrToInteger(ticket),SELECT_BY_TICKET,MODE_TRADES)==True)
    {
    if(OrderMagicNumber()==MN_Buy_Original)
      if(OrderType()==OP_BUY)
        for(i=0; i<_Retry; i++)
          {
          Closing_Order=OrderClose(OrderTicket(),OrderLots(),MarketInfo(_Symbol,MODE_BID),0,Red);
          if(Closing_Order==True)
            break;
          }
    if(OrderMagicNumber()==MN_Sell_Original)
      if(OrderType()==OP_SELL)
        for(i=0; i<_Retry; i++)
          {
          Closing_Order=OrderClose(OrderTicket(),OrderLots(),MarketInfo(_Symbol,MODE_ASK),0,Red);
          if(Closing_Order==True)
            break;
          }
    if(OrderMagicNumber()==MN_Aux)
      {
      if(OrderType()==OP_BUY)
        for(i=0; i<_Retry; i++)
          {
          Closing_Order=OrderClose(OrderTicket(),OrderLots(),MarketInfo(_Symbol,MODE_BID),0,Red);
          if(Closing_Order==True)
            break;
          }
      if(OrderType()==OP_SELL)
        for(i=0; i<_Retry; i++)
          {
          Closing_Order=OrderClose(OrderTicket(),OrderLots(),MarketInfo(_Symbol,MODE_ASK),0,Red);
          if(Closing_Order==True)
            break;
          }
      }
      
    return(True);
    }
  else
    return(False);
  
  }

//---

int CloseAll()
{ 
   bool rv = NO_ERROR;
   int numOfOrders = OrdersTotal();
   int FirstOrderType = 0;
   int index = 0;
   bool Selection;
   
   for (index = 0; index < OrdersTotal(); index++)   
     {
       Selection=OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
       if (OrderSymbol() == Symbol()) 
       {
         FirstOrderType = OrderType();
         break;
       }
     }   
         
   for(index = numOfOrders - 1; index >= 0; index--)
   {
      Selection=OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
      
      if (OrderSymbol() == Symbol())
      switch (OrderType())
      {
         case OP_BUY: 
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slippage, Red))
               rv = AT_LEAST_ONE_FAILED;
            break;

         case OP_SELL:
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slippage, Red))
               rv = AT_LEAST_ONE_FAILED;
            break;

         case OP_BUYLIMIT: 
         case OP_SELLLIMIT:
         case OP_BUYSTOP: 
         case OP_SELLSTOP:
            if (!OrderDelete(OrderTicket()))
               rv = AT_LEAST_ONE_FAILED;
            break;
      }
   }

   return(rv);
}

int CountBuyOrders()
  {
   int count= 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MN_Buy_Original) && OrderType()==OP_BUY)
            count++;
        }
     }
   return(count);
  }
  
double CountBuyPips()
  {
  double pips=0, lots_total=0, pips_weighted=0;
  int k = 1;
  if(_Digits==3 || _Digits==5)
    k=10;
  else
    k=1;
  for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MN_Buy_Original) && OrderType()==OP_BUY)
           {
           pips_weighted += ((OrderOpenPrice()-Bid)/k/_Point);
           //lots_total += OrderLots();
           }
        }
     }
  pips = pips_weighted;
  if(pips<=0)
    pips=MathAbs(pips);
  if(pips>0)
    pips=0-pips;
  return(pips);
  }
  
//+------------------------------------------------------------------+
//| Opened sell orders calculation                                    |
//+------------------------------------------------------------------+
int CountSellOrders()
  {
   int count= 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MN_Sell_Original) && OrderType()==OP_SELL)
            count++;
        }
     }
   return(count);
  }
  
double CountSellPips()
  {
  double pips=0, lots_total=0, pips_weighted=0;
  int k = 1;
  if(_Digits==3 || _Digits==5)
    k=10;
  else
    k=1;
  for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MN_Sell_Original) && OrderType()==OP_SELL)
           {
           pips_weighted += ((OrderOpenPrice()-Ask)/k/_Point);
           //lots_total += OrderLots(); 
           }
        }
     }
  pips = pips_weighted;    
  return(pips);
  }

//+------------------------------------------------------------------+
//| Opened aux orders calculation                                    |
//+------------------------------------------------------------------+
int CountAuxOrders()
  {
   int count= 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MN_Aux))
            count++;
        }
     }
   return(count);
  }