#ifndef module_12s_h_
#define module_12s_h_
#ifndef module_12s_COMMON_INCLUDES_
#define module_12s_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "slsv_diagnostic_codegen_c_api.h"
#include "sl_AsyncioQueue/AsyncioQueueCAPI.h"
#include "simstruc.h"
#include "fixedpoint.h"
#include "math.h"
#endif
#include "module_12s_types.h"
#include "cell_ecm_2rc.h"
#include "model_reference_types.h"
#include "rtw_modelmap_simtarget.h"
#include "rt_nonfinite.h"
#include <string.h>
#include <stddef.h>
typedef struct { lwl5utzxb0q f0l11pwf3l ; } ptnsy2k4dg ; typedef struct {
itmyhcym4e moqrhxu5gp ; } jbjcxivkeg ; typedef struct { d1ckjhhn5k moqrhxu5gp
; } okmdwidedi ; typedef struct { cmlxu2mphg moqrhxu5gp ; } je3ccaikdk ;
typedef struct { ptnsy2k4dg i4vuwvowf0 [ 12 ] ; } jj5jikjqb0 ; typedef struct
{ jbjcxivkeg i4vuwvowf0 [ 12 ] ; } mgyoq5wkxu ; typedef struct { okmdwidedi
i4vuwvowf0 [ 12 ] ; } mzmnekx0vt ; typedef struct { je3ccaikdk i4vuwvowf0 [
12 ] ; } g3blwi2tzk ; struct cutisc5bcg { struct SimStruct_tag * _mdlRefSfcnS
; const rtTimingBridge * timingBridge ; struct { rtwCAPI_ModelMappingInfo mmi
; rtwCAPI_ModelMapLoggingInstanceInfo mmiLogInstanceInfo ;
rtwCAPI_ModelMappingInfo * childMMI [ 1 ] ; sysRanDType * systemRan [ 4 ] ;
int_T systemTid [ 4 ] ; } DataMapInfo ; struct { int_T mdlref_GlobalTID [ 1 ]
; time_T tStart ; } Timing ; } ; typedef struct { jj5jikjqb0 rtdw ;
o3m5zhn2ea rtm ; } eukyfajbmmh ; extern real_T rtP_C1_data [ 147 ] ; extern
real_T rtP_C2_data [ 147 ] ; extern real_T rtP_OCV_data [ 707 ] ; extern
real_T rtP_R0_data [ 147 ] ; extern real_T rtP_R1_data [ 147 ] ; extern
real_T rtP_R2_data [ 147 ] ; extern real_T rtP_SoC_bp_ecm [ 21 ] ; extern
real_T rtP_SoC_bp_ocv [ 101 ] ; extern real_T rtP_T_bp [ 7 ] ; extern real_T
rtP_cp_cell ; extern real_T rtP_h_amb ; extern real_T rtP_h_cool ; extern
real_T rtP_m_cell ; extern void garwwd4yu1 ( SimStruct * _mdlRefSfcnS , int_T
mdlref_TID0 , o3m5zhn2ea * const mhbwal3yff , jj5jikjqb0 * localDW ,
mgyoq5wkxu * localX , void * sysRanPtr , int contextTid ,
rtwCAPI_ModelMappingInfo * rt_ParentMMI , const char_T * rt_ChildPath , int_T
rt_ChildMMIIdx , int_T rt_CSTATEIdx ) ; extern void
mr_module_12s_MdlInfoRegFcn ( SimStruct * mdlRefSfcnS , char_T * modelName ,
int_T * retVal ) ; extern mxArray * mr_module_12s_GetDWork ( const
eukyfajbmmh * mdlrefDW ) ; extern void mr_module_12s_SetDWork ( eukyfajbmmh *
mdlrefDW , const mxArray * ssDW ) ; extern void
mr_module_12s_RegisterSimStateChecksum ( SimStruct * S ) ; extern mxArray *
mr_module_12s_GetSimStateDisallowedBlocks ( ) ; extern const
rtwCAPI_ModelMappingStaticInfo * module_12s_GetCAPIStaticMap ( void ) ;
extern void cmytdbuhw4 ( jj5jikjqb0 * localDW , mgyoq5wkxu * localX ) ;
extern void hpcskk5akc ( jj5jikjqb0 * localDW , mgyoq5wkxu * localX ) ;
extern void coyppjg3er ( const real_T obknyzuaia [ 12 ] , const real_T
avachjvr55 [ 12 ] , const real_T ks5hzw4qzh [ 12 ] , const real_T ndo3fu1df2
[ 12 ] , const real_T b5tfvg4vfb [ 12 ] , jj5jikjqb0 * localDW , mzmnekx0vt *
localXdot ) ; extern void kekbfk5ydx ( const real_T obknyzuaia [ 12 ] , const
real_T avachjvr55 [ 12 ] , const real_T ks5hzw4qzh [ 12 ] , const real_T
ndo3fu1df2 [ 12 ] , const real_T b5tfvg4vfb [ 12 ] , jj5jikjqb0 * localDW ) ;
extern void module_12s ( const real_T * b51xywccig , const real_T obknyzuaia
[ 12 ] , const real_T * ezcdbvfkl0 , const real_T avachjvr55 [ 12 ] , const
real_T ks5hzw4qzh [ 12 ] , const real_T ndo3fu1df2 [ 12 ] , const real_T *
pzx01gxel4 , const real_T * bhsmv5a3cp , const real_T * chwyoniak2 , const
real_T * h1rni01dgp , const real_T b5tfvg4vfb [ 12 ] , real_T * lln1lyw5vu ,
real_T ibfjd5g23i [ 12 ] , real_T h4yqjsgwwu [ 12 ] , real_T adohlixmfn [ 12
] , real_T hy0qoxsopd [ 12 ] , jj5jikjqb0 * localDW , mgyoq5wkxu * localX ) ;
extern void btwsdrwuu2 ( jj5jikjqb0 * localDW , o3m5zhn2ea * const mhbwal3yff
) ;
#endif
