//+------------------------------------------------------------------+
//|                                       yasser.mohamed_EA1_AR1.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "samir arman Copyright 2017,"
#property link      "samir_arman@yahoo.com"
#property version   "1.00"
#property strict


input bool OP_BUY_=true;
input bool OP_SELL_=false;

extern double Lot1=0.1;
extern bool Auto_Lots=false;
extern double  MaxRisk = 0.01;     
extern int  TakeProfit=50;
extern int StopLoss=50;
extern double win_USD=0;

 extern string Time_Start="00:00";
extern string Time_End="23:59"; 
input string Multiplication_info = "0=1,1,1,1....    1=1,2,3,5,8....    2=1,2,4,8,16....    3=1,3,9,27....";
extern double Multiplication_Mode = 2;
extern int MagicNumber=678;
 datetime T_1,T_2,TB,TS,TD,TTM;
int movestopto=1;

double pt;
string nam_B,nam_S;
double Price_S,Price_B,lot;
 string T;double pr,L,LOT;
 color color_pofet,clr;
 int lastorder;
 int OP,Type,M,NS,NB,XX,XX2;
 double BUY,SELL;
 double LB1,lotall;
int OnInit()
  {
if(Digits==5||Digits==4) 
{ 
pt=0.0001; 
} 
else{ 
pt=0.01; 
}
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  double hour=Hour()+Minute()/100.0;
  datetime start_= StrToTime(TimeToStr(TimeCurrent(), TIME_DATE) + " " + Time_Start);
  datetime end= StrToTime(TimeToStr(TimeCurrent(), TIME_DATE) + " " + Time_End);
  bool time=(Time[0]>=start_ && Time[0]<=end); 
  bool end_time=(Time[0]>=end); 


   


 

 
    if(((TotalLostOrders(OP_SELL)<=0&&OP_SELL_)||(OP_SELL_==false&&TotalLostOrders2(OP_SELL)>0))&&time&&ordestotal1_2(OP_BUY)==0&&ordestotal1_2(OP_SELL)==0&&T_1!=Time[0]){//lastorder!=-1lastorder=-1;
    open(OP_SELL,Lots(MaxRisk),Bid,TakeProfit,StopLoss) ;
    T_1=Time[0];
  }
  
  
  
  
if(((TotalLostOrders(OP_BUY)<=0&&OP_BUY_)||(OP_BUY_==false&&TotalLostOrders2(OP_BUY)>0))&&time&&ordestotal1_2(OP_BUY)==0&&ordestotal1_2(OP_SELL)==0&&T_2!=Time[0]){//&&lastorder!=1lastorder=1;//
open(OP_BUY,Lots(MaxRisk),Ask,TakeProfit,StopLoss);
T_2=Time[0];
    }
    
  



 for(int m=0;m<OrdersHistoryTotal();m++){
  if(OrderSelect(m,SELECT_BY_POS,MODE_HISTORY))
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()== MagicNumber){
    lotall=OrderLots();Type=OrderType();
   } 
 }
  





if(Multiplication_Mode==0)LB1=Lots(MaxRisk);

 if(Multiplication_Mode==1)LB1=lotall+Lots(MaxRisk);

if(Multiplication_Mode>1)LB1=lotall*Multiplication_Mode;






 
 if(Type==OP_SELL&&TotalLostOrders(OP_SELL)>0&&time&&ordestotal1_2(OP_BUY)==0&&ordestotal1_2(OP_SELL)==0){
  open(OP_BUY,LB1,Ask,TakeProfit,StopLoss) ;
  }
  if(Type==OP_BUY&&TotalLostOrders(OP_BUY)>0&&time&&ordestotal1_2(OP_SELL)==0&&ordestotal1_2(OP_BUY)==0){
   open(OP_SELL,LB1,Bid,TakeProfit,StopLoss) ;
    }




 if( win_USD>0&&pofet()>=win_USD){CloseDeleteAll();}


   if(pofet()>=0)color_pofet=Lime;else{color_pofet=Red;}
 
