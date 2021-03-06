//+------------------------------------------------------------------+
//|                        Multi Pair Pivot Point Scanner Alerts.mq4 |
//|                                                         NickBixy |
//|                           https://www.mql5.com/en/users/nickbixy |
//+------------------------------------------------------------------+
#property copyright "NickBixy"
#property link      "https://www.mql5.com/en/users/nickbixy"
#property version   "1.00"
#property strict
#property description "Indicator scans multiple symbols looking for when the price crosses a pivot point then it alerts the trader."
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum pivotTypes
  {
   Standard,
   Camarilla,
   Woodie,
   Fibonacci
  };

input pivotTypes pivotSelection=0;//Pivot Point Type (formula)

input string symbols="EURUSD,GBPUSD,USDCHF,USDCAD,SP,CL"; //Symbols to scan (separate with comma no space)
input string symbolPrefix="_ecn"; //Symbol prefix (leave blank if none)

input int alertInternalMinutes=15;//Alert interval in minutes (wait time between same alert)

input bool useDailyPivotAlert=true; // Daily pp cross alerts (pp = pivot points)
input bool useWeeklyPivotAlert=true; // Weekly pp cross alerts
input bool useMonthlyPivotAlert=true; // Monthly pp cross alerts

input bool alertBox=true;//Alert message box (alert pop up box)
input bool sendNotifications=true;//Send notifications alert (mobile alert)

input bool printOutPivotPoints=false;
input int printOutPivotPointsSymbolIndex=0;

int numSymbols=0; //the number of symbols to scan
int alertIntervalTimeSeconds;

string symbolList[]; // array of symbols
datetime symbolTodaysDate[]; //array of symbol dates today used for checking for new day for wach symbol

                             //stores all the pivot points for each timeframe
double dailyPivots[][9];
double weeklyPivots[][9];
double monthlyPivots[][9];

//stores all the bool flags to help detect price cross pivot point for each timeframe
bool dailyPivotsFlag[][9];
bool weeklyPivotsFlag[][9];
bool monthlyPivotsFlag[][9];

//stores the time to wait for alert time interval for each pivot points timeframe
datetime   dailyPivotsWaitTill[][9];
datetime   weeklyPivotsWaitTill[][9];
datetime   monthlyPivotsWaitTill[][9];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"PP MultiPair Scanner");

   alertIntervalTimeSeconds=alertInternalMinutes*60;//waiting time between alerts

   getSymbols();//converts the symbol string to list of symbols

                //checks if all symbols exits, if not removes indicator from chart
   if(testSymbols())
     {
      initializePivotPoints();//sets all the pivot points values and pivotsFlags 
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//check each symbol if thier is a new day , if true recalculate pivot points
   for(int i=0;i<numSymbols;i++)
     {
      if(IsNewDay(symbolList[i]+symbolPrefix,i))//check if new day
        {
         clearPivotWaitTills(i);

         switch(pivotSelection)//initalize seleted pivot point forumula
           {
            case Standard :       initializeStandardPivot(symbolList[i]+symbolPrefix,i);     break;
            case Camarilla :      initializeCamarillaPivot(symbolList[i]+symbolPrefix,i);    break;
            case Woodie :         initializeWoodiePivot(symbolList[i]+symbolPrefix,i);       break;
            case Fibonacci :      initializeFibonacciPivot(symbolList[i]+symbolPrefix,i);    break;
           }
        }
     }//end of for loop

   switch(pivotSelection)//Checking for when price crosses over the pivot points, then alerts the trader
     {
      case Standard :       standardPivotCrossCheck();      break;
      case Camarilla :      camarillaPivotCrossCheck();     break;
      case Woodie :         woodiePivotCrossCheck();        break;
      case Fibonacci :      fibonacciPivotCrossCheck();     break;
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializePivotPoints()
  {
   ArrayResize(symbolTodaysDate,numSymbols);//resize to the number of symbols being used

   if(useDailyPivotAlert) //get the double 2d arrays ready based on number of symbols
     {
      ArrayResize(dailyPivots,numSymbols);
      ArrayResize(dailyPivotsFlag,numSymbols);
      ArrayResize(dailyPivotsWaitTill,numSymbols);
     }

   if(useWeeklyPivotAlert)
     {
      ArrayResize(weeklyPivots,numSymbols);
      ArrayResize(weeklyPivotsFlag,numSymbols);
      ArrayResize(weeklyPivotsWaitTill,numSymbols);
     }

   if(useMonthlyPivotAlert)
     {
      ArrayResize(monthlyPivots,numSymbols);
      ArrayResize(monthlyPivotsFlag,numSymbols);
      ArrayResize(monthlyPivotsWaitTill,numSymbols);
     }

//////////////////////////////////////////////////////////////////////
   if(pivotSelection==Standard)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeStandardPivot(symbolList[i]+symbolPrefix,i);
        }
     }
   if(pivotSelection==Camarilla)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeCamarillaPivot(symbolList[i]+symbolPrefix,i);
        }
     }
   if(pivotSelection==Woodie)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeWoodiePivot(symbolList[i]+symbolPrefix,i);
        }
     }
   if(pivotSelection==Fibonacci)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeFibonacciPivot(symbolList[i]+symbolPrefix,i);
        }
     }
