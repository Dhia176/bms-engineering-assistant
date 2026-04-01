#ifndef cell_ecm_2rc_cap_host_h__
#define cell_ecm_2rc_cap_host_h__
#ifdef HOST_CAPI_BUILD
#include "rtw_capi.h"
#include "rtw_modelmap_simtarget.h"
typedef struct { rtwCAPI_ModelMappingInfo mmi ; }
cell_ecm_2rc_host_DataMapInfo_T ;
#ifdef __cplusplus
extern "C" {
#endif
void cell_ecm_2rc_host_InitializeDataMapInfo ( cell_ecm_2rc_host_DataMapInfo_T
* dataMap , const char * path ) ;
#ifdef __cplusplus
}
#endif
#endif
#endif
