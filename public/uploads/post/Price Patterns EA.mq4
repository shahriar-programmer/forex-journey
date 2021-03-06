//+----------------------------------------------------------------------------+
//|                                                       _Expert Advisor.mq4  |
//|                             Copyright ?2008-2010, TradingSystemForex.Com  |
//|                                        http://www.tradingsystemforex.com/  |
//|  Y2010.M09.D27                                                             |
//+----------------------------------------------------------------------------+

#property copyright "Copyright ?2008-2010, TradingSystemForex.Com"
#property link "http://www.tradingsystemforex.com/"

/*Martingale : You can set a closed martingale : martingale=true, maxtrades=1,
basketpercent or basketpips=true. Or an open martingale : martingale=true,
tradesperbar=100, basketpercent or basketpips=true, addpositions=true.
Scalping : You can use timeout and target, time filter, set maxtrades=1,
changedirection=true to optimize the scalping.*/

//+----------------------------------------------------------------------------+
//|  External inputs                                                           |
//+----------------------------------------------------------------------------+

//--- Add "extern " before each parameter to get them in the inputs tab

string comment="EA";                     // comment to display in the order
 int magic=1234;                   // magic number required if you use different settings on a same pair, same timeframe
bool useprint=false;                     // use print
bool emailalert=false;                   // use email alert
bool onlybuy=false;                      // only enter buy orders
bool onlysell=false;                     // only enter sell orders

string moneymanagement="Money Management";

double lots=0.1;                  // lots size
bool mm=true;                    // enable risk management
extern double risk=1;                    // risk in percentage of the account
double minlot=0.01;               // minimum lots size
double maxlot=100;                // maximum lots size
int lotdigits=2;                  // lot digits, 1=0.1, 2=0.01
extern bool martingale=true;                   // enable the martingale, set maxtrades to 1
extern int martingalemode=true;                    // 0=don't use percentrecovering, 1=use percentrecovering
extern double multiplier=1.3;                   // multiplier used for the martingale
extern double percentrecovering=50;           // percentage of the last losses to recover
extern bool addpositions=false;                 // add positions, set tradesperbar to 100
extern int addposmode=0;                        // 0=counter, 1=follow
extern double pipstep=20;                       // multiplier used for the martingale
extern double pipstepfactor=1.0;                // multiply the pipstep by the number of buy/sell orders

string profitmanagement="Profit Management";

extern bool basketpercent=false;                // enable the basket percent
extern double profit=0.1;                       // close all orders if a profit of 10 percents has been reached
extern double loss=100;                         // close all orders if a loss of 30 percents has been reached
extern bool basketpips=false;                   // enable the basket pips
extern double profitpips=10;                    // close all orders if a profit of 10 percents has been reached
extern double losspips=10000;                   // close all orders if a loss of 30 percents has been reached
extern bool basketdollars=false;                // enable basket dollars
extern double dollars=5;                        // target in dollars

extern string ordersmanagement="Order Management";

extern bool ecn=true;                   // make the expert compatible with ecn brokers
extern bool instantorders=true;                 // instant orders
extern bool stoporders=false;                   // stoporders
extern bool limitorders=false;                  // limit orders
extern bool onecancelother=false;               // cancel opposite pending orders when one is triggered
extern int gap=20;                              // gap for pending orders
extern bool oppositedelete=true;                // delete the pending orders on an opposite signal
extern bool oppositeclose=true;          // close the orders on an opposite signal
int oppositecloseminloss=0;              // min loss to consider to enable opposite close
bool partialexit=false;                  // partial exit at opposite close
 bool partialclose=false;                 // partial close at takeprofit2
extern bool reversesignals=false;        // reverse the signals, long if short, short if long
extern int maxtrades=100;                // maximum trades allowed by the traders
extern int tradesperbar=1;               // maximum trades per bar allowed by the expert
extern bool hidesl=false;                // hide stop loss
extern bool hidetp=false;                // hide take profit
extern double stoploss=0;                // stop loss
extern double takeprofit=0;              // take profit
double takeprofit2=5;                    // takeprofit 2 for the rest of the trade, takeprofit2 has to be smaller than takeprofit
double tp2percentage=25;
double takeprofit3=20;
double tp3percentage=50;
int trailingstopmode=0;                  // 0 new sl=ask+/-trailingstart, 1 new sl=sl+/-trailingstop or order open price/-trailingstop if sl=0
extern double trailingstart=40;           // profit in pips required to enable the trailing stop
extern double trailingstop=25;            // trailing stop
extern double trailingprofit=0;                 // trailing profit
extern double trailingstep=3;            // margin allowed to the market to enable the trailing stop
 double breakevengain=0;           // gain in pips required to enable the break even
double breakeven=0;               // break even
int expiration=1440;                     // expiration in minutes for pending orders
double slippage=3;                       // maximum difference in pips between signal and order
 double maxspread=7;               // maximum spread allowed by the expert, 0=disabled

string adordersmanagement="Advanced Order Management";

bool ignoreinitialbar=false;             // ignore initial bar to not enter when we need to restart the platform
extern bool changedirection=false;              // only buy after a sell order, sell after a buy order
extern bool onesideatatime=false;               // enter only long or short when a long or short is already opened
extern bool enteronopenbar=false;        // enter only on open bar
bool eoobexceptaddpos=true;              // we don't consider added pos for enteronopenbar option
extern bool onetimecalculation=false;    // calculate entry logics one time per bar
double stop=0;                    // stoptake=stoploss and takeprofit
double trailing=0;                // trailing=trailingstart and trailingstop
extern bool reverseatstop=false;                // we reverse the order when the stoploss has been reached
extern bool rasoppositeclose=true;              // close reversed order on opposite signal
extern int rasstoploss=0;                       // reversed order stop loss
extern int rastakeprofit=0;                     // reversed order take profit
bool sleepafterxlosses=false;            // ea sleeps after x consecutive losses
int xlosses=4;                           // x consecutive losses
int sleepminutes=60;                     // sleep minutes
double slfactor=0;                       // enable dynamic stoploss if different of 0
int slmargin=0;                          // margin to add to the stoploss
double tpfactor=0;                       // enable dynamic takeprofit if different of 0
int stoplevel=15;                        // minimum value for dynamic variables
bool atrdynamics=false;                  // dynamic stops based on atr
int atrtimeframe=60;                     // timeframe for the atr
int atrperiod=14;                        // atr period
double tstfactor=0;                      // enable dynamic trailing start if different of 0
double tsfactor=0;                       // enable dynamic trailing stop if different of 0
double begfactor=0;                      // enable dynamic breakevengain if different of 0
double befactor=0;                       // enable dynamic breakeven if different of 0
double psfactor=0;                       // enable dynamic pipstep if different of 0
double gfactor=0;                        // enable dynamic gap if different of 0
bool highlowdynamics=false;              // dynamic stops based on highest/lowest
int hltimeframe=0;                       // high low timeframe
int candles=7;                           // highest/lowest on the last x candles
bool sdldynamics=false;                  // dynamic stops based on slope direction line
int sdltimeframe=0;                      // timeframe of the sdl
int sdlperiod=15;                        // period of the sdl
int method=3;                            // method of the sdl
int price=0;                             // price of the sdl

string entrylogics="Entry Logics";

extern bool batpattern=true;
extern bool gartleypattern=true;
extern bool crabpattern=true;
extern bool abcdpattern=true;
extern bool butterflypattern=true;
extern bool threedrivespattern=true;
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
extern bool enteronce=false;              // enter once per pattern
extern bool checkratio=false;             // check zigzags ratios
extern int ratiodgminus=0;               // withdraw one digit to the price for ratios
extern bool extrasltp=true;
extern double sl1=950;
extern double tp1=30;
extern double sl2=950;
extern double tp2=35;
extern double sl3=950;
extern double tp3=50;
extern double sl4=950;
extern double tp4=25;
extern double sl5=950;
extern double tp5=30;
extern double sl6=950;
extern double tp6=25;
extern int shift=1;                      // bar in the past to take in consideration for the signal

string timefilter="Time Filter";

bool usetimefilter=false;
int summergmtshift=0;                    // gmt offset of the broker
int wintergmtshift=0;                    // gmt offset of the broker
bool mondayfilter=false;                 // enable special time filter on friday
int mondayhour=12;                       // start to trade after this hour
int mondayminute=0;                      // minutes of the friday hour
bool weekfilter=false;                   // enable time filter
int starthour=7;                         // start hour to trade after this hour
int startminute=0;                       // minutes of the start hour
int endhour=21;                          // stop to trade after this hour
int endminute=0;                         // minutes of the start hour
bool tradesunday=true;                   // trade on sunday
bool fridayfilter=false;                 // enable special time filter on friday
int fridayhour=12;                       // stop to trade after this hour
int fridayminute=0;                      // minutes of the friday hour