//////////////////////////////////////////////////////////////////////

   if(printOutPivotPoints)
      printOutPivotPoint(printOutPivotPointsSymbolIndex);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getSymbols()
  {
   string sep=",";
   ushort u_sep;
   u_sep=StringGetCharacter(sep,0);
   StringSplit(symbols,u_sep,symbolList);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool testSymbols()
  {
   bool result=true;
   numSymbols=ArraySize(symbolList);//get the number of how many symbols are in the symbolList array
   for(int i=0;i<numSymbols;i++)
     {
      double bid=MarketInfo(symbolList[i]+symbolPrefix,MODE_BID);

      if(GetLastError()==4106) // unknown symbol
        {
         result=false;
         Alert("Can't find this symbol: "+symbolList[i]+symbolPrefix+" , REMOVING INDICATOR FROM CHART");
         ChartIndicatorDelete(0,0,"PP MultiPair Scanner");
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewDay(string symbol,int index)
  {
   bool result;
   if(symbolTodaysDate[index]!=iTime(symbol,PERIOD_D1,0))
     {
      symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);
     // Print("Its a new day ",TimeToStr(iTime(symbol,PERIOD_D1,0)));
      result=true;
     }
   else
     {
      result=false;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void clearPivotWaitTills(int index)
  {
   int numOfPP=ArrayRange(dailyPivotsWaitTill,1);

   for(int j=0;j<numOfPP;j++)
     {
      dailyPivotsWaitTill[index][j]=(datetime)"1971.01.01 00:00:00";
      weeklyPivotsWaitTill[index][j]=(datetime)"1971.01.01 00:00:00";
      monthlyPivotsWaitTill[index][j]=(datetime)"1971.01.01 00:00:00";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string symbol,string pivotLevelName,pivotTypes pType)
  {
   if(alertBox)
      Alert(symbol+" "+pivotLevelName+" Crossed, "+EnumToString(pType));
   if(sendNotifications)
      SendNotification(symbol+" "+pivotLevelName+" Crossed, "+EnumToString(pType));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void standardPivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {

   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double prevRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh = iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose=iClose(symbolName,timeFrame,1);

   double PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,symbolDigits);
   double R1 = NormalizeDouble((PP * 2)-prevLow,symbolDigits);
   double S1 = NormalizeDouble((PP * 2)-prevHigh,symbolDigits);
   double R2 = NormalizeDouble(PP + prevHigh - prevLow,symbolDigits);
   double S2 = NormalizeDouble(PP - prevHigh + prevLow,symbolDigits);
   double R3 = NormalizeDouble(R1 + (prevHigh-prevLow),symbolDigits);
   double S3 = NormalizeDouble(prevLow - 2 * (prevHigh-PP),symbolDigits);

   ppArrayRef[symbolIndex][0]=PP;
   ppArrayRef[symbolIndex][1]=S1;
   ppArrayRef[symbolIndex][2]=S2;
   ppArrayRef[symbolIndex][3]=S3;
   ppArrayRef[symbolIndex][4]=R1;
   ppArrayRef[symbolIndex][5]=R2;
   ppArrayRef[symbolIndex][6]=R3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void camarillaPivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {

   double camRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh=iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose=iClose(symbolName,timeFrame,1);

   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double R1 = NormalizeDouble(((1.1 / 12) * camRange) + prevClose,symbolDigits);
   double R2 = NormalizeDouble(((1.1 / 6) * camRange) + prevClose,symbolDigits);
   double R3 = NormalizeDouble(((1.1 / 4) * camRange) + prevClose,symbolDigits);
   double R4= NormalizeDouble(((1.1/2) * camRange)+prevClose,symbolDigits);
   double S1= NormalizeDouble(prevClose -((1.1/12) * camRange),symbolDigits);
   double S2= NormalizeDouble(prevClose -((1.1/6) * camRange),symbolDigits);
   double S3 = NormalizeDouble(prevClose - ((1.1 / 4) * camRange),symbolDigits);
   double S4 = NormalizeDouble(prevClose - ((1.1 / 2) * camRange),symbolDigits);
   double PP = NormalizeDouble((R4+S4)/2,symbolDigits);


   ppArrayRef[symbolIndex][0]=PP;
   ppArrayRef[symbolIndex][1]=S1;
   ppArrayRef[symbolIndex][2]=S2;
   ppArrayRef[symbolIndex][3]=S3;
   ppArrayRef[symbolIndex][4]=S4;
   ppArrayRef[symbolIndex][5]=R1;
   ppArrayRef[symbolIndex][6]=R2;
   ppArrayRef[symbolIndex][7]=R3;
   ppArrayRef[symbolIndex][8]=R4;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void woodiePivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {
   double prevRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh = iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose = iClose(symbolName, timeFrame,1);
   double todayOpen = iOpen(symbolName, timeFrame,0);

   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double PP = NormalizeDouble((prevHigh+prevLow+(todayOpen*2))/4,symbolDigits);
   double R1 = NormalizeDouble((PP * 2)-prevLow,symbolDigits);
   double R2 = NormalizeDouble(PP + prevRange,symbolDigits);
   double S1 = NormalizeDouble((PP * 2)-prevHigh,symbolDigits);
   double S2 = NormalizeDouble(PP - prevRange,symbolDigits);

   ppArrayRef[symbolIndex][0]=PP;
   ppArrayRef[symbolIndex][1]=S1;
   ppArrayRef[symbolIndex][2]=S2;
   ppArrayRef[symbolIndex][3]=R1;
   ppArrayRef[symbolIndex][4]=R2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fibonacciPivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {
   double prevRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh = iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose=iClose(symbolName,timeFrame,1);

   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,symbolDigits);
   double R3 = NormalizeDouble(PP + ((prevRange)*1.000),symbolDigits);
   double R2 = NormalizeDouble(PP + ((prevRange)*.618),symbolDigits);
   double R1 = NormalizeDouble(PP + ((prevRange)*.382),symbolDigits);
   double S1 = NormalizeDouble(PP - ((prevRange)*.382),symbolDigits);
   double S2 = NormalizeDouble(PP - ((prevRange)*.618),symbolDigits);
   double S3 = NormalizeDouble(PP - ((prevRange)*1.000),symbolDigits);

   ppArrayRef[symbolIndex][0]=PP;
   ppArrayRef[symbolIndex][1]=S1;
   ppArrayRef[symbolIndex][2]=S2;
   ppArrayRef[symbolIndex][3]=S3;
   ppArrayRef[symbolIndex][4]=R1;
   ppArrayRef[symbolIndex][5]=R2;
   ppArrayRef[symbolIndex][6]=R3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeStandardPivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   if(useDailyPivotAlert)
     {
      standardPivotPoint(PERIOD_D1,dailyPivots,index,symbol);

      //D PP
      if(bid>=dailyPivots[index][0])
         dailyPivotsFlag[index][0]=true;
      else
         dailyPivotsFlag[index][0]=false;

      //D S1
      if(bid>=dailyPivots[index][1])
         dailyPivotsFlag[index][1]=true;
      else
         dailyPivotsFlag[index][1]=false;

      //D S2
      if(bid>=dailyPivots[index][2])
         dailyPivotsFlag[index][2]=true;
      else
         dailyPivotsFlag[index][2]=false;

      //D S3
      if(bid>=dailyPivots[index][3])
         dailyPivotsFlag[index][3]=true;
      else
         dailyPivotsFlag[index][3]=false;

      //D R1
      if(bid>=dailyPivots[index][4])
         dailyPivotsFlag[index][4]=true;
      else
         dailyPivotsFlag[index][4]=false;

      //D R2
      if(bid>=dailyPivots[index][5])
         dailyPivotsFlag[index][5]=true;
      else
         dailyPivotsFlag[index][5]=false;

      //D R3
      if(bid>=dailyPivots[index][6])
         dailyPivotsFlag[index][6]=true;
      else
         dailyPivotsFlag[index][6]=false;
     }//end of daily
   if(useWeeklyPivotAlert)
     {
      standardPivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      //W PP
      if(bid>=weeklyPivots[index][0])
         weeklyPivotsFlag[index][0]=true;
      else
         weeklyPivotsFlag[index][0]=false;

      //W S1
      if(bid>=weeklyPivots[index][1])
         weeklyPivotsFlag[index][1]=true;
      else
         weeklyPivotsFlag[index][1]=false;

      //W S2
      if(bid>=weeklyPivots[index][2])
         weeklyPivotsFlag[index][2]=true;
      else
         weeklyPivotsFlag[index][2]=false;

      //W S3
      if(bid>=weeklyPivots[index][3])
         weeklyPivotsFlag[index][3]=true;
      else
         weeklyPivotsFlag[index][3]=false;

      //W R1
      if(bid>=weeklyPivots[index][4])
         weeklyPivotsFlag[index][4]=true;
      else
         weeklyPivotsFlag[index][4]=false;

      //W R2
      if(bid>=weeklyPivots[index][5])
         weeklyPivotsFlag[index][5]=true;
      else
         weeklyPivotsFlag[index][5]=false;

      //W R3
      if(bid>=weeklyPivots[index][6])
         weeklyPivotsFlag[index][6]=true;
      else
         weeklyPivotsFlag[index][6]=false;
     }//end of weekly
   if(useMonthlyPivotAlert)
     {
      standardPivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      //M PP
      if(bid>=monthlyPivots[index][0])
         monthlyPivotsFlag[index][0]=true;
      else
         monthlyPivotsFlag[index][0]=false;

      //M S1
      if(bid>=monthlyPivots[index][1])
         monthlyPivotsFlag[index][1]=true;
      else
         monthlyPivotsFlag[index][1]=false;

      //M S2
      if(bid>=monthlyPivots[index][2])
         monthlyPivotsFlag[index][2]=true;
      else
         monthlyPivotsFlag[index][2]=false;

      //M S3
      if(bid>=monthlyPivots[index][3])
         monthlyPivotsFlag[index][3]=true;
      else
         monthlyPivotsFlag[index][3]=false;

      //M R1
      if(bid>=monthlyPivots[index][4])
         monthlyPivotsFlag[index][4]=true;
      else
         monthlyPivotsFlag[index][4]=false;

      //M R2
      if(bid>=monthlyPivots[index][5])
         monthlyPivotsFlag[index][5]=true;
      else
         monthlyPivotsFlag[index][5]=false;

      //M R3
      if(bid>=monthlyPivots[index][6])
         monthlyPivotsFlag[index][6]=true;
      else
         monthlyPivotsFlag[index][6]=false;
     }//end of monthly

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void standardPivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolList[i]+symbolPrefix;

      bid=MarketInfo(symbolName,MODE_BID);

      if(useDailyPivotAlert)//daily pivot point cross check
        {
         //D PP
         pivotLevelName="Daily PP";
         result=bid>=dailyPivots[i][0];
         if(result!=dailyPivotsFlag[i][0])
           {
            dailyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=dailyPivotsWaitTill[i][0])
              {
               dailyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S1
         pivotLevelName="Daily S1";
         result=bid>=dailyPivots[i][1];
         if(result!=dailyPivotsFlag[i][1])
           {
            dailyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][1])
              {
               dailyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S2
         pivotLevelName="Daily S2";
         result=bid>=dailyPivots[i][2];
         if(result!=dailyPivotsFlag[i][2])
           {
            dailyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][2])
              {
               dailyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S3
         pivotLevelName="Daily S3";
         result=bid>=dailyPivots[i][3];
         if(result!=dailyPivotsFlag[i][3])
           {
            dailyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][3])
              {
               dailyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R1
         pivotLevelName="Daily R1";
         result=bid>=dailyPivots[i][4];
         if(result!=dailyPivotsFlag[i][4])
           {
            dailyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][4])
              {
               dailyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R2
         pivotLevelName="Daily R2";
         result=bid>=dailyPivots[i][5];
         if(result!=dailyPivotsFlag[i][5])
           {
            dailyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][5])
              {
               dailyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R3
         pivotLevelName="Daily R3";
         result=bid>=dailyPivots[i][6];
         if(result!=dailyPivotsFlag[i][6])
           {
            dailyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][6])
              {
               dailyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
        }//end of daily code
      if(useWeeklyPivotAlert)//weekly pivot point cross check
        {
         //W PP
         pivotLevelName="Weekly PP";
         result=bid>=weeklyPivots[i][0];
         if(result!=weeklyPivotsFlag[i][0])
           {
            weeklyPivotsFlag[i][0]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][0])
              {
               weeklyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S1
         pivotLevelName="Weekly S1";
         result=bid>=weeklyPivots[i][1];
         if(result!=weeklyPivotsFlag[i][1])
           {
            weeklyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][1])
              {
               weeklyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S2
         pivotLevelName="Weekly S2";
         result=bid>=weeklyPivots[i][2];
         if(result!=weeklyPivotsFlag[i][2])
           {
            weeklyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][2])
              {
               weeklyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S3
         pivotLevelName="Weekly S3";
         result=bid>=weeklyPivots[i][3];
         if(result!=weeklyPivotsFlag[i][3])
           {
            weeklyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][3])
              {
               weeklyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R1
         pivotLevelName="Weekly R1";
         result=bid>=weeklyPivots[i][4];
         if(result!=weeklyPivotsFlag[i][4])
           {
            weeklyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][4])
              {
               weeklyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R2
         pivotLevelName="Weekly R2";
         result=bid>=weeklyPivots[i][5];
         if(result!=weeklyPivotsFlag[i][5])
           {
            weeklyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][5])
              {
               weeklyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R3
         pivotLevelName="Weekly R3";
         result=bid>=weeklyPivots[i][6];
         if(result!=weeklyPivotsFlag[i][6])
           {
            weeklyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][6])
              {
               weeklyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
        }//end of weekly code
      if(useMonthlyPivotAlert)//monthly pivot point cross check
        {
         //M PP
         pivotLevelName="Monthly PP";
         result=bid>=monthlyPivots[i][0];
         if(result!=monthlyPivotsFlag[i][0])
           {
            monthlyPivotsFlag[i][0]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][0])
              {
               monthlyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S1
         pivotLevelName="Monthly S1";
         result=bid>=monthlyPivots[i][1];
         if(result!=monthlyPivotsFlag[i][1])
           {
            monthlyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][1])
              {
               monthlyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S2
         pivotLevelName="Monthly S2";
         result=bid>=monthlyPivots[i][2];
         if(result!=monthlyPivotsFlag[i][2])
           {
            monthlyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][2])
              {
               monthlyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S3
         pivotLevelName="Monthly S3";
         result=bid>=monthlyPivots[i][3];
         if(result!=monthlyPivotsFlag[i][3])
           {
            monthlyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][3])
              {
               monthlyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R1
         pivotLevelName="Monthly R1";
         result=bid>=monthlyPivots[i][4];
         if(result!=monthlyPivotsFlag[i][4])
           {
            monthlyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][4])
              {
               monthlyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R2
         pivotLevelName="Monthly R2";
         result=bid>=monthlyPivots[i][5];
         if(result!=monthlyPivotsFlag[i][5])
           {
            monthlyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][5])
              {
               monthlyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R3
         pivotLevelName="Monthly R3";
         result=bid>=monthlyPivots[i][6];
         if(result!=monthlyPivotsFlag[i][6])
           {
            monthlyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][6])
              {
               monthlyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeCamarillaPivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   if(useDailyPivotAlert)
     {
      camarillaPivotPoint(PERIOD_D1,dailyPivots,index,symbol);

      //D PP
      if(bid>=dailyPivots[index][0])
         dailyPivotsFlag[index][0]=true;
      else
         dailyPivotsFlag[index][0]=false;

      //D S1
      if(bid>=dailyPivots[index][1])
         dailyPivotsFlag[index][1]=true;
      else
         dailyPivotsFlag[index][1]=false;

      //D S2
      if(bid>=dailyPivots[index][2])
         dailyPivotsFlag[index][2]=true;
      else
         dailyPivotsFlag[index][2]=false;

      //D S3
      if(bid>=dailyPivots[index][3])
         dailyPivotsFlag[index][3]=true;
      else
         dailyPivotsFlag[index][3]=false;

      //D S4
      if(bid>=dailyPivots[index][4])
         dailyPivotsFlag[index][4]=true;
      else
         dailyPivotsFlag[index][4]=false;

      //D R1
      if(bid>=dailyPivots[index][5])
         dailyPivotsFlag[index][5]=true;
      else
         dailyPivotsFlag[index][5]=false;

      //D R2
      if(bid>=dailyPivots[index][6])
         dailyPivotsFlag[index][6]=true;
      else
         dailyPivotsFlag[index][6]=false;

      //D R3
      if(bid>=dailyPivots[index][7])
         dailyPivotsFlag[index][7]=true;
      else
         dailyPivotsFlag[index][7]=false;

      //D R4
      if(bid>=dailyPivots[index][8])
         dailyPivotsFlag[index][8]=true;
      else
         dailyPivotsFlag[index][8]=false;

     }//end of daily
   if(useWeeklyPivotAlert)
     {
      camarillaPivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      //W PP
      if(bid>=weeklyPivots[index][0])
         weeklyPivotsFlag[index][0]=true;
      else
         weeklyPivotsFlag[index][0]=false;

      //W S1
      if(bid>=weeklyPivots[index][1])
         weeklyPivotsFlag[index][1]=true;
      else
         weeklyPivotsFlag[index][1]=false;

      //W S2
      if(bid>=weeklyPivots[index][2])
         weeklyPivotsFlag[index][2]=true;
      else
         weeklyPivotsFlag[index][2]=false;

      //W S3
      if(bid>=weeklyPivots[index][3])
         weeklyPivotsFlag[index][3]=true;
      else
         weeklyPivotsFlag[index][3]=false;

      //W S4
      if(bid>=weeklyPivots[index][4])
         weeklyPivotsFlag[index][4]=true;
      else
         weeklyPivotsFlag[index][4]=false;

      //W R1
      if(bid>=weeklyPivots[index][5])
         weeklyPivotsFlag[index][5]=true;
      else
         weeklyPivotsFlag[index][5]=false;

      //W R2
      if(bid>=weeklyPivots[index][6])
         weeklyPivotsFlag[index][6]=true;
      else
         weeklyPivotsFlag[index][6]=false;

      //W R3
      if(bid>=weeklyPivots[index][7])
         weeklyPivotsFlag[index][7]=true;
      else
         weeklyPivotsFlag[index][7]=false;

      //W R4
      if(bid>=weeklyPivots[index][8])
         weeklyPivotsFlag[index][8]=true;
      else
         weeklyPivotsFlag[index][8]=false;

     }//end of weekly
   if(useMonthlyPivotAlert)
     {
      camarillaPivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      //M PP
      if(bid>=monthlyPivots[index][0])
         monthlyPivotsFlag[index][0]=true;
      else
         monthlyPivotsFlag[index][0]=false;

      //M S1
      if(bid>=monthlyPivots[index][1])
         monthlyPivotsFlag[index][1]=true;
      else
         monthlyPivotsFlag[index][1]=false;

      //M S2
      if(bid>=monthlyPivots[index][2])
         monthlyPivotsFlag[index][2]=true;
      else
         monthlyPivotsFlag[index][2]=false;

      //M S3
      if(bid>=monthlyPivots[index][3])
         monthlyPivotsFlag[index][3]=true;
      else
         monthlyPivotsFlag[index][3]=false;

      //M S4
      if(bid>=monthlyPivots[index][4])
         monthlyPivotsFlag[index][4]=true;
      else
         monthlyPivotsFlag[index][4]=false;

      //M R1
      if(bid>=monthlyPivots[index][5])
         monthlyPivotsFlag[index][5]=true;
      else
         monthlyPivotsFlag[index][5]=false;

      //M R2
      if(bid>=monthlyPivots[index][6])
         monthlyPivotsFlag[index][6]=true;
      else
         monthlyPivotsFlag[index][6]=false;

      //M R3
      if(bid>=monthlyPivots[index][7])
         monthlyPivotsFlag[index][7]=true;
      else
         monthlyPivotsFlag[index][7]=false;

      //M R4
      if(bid>=monthlyPivots[index][8])
         monthlyPivotsFlag[index][8]=true;
      else
         monthlyPivotsFlag[index][8]=false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void camarillaPivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolList[i]+symbolPrefix;

      bid=MarketInfo(symbolName,MODE_BID);

      if(useDailyPivotAlert)//daily pivot point cross check
        {
         //D PP
         pivotLevelName="Daily PP";
         result=bid>=dailyPivots[i][0];
         if(result!=dailyPivotsFlag[i][0])
           {
            dailyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=dailyPivotsWaitTill[i][0])
              {
               dailyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S1
         pivotLevelName="Daily S1";
         result=bid>=dailyPivots[i][1];
         if(result!=dailyPivotsFlag[i][1])
           {
            dailyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][1])
              {
               dailyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S2
         pivotLevelName="Daily S2";
         result=bid>=dailyPivots[i][2];
         if(result!=dailyPivotsFlag[i][2])
           {
            dailyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][2])
              {
               dailyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S3
         pivotLevelName="Daily S3";
         result=bid>=dailyPivots[i][3];
         if(result!=dailyPivotsFlag[i][3])
           {
            dailyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][3])
              {
               dailyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S4
         pivotLevelName="Daily S4";
         result=bid>=dailyPivots[i][4];
         if(result!=dailyPivotsFlag[i][4])
           {
            dailyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][4])
              {
               dailyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R1
         pivotLevelName="Daily R1";
         result=bid>=dailyPivots[i][5];
         if(result!=dailyPivotsFlag[i][5])
           {
            dailyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][5])
              {
               dailyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R2
         pivotLevelName="Daily R2";
         result=bid>=dailyPivots[i][6];
         if(result!=dailyPivotsFlag[i][6])
           {
            dailyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][6])
              {
               dailyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R3
         pivotLevelName="Daily R3";
         result=bid>=dailyPivots[i][7];
         if(result!=dailyPivotsFlag[i][7])
           {
            dailyPivotsFlag[i][7]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][7])
              {
               dailyPivotsWaitTill[i][7]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }

         //D R4
         pivotLevelName="Daily R4";
         result=bid>=dailyPivots[i][8];
         if(result!=dailyPivotsFlag[i][8])
           {
            dailyPivotsFlag[i][8]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][8])
              {
               dailyPivotsWaitTill[i][8]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }//end

        }//end of daily code
      if(useWeeklyPivotAlert)//weekly pivot point cross check
        {
         //W PP
         pivotLevelName="Weekly PP";
         result=bid>=weeklyPivots[i][0];
         if(result!=weeklyPivotsFlag[i][0])
           {
            weeklyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=weeklyPivotsWaitTill[i][0])
              {
               weeklyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S1
         pivotLevelName="Weekly S1";
         result=bid>=weeklyPivots[i][1];
         if(result!=weeklyPivotsFlag[i][1])
           {
            weeklyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][1])
              {
               weeklyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S2
         pivotLevelName="Weekly S2";
         result=bid>=weeklyPivots[i][2];
         if(result!=weeklyPivotsFlag[i][2])
           {
            weeklyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][2])
              {
               weeklyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S3
         pivotLevelName="Weekly S3";
         result=bid>=weeklyPivots[i][3];
         if(result!=weeklyPivotsFlag[i][3])
           {
            weeklyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][3])
              {
               weeklyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S4
         pivotLevelName="Weekly S4";
         result=bid>=weeklyPivots[i][4];
         if(result!=weeklyPivotsFlag[i][4])
           {
            weeklyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][4])
              {
               weeklyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R1
         pivotLevelName="Weekly R1";
         result=bid>=weeklyPivots[i][5];
         if(result!=weeklyPivotsFlag[i][5])
           {
            weeklyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][5])
              {
               weeklyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R2
         pivotLevelName="Weekly R2";
         result=bid>=weeklyPivots[i][6];
         if(result!=weeklyPivotsFlag[i][6])
           {
            weeklyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][6])
              {
               weeklyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R3
         pivotLevelName="Weekly R3";
         result=bid>=weeklyPivots[i][7];
         if(result!=weeklyPivotsFlag[i][7])
           {
            weeklyPivotsFlag[i][7]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][7])
              {
               weeklyPivotsWaitTill[i][7]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }

         //W R4
         pivotLevelName="Weekly R4";
         result=bid>=weeklyPivots[i][8];
         if(result!=weeklyPivotsFlag[i][8])
           {
            weeklyPivotsFlag[i][8]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][8])
              {
               weeklyPivotsWaitTill[i][8]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }//end
        }//end of weekly code
      if(useMonthlyPivotAlert)//monthly pivot point cross check
        {
         //M PP
         pivotLevelName="Monthly PP";
         result=bid>=monthlyPivots[i][0];
         if(result!=monthlyPivotsFlag[i][0])
           {
            monthlyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=monthlyPivotsWaitTill[i][0])
              {
               monthlyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S1
         pivotLevelName="Monthly S1";
         result=bid>=monthlyPivots[i][1];
         if(result!=monthlyPivotsFlag[i][1])
           {
            monthlyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][1])
              {
               monthlyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S2
         pivotLevelName="Monthly S2";
         result=bid>=monthlyPivots[i][2];
         if(result!=monthlyPivotsFlag[i][2])
           {
            monthlyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][2])
              {
               monthlyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S3
         pivotLevelName="Monthly S3";
         result=bid>=monthlyPivots[i][3];
         if(result!=monthlyPivotsFlag[i][3])
           {
            monthlyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][3])
              {
               monthlyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S4
         pivotLevelName="Monthly S4";
         result=bid>=monthlyPivots[i][4];
         if(result!=monthlyPivotsFlag[i][4])
           {
            monthlyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][4])
              {
               monthlyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R1
         pivotLevelName="Monthly R1";
         result=bid>=monthlyPivots[i][5];
         if(result!=monthlyPivotsFlag[i][5])
           {
            monthlyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][5])
              {
               monthlyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R2
         pivotLevelName="Monthly R2";
         result=bid>=monthlyPivots[i][6];
         if(result!=monthlyPivotsFlag[i][6])
           {
            monthlyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][6])
              {
               monthlyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R3
         pivotLevelName="Monthly R3";
         result=bid>=monthlyPivots[i][7];
         if(result!=monthlyPivotsFlag[i][7])
           {
            monthlyPivotsFlag[i][7]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][7])
              {
               monthlyPivotsWaitTill[i][7]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }

         //M R4
         pivotLevelName="Monthly R4";
         result=bid>=monthlyPivots[i][8];
         if(result!=monthlyPivotsFlag[i][8])
           {
            monthlyPivotsFlag[i][8]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][8])
              {
               monthlyPivotsWaitTill[i][8]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }//end
        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeWoodiePivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   if(useDailyPivotAlert)
     {
      woodiePivotPoint(PERIOD_D1,dailyPivots,index,symbol);

      //D PP
      if(bid>=dailyPivots[index][0])
         dailyPivotsFlag[index][0]=true;
      else
         dailyPivotsFlag[index][0]=false;

      //D S1
      if(bid>=dailyPivots[index][1])
         dailyPivotsFlag[index][1]=true;
      else
         dailyPivotsFlag[index][1]=false;

      //D S2
      if(bid>=dailyPivots[index][2])
         dailyPivotsFlag[index][2]=true;
      else
         dailyPivotsFlag[index][2]=false;

      //D R1
      if(bid>=dailyPivots[index][3])
         dailyPivotsFlag[index][3]=true;
      else
         dailyPivotsFlag[index][3]=false;

      //D R2
      if(bid>=dailyPivots[index][4])
         dailyPivotsFlag[index][4]=true;
      else
         dailyPivotsFlag[index][4]=false;

     }//end of daily
   if(useWeeklyPivotAlert)
     {
      woodiePivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      //W PP
      if(bid>=weeklyPivots[index][0])
         weeklyPivotsFlag[index][0]=true;
      else
         weeklyPivotsFlag[index][0]=false;

      //W S1
      if(bid>=weeklyPivots[index][1])
         weeklyPivotsFlag[index][1]=true;
      else
         weeklyPivotsFlag[index][1]=false;

      //W S2
      if(bid>=weeklyPivots[index][2])
         weeklyPivotsFlag[index][2]=true;
      else
         weeklyPivotsFlag[index][2]=false;

      //W R1
      if(bid>=weeklyPivots[index][3])
         weeklyPivotsFlag[index][3]=true;
      else
         weeklyPivotsFlag[index][3]=false;

      //W R2
      if(bid>=weeklyPivots[index][4])
         weeklyPivotsFlag[index][4]=true;
      else
         weeklyPivotsFlag[index][4]=false;

     }//end of weekly
   if(useMonthlyPivotAlert)
     {
      woodiePivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      //M PP
      if(bid>=monthlyPivots[index][0])
         monthlyPivotsFlag[index][0]=true;
      else
         monthlyPivotsFlag[index][0]=false;

      //M S1
      if(bid>=monthlyPivots[index][1])
         monthlyPivotsFlag[index][1]=true;
      else
         monthlyPivotsFlag[index][1]=false;

      //M S2
      if(bid>=monthlyPivots[index][2])
         monthlyPivotsFlag[index][2]=true;
      else
         monthlyPivotsFlag[index][2]=false;

      //M R1
      if(bid>=monthlyPivots[index][3])
         monthlyPivotsFlag[index][3]=true;
      else
         monthlyPivotsFlag[index][3]=false;

      //M R2
      if(bid>=monthlyPivots[index][4])
         monthlyPivotsFlag[index][4]=true;
      else
         monthlyPivotsFlag[index][4]=false;

     }//end of monthly

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void woodiePivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolList[i]+symbolPrefix;

      bid=MarketInfo(symbolName,MODE_BID);

      if(useDailyPivotAlert)//daily pivot point cross check
        {
         //D PP
         pivotLevelName="Daily PP";
         result=bid>=dailyPivots[i][0];
         if(result!=dailyPivotsFlag[i][0])
           {
            dailyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=dailyPivotsWaitTill[i][0])
              {
               dailyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S1
         pivotLevelName="Daily S1";
         result=bid>=dailyPivots[i][1];
         if(result!=dailyPivotsFlag[i][1])
           {
            dailyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][1])
              {
               dailyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S2
         pivotLevelName="Daily S2";
         result=bid>=dailyPivots[i][2];
         if(result!=dailyPivotsFlag[i][2])
           {
            dailyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][2])
              {
               dailyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R1
         pivotLevelName="Daily R1";
         result=bid>=dailyPivots[i][3];
         if(result!=dailyPivotsFlag[i][3])
           {
            dailyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][3])
              {
               dailyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R2
         pivotLevelName="Daily R2";
         result=bid>=dailyPivots[i][4];
         if(result!=dailyPivotsFlag[i][4])
           {
            dailyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][4])
              {
               dailyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }

        }//end of daily code
      if(useWeeklyPivotAlert)//weekly pivot point cross check
        {
         //W PP
         pivotLevelName="Weekly PP";
         result=bid>=weeklyPivots[i][0];
         if(result!=weeklyPivotsFlag[i][0])
           {
            weeklyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=weeklyPivotsWaitTill[i][0])
              {
               weeklyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S1
         pivotLevelName="Weekly S1";
         result=bid>=weeklyPivots[i][1];
         if(result!=weeklyPivotsFlag[i][1])
           {
            weeklyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][1])
              {
               weeklyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S2
         pivotLevelName="Weekly S2";
         result=bid>=weeklyPivots[i][2];
         if(result!=weeklyPivotsFlag[i][2])
           {
            weeklyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][2])
              {
               weeklyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R1
         pivotLevelName="Weekly R1";
         result=bid>=weeklyPivots[i][3];
         if(result!=weeklyPivotsFlag[i][3])
           {
            weeklyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][3])
              {
               weeklyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R2
         pivotLevelName="Weekly R2";
         result=bid>=weeklyPivots[i][4];
         if(result!=weeklyPivotsFlag[i][4])
           {
            weeklyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][4])
              {
               weeklyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }

        }//end of weekly code
      if(useMonthlyPivotAlert)//monthly pivot point cross check
        {
         //M PP
         pivotLevelName="Monthly PP";
         result=bid>=monthlyPivots[i][0];
         if(result!=monthlyPivotsFlag[i][0])
           {
            monthlyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=monthlyPivotsWaitTill[i][0])
              {
               monthlyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S1
         pivotLevelName="Monthly S1";
         result=bid>=monthlyPivots[i][1];
         if(result!=monthlyPivotsFlag[i][1])
           {
            monthlyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][1])
              {
               monthlyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S2
         pivotLevelName="Monthly S2";
         result=bid>=monthlyPivots[i][2];
         if(result!=monthlyPivotsFlag[i][2])
           {
            monthlyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][2])
              {
               monthlyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R1
         pivotLevelName="Monthly R1";
         result=bid>=monthlyPivots[i][3];
         if(result!=monthlyPivotsFlag[i][3])
           {
            monthlyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][3])
              {
               monthlyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R2
         pivotLevelName="Monthly R2";
         result=bid>=monthlyPivots[i][4];
         if(result!=monthlyPivotsFlag[i][4])
           {
            monthlyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][4])
              {
               monthlyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }

        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeFibonacciPivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   if(useDailyPivotAlert)
     {
      fibonacciPivotPoint(PERIOD_D1,dailyPivots,index,symbol);

      //D PP
      if(bid>=dailyPivots[index][0])
         dailyPivotsFlag[index][0]=true;
      else
         dailyPivotsFlag[index][0]=false;

      //D S1
      if(bid>=dailyPivots[index][1])
         dailyPivotsFlag[index][1]=true;
      else
         dailyPivotsFlag[index][1]=false;

      //D S2
      if(bid>=dailyPivots[index][2])
         dailyPivotsFlag[index][2]=true;
      else
         dailyPivotsFlag[index][2]=false;

      //D S3
      if(bid>=dailyPivots[index][3])
         dailyPivotsFlag[index][3]=true;
      else
         dailyPivotsFlag[index][3]=false;

      //D R1
      if(bid>=dailyPivots[index][4])
         dailyPivotsFlag[index][4]=true;
      else
         dailyPivotsFlag[index][4]=false;

      //D R2
      if(bid>=dailyPivots[index][5])
         dailyPivotsFlag[index][5]=true;
      else
         dailyPivotsFlag[index][5]=false;

      //D R3
      if(bid>=dailyPivots[index][6])
         dailyPivotsFlag[index][6]=true;
      else
         dailyPivotsFlag[index][6]=false;
     }//end of daily
   if(useWeeklyPivotAlert)
     {
      fibonacciPivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      //W PP
      if(bid>=weeklyPivots[index][0])
         weeklyPivotsFlag[index][0]=true;
      else
         weeklyPivotsFlag[index][0]=false;

      //W S1
      if(bid>=weeklyPivots[index][1])
         weeklyPivotsFlag[index][1]=true;
      else
         weeklyPivotsFlag[index][1]=false;

      //W S2
      if(bid>=weeklyPivots[index][2])
         weeklyPivotsFlag[index][2]=true;
      else
         weeklyPivotsFlag[index][2]=false;

      //W S3
      if(bid>=weeklyPivots[index][3])
         weeklyPivotsFlag[index][3]=true;
      else
         weeklyPivotsFlag[index][3]=false;

      //W R1
      if(bid>=weeklyPivots[index][4])
         weeklyPivotsFlag[index][4]=true;
      else
         weeklyPivotsFlag[index][4]=false;

      //W R2
      if(bid>=weeklyPivots[index][5])
         weeklyPivotsFlag[index][5]=true;
      else
         weeklyPivotsFlag[index][5]=false;

      //W R3
      if(bid>=weeklyPivots[index][6])
         weeklyPivotsFlag[index][6]=true;
      else
         weeklyPivotsFlag[index][6]=false;
     }//end of weekly
   if(useMonthlyPivotAlert)
     {
      fibonacciPivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      //M PP
      if(bid>=monthlyPivots[index][0])
         monthlyPivotsFlag[index][0]=true;
      else
         monthlyPivotsFlag[index][0]=false;

      //M S1
      if(bid>=monthlyPivots[index][1])
         monthlyPivotsFlag[index][1]=true;
      else
         monthlyPivotsFlag[index][1]=false;

      //M S2
      if(bid>=monthlyPivots[index][2])
         monthlyPivotsFlag[index][2]=true;
      else
         monthlyPivotsFlag[index][2]=false;

      //M S3
      if(bid>=monthlyPivots[index][3])
         monthlyPivotsFlag[index][3]=true;
      else
         monthlyPivotsFlag[index][3]=false;

      //M R1
      if(bid>=monthlyPivots[index][4])
         monthlyPivotsFlag[index][4]=true;
      else
         monthlyPivotsFlag[index][4]=false;

      //M R2
      if(bid>=monthlyPivots[index][5])
         monthlyPivotsFlag[index][5]=true;
      else
         monthlyPivotsFlag[index][5]=false;

      //M R3
      if(bid>=monthlyPivots[index][6])
         monthlyPivotsFlag[index][6]=true;
      else
         monthlyPivotsFlag[index][6]=false;
     }//end of monthly

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fibonacciPivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolList[i]+symbolPrefix;

      bid=MarketInfo(symbolName,MODE_BID);

      if(useDailyPivotAlert)//daily pivot point cross check
        {
         //D PP
         pivotLevelName="Daily PP";
         result=bid>=dailyPivots[i][0];
         if(result!=dailyPivotsFlag[i][0])
           {
            dailyPivotsFlag[i][0]=result;

            if(TimeCurrent()>=dailyPivotsWaitTill[i][0])
              {
               dailyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S1
         pivotLevelName="Daily S1";
         result=bid>=dailyPivots[i][1];
         if(result!=dailyPivotsFlag[i][1])
           {
            dailyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][1])
              {
               dailyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S2
         pivotLevelName="Daily S2";
         result=bid>=dailyPivots[i][2];
         if(result!=dailyPivotsFlag[i][2])
           {
            dailyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][2])
              {
               dailyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D S3
         pivotLevelName="Daily S3";
         result=bid>=dailyPivots[i][3];
         if(result!=dailyPivotsFlag[i][3])
           {
            dailyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][3])
              {
               dailyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R1
         pivotLevelName="Daily R1";
         result=bid>=dailyPivots[i][4];
         if(result!=dailyPivotsFlag[i][4])
           {
            dailyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][4])
              {
               dailyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R2
         pivotLevelName="Daily R2";
         result=bid>=dailyPivots[i][5];
         if(result!=dailyPivotsFlag[i][5])
           {
            dailyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][5])
              {
               dailyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //D R3
         pivotLevelName="Daily R3";
         result=bid>=dailyPivots[i][6];
         if(result!=dailyPivotsFlag[i][6])
           {
            dailyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=dailyPivotsWaitTill[i][6])
              {
               dailyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
        }//end of daily code
      if(useWeeklyPivotAlert)//weekly pivot point cross check
        {
         //W PP
         pivotLevelName="Weekly PP";
         result=bid>=weeklyPivots[i][0];
         if(result!=weeklyPivotsFlag[i][0])
           {
            weeklyPivotsFlag[i][0]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][0])
              {
               weeklyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S1
         pivotLevelName="Weekly S1";
         result=bid>=weeklyPivots[i][1];
         if(result!=weeklyPivotsFlag[i][1])
           {
            weeklyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][1])
              {
               weeklyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S2
         pivotLevelName="Weekly S2";
         result=bid>=weeklyPivots[i][2];
         if(result!=weeklyPivotsFlag[i][2])
           {
            weeklyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][2])
              {
               weeklyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W S3
         pivotLevelName="Weekly S3";
         result=bid>=weeklyPivots[i][3];
         if(result!=weeklyPivotsFlag[i][3])
           {
            weeklyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][3])
              {
               weeklyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R1
         pivotLevelName="Weekly R1";
         result=bid>=weeklyPivots[i][4];
         if(result!=weeklyPivotsFlag[i][4])
           {
            weeklyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][4])
              {
               weeklyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R2
         pivotLevelName="Weekly R2";
         result=bid>=weeklyPivots[i][5];
         if(result!=weeklyPivotsFlag[i][5])
           {
            weeklyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][5])
              {
               weeklyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //W R3
         pivotLevelName="Weekly R3";
         result=bid>=weeklyPivots[i][6];
         if(result!=weeklyPivotsFlag[i][6])
           {
            weeklyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=weeklyPivotsWaitTill[i][6])
              {
               weeklyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
        }//end of weekly code
      if(useMonthlyPivotAlert)//monthly pivot point cross check
        {
         //M PP
         pivotLevelName="Monthly PP";
         result=bid>=monthlyPivots[i][0];
         if(result!=monthlyPivotsFlag[i][0])
           {
            monthlyPivotsFlag[i][0]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][0])
              {
               monthlyPivotsWaitTill[i][0]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S1
         pivotLevelName="Monthly S1";
         result=bid>=monthlyPivots[i][1];
         if(result!=monthlyPivotsFlag[i][1])
           {
            monthlyPivotsFlag[i][1]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][1])
              {
               monthlyPivotsWaitTill[i][1]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S2
         pivotLevelName="Monthly S2";
         result=bid>=monthlyPivots[i][2];
         if(result!=monthlyPivotsFlag[i][2])
           {
            monthlyPivotsFlag[i][2]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][2])
              {
               monthlyPivotsWaitTill[i][2]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M S3
         pivotLevelName="Monthly S3";
         result=bid>=monthlyPivots[i][3];
         if(result!=monthlyPivotsFlag[i][3])
           {
            monthlyPivotsFlag[i][3]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][3])
              {
               monthlyPivotsWaitTill[i][3]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R1
         pivotLevelName="Monthly R1";
         result=bid>=monthlyPivots[i][4];
         if(result!=monthlyPivotsFlag[i][4])
           {
            monthlyPivotsFlag[i][4]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][4])
              {
               monthlyPivotsWaitTill[i][4]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R2
         pivotLevelName="Monthly R2";
         result=bid>=monthlyPivots[i][5];
         if(result!=monthlyPivotsFlag[i][5])
           {
            monthlyPivotsFlag[i][5]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][5])
              {
               monthlyPivotsWaitTill[i][5]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
         //M R3
         pivotLevelName="Monthly R3";
         result=bid>=monthlyPivots[i][6];
         if(result!=monthlyPivotsFlag[i][6])
           {
            monthlyPivotsFlag[i][6]=result;
            if(TimeCurrent()>=monthlyPivotsWaitTill[i][6])
              {
               monthlyPivotsWaitTill[i][6]=(TimeCurrent()+alertIntervalTimeSeconds);
               doAlert(symbolName,pivotLevelName,pivotSelection);
              }
           }
        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+

void printOutPivotPoint(int index)
  {
   if(index>numSymbols-1 || index<0)
     {
      Alert("printOutPivotPointsSymbolIndex invalid index number");
     }
   else
     {
      Alert(EnumToString(pivotSelection)+" - "+symbolList[index]+symbolPrefix+" - "+(string)symbolTodaysDate[index]);

      if(pivotSelection==Standard)
        {
         if(useDailyPivotAlert) //get the double 2d arrays ready based on number of symbols
           {
            Alert(
                  "D R3 "+(string)dailyPivots[index][6]+"\n"+
                  "D R2 "+(string)dailyPivots[index][5]+"\n"+
                  "D R1 "+(string)dailyPivots[index][4]+"\n"+
                  "D PP "+(string)dailyPivots[index][0]+"\n"+
                  "D S1 "+(string)dailyPivots[index][1]+"\n"+
                  "D S2 "+(string)dailyPivots[index][2]+"\n"+
                  "D S3 "+(string)dailyPivots[index][3]
                  );
           }

         if(useWeeklyPivotAlert)
           {
            Alert(
                  "W R3 "+(string)weeklyPivots[index][6]+"\n"+
                  "W R2 "+(string)weeklyPivots[index][5]+"\n"+
                  "W R1 "+(string)weeklyPivots[index][4]+"\n"+
                  "W PP "+(string)weeklyPivots[index][0]+"\n"+
                  "W S1 "+(string)weeklyPivots[index][1]+"\n"+
                  "W S2 "+(string)weeklyPivots[index][2]+"\n"+
                  "W S3 "+(string)weeklyPivots[index][3]
                  );
           }

         if(useMonthlyPivotAlert)
           {
            Alert(
                  "M R3 "+(string)monthlyPivots[index][6]+"\n"+
                  "M R2 "+(string)monthlyPivots[index][5]+"\n"+
                  "M R1 "+(string)monthlyPivots[index][4]+"\n"+
                  "M PP "+(string)monthlyPivots[index][0]+"\n"+
                  "M S1 "+(string)monthlyPivots[index][1]+"\n"+
                  "M S2 "+(string)monthlyPivots[index][2]+"\n"+
                  "M S3 "+(string)monthlyPivots[index][3]
                  );
           }
        }
      if(pivotSelection==Camarilla)
        {
         if(useDailyPivotAlert) //get the double 2d arrays ready based on number of symbols
           {
            Alert(
                  "D R4 "+(string)dailyPivots[index][8]+"\n"+
                  "D R3 "+(string)dailyPivots[index][7]+"\n"+
                  "D R2 "+(string)dailyPivots[index][6]+"\n"+
                  "D R1 "+(string)dailyPivots[index][5]+"\n"+
                  "D PP "+(string)dailyPivots[index][0]+"\n"+
                  "D S1 "+(string)dailyPivots[index][1]+"\n"+
                  "D S2 "+(string)dailyPivots[index][2]+"\n"+
                  "D S3 "+(string)dailyPivots[index][3]+"\n"+
                  "D S4 "+(string)dailyPivots[index][4]
                  );
           }

         if(useWeeklyPivotAlert)
           {
            Alert(
                  "W R4 "+(string)weeklyPivots[index][8]+"\n"+
                  "W R3 "+(string)weeklyPivots[index][7]+"\n"+
                  "W R2 "+(string)weeklyPivots[index][6]+"\n"+
                  "W R1 "+(string)weeklyPivots[index][5]+"\n"+
                  "W PP "+(string)weeklyPivots[index][0]+"\n"+
                  "W S1 "+(string)weeklyPivots[index][1]+"\n"+
                  "W S2 "+(string)weeklyPivots[index][2]+"\n"+
                  "W S3 "+(string)weeklyPivots[index][3]+"\n"+
                  "W S4 "+(string)weeklyPivots[index][4]
                  );
           }

         if(useMonthlyPivotAlert)
           {
            Alert(
                  "M R4 "+(string)monthlyPivots[index][8]+"\n"+
                  "M R3 "+(string)monthlyPivots[index][7]+"\n"+
                  "M R2 "+(string)monthlyPivots[index][6]+"\n"+
                  "M R1 "+(string)monthlyPivots[index][5]+"\n"+
                  "M PP "+(string)monthlyPivots[index][0]+"\n"+
                  "M S1 "+(string)monthlyPivots[index][1]+"\n"+
                  "M S2 "+(string)monthlyPivots[index][2]+"\n"+
                  "M S3 "+(string)monthlyPivots[index][3]+"\n"+
                  "M S4 "+(string)monthlyPivots[index][4]
                  );
           }
        }
      if(pivotSelection==Woodie)
        {
         if(useDailyPivotAlert) //get the double 2d arrays ready based on number of symbols
           {
            Alert(
                  "D R2 "+(string)dailyPivots[index][4]+"\n"+
                  "D R1 "+(string)dailyPivots[index][3]+"\n"+
                  "D PP "+(string)dailyPivots[index][0]+"\n"+
                  "D S1 "+(string)dailyPivots[index][1]+"\n"+
                  "D S2 "+(string)dailyPivots[index][2]+"\n"
                  );
           }

         if(useWeeklyPivotAlert)
           {
            Alert(
                  "W R2 "+(string)weeklyPivots[index][4]+"\n"+
                  "W R1 "+(string)weeklyPivots[index][3]+"\n"+
                  "W PP "+(string)weeklyPivots[index][0]+"\n"+
                  "W S1 "+(string)weeklyPivots[index][1]+"\n"+
                  "W S2 "+(string)weeklyPivots[index][2]+"\n"
                  );
           }

         if(useMonthlyPivotAlert)
           {
            Alert(
                  "M R2 "+(string)monthlyPivots[index][4]+"\n"+
                  "M R1 "+(string)monthlyPivots[index][3]+"\n"+
                  "M PP "+(string)monthlyPivots[index][0]+"\n"+
                  "M S1 "+(string)monthlyPivots[index][1]+"\n"+
                  "M S2 "+(string)monthlyPivots[index][2]+"\n"
                  );
           }
        }
      if(pivotSelection==Fibonacci)
        {
         if(useDailyPivotAlert) //get the double 2d arrays ready based on number of symbols
           {
            Alert(
                  "D R3 "+(string)dailyPivots[index][6]+"\n"+
                  "D R2 "+(string)dailyPivots[index][5]+"\n"+
                  "D R1 "+(string)dailyPivots[index][4]+"\n"+
                  "D PP "+(string)dailyPivots[index][0]+"\n"+
                  "D S1 "+(string)dailyPivots[index][1]+"\n"+
                  "D S2 "+(string)dailyPivots[index][2]+"\n"+
                  "D S3 "+(string)dailyPivots[index][3]
                  );
           }

         if(useWeeklyPivotAlert)
           {
            Alert(
                  "W R3 "+(string)weeklyPivots[index][6]+"\n"+
                  "W R2 "+(string)weeklyPivots[index][5]+"\n"+
                  "W R1 "+(string)weeklyPivots[index][4]+"\n"+
                  "W PP "+(string)weeklyPivots[index][0]+"\n"+
                  "W S1 "+(string)weeklyPivots[index][1]+"\n"+
                  "W S2 "+(string)weeklyPivots[index][2]+"\n"+
                  "W S3 "+(string)weeklyPivots[index][3]
                  );
           }

         if(useMonthlyPivotAlert)
           {
            Alert(
                  "M R3 "+(string)monthlyPivots[index][6]+"\n"+
                  "M R2 "+(string)monthlyPivots[index][5]+"\n"+
                  "M R1 "+(string)monthlyPivots[index][4]+"\n"+
                  "M PP "+(string)monthlyPivots[index][0]+"\n"+
                  "M S1 "+(string)monthlyPivots[index][1]+"\n"+
                  "M S2 "+(string)monthlyPivots[index][2]+"\n"+
                  "M S3 "+(string)monthlyPivots[index][3]
                  );
           }
        }
     }
  }
//+------------------------------------------------------------------+
