//+------------------------------------------------------------------+
//|                                               CATZZADXInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

// Field naming convention:
//  1. With the prefix '__' the field will not be declared for user input
//  2. With the prefix '_' the field will be declared as 'sinput'
//  3. otherwise it will be declared as 'input'


#include "Include\DKStdLib\Common\DKStdLib.mqh"

enum ENUM_REVERSAL_EXIT_MODE {
  REVERSAL_EXIT_MODE_OFF,        // Отключен
  REVERSAL_EXIT_MODE_NEW_ZZ_TOP, // После новой вершины ZigZag-a
  REVERSAL_EXIT_MODE_NEW_SIGNAL, // После нового сигнала
};

// PARSING AREA OF INPUT STRUCTURE == START == DO NOT REMOVE THIS COMMENT
struct CATZZADXBotInputs {
  // input  group                    "1. СИГНАЛ (SIG)"
  uint                        SIG_DPT;                  // SIG_DPT: Глубина поиска сигнала, баров // 200(x >= 2)
  uint                        SIG_ZZ_DPT;               // SIG_ZZ_DPT: ZigZag Depth // 12(x >= 0)
  uint                        SIG_ZZ_DEV;               // SIG_ZZ_DPT: ZigZag Deviation // 5(x >= 0)
  uint                        SIG_ZZ_BST;               // SIG_ZZ_DPT: ZigZag Back Step // 3(x >= 0)
  uint                        SIG_ZZ_STR;               // SIG_ZZ_STR: ZigZag Игнорировать вершины до бара // 2
  uint                        SIG_ADX_PER;              // SIG_ADX_PER: ADX Period // 14(x > 0)
  uint                        SIG_TEM_PER;              // SIG_TEM_PER: TEMA Period // 14(x > 0)
  uint                        SIG_WPR_PER;              // SIG_WPR_PER: WPR Period // 14(x > 0)

  // input  group                    "2. ФИЛЬТР (FIL)"
  bool                        FIL_WPR_ENB;              // FIL_WPR_ENB: Фильтр по направлению WPR включен // false
  double                      FIL_DID_VAL;              // FIL_DID_VAL: Фильтр по значению |Δ(+DI;-DI)| (<=0.0-откл) // 0.4
  bool                        FIL_ADX_ENB;              // FIL_ADX_ENB: Фильтр ADX<DI // true
  uint                        FIL_ZZS_MAX;              // FIL_ZZS_MAX: Фильтр макс. кол-ва баров после ZZ (0-откл) // 7
  uint                        FIL_BBS_MIN;              // FIL_BBS_MIN: Фильтр мин. размера тела бара, пункт (0-откл) // 9


  // input  group                    "3. ВХОД (ENT)"
  ENUM_MM_TYPE                ENT_LTP;                  // ENT_LTP: Lot Type // ENUM_MM_TYPE_FIXED_LOT
  double                      ENT_LTV;                  // ENT_LTV: Lot Type Value // 1.0(x > 0)
  double                      __ENT_SL_SHF_PER;           // ENT_SL_SHT_PER: Сдвиг SL (0-откл), % от цены DEPRECATED // 0.2(x >= 0)
  uint                        ENT_SL_SHF_PNT;           // ENT_SL_SHT_PER: Сдвиг SL (0-откл), пункт // 200
  uint                        ENT_TP_PNT;               // ENT_TP_PNT: Fixed TP, pnt (0-откл) // 0
  
  // input  group                    "4. ВЫХОД (EXT)"
  ENUM_REVERSAL_EXIT_MODE     EXT_REV_MOD;              // EXT_REV_MOD: Режим выхода по развороту // REVERSAL_EXIT_MODE_NEW_SIGNAL
  bool                        EXT_TSL_ENB;              // EXT_TSL_ENB: Trailing Stop включен // false
  uint                        EXT_TSL_BAR;              // EXT_TSL_BAR: Trailing Stop на хай/лоу за N баров // 3(x > 0)
  string                      EXT_TIM;                  // EXT_TIM: Принудительный выход после времени (""-откл) // "22:30"
  
  // input  group                    "5. ГРАФИКА (GUI)"
  bool                        _GUI_ZZ_ENB;              // GUI_ZZ_ENB: Рисовать ребро ZZ при входе // false
  bool                        _GUI_TSL_ENB;             // GUI_TSL_ENB: Рисовать уровень TSL // false
  color                       _GUI_TSL_CLR;             // GUI_TSL_CLR: Цвет линии уровня TSL // clrWhite
  uint                        _GUI_TSL_WDT;             // GUI_TSL_WDT: Толщина линии уровня TSL // 1(x > 0)
    