bool newsfilter=false;                   // news filter option
int minutesbefore=120;                   // minutes before the news
int newshour=14;                         // hour of the news
int newsminute=30;                       // minute of the news
int minutesafter=120;                    // minutes after the news

string timeout="Time Outs and Targets";

bool usetimeout=false;                   // time out, we close the order if after timeout minutes we are over target pips
int timeout1=30;                         // time out 1
int target1=7;                           // target 1
int timeout2=70;                         // time out 2
int target2=5;                           // target 2
int timeout3=95;                         // time out 3
int target3=4;                           // target 3
int timeout4=120;                        // time out 4
int target4=2;                           // target 4
int timeout5=150;                        // time out 5
int target5=-5;                          // target 5
int timeout6=180;                        // time out 6
int target6=-8;                          // target 6
int timeout7=210;                        // time out 7
int target7=-15;                         // target 7

//+----------------------------------------------------------------------------+
//|  Internal parameters                                                       |
//+----------------------------------------------------------------------------+

datetime tstart,tend,tfriday,tmonday,lastbuyopentime,tnews,lastsellopentime,time,time2,time3,time4,time5,time6,time7,lastorderclosetime,longemailtime,shortemailtime;
int i,bc=-1,tpb,tps,tries=100,lastorder,buyorderprofit,sellorderprofit,lotsize,losses,sleep,xmartingalemode=0,mstop;
int nstarthour,nnewshour,nendhour,nfridayhour,nmondayhour,number,ticket,gmtshift,tradetime,expire,
total,totalbuy,totalsell,totalstopbuy,totalstopsell,totallimitbuy,totallimitsell,oldestlong,oldestshort;
string istarthour,inewshour,istartminute,iendhour,iendminute,inewsminute,ifridayhour,ifridayminute,imondayhour,imondayminute;
double cb,sl,tp,blots,slots,lastbuylot,lastselllot,lastlot,lastprofit,mlots,win[14],sum[14],totalpips,totalprofit,percentprofit,percentloss;
double lastbuyopenprice,lastsellopenprice,lastbuyprofit,lastsellprofit,tradeprofit,buyorderpips,sellorderpips,lossestorecover=0,globallosses,initialbar=0;

bool closebasket=false;

bool continuebuy=true;
bool continuesell=true;

double pt,mt,zz[7];
int dg;
double zzarch1,zzarch2,zzarch3,zzarch4,zzarch5,zzarch6,zzarch7,zzarch8,zzarch9,zzarch10,zzarch11,zzarch12;

//+----------------------------------------------------------------------------+
//|  Initialization (done only when you attach the EA to the chart)            |
//+----------------------------------------------------------------------------+

int init(){
   if(usetimefilter){
      sum[2012-1999]=D'2012.03.28 02:00:00';win[2012-1999]=D'2012.10.31 03:00:00';
      sum[2011-1999]=D'2011.03.29 02:00:00';win[2011-1999]=D'2011.10.25 03:00:00';
      sum[2010-1999]=D'2010.03.30 02:00:00';win[2010-1999]=D'2010.10.26 03:00:00';
      sum[2009-1999]=D'2009.03.29 02:00:00';win[2009-1999]=D'2009.10.25 03:00:00';
      sum[2008-1999]=D'2008.03.30 02:00:00';win[2008-1999]=D'2008.10.26 03:00:00';
      sum[2007-1999]=D'2007.03.25 02:00:00';win[2007-1999]=D'2007.10.28 03:00:00';
      sum[2006-1999]=D'2006.03.26 02:00:00';win[2006-1999]=D'2006.10.29 03:00:00';
      sum[2005-1999]=D'2005.03.27 02:00:00';win[2005-1999]=D'2005.10.30 03:00:00';
      sum[2004-1999]=D'2004.03.28 02:00:00';win[2004-1999]=D'2004.10.31 03:00:00';
      sum[2003-1999]=D'2003.03.30 02:00:00';win[2003-1999]=D'2003.10.26 03:00:00';
      sum[2002-1999]=D'2002.03.31 02:00:00';win[2002-1999]=D'2002.10.27 03:00:00';
      sum[2001-1999]=D'2001.03.25 02:00:00';win[2001-1999]=D'2001.10.28 03:00:00';
      sum[2000-1999]=D'2000.03.26 02:00:00';win[2000-1999]=D'2000.10.29 03:00:00';
      sum[1999-1999]=D'1999.03.28 02:00:00';win[1999-1999]=D'1999.10.31 03:00:00';
   }
   if(Digits==3 || Digits==5){
      pt=Point*10;
      mt=10;
      dg=Digits-(ratiodgminus+1);
   }else{
      pt=Point;
      mt=1;
      dg=Digits-ratiodgminus;
   }
   if(stop>0){
      stoploss=stop;
      takeprofit=stop;
   }
   if(mm){
      if(minlot>=1){lotsize=100000;}
      if(minlot<1){lotsize=10000;}
      if(minlot<0.1){lotsize=1000;}
   }
   initialbar=Open[0];
   return(0);
}

//+----------------------------------------------------------------------------+
//|  Start (called after each tick)                                            |
//+----------------------------------------------------------------------------+

int start(){

   if(Bars<100){
      if(useprint)Print("Bars less than 100");
      return(0);
   }

//+----------------------------------------------------------------------------+
//|  One time                                                                  |
//+----------------------------------------------------------------------------+

   bool onetime=true;
   if(onetimecalculation)if(time==Time[0])onetime=false;

//+----------------------------------------------------------------------------+
//|  Ignore initial bar                                                        |
//+----------------------------------------------------------------------------+

   if(ignoreinitialbar)if(initialbar==Open[0])return(0);

//+----------------------------------------------------------------------------+
//|  Counters                                                                  |
//+----------------------------------------------------------------------------+

   if(closebasket || addpositions || onesideatatime || onecancelother || maxtrades<100 || martingale){
      totalbuy=count(OP_BUY);
      totalsell=count(OP_SELL);
      total=totalbuy+totalsell;
      if(closebasket){
         totalstopbuy=count(OP_BUYSTOP);
         totalstopsell=count(OP_SELLSTOP);
         totallimitbuy=count(OP_BUYLIMIT);
         totallimitsell=count(OP_SELLLIMIT);
      }
   }

//+----------------------------------------------------------------------------+
//|  Basket close                                                              |
//+----------------------------------------------------------------------------+

   if(closebasket)if(total+totalstopbuy+totalstopsell+totallimitbuy+totallimitsell>0){
      close(3);
      Delete(6);
   }
   if(closebasket)if(total+totalstopbuy+totalstopsell+totallimitbuy+totallimitsell==0)closebasket=false;
   if(closebasket)return(0);

//+----------------------------------------------------------------------------+
//|  Visualize the equity curve with the indicator vGrafBalance&Equity.mq4     |
//+----------------------------------------------------------------------------+

/*
   GlobalVariableSet("vGrafBalance",AccountBalance());
   GlobalVariableSet("vGrafEquity",AccountEquity());
*/

//+----------------------------------------------------------------------------+
//|  Break even, trailing, trailingstop and trailing profit                    |
//+----------------------------------------------------------------------------+

   if(breakevengain>0 && onetime)movebreakeven(breakevengain,breakeven);
   if(trailingstop>0 && onetime)movetrailingstop(trailingstopmode,trailingstart,trailingstop);
   if(trailingstop>0 && onetime)movetrailingstop(trailingstopmode,trailingstart,trailingstop);
   if(trailing>0 && onetime)movetrailingstop(0,trailing,trailing);
   if(trailingprofit>0 && onetime)movetrailingprofit(trailingstart,trailingprofit);

//+----------------------------------------------------------------------------+
//|  Last open time, price and profits                                         |
//+----------------------------------------------------------------------------+

   if(basketpercent || basketdollars || xmartingalemode==1){
      buyorderprofit=0;
      sellorderprofit=0;
   }
   if(basketpips){
      buyorderpips=0;
      sellorderpips=0;
   }
   if(oppositeclose){
      oldestlong=0;
      oldestshort=0;
   }
   lastbuyopenprice=0;lastsellopenprice=0;

   if(OrdersTotal()>0){
      for(i=0;i<=OrdersTotal();i++){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderCloseTime()==0){
            if(OrderType()==OP_BUY){
               if(oppositeclose)if(oldestlong==0 || oldestlong>OrderOpenTime())oldestlong=OrderOpenTime();
               lastbuyopentime=OrderOpenTime();
               if(addpositions)lastbuyopenprice=OrderOpenPrice();
               if(basketpercent || basketdollars || xmartingalemode==1)buyorderprofit=buyorderprofit+OrderProfit();
               if(basketpips)buyorderpips=buyorderpips+(OrderClosePrice()-OrderOpenPrice())/pt-MarketInfo(Symbol(),MODE_SPREAD);
            }
            if(OrderType()==OP_SELL){
               if(oppositeclose)if(oldestlong==0 || oldestshort>OrderOpenTime())oldestshort=OrderOpenTime();
               lastsellopentime=OrderOpenTime();
               if(addpositions)lastsellopenprice=OrderOpenPrice();
               if(basketpercent || basketdollars || xmartingalemode==1)sellorderprofit=sellorderprofit+OrderProfit();
               if(basketpips)sellorderpips=sellorderpips+(OrderOpenPrice()-OrderClosePrice())/pt-MarketInfo(Symbol(),MODE_SPREAD);
            }
         }
      }
   }
   if(basketpercent || basketdollars || xmartingalemode==1)totalprofit=buyorderprofit+sellorderprofit;
   if(basketpips)totalpips=buyorderpips+sellorderpips;

