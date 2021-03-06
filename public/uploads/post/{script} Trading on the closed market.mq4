//+------------------------------------------------------------------+
#property copyright "Copyright 2015, http://cmillion.ru"
#property link      "http://cmillion.ru"
#property version   "1.00"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
/*
Ñêðèïò ïðåäíàçíà÷åí äëÿ âûñòàâëåíèÿ îðäåðîâ â òî âðåìÿ, êîãäà ýòî ñäåëàòü íåâîçìîæíî, íàïðèìåð, êîãäà ðûíîê çàêðûò.
Óêàçûâàåòå â ñêðèïòå íàïðàâëåíèå òîðãîâëè (ïîêóïêà èëè ïðîäàæà) îáúåì îðäåðà è ïàðàìåòðû ñòîïîâ. Êàê òîëüêî ðûíîê îòêðîåòñÿ, îðäåð áóäåò âûñòàâëåí. 
Áîëåå òîãî, ñêðèïò äîâåäåò ýòîò îðäåð äî çàêðûòèÿ.
Ìîæíî ñðàçó óêàçàòü âñå ïàðàìåòðû òðàëà è ïîñëå îòêðûòèÿ îðäåð áóäåò ñîïðîâîæäàòüñÿ òðàëîì. 
Åñòü è åùå îäíà ôóíêöèÿ, ýòî âèðòóàëüíûå ñòîïû. 
Åñëè ñòîïëîññ èëè òåéêïðîôèò óêàçàíû ìåíåå ðàçðåøåííîãî áðîêåðîì óðîâíÿ ñòîïëåâåë, òî ñêðèïò áóäåò êîíòðîëèðîâàòü ñòîïëîññ è òåéêïðîôèò âèðòóàëüíî è çàêðîåò îðäåð ïî óêàçàííûì ïàðàìåòðàì ñàì.
Åñëè ïîñëå óñòàíîâêè ñêðèïòà íà ãðàôèê, ïðîèçîøåë ÃÝÏ, òî ñêðèïò áóäåò ïûòàòüñÿ îòêðûòü îðäåð ïî ïåðâîé âîçìîæíîé öåíå.
Ìîæíî òàê æå óñòàíîâèòü âðåìÿ ñòàðòà ñêðèïòà è òîãäà îðäåð áóäåò óñòàíîâëåí íå ñðàçó ïðè îòêðûòèè ðûíêà, à â óêàçàííîå âðåìÿ.
Ñêðèïò çàêàí÷èâàåò ñâîþ ðàáîòó, êîãäà âûñòàâëåííûé èì îðäåð áóäåò çàêðûò.
*/
//+------------------------------------------------------------------+
enum t
  {
   Buy=0,     
   Sell=1,     
  };
input t        O                    = Buy;      
extern double  Lot                  = 0.01;    
extern int     Stoploss             = 0,      
               Takeprofit           = 40;     
extern int     TrailingStop         = 15;     
extern int     TrailingStart        = 0;      
extern int     TrailingStep         = 1;      
extern int     slippage                    =30;     
extern string  TimeStart            = "00:01";
extern int     Magic                = 0;      
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!IsTradeAllowed()) {Comment("");return;}
   double STOPLEVEL,OSL,OTP,StLo,OOP,SL,TP;
   int n=0,OT;
   string txt=StringConcatenate(" = ",Stoploss,"\n",
                                " = ",Takeprofit,"\n",
                                " = ",TrailingStop,"\n",
                                " = ",TrailingStart,"\n",
                                " = ",TrailingStep,"\n");
   while(!IsStopped())
     {
      RefreshRates();
      STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
      n=0;
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
              {
               OT=OrderType();
               OSL = NormalizeDouble(OrderStopLoss(),Digits);
               OTP = NormalizeDouble(OrderTakeProfit(),Digits);
               OOP = NormalizeDouble(OrderOpenPrice(),Digits);
               SL=OSL;TP=OTP;
               if(OT==OP_BUY)
                 {
                  if(Stoploss!=0   && Bid<=OOP - Stoploss   * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE)) continue;}
                  if(Takeprofit!=0 && Bid>=OOP + Takeprofit * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE)) continue;}
                  n++;
                  if(OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                    {
                     SL=NormalizeDouble(OOP-Stoploss  *Point,Digits);
                    }
                  if(OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                    {
                     TP=NormalizeDouble(OOP+Takeprofit*Point,Digits);
                    }
                  if(TrailingStop>=STOPLEVEL && TrailingStop!=0 && (Bid-OOP)/Point>=TrailingStart)
                    {
                     StLo=NormalizeDouble(Bid-TrailingStop*Point,Digits);
                     if(StLo>=OOP && StLo>OSL+TrailingStep*Point) SL=StLo;
                    }
                  if(SL!=OSL || TP!=OTP)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SL,TP,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
               if(OT==OP_SELL)
                 {
                  if(Stoploss!=0   && Ask>=OOP + Stoploss   * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE)) continue;}
                  if(Takeprofit!=0 && Ask<=OOP - Takeprofit * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE)) continue;}
                  n++;
                  if(OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                    {
                     SL=NormalizeDouble(OOP+Stoploss  *Point,Digits);
                    }
                  if(OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                    {
                     TP=NormalizeDouble(OOP-Takeprofit*Point,Digits);
                    }
                  if(TrailingStop>=STOPLEVEL && TrailingStop!=0 && (OOP-Ask)/Point>=TrailingStart)
                    {
                     StLo=NormalizeDouble(Ask+TrailingStop*Point,Digits);
                     if(StLo<=OOP && (StLo<OSL-TrailingStep*Point || OSL==0)) SL=StLo;
                    }
                  if(SL!=OSL || TP!=OTP)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SL,TP,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
              }
           }
        }
      if(Lot!=0)
        {
         if(O==0) Comment(" ",WindowExpertName(),"\ ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt," ",n," "," ",TimeStart);
         if(O==1) Comment(" ",WindowExpertName(),"\ ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt," ",n," "," ",TimeStart);
        }
      else Comment(" ",WindowExpertName(),"\ ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt," ",n," ");

      if(Lot==0 && n==0) {Comment(" ",WindowExpertName(),"  ",TimeToStr(TimeCurrent(),TIME_SECONDS));return;}

      if(TimeCurrent()>=StrToTime(TimeStart))
        {
         if(O==0) if(OrderSend(Symbol(),OP_BUY,Lot,NormalizeDouble(Ask,Digits),slippage,0,0,NULL,Magic,0,CLR_NONE)!=-1) Lot=0;
         if(O==1) if(OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),slippage,0,0,NULL,Magic,0,CLR_NONE)!=-1) Lot=0;
        }
     }
  }
//+------------------------------------------------------------------+