  // input  group                    "6. РАЗНОЕ (MS)"
  ulong                       _MS_MGC;                  // MS_MGC: Expert Adviser ID - Magic // 20250122
  string                      _MS_EGP;                  // MS_EGP: Expert Adviser Global Prefix // "ATZZADX"
  LogLevel                    _MS_LOG_LL;               // MS_LOG_LL: Log Level // INFO
  string                      _MS_LOG_FI;               // MS_LOG_FI: Log Filter IN String (use `;` as sep) // ""
  string                      _MS_LOG_FO;               // MS_LOG_FO: Log Filter OUT String (use `;` as sep) // ""
  bool                        _MS_COM_EN;               // MS_COM_EN: Comment Enable (turn off for fast testing) // true
  bool                        _MS_COM_IS;               // MS_COM_IS: Comment Interval, Sec // 30
  bool                        _MS_COM_CW;               // MS_COM_EW: Comment Custom Window // false
  uint                        __MS_TIM_MS;              // MS_TIM_MS: Timer Interval, ms // 30000
  uint                        __MS_LIC_DUR_SEC;         // MS_LIC_DUR_SEC: License Duration, Sec // 15*24*60*60
  
  
// PARSING AREA OF INPUT STRUCTURE == END == DO NOT REMOVE THIS COMMENT

  string LastErrorMessage;
  bool CATZZADXBotInputs::InitAndCheck();
  bool CATZZADXBotInputs::Init();
  bool CATZZADXBotInputs::CheckBeforeInit();
  bool CATZZADXBotInputs::CheckAfterInit();
  void CATZZADXBotInputs::CATZZADXBotInputs();
  
  
  // IND HNDLs
  int IndZZHndl;
  int IndADXHndl;
  int IndTEMAHndl;
  int IndWPRHndl;
};

//+------------------------------------------------------------------+
//| Init struc and Check values
//+------------------------------------------------------------------+
bool CATZZADXBotInputs::InitAndCheck(){
  LastErrorMessage = "";

  if (!CheckBeforeInit())
    return false;

  if (!Init()) {
    LastErrorMessage = "Input.Init() failed";
    return false;
  }

  return CheckAfterInit();
}

//+------------------------------------------------------------------+
//| Init struc
//+------------------------------------------------------------------+
bool CATZZADXBotInputs::Init(){
  IndZZHndl = iCustom(Symbol(), Period(), "Examples\\ZigZagColor", SIG_ZZ_DPT, SIG_ZZ_DEV, SIG_ZZ_BST);
  IndADXHndl = iADX(Symbol(), Period(), SIG_ADX_PER);
  IndTEMAHndl = iTEMA(Symbol(), Period(), SIG_TEM_PER, 0, PRICE_CLOSE);
  IndWPRHndl = iCustom(Symbol(), Period(), "Examples\\WPR", SIG_WPR_PER);
  return true;
}

//+------------------------------------------------------------------+
//| Check struc after Init
//+------------------------------------------------------------------+
bool CATZZADXBotInputs::CheckAfterInit(){
  LastErrorMessage = "";

  if(IndZZHndl <= 0) LastErrorMessage = "ZigZagColor init failed";
  if(IndADXHndl <= 0) LastErrorMessage = "ADX init failed";
  if(IndTEMAHndl <= 0) LastErrorMessage = "TEMA init failed";
  if(IndWPRHndl <= 0) LastErrorMessage = "WPR init failed";
    
  return LastErrorMessage == "";
}

// GENERATED CODE == START == DO NOT REMOVE THIS COMMENT

input  group                    "1. СИГНАЛ (SIG)"
input  uint                      Inp_SIG_DPT                        = 200;                           // SIG_DPT: Глубина поиска сигнала, баров
input  uint                      Inp_SIG_ZZ_DPT                     = 12;                            // SIG_ZZ_DPT: ZigZag Depth
input  uint                      Inp_SIG_ZZ_DEV                     = 5;                             // SIG_ZZ_DPT: ZigZag Deviation
input  uint                      Inp_SIG_ZZ_BST                     = 3;                             // SIG_ZZ_DPT: ZigZag Back Step
input  uint                      Inp_SIG_ZZ_STR                     = 2;                             // SIG_ZZ_STR: ZigZag Игнорировать вершины до бара
input  uint                      Inp_SIG_ADX_PER                    = 14;                            // SIG_ADX_PER: ADX Period
input  uint                      Inp_SIG_TEM_PER                    = 14;                            // SIG_TEM_PER: TEMA Period
input  uint                      Inp_SIG_WPR_PER                    = 14;                            // SIG_WPR_PER: WPR Period