//+----------------------------------------------------------------------------+
//|  Baskets                                                                   |
//+----------------------------------------------------------------------------+

   if(basketpercent){
      percentprofit=AccountBalance()*profit*0.01;
      percentloss=-1*AccountBalance()*loss*0.01;
      if((mm && totalprofit>=(AccountBalance()*profit*0.01)) || (mm==false && totalprofit>=percentprofit)
      || (mm && totalprofit<=(-1*AccountBalance()*loss*0.01))|| (mm==false && totalprofit<=percentloss))closebasket=true;
   }
   if(basketpips)if((totalpips>=profitpips) || (totalpips<=(-1*losspips)))closebasket=true;
   if(basketdollars)if(totalprofit>=dollars)closebasket=true;
   if(closebasket)return(0);

//+----------------------------------------------------------------------------+
//|  Sleep                                                                   |
//+----------------------------------------------------------------------------+

   bool nosleep=true;
   if(sleepafterxlosses && OrdersHistoryTotal()>0){
      losses=0;sleep=0;
      for(i=OrdersHistoryTotal()-1;i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(OrderProfit()>=0)sleep=1;
            if(OrderProfit()<0 && sleep==0){losses++;}
         }
      }
      for(i=0;i<OrdersHistoryTotal();i++){
         OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(losses>=xlosses)lastorderclosetime=OrderCloseTime();
         }
      }
      if(TimeCurrent()-lastorderclosetime<sleepminutes*60)nosleep=false;
   }

//+----------------------------------------------------------------------------+
//|  Trades per bar                                                            |
//+----------------------------------------------------------------------------+

   if(tradesperbar==1){
      if(lastbuyopentime<Time[0])tpb=0;else tpb=1;
      if(lastsellopentime<Time[0])tps=0;else tps=1;
   }
   if(tradesperbar!=1 && bc!=Bars){tpb=0;tps=0;bc=Bars;}

