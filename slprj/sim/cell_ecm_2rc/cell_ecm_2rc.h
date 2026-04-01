#ifndef cell_ecm_2rc_h_
#define cell_ecm_2rc_h_
#ifndef cell_ecm_2rc_COMMON_INCLUDES_
#define cell_ecm_2rc_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "slsv_diagnostic_codegen_c_api.h"
#include "sl_AsyncioQueue/AsyncioQueueCAPI.h"
#include "simstruc.h"
#include "fixedpoint.h"
#include "math.h"
#endif
#include "cell_ecm_2rc_types.h"
#include "model_reference_types.h"
#include "rtw_modelmap_simtarget.h"
#include "rt_nonfinite.h"
#include <string.h>
#include <stddef.h>
typedef struct { real_T dirdlno05n ; real_T oeyqqwqwt0 ; real_T bkokd1y3rk ;
real_T jxslalyhmb ; } emp5l05eu4 ; typedef struct { boolean_T gwvla1xe0s ;
boolean_T mylbtsjpxf ; boolean_T gervpqnbyr ; } gfjhxexy1w ; typedef struct {
real_T on4cal32df ; real_T dlusskas02 ; real_T oua2tz5vwd ; real_T astatdwtg1
; } itmyhcym4e ; typedef struct { real_T on4cal32df ; real_T dlusskas02 ;
real_T oua2tz5vwd ; real_T astatdwtg1 ; } d1ckjhhn5k ; typedef struct {
boolean_T on4cal32df ; boolean_T dlusskas02 ; boolean_T oua2tz5vwd ;
boolean_T astatdwtg1 ; } cmlxu2mphg ; struct gukvvxbc0d3_ { real_T P_13 ;
real_T P_14 ; real_T P_15 ; uint32_T P_16 [ 2 ] ; uint32_T P_17 [ 2 ] ;
uint32_T P_18 [ 2 ] ; uint32_T P_19 [ 2 ] ; uint32_T P_20 [ 2 ] ; uint32_T
P_21 [ 2 ] ; } ; struct on2tffqips { struct SimStruct_tag * _mdlRefSfcnS ;
const rtTimingBridge * timingBridge ; struct { rtwCAPI_ModelMappingInfo mmi ;
rtwCAPI_ModelMapLoggingInstanceInfo mmiLogInstanceInfo ; void * dataAddress [
4 ] ; int32_T * vardimsAddress [ 4 ] ; RTWLoggingFcnPtr loggingPtrs [ 4 ] ;
sysRanDType * systemRan [ 2 ] ; int_T systemTid [ 2 ] ; } DataMapInfo ;
struct { int_T mdlref_GlobalTID [ 1 ] ; time_T tStart ; } Timing ; } ;
typedef struct { emp5l05eu4 rtb ; gfjhxexy1w rtdw ; hjkdgfps1n rtm ; }
lwl5utzxb0q ; extern real_T rtP_C1_data [ 147 ] ; extern real_T rtP_C2_data [
147 ] ; extern real_T rtP_OCV_data [ 707 ] ; extern real_T rtP_R0_data [ 147
] ; extern real_T rtP_R1_data [ 147 ] ; extern real_T rtP_R2_data [ 147 ] ;
extern real_T rtP_SoC_bp_ecm [ 21 ] ; extern real_T rtP_SoC_bp_ocv [ 101 ] ;
extern real_T rtP_T_bp [ 7 ] ; extern real_T rtP_cp_cell ; extern real_T
rtP_h_amb ; extern real_T rtP_h_cool ; extern real_T rtP_m_cell ; extern void
esbq2vopok ( SimStruct * _mdlRefSfcnS , int_T mdlref_TID0 , hjkdgfps1n *
const ey5bsreltl , emp5l05eu4 * localB , gfjhxexy1w * localDW , itmyhcym4e *
localX , void * sysRanPtr , int contextTid , rtwCAPI_ModelMappingInfo *
rt_ParentMMI , const char_T * rt_ChildPath , int_T rt_ChildMMIIdx , int_T
rt_CSTATEIdx ) ; extern void mr_cell_ecm_2rc_MdlInfoRegFcn ( SimStruct *
mdlRefSfcnS , char_T * modelName , int_T * retVal ) ; extern mxArray *
mr_cell_ecm_2rc_GetDWork ( const lwl5utzxb0q * mdlrefDW ) ; extern void
mr_cell_ecm_2rc_SetDWork ( lwl5utzxb0q * mdlrefDW , const mxArray * ssDW ) ;
extern void mr_cell_ecm_2rc_RegisterSimStateChecksum ( SimStruct * S ) ;
extern mxArray * mr_cell_ecm_2rc_GetSimStateDisallowedBlocks ( ) ; extern
const rtwCAPI_ModelMappingStaticInfo * cell_ecm_2rc_GetCAPIStaticMap ( void )
; extern void n03twtt14d ( hjkdgfps1n * const ey5bsreltl , gfjhxexy1w *
localDW , itmyhcym4e * localX ) ; extern void ehc0w2q3bn ( hjkdgfps1n * const
ey5bsreltl , gfjhxexy1w * localDW , itmyhcym4e * localX ) ; extern void
bawlksqdxc ( emp5l05eu4 * localB , d1ckjhhn5k * localXdot ) ; extern void
iqaf22scse ( gfjhxexy1w * localDW ) ; extern void cell_ecm_2rc ( hjkdgfps1n *
const ey5bsreltl , const real_T * ilk5lknf5t , const real_T * is0ewwrs1v ,
const real_T * g3amwwkhom , const real_T * f1zftub3tg , const real_T *
dnloh1nsmt , const real_T * k4wfdd52dd , const real_T * abkkh3tegs , const
real_T * puanlby4mj , const real_T * mbzfkgcqmc , const real_T * f5xpcqxrw0 ,
const real_T * jd11vgptvz , real_T * aguaycxiba , real_T * b5qgl2blqs ,
real_T * c54xup1sjc , real_T * ic5p5gf4j1 , emp5l05eu4 * localB , gfjhxexy1w
* localDW , itmyhcym4e * localX ) ; extern void c2rhooelty ( hjkdgfps1n *
const ey5bsreltl ) ;
#endif