input  group                    "2. ФИЛЬТР (FIL)"
input  bool                      Inp_FIL_WPR_ENB                    = false;                         // FIL_WPR_ENB: Фильтр по направлению WPR включен
input  double                    Inp_FIL_DID_VAL                    = 0.4;                           // FIL_DID_VAL: Фильтр по значению Δ(+DI;-DI) (<=0.0-откл)
input  bool                      Inp_FIL_ADX_ENB                    = true;                          // FIL_ADX_ENB: Фильтр ADX<DI
input  uint                      Inp_FIL_ZZS_MAX                    = 7;                             // FIL_ZZS_MAX: Фильтр макс. кол-ва баров после ZZ (0-откл)
input  uint                      Inp_FIL_BBS_MIN                    = 9;                             // FIL_BBS_MIN: Фильтр мин. размера тела бара, пункт (0-откл)

input  group                    "3. ВХОД (ENT)"
input  ENUM_MM_TYPE              Inp_ENT_LTP                        = ENUM_MM_TYPE_FIXED_LOT;        // ENT_LTP: Lot Type
input  double                    Inp_ENT_LTV                        = 1.0;                           // ENT_LTV: Lot Type Value
input  uint                      Inp_ENT_SL_SHF_PNT                 = 200;                           // ENT_SL_SHT_PER: Сдвиг SL (0-откл), пункт
input  uint                      Inp_ENT_TP_PNT                     = 0;                             // ENT_TP_PNT: Fixed TP, pnt (0-откл)

input  group                    "4. ВЫХОД (EXT)"
input  ENUM_REVERSAL_EXIT_MODE   Inp_EXT_REV_MOD                    = REVERSAL_EXIT_MODE_NEW_SIGNAL; // EXT_REV_MOD: Режим выхода по развороту
input  bool                      Inp_EXT_TSL_ENB                    = false;                         // EXT_TSL_ENB: Trailing Stop включен
input  uint                      Inp_EXT_TSL_BAR                    = 3;                             // EXT_TSL_BAR: Trailing Stop на хай/лоу за N баров
input  string                    Inp_EXT_TIM                        = "22:30";                       // EXT_TIM: Принудительный выход после времени (""-откл)

input  group                    "5. ГРАФИКА (GUI)"
sinput bool                      Inp__GUI_ZZ_ENB                    = false;                         // GUI_ZZ_ENB: Рисовать ребро ZZ при входе
sinput bool                      Inp__GUI_TSL_ENB                   = false;                         // GUI_TSL_ENB: Рисовать уровень TSL
sinput color                     Inp__GUI_TSL_CLR                   = clrWhite;                      // GUI_TSL_CLR: Цвет линии уровня TSL
sinput uint                      Inp__GUI_TSL_WDT                   = 1;                             // GUI_TSL_WDT: Толщина линии уровня TSL

input  group                    "6. РАЗНОЕ (MS)"
sinput ulong                     Inp__MS_MGC                        = 20250122;                      // MS_MGC: Expert Adviser ID - Magic
sinput string                    Inp__MS_EGP                        = "ATZZADX";                     // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                  Inp__MS_LOG_LL                     = INFO;                          // MS_LOG_LL: Log Level
sinput string                    Inp__MS_LOG_FI                     = "";                            // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                    Inp__MS_LOG_FO                     = "";                            // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
sinput bool                      Inp__MS_COM_EN                     = true;                          // MS_COM_EN: Comment Enable (turn off for fast testing)
sinput bool                      Inp__MS_COM_IS                     = 30;                            // MS_COM_IS: Comment Interval, Sec
sinput bool                      Inp__MS_COM_CW                     = false;                         // MS_COM_EW: Comment Custom Window