//+----------------------------------------------------------------------------+
//|  Indicators calling                                                        |
//+----------------------------------------------------------------------------+

   if(onetime || shift==0){
      if(atrdynamics){
         double atr=iATR(NULL,atrtimeframe,atrperiod,shift);
      }
      if(highlowdynamics){
         double high=iHigh(NULL,hltimeframe,iHighest(NULL,0,MODE_HIGH,candles,1));
         double low=iLow(NULL,hltimeframe,iLowest(NULL,0,MODE_LOW,candles,1));
      }
      if(sdldynamics){
         int sdlbar1=0;
         for(i=0;i<=100;i++){
            if(sdlbar1!=0)continue;
            if(iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i)>
            iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i+1)
            && iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i+1)<
            iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i+2))sdlbar1=i;
         }
         int sdlbar2=0;
         for(i=0;i<=100;i++){
            if(sdlbar2!=0)continue;
            if(iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i)<
            iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i+1)
            && iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i+1)>
            iCustom(NULL,sdltimeframe,"Slope Direction Line",sdlperiod,method,price,2,i+2))sdlbar2=i;
         }
      }
      
      //iCustom(NULL,0,"StepMA_v7",maperiod,0,shift);
      
      // last peaks
      
      int x=0;
      for(i=shift;i<=500;i++){
         if(x>=8)continue;
         if(iCustom(NULL,0,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,i)>0
         && iCustom(NULL,0,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,i)!=EMPTY_VALUE){
            zz[x]=NormalizeDouble(iCustom(NULL,0,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,i),dg);
            x++;
         }
      }

      if(threedrivespattern){
      double bulltdp1=NormalizeDouble(zz[2]-zz[1],dg);
      double bulltdp2=NormalizeDouble(zz[2]-zz[3],dg);
      double bulltdp3=NormalizeDouble(zz[4]-zz[3],dg);
      double bulltdp4=NormalizeDouble(zz[4]-zz[5],dg);

      double beartdp1=NormalizeDouble(zz[1]-zz[2],dg);
      double beartdp2=NormalizeDouble(zz[3]-zz[2],dg);
      double beartdp3=NormalizeDouble(zz[3]-zz[4],dg);
      double beartdp4=NormalizeDouble(zz[5]-zz[4],dg);
      }
      if(butterflypattern){
      double bullbp1=NormalizeDouble(zz[1]-zz[0],dg);
      double bullbp2=NormalizeDouble(zz[1]-zz[2],dg);
      double bullbp3=NormalizeDouble(zz[3]-zz[2],dg);
      double bullbp4=NormalizeDouble(zz[3]-zz[4],dg);

      double bearbp1=NormalizeDouble(zz[0]-zz[1],dg);
      double bearbp2=NormalizeDouble(zz[2]-zz[1],dg);
      double bearbp3=NormalizeDouble(zz[2]-zz[3],dg);
      double bearbp4=NormalizeDouble(zz[4]-zz[3],dg);
      }
      if(abcdpattern){
      double bullabcdp1=NormalizeDouble(zz[1]-zz[0],dg);
      double bullabcdp2=NormalizeDouble(zz[1]-zz[2],dg);
      double bullabcdp3=NormalizeDouble(zz[3]-zz[2],dg);
      
      double bearabcdp1=NormalizeDouble(zz[0]-zz[1],dg);
      double bearabcdp2=NormalizeDouble(zz[2]-zz[1],dg);
      double bearabcdp3=NormalizeDouble(zz[2]-zz[3],dg);
      }
      if(crabpattern){
      double bullcp1=NormalizeDouble(zz[1]-zz[0],dg);
      double bullcp2=NormalizeDouble(zz[1]-zz[2],dg);
      double bullcp3=NormalizeDouble(zz[3]-zz[2],dg);
      double bullcp4=NormalizeDouble(zz[3]-zz[4],dg);

      double bearcp1=NormalizeDouble(zz[0]-zz[1],dg);
      double bearcp2=NormalizeDouble(zz[2]-zz[1],dg);
      double bearcp3=NormalizeDouble(zz[2]-zz[3],dg);
      double bearcp4=NormalizeDouble(zz[4]-zz[3],dg);
      }
      if(gartleypattern || batpattern){
      double bullgp1=NormalizeDouble(zz[1]-zz[0],dg);
      double bullgp2=NormalizeDouble(zz[1]-zz[2],dg);
      double bullgp3=NormalizeDouble(zz[3]-zz[2],dg);
      double bullgp4=NormalizeDouble(zz[3]-zz[4],dg);

      double beargp1=NormalizeDouble(zz[0]-zz[1],dg);
      double beargp2=NormalizeDouble(zz[2]-zz[1],dg);
      double beargp3=NormalizeDouble(zz[2]-zz[3],dg);
      double beargp4=NormalizeDouble(zz[4]-zz[3],dg);
      }
      string pattern="";
      int signal=0;
      
      if(threedrivespattern){
      if(zz[0]>zz[1] && zz[1]<zz[2] && zz[2]>zz[3] && zz[3]<zz[4] && zz[4]>zz[5] && zz[5]<zz[6]
      && zz[1]<zz[3] && zz[3]<zz[5] && zz[2]<zz[4]
      && (checkratio==false || (checkratio
      && (bulltdp1==NormalizeDouble(bulltdp2*1.13,dg) && bulltdp3==NormalizeDouble(bulltdp4*1.13,dg))
      || (bulltdp1==NormalizeDouble(bulltdp2*1.27,dg) && bulltdp3==NormalizeDouble(bulltdp4*1.27,dg))
      || (bulltdp1==NormalizeDouble(bulltdp2*1.618,dg) && bulltdp3==NormalizeDouble(bulltdp4*1.618,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch1))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish Three Drives Pattern";zzarch1=zz[1];if(extrasltp){stoploss=sl1;takeprofit=tp1;}}

      if(zz[0]<zz[1] && zz[1]>zz[2] && zz[2]<zz[3] && zz[3]>zz[4] && zz[4]<zz[5] && zz[5]>zz[6]
      && zz[1]>zz[3] && zz[3]>zz[5] && zz[2]>zz[4]
      && (checkratio==false || (checkratio
      && (beartdp1==NormalizeDouble(beartdp2*1.13,dg) && beartdp3==NormalizeDouble(beartdp4*1.13,dg))
      || (beartdp1==NormalizeDouble(beartdp2*1.27,dg) && beartdp3==NormalizeDouble(beartdp4*1.27,dg))
      || (beartdp1==NormalizeDouble(beartdp2*1.618,dg) && beartdp3==NormalizeDouble(beartdp4*1.618,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch2))
      && IsTradeContextBusy()==false){signal=2;pattern="Bearish Three Drives Pattern";zzarch2=zz[1];if(extrasltp){stoploss=sl1;takeprofit=tp1;}}
      }
      if(butterflypattern){
      if(zz[0]<zz[1] && zz[1]>zz[2] && zz[2]<zz[3] && zz[3]>zz[4]
      && zz[0]<zz[2] && zz[0]<zz[4] && zz[2]<zz[4]
      && (checkratio==false || (checkratio
      && (bullbp1==NormalizeDouble(bullbp2*1.618,dg) || bullbp1==NormalizeDouble(bullbp2*2.618,dg))
      && (bullbp2==NormalizeDouble(bullbp3*0.382,dg) || bullbp2==NormalizeDouble(bullbp3*0.886,dg))
      && (bullbp3==NormalizeDouble(bullbp4*0.786,dg) || bullbp3==NormalizeDouble(bullbp4*0.786,dg))
      && (bullbp1==NormalizeDouble(bullbp4*1.27,dg) || bullbp1==NormalizeDouble(bullbp4*1.618,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch3))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish Butterfly Pattern";zzarch3=zz[1];if(extrasltp){stoploss=sl2;takeprofit=tp2;}}
      
      if(zz[0]>zz[1] && zz[1]<zz[2] && zz[2]>zz[3] && zz[3]<zz[4]
      && zz[0]>zz[2] && zz[0]>zz[4] && zz[2]>zz[4]
      && (checkratio==false || (checkratio
      && (bearbp1==NormalizeDouble(bearbp2*1.618,dg) || bearbp1==NormalizeDouble(bearbp2*2.618,dg))
      && (bearbp2==NormalizeDouble(bearbp3*0.382,dg) || bearbp2==NormalizeDouble(bearbp3*0.886,dg))
      && (bearbp3==NormalizeDouble(bearbp4*0.786,dg) || bearbp3==NormalizeDouble(bearbp4*0.786,dg))
      && (bearbp1==NormalizeDouble(bearbp4*1.27,dg) || bearbp1==NormalizeDouble(bearbp4*1.618,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch4))
      && IsTradeContextBusy()==false){signal=2;pattern="Bearish Butterfly Pattern";zzarch4=zz[1];if(extrasltp){stoploss=sl2;takeprofit=tp2;}}
      }
      if(abcdpattern){
      if(zz[0]<zz[1] && zz[1]>zz[2] && zz[2]<zz[3]
      && zz[0]<zz[2] && zz[1]<zz[3]
      && (checkratio==false || (checkratio
      && (bullabcdp1==NormalizeDouble(bullabcdp2*1.27,dg) && bullabcdp2==NormalizeDouble(bullabcdp3*0.786,dg))
      && (bullabcdp2==NormalizeDouble(bullabcdp3*0.618,dg) && bullabcdp1==NormalizeDouble(bullabcdp2*1.618,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch5))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish AB=CD Pattern";zzarch5=zz[1];if(extrasltp){stoploss=sl3;takeprofit=tp3;}}
      
      if(zz[0]>zz[1] && zz[1]<zz[2] && zz[2]>zz[3]
      && zz[0]>zz[2] && zz[1]>zz[3]
      && (checkratio==false || (checkratio
      && (bearabcdp1==bearabcdp2*1.27 && bearabcdp2==bearabcdp3*0.786)
      && (bearabcdp2==bearabcdp3*0.618 && bearabcdp1==bearabcdp2*1.618)))
      && (enteronce==false || (enteronce && zz[1]!=zzarch6))
      && IsTradeContextBusy()==false){signal=2;pattern="Bearish AB=CD Pattern";zzarch6=zz[1];if(extrasltp){stoploss=sl3;takeprofit=tp3;}}
      }
      if(crabpattern){
      if(zz[0]<zz[1] && zz[1]>zz[2] && zz[2]<zz[3] && zz[3]>zz[4]
      && zz[0]<zz[2] && zz[0]<zz[4] && zz[2]>zz[4]
      && (checkratio==false || (checkratio
      && (bullcp1==NormalizeDouble(bullcp2*2.24,dg)) || (bullcp1==NormalizeDouble(bullcp2*3.618,dg))
      && (bullcp2==NormalizeDouble(bullcp3*0.382,dg)) || (bullcp2==NormalizeDouble(bullcp3*0.886,dg))
      && (bullcp3==NormalizeDouble(bullcp4*0.382,dg)) || (bullcp3==NormalizeDouble(bullcp4*0.618,dg))
      && (bullcp1==NormalizeDouble(bullcp4*1.618,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch7))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish Crab Pattern";zzarch7=zz[1];if(extrasltp){stoploss=sl4;takeprofit=tp4;}}
      
      if(zz[0]>zz[1] && zz[1]<zz[2] && zz[2]>zz[3] && zz[3]<zz[4]
      && zz[0]>zz[2] && zz[0]>zz[4] && zz[2]<zz[4]
      && (checkratio==false || (checkratio
      && (bearcp1==NormalizeDouble(bearcp2*2.24,dg)) || (bearcp1==NormalizeDouble(bearcp2*3.618,dg))
      && (bearcp2==NormalizeDouble(bearcp3*0.382,dg)) || (bearcp2==NormalizeDouble(bearcp3*0.886,dg))
      && (bearcp3==NormalizeDouble(bearcp4*0.382,dg)) || (bearcp3==NormalizeDouble(bearcp4*0.618,dg))
      && (bearcp1==NormalizeDouble(bearcp4*1.618,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch8))
      && IsTradeContextBusy()==false){signal=2;pattern="Bearish Crab Pattern";zzarch8=zz[1];if(extrasltp){stoploss=sl4;takeprofit=tp4;}}
      }
      if(gartleypattern){
      if(zz[0]<zz[1] && zz[1]>zz[2] && zz[2]<zz[3] && zz[3]>zz[4]
      && zz[0]<zz[2] && zz[0]>zz[4] && zz[2]>zz[4]
      && (checkratio==false || (checkratio
      && (bullgp1==NormalizeDouble(bullgp2*1.27,dg)) || (bullgp1==NormalizeDouble(bullgp2*1.618,dg))
      && (bullgp2==NormalizeDouble(bullgp3*0.382,dg)) || (bullgp2==NormalizeDouble(bullgp3*0.886,dg))
      && (bullgp3==NormalizeDouble(bullgp4*0.618,dg))
      && (bullgp1==NormalizeDouble(bullgp4*0.786,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch9))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish Gartley Pattern";zzarch9=zz[1];if(extrasltp){stoploss=sl5;takeprofit=tp5;}}
      
      if(zz[0]>zz[1] && zz[1]<zz[2] && zz[2]>zz[3] && zz[3]<zz[4]
      && zz[0]>zz[2] && zz[0]<zz[4] && zz[2]<zz[4]
      && (checkratio==false || (checkratio
      && (beargp1==NormalizeDouble(beargp2*1.27,dg)) || (beargp1==NormalizeDouble(beargp2*1.618,dg))
      && (beargp2==NormalizeDouble(beargp3*0.382,dg)) || (beargp2==NormalizeDouble(beargp3*0.886,dg))
      && (beargp3==NormalizeDouble(beargp4*0.618,dg))
      && (beargp1==NormalizeDouble(beargp4*0.786,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch10))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish Gartley Pattern";zzarch10=zz[1];if(extrasltp){stoploss=sl5;takeprofit=tp5;}}
      }
      if(batpattern){
      if(zz[0]<zz[1] && zz[1]>zz[2] && zz[2]<zz[3] && zz[3]>zz[4]
      && zz[0]<zz[2] && zz[0]>zz[4] && zz[2]>zz[4]
      && (checkratio==false || (checkratio
      && (bullgp1==NormalizeDouble(bullgp2*1.618,dg)) || (bullgp1==NormalizeDouble(bullgp2*2.618,dg))
      && (bullgp2==NormalizeDouble(bullgp3*0.382,dg)) || (bullgp2==NormalizeDouble(bullgp3*0.886,dg))
      && (bullgp3<NormalizeDouble(bullgp4*0.618,dg))
      && (bullgp1==NormalizeDouble(bullgp4*0.886,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch11))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish Bat Pattern";zzarch11=zz[1];if(extrasltp){stoploss=sl6;takeprofit=tp6;}}
      
      if(zz[0]>zz[1] && zz[1]<zz[2] && zz[2]>zz[3] && zz[3]<zz[4]
      && zz[0]>zz[2] && zz[0]<zz[4] && zz[2]<zz[4]
      && (checkratio==false || (checkratio
      && (beargp1==NormalizeDouble(beargp2*1.618,dg)) || (beargp1==NormalizeDouble(beargp2*2.618,dg))
      && (beargp2==NormalizeDouble(beargp3*0.382,dg)) || (beargp2==NormalizeDouble(beargp3*0.886,dg))
      && (beargp3<NormalizeDouble(beargp4*0.618,dg))
      && (beargp1==NormalizeDouble(beargp4*0.886,dg))))
      && (enteronce==false || (enteronce && zz[1]!=zzarch12))
      && IsTradeContextBusy()==false){signal=1;pattern="Bullish Bat Pattern";zzarch12=zz[1];if(extrasltp){stoploss=sl6;takeprofit=tp6;}}
      }
      Comment(
      "\nzz1 = "+DoubleToStr(zz[0],5),
      "\nzz2 = "+DoubleToStr(zz[1],5),
      "\nzz3 = "+DoubleToStr(zz[2],5),
      "\nzz4 = "+DoubleToStr(zz[3],5),
      "\nzz5 = "+DoubleToStr(zz[4],5),
      "\nzz6 = "+DoubleToStr(zz[5],5),
      "\nzz7 = "+DoubleToStr(zz[6],5),
      "\n\nPattern = "+pattern);

      //--- dynamics variables

      if(atrdynamics){
         if(signal!=0 && slfactor!=0)stoploss=(atr/pt)*slfactor+slmargin;
         if(signal!=0 && tpfactor!=0)takeprofit=(atr/pt)*tpfactor+slmargin;
         if(signal!=0 && tstfactor!=0)trailingstart=(atr/pt)*tstfactor;
         if(signal!=0 && tsfactor!=0)trailingstop=(atr/pt)*tsfactor;
         if(signal!=0 && begfactor!=0)breakevengain=(atr/pt)*begfactor;
         if(signal!=0 && befactor!=0)breakeven=(atr/pt)*befactor;
         if(signal!=0 && psfactor!=0)pipstep=(atr/pt)*psfactor;
         if(signal!=0 && gfactor!=0)gap=(atr/pt)*gfactor;
      }
      if(highlowdynamics){
         if(signal==1 && slfactor!=0)stoploss=((Ask-low)/pt)*slfactor+slmargin;
         if(signal==1 && tpfactor!=0)takeprofit=((high-Bid)/pt)*tpfactor;
         if(signal==2 && slfactor!=0)stoploss=((high-Bid)/pt)*slfactor+slmargin;
         if(signal==2 && tpfactor!=0)takeprofit=((Ask-low)/pt)*tpfactor;
      }
      if(sdldynamics){
         if(signal==1 && slfactor!=0)stoploss=((Ask-Low[sdlbar1])/pt)*slfactor+slmargin;
         if(signal==1 && tpfactor!=0)takeprofit=((High[sdlbar2]-Bid)/pt)*tpfactor;
         if(signal==2 && slfactor!=0)stoploss=((High[sdlbar2]-Bid)/pt)*slfactor+slmargin;
         if(signal==2 && tpfactor!=0)takeprofit=((Ask-Low[sdlbar1])/pt)*tpfactor;
      }
      if(atrdynamics || highlowdynamics || sdldynamics){
         if(stoploss<stoplevel)stoploss=stoplevel;
         if(takeprofit<stoplevel)takeprofit=stoplevel;
      }

      //if(ma>0 && ma!=EMPTY_VALUE)signal=1;
   }

   //Comment("\nhau = "+DoubleToStr(hau,5),"\nhad = "+DoubleToStr(had,5));
   
//+----------------------------------------------------------------------------+
//|  Time filter                                                               |
//+----------------------------------------------------------------------------+

   bool tradetime=true;
   if(usetimefilter)if(checktime())tradetime=false;

//+----------------------------------------------------------------------------+
//|  Change direction                                                          |
//+----------------------------------------------------------------------------+

   if(changedirection)if(initialbar==Open[0]){
      if(OrdersHistoryTotal()>0){
         OrderSelect(OrdersHistoryTotal(),SELECT_BY_POS,MODE_HISTORY);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){continuebuy=false;continuesell=true;}
            if(OrderType()==OP_SELL){continuebuy=true;continuesell=false;}
         }
      }
   }

//+----------------------------------------------------------------------------+
//|  Signals                                                                   |
//+----------------------------------------------------------------------------+

   bool buy=false;
   bool sell=false;

   bool barstatus=true;
   if(enteronopenbar)if(iVolume(NULL,0,0)>1)barstatus=false;

   bool buyaddstatus=true;bool selladdstatus=true;
   if(addpositions){
      if(totalbuy>0)buyaddstatus=false;
      if(totalsell>0)selladdstatus=false;
      if(totalbuy>0){if((addposmode==0 && Ask<=lastbuyopenprice-pipstep*pt*MathPow(pipstepfactor,totalbuy))
      || (addposmode==1 && Ask>=lastbuyopenprice+pipstep*pt*MathPow(pipstepfactor,totalbuy))
      && (eoobexceptaddpos || (eoobexceptaddpos==false && barstatus)))buy=true;}
      if(totalsell>0){if((addposmode==0 && Bid>=lastsellopenprice+pipstep*pt*MathPow(pipstepfactor,totalsell))
      || (addposmode==1 && Bid<=lastsellopenprice-pipstep*pt*MathPow(pipstepfactor,totalsell))
      && (eoobexceptaddpos || (eoobexceptaddpos==false && barstatus)))sell=true;}
   }

   bool buyside=true;bool sellside=true;
   if(onesideatatime){if(totalsell>0)buyside=false;if(totalbuy>0)sellside=false;}

   if(signal==1 && buyaddstatus && barstatus && buyside && continuebuy && tradetime && nosleep){
      if(reversesignals)sell=true;else buy=true;
      if(changedirection){continuebuy=false;continuesell=true;}
   }
   if(signal==2 && selladdstatus && barstatus && sellside && continuesell && tradetime && nosleep){
      if(reversesignals)buy=true;else sell=true;
      if(changedirection){continuebuy=true;continuesell=false;}
   }

//+----------------------------------------------------------------------------+
//|  Close and delete                                                          |
//+----------------------------------------------------------------------------+

   if(oppositeclose){
      if(buy){
         if(partialexit)partialclose(OP_SELL,1,lots*tp2percentage*0.01,0);
         else close(OP_SELL);
      }
      if(sell){
         if(partialexit)partialclose(OP_BUY,1,lots*tp2percentage*0.01,0);
         else close(OP_BUY);
      }
      if(partialexit==false && oldestlong>oldestshort && oldestshort!=0)close(OP_SELL);
      if(partialexit==false && oldestshort>oldestlong && oldestlong!=0)close(OP_BUY);
   }
   if(hidetp || hidesl)hideclose();
   if(onecancelother){
      if(totalsell>0)Delete(7);
      if(totalbuy>0)Delete(8);
   }
   if(partialclose){
      partialclose(3,0,lots*tp2percentage*0.01,takeprofit2);
      partialclose(3,0,lots*tp3percentage*0.01,takeprofit3);
   }
   if(xmartingalemode==1 && totalprofit>=-1*lossestorecover)close(3);
   if(usetimeout && onetime){
      closetime(0,target1,timeout1,timeout2);
      closetime(0,target2,timeout2,timeout3);
      closetime(0,target3,timeout3,timeout4);
      closetime(0,target4,timeout4,timeout5);
      closetime(0,target5,timeout5,timeout6);
      closetime(0,target6,timeout6,timeout7);
      closetime(1,target7,timeout7,0);
   }

//+----------------------------------------------------------------------------+
//|  Closed martingale                                                         |
//+----------------------------------------------------------------------------+

   xmartingalemode=0;
   if(martingale && !addpositions){
      globallosses=0;
      lossestorecover=0;

      if(OrdersHistoryTotal()>0){
         for(i=0;i<=OrdersHistoryTotal();i++){
            OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
               lastprofit=OrderProfit();
               lastlot=OrderLots();
            }
         }
      }
      mlots=0;
      if(lastprofit<0){
         mstop=0;
         if(OrdersHistoryTotal()>0){
            for(i=OrdersHistoryTotal();i>=0;i--){
               OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
                  if(OrderProfit()>0)mstop=1;
                  if(mstop==0)globallosses=globallosses+OrderProfit();
               }
            }
         }
         mlots=lastlot*multiplier;
         if(martingalemode==1)xmartingalemode=1;
         lossestorecover=NormalizeDouble(globallosses*0.01*percentrecovering,2);
      }
      else mlots=lots;
   }

//+----------------------------------------------------------------------------+
//|  Max spread, max trades                                                    |
//+----------------------------------------------------------------------------+

   if(maxspread!=0)if((Ask-Bid)>maxspread*pt)return(0);
   if(maxtrades<100)if((total)>=maxtrades)return(0);

   if(mm)if(martingale==false || (martingale && !addpositions && lastprofit>=0) || (martingale && addpositions))lots=lotsoptimized();
   blots=lots;slots=lots;
   if(martingale){
      if(addpositions){blots=lots*MathPow(multiplier,totalbuy);slots=lots*MathPow(multiplier,totalsell);}
      else {blots=mlots;slots=mlots;}
   }

//+----------------------------------------------------------------------------+
//|  Instant and pending orders                                                |
//+----------------------------------------------------------------------------+

   if(buy && tpb<tradesperbar && !onlysell){
      if(oppositedelete){Delete(OP_SELLSTOP);Delete(OP_SELLLIMIT);}
      ticket=0;
      number=0;
      expire=0;
      if(stoporders || limitorders)if(expiration>0)expire=TimeCurrent()+(expiration*60)-5;
      if(!ecn){
         if(instantorders && xmartingalemode==0){
            while(ticket<=0 && number<tries){
               while(!IsTradeAllowed())Sleep(5000);
               RefreshRates();ticket=open(OP_BUY,blots,Ask,stoploss,takeprofit,expire,Blue);
               if(ticket<0){if(useprint)Print("Error opening BUY order! ",errordescription(GetLastError()));number++;}
            }
         }
         if(instantorders && xmartingalemode==1){
            while(ticket<=0 && number<tries){
               while(!IsTradeAllowed())Sleep(5000);
               RefreshRates();ticket=open(OP_BUY,blots,Ask,stoploss,0,expire,Blue);
               if(ticket<0){if(useprint)Print("Error opening BUY order! ",errordescription(GetLastError()));number++;}
            }
         }
         if(stoporders)if(time2!=Time[0]){RefreshRates();ticket=open(OP_BUYSTOP,blots,Ask+gap*pt,stoploss,takeprofit,expire,Blue);time2=Time[0];tpb++;}
         if(limitorders)if(time3!=Time[0]){RefreshRates();ticket=open(OP_BUYLIMIT,blots,Bid-gap*pt,stoploss,takeprofit,expire,Blue);time3=Time[0];tpb++;}
         if(reverseatstop)if(time6!=Time[0]){if(rasoppositeclose)Delete(OP_BUYSTOP);RefreshRates();ticket=open(OP_SELLSTOP,blots,Bid-stoploss*pt,rasstoploss,rastakeprofit,expire,Red);time6=Time[0];}
      }
      if(ecn){
         if(instantorders){
            while(ticket<=0 && number<tries){
               while(!IsTradeAllowed())Sleep(5000);
               RefreshRates();ticket=open(OP_BUY,blots,Ask,0,0,expire,Blue);
               if(ticket<0){if(useprint)Print("Error opening BUY order! ",errordescription(GetLastError()));number++;}
            }
         }
         if(stoporders)if(time2!=Time[0]){RefreshRates();ticket=open(OP_BUYSTOP,blots,Ask+gap*pt,0,0,expire,Blue);time2=Time[0];tpb++;}
         if(limitorders)if(time3!=Time[0]){RefreshRates();ticket=open(OP_BUYLIMIT,blots,Bid-gap*pt,0,0,expire,Blue);time3=Time[0];tpb++;}
         if(reverseatstop)if(time6!=Time[0]){if(rasoppositeclose)Delete(OP_BUYSTOP);RefreshRates();ticket=open(OP_SELLSTOP,blots,Bid-stoploss*pt,0,0,expire,Red);time6=Time[0];}
      }
      if(instantorders)if(ticket<=0){if(useprint)Print("Error Occured : "+errordescription(GetLastError()));}else tpb++;
      if(emailalert)if(longemailtime!=Time[0]){RefreshRates();RefreshRates();SendMail("[Long Trade]", "["+Symbol()+"] "+DoubleToStr(Ask,Digits));longemailtime=Time[0];}
   }
   if(sell && tps<tradesperbar && !onlybuy){
      if(oppositedelete){Delete(OP_BUYSTOP);Delete(OP_BUYLIMIT);}
      ticket=0;
      number=0;
      expire=0;
      if(stoporders || limitorders)if(expiration>0)expire=TimeCurrent()+(expiration*60)-5;
      if(!ecn){
         if(instantorders && xmartingalemode==0){
            while(ticket<=0 && number<tries){
               while(!IsTradeAllowed())Sleep(5000);
               RefreshRates();ticket=open(OP_SELL,slots,Bid,stoploss,takeprofit,expire,Red);
               if(ticket<0){if(useprint)Print("Error opening BUY order! ",errordescription(GetLastError()));number++;}
            }
         }
         if(instantorders && xmartingalemode==1){
            while(ticket<=0 && number<tries){
               while(!IsTradeAllowed())Sleep(5000);
               RefreshRates();ticket=open(OP_SELL,slots,Bid,stoploss,0,expire,Red);
               if(ticket<0){if(useprint)Print("Error opening BUY order! ",errordescription(GetLastError()));number++;}
            }
         }
         if(stoporders)if(time4!=Time[0]){RefreshRates();ticket=open(OP_SELLSTOP,slots,Bid-gap*pt,stoploss,takeprofit,expire,Red);time4=Time[0];tps++;}
         if(limitorders)if(time5!=Time[0]){RefreshRates();ticket=open(OP_SELLLIMIT,slots,Ask+gap*pt,stoploss,takeprofit,expire,Red);time5=Time[0];tps++;}
         if(reverseatstop)if(time7!=Time[0]){if(rasoppositeclose)Delete(OP_SELLSTOP);RefreshRates();ticket=open(OP_BUYSTOP,blots,Ask+stoploss*pt,rasstoploss,rastakeprofit,expire,Blue);time7=Time[0];}
      }
      if(ecn){
         if(instantorders){
            while(ticket<=0 && number<tries){
               while(!IsTradeAllowed())Sleep(5000);
               RefreshRates();ticket=open(OP_SELL,slots,Bid,0,0,expire,Red);
               if(ticket<0){if(useprint)Print("Error opening BUY order! ",errordescription(GetLastError()));number++;}
            }
         }
         if(stoporders)if(time4!=Time[0]){RefreshRates();ticket=open(OP_SELLSTOP,slots,Bid-gap*pt,0,0,expire,Red);time4=Time[0];tps++;}
         if(limitorders)if(time5!=Time[0]){RefreshRates();ticket=open(OP_SELLLIMIT,slots,Ask+gap*pt,0,0,expire,Red);time5=Time[0];tps++;}
         if(reverseatstop)if(time7!=Time[0]){if(rasoppositeclose)Delete(OP_SELLSTOP);RefreshRates();ticket=open(OP_BUYSTOP,blots,Ask+stoploss*pt,0,0,expire,Blue);time7=Time[0];}
      }
      if(instantorders)if(ticket<=0){if(useprint)Print("Error Occured : "+errordescription(GetLastError()));}else tps++;
      if(emailalert)if(shortemailtime!=Time[0]){RefreshRates();RefreshRates();SendMail("[Short Trade]", "["+Symbol()+"] "+DoubleToStr(Bid,Digits));shortemailtime=Time[0];}
   }
   if(ecn)ecnmodify(stoploss,takeprofit);
   if(onetimecalculation)time=Time[0];
   return(0);
}

//+----------------------------------------------------------------------------+
//|  Open orders function                                                      |
//+----------------------------------------------------------------------------+

int open(int type,double lots,double price,double stoploss,double takeprofit,int expire,color clr){
   int ticket=0;
   if(lots<minlot)lots=minlot;
   if(lots>maxlot)lots=maxlot;
   if(type==OP_BUY || type==OP_BUYSTOP || type==OP_BUYLIMIT){
      if(hidesl==false && stoploss>0){sl=price-stoploss*pt;}else{sl=0;}
      if(hidetp==false && takeprofit>0){tp=price+takeprofit*pt;}else{tp=0;}
   }
   if(type==OP_SELL || type==OP_SELLSTOP || type==OP_SELLLIMIT){
      if(hidesl==false && stoploss>0){sl=price+stoploss*pt;}else{sl=0;}
      if(hidetp==false && takeprofit>0){tp=price-takeprofit*pt;}else{tp=0;}
   }
   ticket=OrderSend(Symbol(),type,NormalizeDouble(lots,lotdigits),NormalizeDouble(price,Digits),slippage*mt,sl,tp,comment+" "+DoubleToStr(magic,0),magic,expire,clr);
   return(ticket);
}

//+----------------------------------------------------------------------------+
//|  Lots optimized functions                                                  |
//+----------------------------------------------------------------------------+

double lotsoptimized(){
   double lot;
   if(stoploss>0)lot=AccountBalance()*(risk/100)/(stoploss*pt/MarketInfo(Symbol(),MODE_TICKSIZE)*MarketInfo(Symbol(),MODE_TICKVALUE));
   else lot=NormalizeDouble((AccountBalance()/lotsize)*0.01*risk,lotdigits);
   return(lot);
}

//+----------------------------------------------------------------------------+
//|  Time filter functions                                                     |
//+----------------------------------------------------------------------------+

bool checktime(){
   if(TimeCurrent()<win[TimeYear(TimeCurrent())-1999] && TimeCurrent()>sum[TimeYear(TimeCurrent())-1999])gmtshift=summergmtshift;
   else gmtshift=wintergmtshift;

   string svrdate=Year()+"."+Month()+"."+Day();

   if(mondayfilter){
      nmondayhour=mondayhour+(gmtshift);if(nmondayhour>23)nmondayhour=nmondayhour-24;
      if(nmondayhour<10)imondayhour="0"+nmondayhour;
      if(nmondayhour>9)imondayhour=nmondayhour;
      if(mondayminute<10)imondayminute="0"+mondayminute;
      if(mondayminute>9)imondayminute=mondayminute;
      tmonday=StrToTime(svrdate+" "+imondayhour+":"+imondayminute);
   }
   if(weekfilter){
      nstarthour=starthour+(gmtshift);if(nstarthour>23)nstarthour=nstarthour-24;
      if(nstarthour<10)istarthour="0"+nstarthour;
      if(nstarthour>9)istarthour=nstarthour;
      if(startminute<10)istartminute="0"+startminute;
      if(startminute>9)istartminute=startminute;
      tstart=StrToTime(svrdate+" "+istarthour+":"+istartminute);

      nendhour=endhour+(gmtshift);if(nendhour>23)nendhour=nendhour-24;
      if(nendhour<10)iendhour="0"+nendhour;
      if(nendhour>9)iendhour=nendhour;
      if(endminute<10)iendminute="0"+endminute;
      if(endminute>9)iendminute=endminute;
      tend=StrToTime(svrdate+" "+iendhour+":"+iendminute);
   }
   if(fridayfilter){
      nfridayhour=fridayhour+(gmtshift);if(nfridayhour>23)nfridayhour=nfridayhour-24;
      if(nfridayhour<10)ifridayhour="0"+nfridayhour;
      if(nfridayhour>9)ifridayhour=nfridayhour;
      if(fridayminute<10)ifridayminute="0"+fridayminute;
      if(fridayminute>9)ifridayminute=fridayminute;
      tfriday=StrToTime(svrdate+" "+ifridayhour+":"+ifridayminute);
   }
   if(newsfilter){
      nnewshour=newshour+(gmtshift);if(nnewshour>23)nnewshour=nnewshour-24;
      if(nnewshour<10)inewshour="0"+nnewshour;
      if(nnewshour>9)inewshour=nnewshour;
      if(newsminute<10)inewsminute="0"+newsminute;
      if(newsminute>9)inewsminute=newsminute;
      tnews=StrToTime(svrdate+" "+inewshour+":"+inewsminute);
   }
   if(weekfilter)if((nstarthour<=nendhour && TimeCurrent()<tstart || TimeCurrent()>tend) || (nstarthour>nendhour && TimeCurrent()<tstart && TimeCurrent()>tend))return(true);
   if(tradesunday==false)if(DayOfWeek()==0)return(true);
   if(fridayfilter)if(DayOfWeek()==5 && TimeCurrent()>tfriday)return(true);
   if(mondayfilter)if(DayOfWeek()==1 && TimeCurrent()<tmonday)return(true);
   if(newsfilter)if(TimeCurrent()>tnews-minutesbefore*60 && TimeCurrent()<tnews+minutesafter*60)return(true);
   return(false);
}

//+----------------------------------------------------------------------------+
//|  Counter                                                                   |
//+----------------------------------------------------------------------------+

int count(int type){
   int cnt=0;
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderType()==type && OrderMagicNumber()==magic)cnt++;
      }
      return(cnt);
   }
}

//+----------------------------------------------------------------------------+
//|  Close functions                                                           |
//+----------------------------------------------------------------------------+

void close(int type){
   if(OrdersTotal()>0){
      for(i=OrdersTotal()-1;i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(type==3 || type==OP_BUY && OrderType()==OP_BUY){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && (oppositecloseminloss==0 || (oppositecloseminloss>0 && (OrderClosePrice()-OrderOpenPrice())<-1*oppositecloseminloss*pt))){
               RefreshRates();OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage*mt);
            }
         }
         if(type==3 || type==OP_SELL && OrderType()==OP_SELL){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && (oppositecloseminloss==0 || (oppositecloseminloss>0 && (OrderOpenPrice()-OrderClosePrice())<-1*oppositecloseminloss*pt))){
               RefreshRates();OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage*mt);
            }
         }
      }
   }
}

void partialclose(int type,int mode,double lot,double takeprofit){
   if(OrdersTotal()>0){
      for(i=OrdersTotal()-1;i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(type==3 || type==OP_BUY && OrderType()==OP_BUY){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderLots()>=lot && (mode==0 && OrderClosePrice()-OrderOpenPrice()>=takeprofit*pt) || mode==1){
               RefreshRates();OrderClose(OrderTicket(),NormalizeDouble(lot,lotdigits),NormalizeDouble(Bid,Digits),slippage*mt);
            }
         }
         if(type==3 || type==OP_SELL && OrderType()==OP_SELL){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderLots()>=lot && (mode==0 && OrderOpenPrice()-OrderClosePrice()>=takeprofit*pt) || mode==1){
               RefreshRates();OrderClose(OrderTicket(),NormalizeDouble(lot,lotdigits),NormalizeDouble(Ask,Digits),slippage*mt);
            }
         }
      }
   }
}

void hideclose(){
   if(OrdersTotal()>0){
      for(i=OrdersTotal()-1;i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()==OP_BUY){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic
            && (hidesl && stoploss>0 && NormalizeDouble(OrderClosePrice()-OrderOpenPrice(),Digits)<=(-1)*stoploss*pt-MarketInfo(Symbol(),MODE_SPREAD)*pt)
            || (hidetp && takeprofit>0 && NormalizeDouble(OrderClosePrice()-OrderOpenPrice(),Digits)>=takeprofit*pt)){
               RefreshRates();OrderClose(OrderTicket(),OrderLots(),Bid,slippage*mt);
            }
         }
         if(OrderType()==OP_SELL){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic
            && (hidesl && stoploss>0 && NormalizeDouble(OrderOpenPrice()-OrderClosePrice(),Digits)<=(-1)*stoploss*pt-MarketInfo(Symbol(),MODE_SPREAD)*pt)
            || (hidetp && takeprofit>0 && NormalizeDouble(OrderOpenPrice()-OrderClosePrice(),Digits)>=takeprofit*pt)){
               RefreshRates();OrderClose(OrderTicket(),OrderLots(),Ask,slippage*mt);
            }
         }
      }
   }
}

void closetime(int mode,double target,double timeout1,double timeout2){
   tradeprofit=0;
   tradetime=0;
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()==OP_BUY){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){ 
               tradeprofit=NormalizeDouble(OrderClosePrice()-OrderOpenPrice(),Digits);
               tradetime=TimeCurrent()-OrderOpenTime();
               if((mode==0 && tradeprofit>=target*pt && tradetime>timeout1*60 && tradetime<timeout2*60)
               || (mode==1 && tradeprofit>=target*pt && tradetime>timeout1*60)){
                  RefreshRates();OrderClose(OrderTicket(),OrderLots(),Bid,slippage*mt);
               }
            }
         }
         if(OrderType()==OP_SELL){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){ 
               tradeprofit=NormalizeDouble(OrderOpenPrice()-OrderClosePrice(),Digits);
               tradetime=TimeCurrent()-OrderOpenTime();
               if((mode==0 && tradeprofit>=target*pt && tradetime>timeout1*60 && tradetime<timeout2*60)
               || (mode==1 && tradeprofit>=target*pt && tradetime>timeout1*60)){
                  RefreshRates();OrderClose(OrderTicket(),OrderLots(),Ask,slippage*mt);
               }
            }
         }
      }
   }
}

void Delete(int type){
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(type!=6 && type!=7 && type!=8)if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type)OrderDelete(OrderTicket());
         if(type==6)if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
            OrderDelete(OrderTicket());
         if(type==7)if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT)OrderDelete(OrderTicket());
         if(type==8)if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT)OrderDelete(OrderTicket());
      }
   }
}

