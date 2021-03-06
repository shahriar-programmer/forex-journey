//+------------------------------------------------------------------+
//|                                                       HMA_v2.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                         Revised by IgorAD,igorad2003@yahoo.co.uk |   
//|                                        http://www.forex-tsd.com/ |                                      
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
/*
HMA_v2 with dynamic filter(PctFilter) like for NonLagMA
*/
//---- indicator settings
#property indicator_chart_window 
#property indicator_buffers 8 
#property indicator_color1 Yellow 
#property indicator_color2 CornflowerBlue
#property indicator_color3 Tomato 
#property indicator_color8 CLR_NONE
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width8 1 
//---- indicator parameters
extern int     Price          = 0;
extern int     HMA_Period     =13;
extern double  PctFilter      = 0;  //Dynamic filter in decimal
extern int     ColorMode      = 1;
extern int     ColorBarBack   = 0;
extern int     MA_Mode        = 3;  //0 => SMA; 1 => EMA; 2 => SMMA; 3 => LWMA - Added by Chrisstoff
extern int     AlertMode      = 1;  //Sound Alert switch   (0-off,1-on) 
extern int     WarningMode    = 1;  //Sound Warning switch (0-off,1-on) 
extern bool    EMail_Signals  = False;
//---- indicator buffers
double     ind_buffer0[];
double     Uptrend[];
double     Dntrend[];
double     ind_buffer1[];
double     trend[];
double     Del[];
double     AvgDel[];
double     Arrow[];

int        draw_begin0;
bool       UpTrendAlert=false, DownTrendAlert=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   IndicatorBuffers(8);
   SetIndexBuffer(0,ind_buffer0);
   SetIndexBuffer(1,Uptrend);
   SetIndexBuffer(2,Dntrend);
   SetIndexBuffer(3,ind_buffer1);
   SetIndexBuffer(4,trend);  
   SetIndexBuffer(5,Del);
   SetIndexBuffer(6,AvgDel);
   SetIndexBuffer(7,Arrow);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,233); SetIndexLabel(0,"C4Scalp Up");
   draw_begin0=HMA_Period+MathFloor(MathSqrt(HMA_Period));
   SetIndexDrawBegin(0,draw_begin0);
   SetIndexDrawBegin(1,draw_begin0);
   SetIndexDrawBegin(2,draw_begin0);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("HMA("+HMA_Period+")");
   SetIndexLabel(0,"HullMA");
   SetIndexLabel(1,"HullMA Uptrend");
   SetIndexLabel(2,"HullMA Dntrend");
   SetIndexLabel(7,"HullMA Change Trend");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<1)
     {
      for(i=1;i<=draw_begin0;i++) ind_buffer0[Bars-i]=0;
      for(i=1;i<=HMA_Period;i++) ind_buffer1[Bars-i]=0;
     }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- MA difference counted in the 1-st buffer
   for(i=0; i<limit; i++)
   {
      double v1 = iMA(NULL,0,MathFloor(HMA_Period/2),0,MA_Mode,Price,i);
      double v2 = iMA(NULL,0,HMA_Period,0,MA_Mode,Price,i);
      ind_buffer1[i]=2.0*v1-v2;
   }                      
                      
//---- HMA counted in the 0-th buffer
   for(i=limit; i>=0; i--)
   {
   ind_buffer0[i]=iMAOnArray(ind_buffer1,0,MathFloor(MathSqrt(HMA_Period)),0,MA_Mode,i);
   int Length = HMA_Period;
      if (PctFilter>0)
      {
      Del[i] = MathAbs(ind_buffer0[i] - ind_buffer0[i+1]);
   
      double sumdel=0;
      for (int j=0;j<=Length-1;j++) sumdel = sumdel+Del[i+j];
      AvgDel[i] = sumdel/Length;
    
      double sumpow = 0;
      for (j=0;j<=Length-1;j++) sumpow+=MathPow(Del[j+i]-AvgDel[j+i],2);
      double StdDev = MathSqrt(sumpow/Length); 
     
      double Filter = PctFilter * StdDev;
     
      if( MathAbs(ind_buffer0[i]-ind_buffer0[i+1]) < Filter ) ind_buffer0[i]=ind_buffer0[i+1];
      }
      else
      Filter=0;
   
      
      if (ColorMode>0)
      {
         trend[i] = trend[i+1];
         if (ind_buffer0[i] - ind_buffer0[i+1] > Filter) trend[i] = 1;
         if (ind_buffer0[i+1] - ind_buffer0[i] > Filter) trend[i] =-1;
    
         if (trend[i]>0)
         {
            Uptrend[i] = ind_buffer0[i]; 
            if (trend[i+ColorBarBack]<0) Uptrend[i+ColorBarBack]=ind_buffer0[i+ColorBarBack];
            Dntrend[i] = EMPTY_VALUE;
            if (WarningMode>0 && trend[i+1]<0 && i==0) PlaySound("alert2.wav");
         }
         else              
         if (trend[i]<0)
         { 
            Dntrend[i] = ind_buffer0[i]; 
            if (trend[i+ColorBarBack]>0) Dntrend[i+ColorBarBack]=ind_buffer0[i+ColorBarBack];
            Uptrend[i] = EMPTY_VALUE;
            if (WarningMode>0 && trend[i+1]>0 && i==0) PlaySound("alert2.wav");
         }               
      }
   }      
//----------   
   string Message;
   
   if ( trend[2]<0 && trend[1]>0 && Volume[0]>1 && !UpTrendAlert)
	{
	Message = " "+Symbol()+" M"+Period()+": HMA Signal for BUY";
	if ( AlertMode>0 ) Alert (Message); 
	if (EMail_Signals) SendMail(Symbol()+": HMA Signal",Message);
	Arrow[1]=iLow(NULL,0,1);
	UpTrendAlert=true; DownTrendAlert=false;
	} 
	 	  
	if ( trend[2]>0 && trend[1]<0 && Volume[0]>1 && !DownTrendAlert)
	{
	Message = " "+Symbol()+" M"+Period()+": HMA Signal for SELL";
	if ( AlertMode>0 ) Alert (Message); 
	if (EMail_Signals) SendMail(Symbol()+": HMA Signal",Message);
	Arrow[1]=iHigh(NULL,0,1);
	DownTrendAlert=true; UpTrendAlert=false;
	} 	         



//---- done
   return(0);
  }