//+------------------------------------------------------------------+
//| Fill Input struc with user inputs vars
//+------------------------------------------------------------------+    
void FillInputs(CATZZADXBotInputs& _inputs) {
  _inputs.SIG_DPT                   = Inp_SIG_DPT;                                                   // SIG_DPT: Глубина поиска сигнала, баров
  _inputs.SIG_ZZ_DPT                = Inp_SIG_ZZ_DPT;                                                // SIG_ZZ_DPT: ZigZag Depth
  _inputs.SIG_ZZ_DEV                = Inp_SIG_ZZ_DEV;                                                // SIG_ZZ_DPT: ZigZag Deviation
  _inputs.SIG_ZZ_BST                = Inp_SIG_ZZ_BST;                                                // SIG_ZZ_DPT: ZigZag Back Step
  _inputs.SIG_ZZ_STR                = Inp_SIG_ZZ_STR;                                                // SIG_ZZ_STR: ZigZag Игнорировать вершины до бара
  _inputs.SIG_ADX_PER               = Inp_SIG_ADX_PER;                                               // SIG_ADX_PER: ADX Period
  _inputs.SIG_TEM_PER               = Inp_SIG_TEM_PER;                                               // SIG_TEM_PER: TEMA Period
  _inputs.SIG_WPR_PER               = Inp_SIG_WPR_PER;                                               // SIG_WPR_PER: WPR Period
  _inputs.FIL_WPR_ENB               = Inp_FIL_WPR_ENB;                                               // FIL_WPR_ENB: Фильтр по направлению WPR включен
  _inputs.FIL_DID_VAL               = Inp_FIL_DID_VAL;                                               // FIL_DID_VAL: Фильтр по значению Δ(+DI;-DI) (<=0.0-откл)
  _inputs.FIL_ADX_ENB               = Inp_FIL_ADX_ENB;                                               // FIL_ADX_ENB: Фильтр ADX<DI
  _inputs.FIL_ZZS_MAX               = Inp_FIL_ZZS_MAX;                                               // FIL_ZZS_MAX: Фильтр макс. кол-ва баров после ZZ (0-откл)
  _inputs.FIL_BBS_MIN               = Inp_FIL_BBS_MIN;                                               // FIL_BBS_MIN: Фильтр мин. размера тела бара, пункт (0-откл)
  _inputs.ENT_LTP                   = Inp_ENT_LTP;                                                   // ENT_LTP: Lot Type
  _inputs.ENT_LTV                   = Inp_ENT_LTV;                                                   // ENT_LTV: Lot Type Value
  _inputs.ENT_SL_SHF_PNT            = Inp_ENT_SL_SHF_PNT;                                            // ENT_SL_SHT_PER: Сдвиг SL (0-откл), пункт
  _inputs.ENT_TP_PNT                = Inp_ENT_TP_PNT;                                                // ENT_TP_PNT: Fixed TP, pnt (0-откл)
  _inputs.EXT_REV_MOD               = Inp_EXT_REV_MOD;                                               // EXT_REV_MOD: Режим выхода по развороту
  _inputs.EXT_TSL_ENB               = Inp_EXT_TSL_ENB;                                               // EXT_TSL_ENB: Trailing Stop включен
  _inputs.EXT_TSL_BAR               = Inp_EXT_TSL_BAR;                                               // EXT_TSL_BAR: Trailing Stop на хай/лоу за N баров
  _inputs.EXT_TIM                   = Inp_EXT_TIM;                                                   // EXT_TIM: Принудительный выход после времени (""-откл)
  _inputs._GUI_ZZ_ENB               = Inp__GUI_ZZ_ENB;                                               // GUI_ZZ_ENB: Рисовать ребро ZZ при входе
  _inputs._GUI_TSL_ENB              = Inp__GUI_TSL_ENB;                                              // GUI_TSL_ENB: Рисовать уровень TSL
  _inputs._GUI_TSL_CLR              = Inp__GUI_TSL_CLR;                                              // GUI_TSL_CLR: Цвет линии уровня TSL
  _inputs._GUI_TSL_WDT              = Inp__GUI_TSL_WDT;                                              // GUI_TSL_WDT: Толщина линии уровня TSL
  _inputs._MS_MGC                   = Inp__MS_MGC;                                                   // MS_MGC: Expert Adviser ID - Magic
  _inputs._MS_EGP                   = Inp__MS_EGP;                                                   // MS_EGP: Expert Adviser Global Prefix
  _inputs._MS_LOG_LL                = Inp__MS_LOG_LL;                                                // MS_LOG_LL: Log Level
  _inputs._MS_LOG_FI                = Inp__MS_LOG_FI;                                                // MS_LOG_FI: Log Filter IN String (use `;` as sep)
  _inputs._MS_LOG_FO                = Inp__MS_LOG_FO;                                                // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
  _inputs._MS_COM_EN                = Inp__MS_COM_EN;                                                // MS_COM_EN: Comment Enable (turn off for fast testing)
  _inputs._MS_COM_IS                = Inp__MS_COM_IS;                                                // MS_COM_IS: Comment Interval, Sec
  _inputs._MS_COM_CW                = Inp__MS_COM_CW;                                                // MS_COM_EW: Comment Custom Window
}