//+----------------------------------------------------------------------------+
//|  Modifications functions                                                   |
//+----------------------------------------------------------------------------+

void movebreakeven(double breakevengain,double breakeven){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble((Bid-OrderOpenPrice()),Digits)>=NormalizeDouble(breakevengain*pt,Digits)){
                  if((NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),Digits)<NormalizeDouble(breakeven*pt,Digits)) || OrderStopLoss()==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+breakeven*pt,Digits),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
            }
            else{
               if(NormalizeDouble((OrderOpenPrice()-Ask),Digits)>=NormalizeDouble(breakevengain*pt,Digits)){
                  if((NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),Digits)<NormalizeDouble(breakeven*pt,Digits)) || OrderStopLoss()==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-breakeven*pt,Digits),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
}

void movetrailingstop(int mode,double trailingstart,double trailingstop){
   RefreshRates();
   if(OrdersTotal()>0){
      for(i=OrdersTotal();i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(mode==0){
            if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
               if(OrderType()==OP_BUY){
                  if(NormalizeDouble(Ask,Digits)>NormalizeDouble(OrderOpenPrice()+trailingstart*pt,Digits)
                  && NormalizeDouble(OrderStopLoss(),Digits)<NormalizeDouble(Bid-(trailingstop+trailingstep)*pt,Digits)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-trailingstop*pt,Digits),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
               else{
                  if(NormalizeDouble(Bid,Digits)<NormalizeDouble(OrderOpenPrice()-trailingstart*pt,Digits)
                  && (NormalizeDouble(OrderStopLoss(),Digits)>(NormalizeDouble(Ask+(trailingstop+trailingstep)*pt,Digits))) || (OrderStopLoss()==0)){                 
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+trailingstop*pt,Digits),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
         if(mode==1){
            if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
               if(OrderType()==OP_BUY && OrderStopLoss()==0){
                  if(NormalizeDouble(Ask,Digits)>=NormalizeDouble(OrderOpenPrice()+trailingstart*pt,Digits)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask-trailingstop*pt,Digits),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
               if(OrderType()==OP_BUY && OrderStopLoss()!=0){
                  if(NormalizeDouble(Ask,Digits)>=NormalizeDouble(OrderOpenPrice()+trailingstart*pt,Digits)
                  && NormalizeDouble(Ask,Digits)>=NormalizeDouble(OrderStopLoss()+trailingstart*pt,Digits)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()+trailingstop*pt,Digits),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
               if(OrderType()==OP_SELL && OrderStopLoss()==0){
                  if(NormalizeDouble(Bid,Digits)<=NormalizeDouble(OrderOpenPrice()-trailingstart*pt,Digits)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid+trailingstop*pt,Digits),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
               if(OrderType()==OP_SELL && OrderStopLoss()!=0){
                  if(NormalizeDouble(Bid,Digits)<=NormalizeDouble(OrderOpenPrice()-trailingstart*pt,Digits)
                  && NormalizeDouble(Bid,Digits)<=NormalizeDouble(OrderStopLoss()-trailingstart*pt,Digits)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()-trailingstop*pt,Digits),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
}

void movetrailingprofit(double trailingstart,double trailingprofit){
   RefreshRates();
   for(i=OrdersTotal();i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(OrderSymbol()==Symbol()&& OrderMagicNumber()==magic){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble(Bid-OrderOpenPrice(),Digits)<=NormalizeDouble((-1)*trailingstart*pt,Digits)){
                  if(NormalizeDouble(OrderTakeProfit(),Digits)>NormalizeDouble(Bid+(trailingprofit+trailingstep)*pt,Digits)
                  || NormalizeDouble(OrderTakeProfit(),Digits)==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Bid+trailingprofit*pt,Digits),0,Blue);
                  }
               }
            }
            if(OrderType()==OP_SELL){
               if(NormalizeDouble(OrderOpenPrice()-Ask,Digits)<=NormalizeDouble((-1)*trailingstart*pt,Digits)){
                  if(NormalizeDouble(OrderTakeProfit(),Digits)<NormalizeDouble(Ask-(trailingprofit+trailingstep)*pt,Digits)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Ask-trailingprofit*pt,Digits),0,Red);
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| ECN modification                                                 |
//+------------------------------------------------------------------+

void ecnmodify(double stoploss,double takeprofit){
   for(i=OrdersTotal();i>=0;i--){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic){
         if(OrderType()==OP_BUY){
            if(OrderStopLoss()==0 && stoploss>0 && takeprofit==0){
               RefreshRates();OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask-stoploss*pt,Digits),OrderTakeProfit(),0,Red);
            }
            if(OrderTakeProfit()==0 && stoploss==0 && takeprofit>0){
               RefreshRates();OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Ask+takeprofit*pt,Digits),0,Red);
            }
            if(OrderTakeProfit()==0 && OrderStopLoss()==0 && stoploss>0 && takeprofit>0){
               RefreshRates();OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask-stoploss*pt,Digits),NormalizeDouble(Ask+takeprofit*pt,Digits),0,Red);
            }
         }
         if(OrderType()==OP_SELL){
            if(OrderStopLoss()==0 && stoploss>0 && takeprofit==0){
               RefreshRates();
               OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid+stoploss*pt,Digits),OrderTakeProfit(),0,Red);
            }
            if(OrderTakeProfit()==0 && stoploss==0 && takeprofit>0){
               RefreshRates();OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Bid-takeprofit*pt,Digits),0,Red);
            }
            if(OrderTakeProfit()==0 && OrderStopLoss()==0 && stoploss>0 && takeprofit>0){
               RefreshRates();OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid+stoploss*pt,Digits),NormalizeDouble(Bid-takeprofit*pt,Digits),0,Red);
            }
         }
      }
   }
}

