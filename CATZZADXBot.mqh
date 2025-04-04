//+------------------------------------------------------------------+
//|                                                  CATZZADXBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
//#include <Generic\HashMap.mqh>
//#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
//#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
//#include <Trade\DealInfo.mqh>
//#include <Charts\Chart.mqh>
//#include <Math\Stat\Math.mqh>
//#include <Trade\OrderInfo.mqh>

//#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
//#include <ChartObjects\ChartObjectsArrows.mqh> 

//#include "Include\DKStdLib\Analysis\DKChartAnalysis.mqh"
#include "Include\DKStdLib\Common\DKNumPy.mqh"
#include "Include\DKStdLib\Common\CDKBarTag.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLFibo.mqh"
#include "Include\DKStdLib\TradingManager\CDKTSLPriceChannel.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"
//#include "Include\DKStdLib\History\DKHistory.mqh"

#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CATZZADXInputs.mqh"

enum ENUM_SIG_MODE {
  NONE = -1,
  BAR  = 0,
  DUA  = 1,
  REV  = 2,
};

class CATZZADXBot : public CDKBaseBot<CATZZADXBotInputs> {
public: // SETTINGS

protected:
  CDKBarTag                  ZZTopBT;
  CDKBarTag                  ZZBotBT;
  CDKBarTag                  SigBT;
  ENUM_SIG_MODE              SigBarType;
  int                        SigDir;
  CDKBarTag                  EPBySigBT;
  int                        EPDir;
  
  datetime                   CloseTime;
  
public:
  // Constructor & init
  //void                       CATZZADXBot::CATZZADXBot(void);
  void                       CATZZADXBot::~CATZZADXBot(void);
  void                       CATZZADXBot::InitChild();
  bool                       CATZZADXBot::Check(void);

  // Event Handlers
  void                       CATZZADXBot::OnDeinit(const int reason);
  void                       CATZZADXBot::OnTick(void);
  void                       CATZZADXBot::OnTrade(void);
  void                       CATZZADXBot::OnTimer(void);
  double                     CATZZADXBot::OnTester(void);
  void                       CATZZADXBot::OnBar(CArrayInt& _tf_list);
  
  // Bot's logic
  void                       CATZZADXBot::UpdateComment(const bool _ignore_interval = false);

  
  int                        CATZZADXBot::GetZZDir();
  int                        CATZZADXBot::GetADXDir();
  int                        CATZZADXBot::GetTEMADir();
  int                        CATZZADXBot::GetSignal();

  bool                       CATZZADXBot::IsBSFilterPass_NoPosInMarket();
  bool                       CATZZADXBot::IsBSFilterPass_AllowedTime();
  
  bool                       CATZZADXBot::IsASFilterPass_FIL_DID_VAL();
  bool                       CATZZADXBot::IsASFilterPass_FIL_ADX_ENB(const int _dir);
  bool                       CATZZADXBot::IsASFilterPass_FIL_ZZS_MAX();
  bool                       CATZZADXBot::IsASFilterPass_FIL_BBS_MIN();  
  bool                       CATZZADXBot::IsASFilterPass_FirstEntryOnZZRib();
  bool                       CATZZADXBot::IsASFilterPass_WPR(const int _sig_dir);  
  bool                       CATZZADXBot::AreAllASFiltersPass(const int _sig_dir);
  
  ulong                      CATZZADXBot::OpenPosOnSignal();
  
  bool                       CATZZADXBot::CloseOnReversal(const int _sig_dir);
  bool                       CATZZADXBot::CloseOnTime();
  
  bool                       CATZZADXBot::UpdateTSL();
  