//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CATZZADXBotInputs::CATZZADXBotInputs():
       SIG_DPT(200),
       SIG_ZZ_DPT(12),
       SIG_ZZ_DEV(5),
       SIG_ZZ_BST(3),
       SIG_ZZ_STR(2),
       SIG_ADX_PER(14),
       SIG_TEM_PER(14),
       SIG_WPR_PER(14),
       FIL_WPR_ENB(false),
       FIL_DID_VAL(0.4),
       FIL_ADX_ENB(true),
       FIL_ZZS_MAX(7),
       FIL_BBS_MIN(9),
       ENT_LTP(ENUM_MM_TYPE_FIXED_LOT),
       ENT_LTV(1.0),
       __ENT_SL_SHF_PER(0.2),
       ENT_SL_SHF_PNT(200),
       EXT_REV_MOD(REVERSAL_EXIT_MODE_NEW_SIGNAL),
       EXT_TSL_ENB(false),
       EXT_TSL_BAR(3),
       EXT_TIM("22:30"),
       _GUI_ZZ_ENB(false),
       _GUI_TSL_ENB(false),
       _GUI_TSL_CLR(clrWhite),
       _GUI_TSL_WDT(1),
       _MS_MGC(20250122),
       _MS_EGP("ATZZADX"),
       _MS_LOG_LL(INFO),
       _MS_LOG_FI(""),
       _MS_LOG_FO(""),
       _MS_COM_EN(true),
       _MS_COM_IS(30),
       _MS_COM_CW(false),
       __MS_TIM_MS(30000),
       __MS_LIC_DUR_SEC(15*24*60*60){

};


//+------------------------------------------------------------------+
//| Check struc before Init
//+------------------------------------------------------------------+
bool CATZZADXBotInputs::CheckBeforeInit() {
  LastErrorMessage = "";
  if(!(SIG_DPT >= 2)) LastErrorMessage = "'SIG_DPT' must satisfy condition: SIG_DPT >= 2";
  if(!(SIG_ZZ_DPT >= 0)) LastErrorMessage = "'SIG_ZZ_DPT' must satisfy condition: SIG_ZZ_DPT >= 0";
  if(!(SIG_ZZ_DEV >= 0)) LastErrorMessage = "'SIG_ZZ_DEV' must satisfy condition: SIG_ZZ_DEV >= 0";
  if(!(SIG_ZZ_BST >= 0)) LastErrorMessage = "'SIG_ZZ_BST' must satisfy condition: SIG_ZZ_BST >= 0";
  if(!(SIG_ADX_PER > 0)) LastErrorMessage = "'SIG_ADX_PER' must satisfy condition: SIG_ADX_PER > 0";
  if(!(SIG_TEM_PER > 0)) LastErrorMessage = "'SIG_TEM_PER' must satisfy condition: SIG_TEM_PER > 0";
  if(!(SIG_WPR_PER > 0)) LastErrorMessage = "'SIG_WPR_PER' must satisfy condition: SIG_WPR_PER > 0";
  if(!(ENT_LTV > 0)) LastErrorMessage = "'ENT_LTV' must satisfy condition: ENT_LTV > 0";
  if(!(__ENT_SL_SHF_PER >= 0)) LastErrorMessage = "'__ENT_SL_SHF_PER' must satisfy condition: __ENT_SL_SHF_PER >= 0";
  if(!(EXT_TSL_BAR > 0)) LastErrorMessage = "'EXT_TSL_BAR' must satisfy condition: EXT_TSL_BAR > 0";
  if(!(_GUI_TSL_WDT > 0)) LastErrorMessage = "'_GUI_TSL_WDT' must satisfy condition: _GUI_TSL_WDT > 0";

  return LastErrorMessage == "";
}
// GENERATED CODE == END == DO NOT REMOVE THIS COMMENT