samir("Panel_MAT1",1,20,80,"Account Balance",10,"",Lime);
  samir("Panel_MA1",1,20,21,DoubleToStr(AccountBalance(), 2),10,"",Lime);

  samir("Panel_MAT2",1,40,80,"Account Equity",10,"",Lime);
  samir("Panel_MA2",1,40,21,DoubleToStr(AccountEquity(), 2),10,"",Lime);


 samir("Panel_MAT3",1,60,80,"profit",10,"",Lime);
 samir("Panel_MA3",1,60,21,DoubleToStr(pofet(), 2),10,"",color_pofet);


 samir("Panel_MAT5",1,80,80,"Hour GMT",10,"",Lime);
 samir("Panel_MA5",1,80,21,TimeToString(TimeGMT(),2 ),10,"",Lime);

 samir("Panel_MAT6",1,100,80,"Hour",10,"",Lime);
 samir("Panel_MA6",1,100,21,DoubleToStr(hour,TIME_MINUTES ),10,"",Lime);

   
   
   
  }
//+------------------------------------------------------------------+

int open(int ty,double lott,double prc,int pof,int sll)
   {
     double sl=0,tp=0;
   
     bool modi;
    
     if(ty==OP_BUY || ty==OP_BUYSTOP || ty==OP_BUYLIMIT)
        {
         if(sll>0){sl=prc-(sll*pt);}else{sl=0;}
         if(pof>0){tp=prc+(pof*pt);}else{tp=0;}
         clr=Green;
         T="Ask ";
         pr=NormalizeDouble(Ask,Digits);
        }
     if(ty==OP_SELL || ty==OP_SELLSTOP || ty==OP_SELLLIMIT)
       { 
         if(sll>0){sl=prc+(sll*pt);}else{sl=0;}
         if(pof>0){tp=prc-(pof*pt);}else{tp=0;}
         clr=Red;
         T="Bid";
         pr=NormalizeDouble(Bid,Digits);
       }     
         int tik=OrderSend(Symbol()
                ,ty
                ,lott
                ,NormalizeDouble(prc,Digits)
                ,10
                ,0
                ,0
                ,"samir"
                ,MagicNumber
                ,0
                ,clr);
          string t;
            if(ty==OP_BUY)t="BUY";if(ty==OP_SELL)t="SELL";if(ty==OP_BUYSTOP)t="BUY STOP";if(ty==OP_SELLSTOP)t="SELL STOP";if(ty==OP_BUYLIMIT)t="BUY LIMIT";if(ty==OP_SELLLIMIT)t="SELL LIMIT";
      if(tik>0)
         {
          if(tp>0 || sl>0)modi=OrderModify(tik,prc,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),0,CLR_NONE);   else modi=true;
          if(!modi){Print("Modify Err#= ",GetLastError(),"   ",Symbol()," ",Period(),"   Open Price= ",DoubleToStr(prc,Digits),"   SL= ",DoubleToStr(sl,Digits),"   Tp= ",DoubleToStr(tp,Digits));} 
           Print("Order Opened successfully   " ,"Type   ",t,"  LotSize   ",lott,"  Price   ",DoubleToStr(prc,Digits),"  TP   ",DoubleToStr(tp,Digits),"  SL   ",DoubleToStr(sl,Digits));
         }
         else
           {
            Print("OrderSend failed with error #",GetLastError(), " Type ",t,"   LotSize= ",lott,"   ",T,"Now= ",DoubleToStr(pr,Digits),"   Price= ",DoubleToStr(prc,Digits),"   TP= ",DoubleToStr(tp,Digits),"   SL= ",DoubleToStr(sl,Digits),"   Spread= ",MarketInfo(Symbol(),MODE_SPREAD));
           }
                //////
         return(tik);
   
}

//-------------------------------------------------------------------------    


 int ordestotal1_2(int type)//دالة التحكم فى عدد الصفقات 
{ 
int total_2=0; 
for(int b=0;b<OrdersTotal();b++){ 
if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
if(OrderSymbol()==Symbol()&&MagicNumber==OrderMagicNumber()&&OrderType()==type){ 
total_2++; 
} 
} 
return(total_2); 
} 