  void                       CATZZADXBot::DrawZZ();
  void                       CATZZADXBot::DrawTSL(const ulong _ticket, const double _sl);
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CATZZADXBot::~CATZZADXBot(void){
}

string MyStr() {
  Print("123123");
  return "123123";
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CATZZADXBot::InitChild() {
  // Put code here
  ZZBotBT.Init(Sym.Name(), TF);
  ZZTopBT.Init(Sym.Name(), TF);
  SigBT.Init(Sym.Name(), TF);
  EPBySigBT.Init(Sym.Name(), TF);
  EPDir = 0;
  SigBarType = -1;
  
  CloseTime = StringToTime(Inputs.EXT_TIM);
  
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CATZZADXBot::Check(void) {
  if(!CDKBaseBot<CATZZADXBotInputs>::Check())
    return false;
    
  if(!Inputs.InitAndCheck()) {
    Logger.Critical(Inputs.LastErrorMessage, true);
    return false;
  }
  
  return true;
}

//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CATZZADXBot::OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CATZZADXBot::OnTick(void) {
  CDKBaseBot<CATZZADXBotInputs>::OnTick(); // Check new bar and show comment
  
  // 03. Channels update
  bool need_update = false;

  // 06. Update comment
  if(need_update)
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CATZZADXBot::OnBar(CArrayInt& _tf_list) {
  UpdateTSL();
  OpenPosOnSignal();
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CATZZADXBot::OnTrade(void) {
  CDKBaseBot<CATZZADXBotInputs>::OnTrade();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CATZZADXBot::OnTimer(void) {
  CloseOnTime();
  UpdateComment();
  CDKBaseBot<CATZZADXBotInputs>::OnTimer();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CATZZADXBot::OnTester(void) {
  return 0;
}



//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CATZZADXBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();

  //datetime dt_curr = TimeCurrent();
  //AddCommentLine(StringFormat("Time:   %s", TimeToString(TimeCurrent())));
  //AddCommentLine(StringFormat("Signal: %s in %s", TimeToString(StructToTime(SignalTime)), TimeDurationToString(StructToTime(SignalTime)-dt_curr)));
  //AddCommentLine(StringFormat("Close:  %s in %s", TimeToString(StructToTime(CloseTime)), TimeDurationToString(StructToTime(CloseTime)-dt_curr)));

  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Get ZigZag current dir
//+------------------------------------------------------------------+
int CATZZADXBot::GetZZDir() {
  int dir = 0;
  string msg = "";
  
  // Load ZZ
  double buf_zz_top[]; ArraySetAsSeries(buf_zz_top, true);
  double buf_zz_bot[]; ArraySetAsSeries(buf_zz_bot, true);
  if(CopyBuffer(Inputs.IndZZHndl, 0, 0, Inputs.SIG_DPT, buf_zz_top) >= (int)Inputs.SIG_DPT &&
     CopyBuffer(Inputs.IndZZHndl, 1, 0, Inputs.SIG_DPT, buf_zz_bot) >= (int)Inputs.SIG_DPT) {
    // Find ZZ picks
    int zz_top_idx = ArrayFindFirstConditional(buf_zz_top, true, 0.0);
    int zz_bot_idx = ArrayFindFirstConditional(buf_zz_bot, true, 0.0);
    ZZTopBT.Init(Sym.Name(), TF, zz_top_idx, 
                 zz_top_idx >= 0 ? buf_zz_top[zz_top_idx] : 0.0);
    ZZBotBT.Init(Sym.Name(), TF, zz_bot_idx, 
                 zz_bot_idx >= 0 ? buf_zz_bot[zz_bot_idx] : 0.0);
    
    // Get Dir using ZZ  
    if(zz_bot_idx >= (int)Inputs.SIG_ZZ_STR && zz_top_idx >= (int)Inputs.SIG_ZZ_STR) {
      if(zz_bot_idx > zz_top_idx) dir = -1;
      if(zz_bot_idx < zz_top_idx) dir = +1;
    }  
    else
      msg = "Нет двух вершин";
  }
  else {
    msg = "CopyBuffer(ZigZag) failed";
    LSF_ERROR(msg);
  }

  LSF_DEBUG(StringFormat("ZZ_DIR=%d; ZZ_TOP=%s; ZZ_BOT=%s; MSG='%s'",
                         dir,
                         ZZTopBT.__repr__(true),
                         ZZBotBT.__repr__(true),
                         msg));
  
  return dir;
}

//+------------------------------------------------------------------+
//| Get ADX current dir
//+------------------------------------------------------------------+
int CATZZADXBot::GetADXDir() {
  double adx_dip[]; ArraySetAsSeries(adx_dip, true);
  double adx_din[]; ArraySetAsSeries(adx_din, true);
  if(CopyBuffer(Inputs.IndADXHndl, 1, 1, 1, adx_dip) >= 1 &&
     CopyBuffer(Inputs.IndADXHndl, 2, 1, 1, adx_din) >= 1){
     
    int dir = 0;
    if(adx_dip[0] > adx_din[0]) dir = +1;
    if(adx_din[0] > adx_dip[0]) dir = -1;
    
    LSF_DEBUG(StringFormat("ADX_DIR=%d; +DI=%.10g; -DI=%.10g", 
                           dir, adx_dip[0], adx_din[0]));
    return dir;
  }

  LSF_ERROR("CopyBuffer(ADX) failed");
  return 0;
}

//+------------------------------------------------------------------+
//| Check filter FIL_DID_VAL
//+------------------------------------------------------------------+
bool CATZZADXBot::IsASFilterPass_FIL_DID_VAL() {
  if(Inputs.FIL_DID_VAL <= 0.0) {
    LSF_DEBUG("RES=PASS; FIL_DID_VAL=0.0");
    return true;
  }
  
  double adx_dip[]; ArraySetAsSeries(adx_dip, true);
  double adx_din[]; ArraySetAsSeries(adx_din, true);
  if(CopyBuffer(Inputs.IndADXHndl, 1, 1, 1, adx_dip) >= 1 &&
     CopyBuffer(Inputs.IndADXHndl, 2, 1, 1, adx_din) >= 1){
     
    double dt = MathAbs(adx_dip[0]-adx_din[0]); 
    bool res = dt >= Inputs.FIL_DID_VAL;
    
    LSF_ASSERT(res, 
               StringFormat("RES=%d; +DI=%.10g; -DI=%.10g; Δ=%.10g; FIL_DID_VAL=%.10g", 
                            res, adx_dip[0], adx_din[0], dt, Inputs.FIL_DID_VAL),
               INFO, DEBUG);
     return res;
  }

  LSF_ERROR("RES=FAIL; MSG='CopyBuffer(ADX) error'");
  return false;
}

//+------------------------------------------------------------------+
//| Check filter FIL_ADX_ENB
//+------------------------------------------------------------------+
bool CATZZADXBot::IsASFilterPass_FIL_ADX_ENB(const int _dir) {
  if(!Inputs.FIL_ADX_ENB) {
    LSF_DEBUG("RES=PASS; FIL_ADX_ENB=0");
    return true;
  }
  
  double adx[]; ArraySetAsSeries(adx, true);
  double adx_dip[]; ArraySetAsSeries(adx_dip, true);
  double adx_din[]; ArraySetAsSeries(adx_din, true);
  if(CopyBuffer(Inputs.IndADXHndl, 0, 1, 1, adx) >= 1 &&
     CopyBuffer(Inputs.IndADXHndl, 1, 1, 1, adx_dip) >= 1 &&
     CopyBuffer(Inputs.IndADXHndl, 2, 1, 1, adx_din) >= 1){
     
    double di = _dir > 0 ? adx_dip[0] : adx_din[0];
    bool res = adx[0] >= di;
    
    LSF_ASSERT(res, 
               StringFormat("RES=%d; ADX=%.10g; +DI=%.10g; -DI=%.10g", 
                            res, adx[0], adx_dip[0], adx_din[0]),
               INFO, DEBUG);
     return res;
  }

  LSF_ERROR("RES=FAIL; MSG='CopyBuffer(ADX) error'");
  return false;
}

//+------------------------------------------------------------------+
//| Check filter FIL_ZZS_MAX
//+------------------------------------------------------------------+
bool CATZZADXBot::IsASFilterPass_FIL_ZZS_MAX() {
  if(Inputs.FIL_ZZS_MAX <= 0) {
    LSF_DEBUG("RES=PASS; FIL_ZZS_MAX=0");
    return true;
  }
  
  int prev_zz_top_idx = MathMin(ZZBotBT.GetIndex(true), ZZTopBT.GetIndex(true));
  bool res = prev_zz_top_idx <= (int)Inputs.FIL_ZZS_MAX;
  LSF_ASSERT(res,
             StringFormat("RES=%d; ZZ_TOP_IDX=%d; FIL_ZZS_MAX=%d",
                          res, prev_zz_top_idx, Inputs.FIL_ZZS_MAX),
             INFO, DEBUG);

  return res;
}

//+------------------------------------------------------------------+
//| Check filter FIL_BBS_MIN
//+------------------------------------------------------------------+
bool CATZZADXBot::IsASFilterPass_FIL_BBS_MIN() {
  if(Inputs.FIL_BBS_MIN <= 0) {
    LSF_DEBUG("RES=PASS; FIL_BBS_MIN=0");
    return true;
  }
  
  MqlRates buf_rates[]; ArraySetAsSeries(buf_rates, true);
  if(CopyRates(Sym.Name(), TF, 1, 1, buf_rates) <= 0) {
    LSF_ERROR("RES=FAIL; MSG='CopyRates() failed'");
    return false;
  }    
  
  int body_pnt = Sym.PriceToPoints(MathAbs(buf_rates[0].open - buf_rates[0].close));
  bool res = body_pnt >= (int)Inputs.FIL_BBS_MIN;
  LSF_ASSERT(res,
             StringFormat("RES=%d; O=%s; C=%s; BODY_PNT=%d; FIL_BBS_MIN=%d",
                          res, Sym.PriceFormat(buf_rates[0].open), Sym.PriceFormat(buf_rates[0].close), body_pnt, Inputs.FIL_BBS_MIN),
             INFO, DEBUG);

  return res;
}



//+------------------------------------------------------------------+
//| Get TEMA current dir
//+------------------------------------------------------------------+
int CATZZADXBot::GetTEMADir() {
  double tema[]; ArraySetAsSeries(tema, true);
  if(CopyBuffer(Inputs.IndTEMAHndl, 0, 1, 2, tema) >= 2){
     
    int dir = 0;
    if(tema[0] > tema[1]) dir = +1;
    if(tema[0] < tema[1]) dir = -1;
    
    LSF_DEBUG(StringFormat("TEMA_DIR=%d; TEMA[1]=%.10g; TEMA[0]=%.10g", 
                           dir, tema[1], tema[0]));
    return dir;
  }

  LSF_ERROR("CopyBuffer(TEMA) failed");
  return 0;
}


//+------------------------------------------------------------------+
//| Check all AS filter pass
//+------------------------------------------------------------------+
bool CATZZADXBot::AreAllASFiltersPass(const int _sig_dir) {
  bool res = true;
  string msg = "";
  // 01. WPR Filter
  if(res && !IsASFilterPass_WPR(_sig_dir)) { msg = "FIL_WPR_ENB"; res = false; }

  // 02. Check ΔDI filter - FIL_DID_VAL
  if(res && !IsASFilterPass_FIL_DID_VAL()) { msg = "FIL_DID_VAL"; res = false; }
  
  // 03. Check ADX<DI filter - FIL_ADX_ENB
  if(res && !IsASFilterPass_FIL_ADX_ENB(_sig_dir)) { msg = "FIL_ADX_ENB"; res = false; }
  
  // 04. Check FIL_ZZS_MAX - FIL_ZZS_MAX
  if(res && !IsASFilterPass_FIL_ZZS_MAX()) { msg = "FIL_ZZS_MAX"; res = false; }
  
  // 05. Check FIL_BBS_MIN - FIL_BBS_MIN
  if(res && !IsASFilterPass_FIL_BBS_MIN()) { msg = "FIL_BBS_MIN"; res = false; }

    
  
  // 06. Time ok?
  if(res && !IsBSFilterPass_AllowedTime()) { msg = "EXT_TIM"; res = false; }
  
  // 07. No any pos
  if(res && !IsBSFilterPass_NoPosInMarket()) { msg = "POS_IN_MARKET"; res = false; }
  
  // 08. No any pos on current ZZ rib
  if(res && !IsASFilterPass_FirstEntryOnZZRib()) { msg = "SECONT_ENTRY_ON_ZZ_RIB"; res = false; }
  
  LSF_INFO(StringFormat("RES=%d; SIG_DIR=%d; MSG=%s", 
                        res, _sig_dir, 
                        !res ? msg : "PASS"));
  return res;  
}

//+------------------------------------------------------------------+
//| Get Signal
//+------------------------------------------------------------------+
int CATZZADXBot::GetSignal() {
  // 01. Get ZZ dir
  int dir_zz = GetZZDir();
  if(dir_zz == 0) {
    LSF_INFO("RES=0; ZZ_DIR=0");
    return 0;  
  }
  
  // 02. Load ADX
  int dir_adx = GetADXDir();
  if(dir_adx == 0) return 0;
  
  // 03. Load TEMA
  int dir_tema = GetTEMADir();
  if(dir_tema == 0) return 0;
  
  // 04. Full dir
  int dir_full = 0;
  if(dir_zz > 0 && dir_adx > 0 && dir_tema > 0) dir_full = +1;
  if(dir_zz < 0 && dir_adx < 0 && dir_tema < 0) dir_full = -1;
  
  LSF_INFO(StringFormat("DIR=%d; ZZ_DIR=%d; ADX_DIR=%d; TEMA_DIR=%d", 
                        dir_full, dir_zz, dir_adx, dir_tema));
  return dir_full;
}

//+------------------------------------------------------------------+
//| Filter passes if there's no pos in market
//+------------------------------------------------------------------+
bool CATZZADXBot::IsBSFilterPass_NoPosInMarket() {
  bool res = Poses.Total() <= 0;
  LSF_DEBUG(StringFormat("RES=%d; POS_CNT=%d", res, Poses.Total()));
  return res; 
}

//+------------------------------------------------------------------+
//| Filter passes if curr time is allowed
//+------------------------------------------------------------------+
bool CATZZADXBot::IsBSFilterPass_AllowedTime() {
  if(Inputs.EXT_TIM == "") return true;
  
  datetime dt_curr = TimeCurrent();
  bool res = !IsTimeCurrentAfterUpdatedTimeToToday(CloseTime);

  return res;
}

//+------------------------------------------------------------------+
//| Filter passes if there's 1st pos on current ZZ rib
//+------------------------------------------------------------------+
bool CATZZADXBot::IsASFilterPass_FirstEntryOnZZRib() {
  CDKBarTag zz_bt;
  //zz_bt = SigDir > 0 ? ZZBotBT : ZZTopBT; <-- ver 1.01
  zz_bt = (ZZTopBT.GetTime() >= ZZBotBT.GetTime()) ? ZZBotBT : ZZTopBT; // ver 1.02
  bool res = (SigDir != EPDir) || (zz_bt.GetTime() != EPBySigBT.GetTime());
  LSF_DEBUG(StringFormat("RES=%d; SIG_DIR=%d; LAST_EP_DIR=%d; ZZ_DT=%s; LAST_EP_BY_SIG_DT=%s", 
                         res, 
                         SigDir, EPDir,
                         TimeToString(zz_bt.GetTime()), TimeToString(EPBySigBT.GetTime())));
  return res; 
}

//+------------------------------------------------------------------+
//| Filter passed if last WPR segment dir is the same with signal
//+------------------------------------------------------------------+
bool CATZZADXBot::IsASFilterPass_WPR(const int _sig_dir) {
  if(!Inputs.FIL_WPR_ENB) {
    LSF_DEBUG("RES=1; FIL_WPR_ENB=0"); 
    return true;
  }
  
  double buf_wpr[]; ArraySetAsSeries(buf_wpr, true);
  if(CopyBuffer(Inputs.IndWPRHndl, 0, 1, 2, buf_wpr) < 2) {
    LSF_ERROR("RES=0; MSG='CopyBuffer(WPR) failed'"); 
    return false;
  }
  
  int wpr_dir = 0;
  if(buf_wpr[1]<buf_wpr[0]) wpr_dir = +1;
  if(buf_wpr[1]>buf_wpr[0]) wpr_dir = -1;
  
  bool res = (_sig_dir*wpr_dir) > 0;
  LSF_DEBUG(StringFormat("RES=%d; SIG_DIR=%d; WPR_DIR=%d; WPR[2]=%f; WPR[1]=%f", 
                         res, _sig_dir, wpr_dir, buf_wpr[1], buf_wpr[0]));
  return res; 
}

//+------------------------------------------------------------------+
//| Close pos on ZZ reversal
//+------------------------------------------------------------------+
bool CATZZADXBot::CloseOnReversal(const int _sig_dir) {
  if(Inputs.EXT_REV_MOD == REVERSAL_EXIT_MODE_OFF) return false;
  if(Poses.Total() <= 0) return false;
  
  bool pos_close_cnt = 0;
  
  int sig_dir = 0;
  if(Inputs.EXT_REV_MOD == REVERSAL_EXIT_MODE_NEW_ZZ_TOP)
    if(ZZBotBT.GetIndex() >= (int)Inputs.SIG_ZZ_STR && ZZTopBT.GetIndex() >= (int)Inputs.SIG_ZZ_STR)
      sig_dir = ZZBotBT.GetIndex() > ZZTopBT.GetIndex() ? -1 : +1;
  if(Inputs.EXT_REV_MOD == REVERSAL_EXIT_MODE_NEW_SIGNAL)
    sig_dir = _sig_dir;

  CDKPositionInfo pos;
  for(int i=0;i<PositionsTotal();i++) {
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    if((pos.PositionType() == POSITION_TYPE_BUY  && sig_dir < 0) || 
       (pos.PositionType() == POSITION_TYPE_SELL && sig_dir > 0)) {
      bool res = Trade.PositionClose(Poses.At(i));
      
      if(res) pos_close_cnt++;      
      LSF_ASSERT(res,
                 StringFormat("TICKET=%I64u; MODE=%s; DIR=%s; SIG_DIR=%d; RET_CODE=%d",
                              Poses.At(i),
                              EnumToString(Inputs.EXT_REV_MOD),
                              PositionTypeToString(pos.PositionType()),
                              sig_dir,
                              Trade.ResultRetcode()),
                 WARN, ERROR);
    }
  }
  
  // Refresh Poses.Total()
  if(pos_close_cnt > 0)
    LoadMarket();
  
  return pos_close_cnt > 0; 
}

//+------------------------------------------------------------------+
//| Close pos on time
//+------------------------------------------------------------------+
bool CATZZADXBot::CloseOnTime() {
  // 01. Have pos in market
  if(Poses.Total() <= 0) return false;  
  
  // 02. Time is ok
  if(IsBSFilterPass_AllowedTime()) return false;
  
  // 03. Close pos
  int close_cnt = 0;
  CDKPositionInfo pos;
  for(int i=0;i<Poses.Total();i++){
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    
    bool res = Trade.PositionClose(Poses.At(i));
    if(res) close_cnt++;
    
    LSF_ASSERT(res, 
               StringFormat("TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            Poses.At(i), 
                            Trade.ResultRetcode(), Trade.ResultRetcodeDescription()),
               WARN, ERROR);
  }

  return close_cnt > 0;    
}

//+------------------------------------------------------------------+
//| TSL
//+------------------------------------------------------------------+
bool CATZZADXBot::UpdateTSL() {
  // 01. Have pos in market
  if(!Inputs.EXT_TSL_ENB) {
    LSF_DEBUG("RES=0; EXT_TSL_ENB=0");
    return false;  
  }  

  // 02. Have pos in market
  if(Poses.Total() <= 0) {
    LSF_DEBUG("RES=0; POS_CNT=0");
    return false;  
  }
  
  // 03. TSL update
  int tsl_cnt = 0;
  CDKTSLPriceChannel pos;
  for(int i=0;i<Poses.Total();i++){
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    
    pos.Init(0, TF, 1, Inputs.EXT_TSL_BAR, CHANNEL_BORDER_WICK, 0);
    bool res = pos.Update(Trade, false);
    if(res) tsl_cnt++;
    pos.SelectByTicket(Poses.At(i));
    DrawTSL(Poses.At(i), pos.StopLoss());
    
    LSF_ASSERT(res, 
               StringFormat("TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            Poses.At(i), 
                            pos.ResultRetcode(), pos.ResultRetcodeDescription()),
               WARN, ERROR);
  }

  return tsl_cnt > 0;    
}


//+------------------------------------------------------------------+
//| Open pos on Signal
//+------------------------------------------------------------------+
ulong CATZZADXBot::OpenPosOnSignal() {
  // 01. Get pure signal with no filters
  int new_sig_dir = GetSignal();
  if(new_sig_dir == 0) return 0;
 
  // 02. Try to close pos on reversal
  CloseOnReversal(new_sig_dir);
  
  // 03. Apply signal filters
  if(!AreAllASFiltersPass(new_sig_dir)) return 0;

  // 04. Save Sig  
  SigDir = new_sig_dir;
  SigBT.Init(Sym.Name(), TF, iTime(Sym.Name(), TF, 0), iClose(Sym.Name(), TF, 0));  
  
  
  // 07. Open pos
  ulong ticket = 0;
  string comment = StringFormat("%s:%s_%s", Logger.Name, EnumToString(SigBarType), TimeToString(TimeCurrent()));
  
  ENUM_POSITION_TYPE pos_type = SigDir > 0 ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
  double ep = Sym.GetPriceToOpen(pos_type);
  double sl = SigDir > 0 ? ZZBotBT.GetValue() : ZZTopBT.GetValue();
  //double extra_sl_shift = ep*Inputs.ENT_SL_SHF_PER/100;
  //sl = Sym.AddToPrice(pos_type, sl, -1*extra_sl_shift);
  sl = Sym.AddToPrice(pos_type, sl, -1*Inputs.ENT_SL_SHF_PNT);
  double tp = (Inputs.ENT_TP_PNT > 0) ? Sym.AddToPrice(pos_type, ep, +1*Inputs.ENT_TP_PNT) : 0;
  double lot = CalculateLotSuper(Sym.Name(), Inputs.ENT_LTP, Inputs.ENT_LTV, ep, sl);
  
  if(SigDir > 0) 
    ticket = Trade.Buy(lot, Sym.Name(), 0, sl, tp, comment);
  else
    ticket = Trade.Sell(lot, Sym.Name(), 0, sl, tp, comment);
  
  if(ticket > 0) {
    //EPBySigBT = SigDir > 0 ? ZZBotBT : ZZTopBT; // Save ZZ top of entry to skip 2nd entry from it <-- ver 1.01
    EPBySigBT = (ZZTopBT.GetTime() >= ZZBotBT.GetTime()) ? ZZBotBT : ZZTopBT; // ver 1.02
    EPDir = SigDir;
    DrawZZ();
  }
  
  LSF_ASSERT(ticket > 0,
             StringFormat("TICKET=%I64u; SIG_DIR=%d; RET_CODE=%d",
                          ticket,
                          SigDir,
                          Trade.ResultRetcode()),
             WARN, ERROR);

  return ticket;
}


void CATZZADXBot::DrawZZ() {
  if(!Inputs._GUI_ZZ_ENB) return;

  CChartObjectTrend line;
  string name = StringFormat("%s_ZZ_RIB_%s", Logger.Name, TimeToString(TimeCurrent()));
  line.Create(0, name, 0, 
              ZZBotBT.GetTime(), ZZBotBT.GetValue(),
              ZZTopBT.GetTime(), ZZTopBT.GetValue());
  line.Color(SigDir < 0 ? clrGreen : clrRed);
  line.Width(3);
  line.Detach();
  
  name = StringFormat("%s_SIG_BAR_%s", Logger.Name, TimeToString(TimeCurrent()));
  line.Create(0, name, 0, 
              SigDir > 0 ? ZZBotBT.GetTime() : ZZTopBT.GetTime(),
              SigDir > 0 ? ZZBotBT.GetValue() : ZZTopBT.GetValue(),
              SigBT.GetTime(), SigBT.GetValue());
  line.Color(SigDir < 0 ? clrRed : clrGreen);
  line.Style(STYLE_DOT);
  line.Detach();
  
  
  CChartObjectVLine vline;
  name = StringFormat("%s_SIG_VDT_%s", Logger.Name, TimeToString(TimeCurrent()));
  vline.Create(0, name, 0, TimeCurrent());
  vline.Color(SigDir > 0 ? clrGreen : clrRed);
  vline.Style(STYLE_DOT);
  vline.Detach();  
}

void CATZZADXBot::DrawTSL(const ulong _ticket, const double _sl) {
  if(!Inputs._GUI_TSL_ENB) return;

  CChartObjectTrend line;
  string name = StringFormat("%s_TSL_%d", Logger.Name, _ticket);
  line.Create(0, name, 0, 
              iTime(Sym.Name(), TF, Inputs.EXT_TSL_BAR), _sl,
              TimeCurrent(), _sl);
  line.Color(Inputs._GUI_TSL_CLR);
  line.Width(Inputs._GUI_TSL_WDT);
  line.Detach();  
}