//+----------------------------------------------------------------------------+
//|  Error functions                                                           |
//+----------------------------------------------------------------------------+

string errordescription(int code){
   string error;
   switch(code){
      case 0:
      case 1:error="no error";break;
      case 2:error="common error";break;
      case 3:error="invalid trade parameters";break;
      case 4:error="trade server is busy";break;
      case 5:error="old version of the client terminal";break;
      case 6:error="no connection with trade server";break;
      case 7:error="not enough rights";break;
      case 8:error="too frequent requests";break;
      case 9:error="malfunctional trade operation";break;
      case 64:error="account disabled";break;
      case 65:error="invalid account";break;
      case 128:error="trade timeout";break;
      case 129:error="invalid price";break;
      case 130:error="invalid stops";break;
      case 131:error="invalid trade volume";break;
      case 132:error="market is closed";break;
      case 133:error="trade is disabled";break;
      case 134:error="not enough money";break;
      case 135:error="price changed";break;
      case 136:error="off quotes";break;
      case 137:error="broker is busy";break;
      case 138:error="requote";break;
      case 139:error="order is locked";break;
      case 140:error="long positions only allowed";break;
      case 141:error="too many requests";break;
      case 145:error="modification denied because order too close to market";break;
      case 146:error="trade context is busy";break;
      case 4000:error="no error";break;
      case 4001:error="wrong function pointer";break;
      case 4002:error="array index is out of range";break;
      case 4003:error="no memory for function call stack";break;
      case 4004:error="recursive stack overflow";break;
      case 4005:error="not enough stack for parameter";break;
      case 4006:error="no memory for parameter string";break;
      case 4007:error="no memory for temp string";break;
      case 4008:error="not initialized string";break;
      case 4009:error="not initialized string in array";break;
      case 4010:error="no memory for array\' string";break;
      case 4011:error="too long string";break;
      case 4012:error="remainder from zero divide";break;
      case 4013:error="zero divide";break;
      case 4014:error="unknown command";break;
      case 4015:error="wrong jump (never generated error)";break;
      case 4016:error="not initialized array";break;
      case 4017:error="dll calls are not allowed";break;
      case 4018:error="cannot load library";break;
      case 4019:error="cannot call function";break;
      case 4020:error="expert function calls are not allowed";break;
      case 4021:error="not enough memory for temp string returned from function";break;
      case 4022:error="system is busy (never generated error)";break;
      case 4050:error="invalid function parameters count";break;
      case 4051:error="invalid function parameter value";break;
      case 4052:error="string function internal error";break;
      case 4053:error="some array error";break;
      case 4054:error="incorrect series array using";break;
      case 4055:error="custom indicator error";break;
      case 4056:error="arrays are incompatible";break;
      case 4057:error="global variables processing error";break;
      case 4058:error="global variable not found";break;
      case 4059:error="function is not allowed in testing mode";break;
      case 4060:error="function is not confirmed";break;
      case 4061:error="send mail error";break;
      case 4062:error="string parameter expected";break;
      case 4063:error="integer parameter expected";break;
      case 4064:error="double parameter expected";break;
      case 4065:error="array as parameter expected";break;
      case 4066:error="requested history data in update state";break;
      case 4099:error="end of file";break;
      case 4100:error="some file error";break;
      case 4101:error="wrong file name";break;
      case 4102:error="too many opened files";break;
      case 4103:error="cannot open file";break;
      case 4104:error="incompatible access to a file";break;
      case 4105:error="no order selected";break;
      case 4106:error="unknown symbol";break;
      case 4107:error="invalid price parameter for trade function";break;
      case 4108:error="invalid ticket";break;
      case 4109:error="trade is not allowed";break;
      case 4110:error="longs are not allowed";break;
      case 4111:error="shorts are not allowed";break;
      case 4200:error="object is already exist";break;
      case 4201:error="unknown object property";break;
      case 4202:error="object is not exist";break;
      case 4203:error="unknown object type";break;
      case 4204:error="no object name";break;
      case 4205:error="object coordinates error";break;
      case 4206:error="no specified subwindow";break;
      default:error="unknown error";
   }
   return(error);
}

