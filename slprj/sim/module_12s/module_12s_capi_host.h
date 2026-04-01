#ifndef module_12s_cap_host_h__
#define module_12s_cap_host_h__
#ifdef HOST_CAPI_BUILD
#include "rtw_capi.h"
#include "rtw_modelmap_simtarget.h"
#include "cell_ecm_2rc_capi_host.h"
typedef struct { rtwCAPI_ModelMappingInfo mmi ; rtwCAPI_ModelMappingInfo *
childMMI [ 1 ] ; cell_ecm_2rc_host_DataMapInfo_T child0 ; }
module_12s_host_DataMapInfo_T ;
#ifdef __cplusplus
extern "C" {
#endif
void module_12s_host_InitializeDataMapInfo ( module_12s_host_DataMapInfo_T *
dataMap , const char * path ) ;
#ifdef __cplusplus
}
#endif
#endif
#endif