//------------------------------------------------------------------


 bool CloseDeleteAll()//دالة اغلاق الصفقات معا
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
       
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
         if(OrderSymbol()==Symbol()&&MagicNumber==OrderMagicNumber()){
            switch(OrderType())
            {
               case OP_BUY       :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),0,Violet))
                     return(false);
               }break;                  
               case OP_SELL      :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),0,Violet))
                     return(false);
               }break;
            }             
         
            
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
               if(!OrderDelete(OrderTicket()))
               { 
                  Print("Error deleting " + (string)OrderType() + " order : ",GetLastError());
                  return (false);
             }  }
          }
      }
      return (true);
}

//------------------------------------------


  double Lots(double risk)//دالة ادارة راس المال
   {
    double Lot;
    if(Auto_Lots)
       { 
        if(risk>1)risk=1;
        //_________________________________________________________________________________________
        double Min_Lot = MarketInfo(Symbol(), MODE_MINLOT);
        double Max_Lot = MarketInfo(Symbol(), MODE_MAXLOT);
        double lot_step= MarketInfo(Symbol(), MODE_LOTSTEP);
        Lot=NormalizeDouble(AccountBalance()*risk/100/10,2);
        Lot=NormalizeDouble(Lot,2);
        Lot=NormalizeDouble(Lot/lot_step,0)*lot_step;
        if (Lot < Min_Lot) Lot = Min_Lot; 
        if (Lot > Max_Lot) Lot = Max_Lot;
        //_________________________________________________________________________________________
       }
      else Lot=Lot1;
    return(Lot);
   }
  
      
//---------------------------------------------
 
  double pofet(){ //دالة معرفة حجم ربح الصفقات المفتوحه
 
 double pr_2=0;
 for(int p=0;p<OrdersTotal();p++){
 if(OrderSelect(p,SELECT_BY_POS,MODE_TRADES))
 if(OrderSymbol()==Symbol()&&MagicNumber==OrderMagicNumber()){
 pr_2=pr_2+OrderProfit();
}
 }return(pr_2);
 }
 
//----------------------------------------------------------

//--------------------------------------------------------
//دالة التوضيح على الشارت بيانات عمل الاكسبيرت
void samir(string a_name_0, double a_corner_8, int a_y_16, int a_x_20, string a_text_24, int a_fontsize_32, string a_fontname_36, color a_color_44) {
   ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(a_name_0, a_text_24, a_fontsize_32, a_fontname_36, a_color_44);
   ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_8);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_20);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_16);
 } 
 
//-------------------------------------------------
    int TotalLostOrders(int typer)
{
 int TotalLost=0;
 for(int i=OrdersHistoryTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
  if(OrderSymbol()==Symbol()&&MagicNumber==OrderMagicNumber()&&OrderType()== typer)
  {
   if(OrderProfit()<0)TotalLost++;
   else return(TotalLost);
  }
 }
 return(TotalLost);
}
//---------------------------------------------------------------------------------

int TotalLostOrders2(int typer)
{
 int TotalLost=0;
 for(int i=OrdersHistoryTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
  if(OrderSymbol()==Symbol()&&MagicNumber==OrderMagicNumber()&&OrderType()== typer)
  {
   if(OrderProfit()>0)TotalLost++;
   else return(TotalLost);
  }
 }
 return(TotalLost);
}
//---------------------------------------------------------------------------------


 void closeordar(int typer){
 for(int c=0;c<OrdersTotal();c++){
 if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES))
 if(OrderMagicNumber()==MagicNumber&&OrderSymbol()==Symbol()&&OrderType()== typer){
 if(OrderType()==OP_BUY)bool j=OrderClose(OrderTicket(),OrderLots(),Bid,30);
 if(OrderType()==OP_SELL)bool k=OrderClose(OrderTicket(),OrderLots(),Ask,30);
 RefreshRates();
    }
   }
  }