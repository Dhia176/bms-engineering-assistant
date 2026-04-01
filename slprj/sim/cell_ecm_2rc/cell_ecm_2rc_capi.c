#include <stddef.h>
#include "rtw_capi.h"
#ifdef HOST_CAPI_BUILD
#include "cell_ecm_2rc_capi_host.h"
#define sizeof(...) ((size_t)(0xFFFF))
#undef rt_offsetof
#define rt_offsetof(s,el) ((uint16_T)(0xFFFF))
#define TARGET_CONST
#define TARGET_STRING(s) (s)
#ifndef SS_UINT64
#define SS_UINT64 17
#endif
#ifndef SS_INT64
#define SS_INT64 18
#endif
#else
#include "builtin_typeid_types.h"
#include "cell_ecm_2rc.h"
#include "cell_ecm_2rc_capi.h"
#include "cell_ecm_2rc_private.h"
#ifdef LIGHT_WEIGHT_CAPI
#define TARGET_CONST
#define TARGET_STRING(s)               ((NULL))
#else
#define TARGET_CONST                   const
#define TARGET_STRING(s)               (s)
#endif
#endif
static rtwCAPI_Signals rtBlockSignals [ ] = { { 0 , 0 , ( NULL ) , ( NULL ) ,
0 , 0 , 0 , 0 , 0 } } ; static rtwCAPI_States rtBlockStates [ ] = { { 0 , 2 ,
TARGET_STRING ( "cell_ecm_2rc/Cell_ECM/RC1_Dynamics/Integrator" ) ,
TARGET_STRING ( "" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 0 , 1 , - 1 , 0
} , { 1 , 3 , TARGET_STRING ( "cell_ecm_2rc/Cell_ECM/RC2_Dynamics/Integrator"
) , TARGET_STRING ( "" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 0 , 1 , - 1
, 0 } , { 2 , 0 , TARGET_STRING ( "cell_ecm_2rc/Cell_ECM/SoC_Estimator/Integrator" ) , TARGET_STRING ( "" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 0 , 1 , - 1 , 0 } , { 3 , 1 , TARGET_STRING ( "cell_ecm_2rc/Cell_ECM/Thermal_Node/Integrator" ) , TARGET_STRING ( "" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 0 , 1 , - 1 , 0 } , { 0 , - 1 , ( NULL ) , ( NULL ) , ( NULL ) , 0 , 0 , 0 , 0 , 0 , 0 , - 1 , 0 } } ; static int_T rt_LoggedStateIdxList [ ] = { 2 , 3 , 0 , 1 } ;
#ifndef HOST_CAPI_BUILD
static void cell_ecm_2rc_InitializeDataAddr ( void * dataAddr [ ] ,
gfjhxexy1w * localDW , itmyhcym4e * localX ) { dataAddr [ 0 ] = ( void * ) ( &
localX -> oua2tz5vwd ) ; dataAddr [ 1 ] = ( void * ) ( & localX -> astatdwtg1
) ; dataAddr [ 2 ] = ( void * ) ( & localX -> on4cal32df ) ; dataAddr [ 3 ] =
( void * ) ( & localX -> dlusskas02 ) ; }
#endif
#ifndef HOST_CAPI_BUILD
static void cell_ecm_2rc_InitializeVarDimsAddr ( int32_T * vardimsAddr [ ] )
{ vardimsAddr [ 0 ] = ( NULL ) ; }
#endif
#ifndef HOST_CAPI_BUILD
static void cell_ecm_2rc_InitializeLoggingFunctions ( RTWLoggingFcnPtr
loggingPtrs [ ] ) { loggingPtrs [ 0 ] = ( NULL ) ; loggingPtrs [ 1 ] = ( NULL
) ; loggingPtrs [ 2 ] = ( NULL ) ; loggingPtrs [ 3 ] = ( NULL ) ; }
#endif
static TARGET_CONST rtwCAPI_DataTypeMap rtDataTypeMap [ ] = { { "double" ,
"real_T" , 0 , 0 , sizeof ( real_T ) , ( uint8_T ) SS_DOUBLE , 0 , 0 , 0 } }
;
#ifdef HOST_CAPI_BUILD
#undef sizeof
#endif
static TARGET_CONST rtwCAPI_ElementMap rtElementMap [ ] = { { ( NULL ) , 0 ,
0 , 0 , 0 } , } ; static rtwCAPI_DimensionMap rtDimensionMap [ ] = { {
rtwCAPI_SCALAR , 0 , 2 , 0 } } ; static uint_T rtDimensionArray [ ] = { 1 , 1
} ; static const real_T rtcapiStoredFloats [ ] = { 0.0 } ; static
rtwCAPI_FixPtMap rtFixPtMap [ ] = { { ( NULL ) , ( NULL ) ,
rtwCAPI_FIX_RESERVED , 0 , 0 , ( boolean_T ) 0 } , } ; static
rtwCAPI_SampleTimeMap rtSampleTimeMap [ ] = { { ( const void * ) &
rtcapiStoredFloats [ 0 ] , ( const void * ) & rtcapiStoredFloats [ 0 ] , ( int8_T ) 0 , ( uint8_T ) 0 } } ; static int_T rtContextSystems [ 2 ] ; static rtwCAPI_LoggingMetaInfo loggingMetaInfo [ ] = { { 0 , 0 , "" , 0 } } ; static rtwCAPI_ModelMapLoggingStaticInfo mmiStaticInfoLogging = { 2 , rtContextSystems , loggingMetaInfo , 0 , ( NULL ) , { 0 , ( NULL ) , ( NULL ) } , 0 , ( NULL ) } ; static rtwCAPI_ModelMappingStaticInfo mmiStatic = { { rtBlockSignals , 0 , ( NULL ) , 0 , ( NULL ) , 0 } , { ( NULL ) , 0 , ( NULL ) , 0 } , { rtBlockStates , 4 } , { rtDataTypeMap , rtDimensionMap , rtFixPtMap , rtElementMap , rtSampleTimeMap , rtDimensionArray } , "float" , { 2033659798U , 3335207604U , 1333411296U , 3006345451U } , & mmiStaticInfoLogging , 0 , ( boolean_T ) 0 , rt_LoggedStateIdxList } ; const rtwCAPI_ModelMappingStaticInfo * cell_ecm_2rc_GetCAPIStaticMap ( void ) { return & mmiStatic ; }
#ifndef HOST_CAPI_BUILD
static void cell_ecm_2rc_InitializeSystemRan ( hjkdgfps1n * const ey5bsreltl
, sysRanDType * systemRan [ ] , gfjhxexy1w * localDW , int_T systemTid [ ] ,
void * rootSysRanPtr , int rootTid ) { UNUSED_PARAMETER ( ey5bsreltl ) ;
UNUSED_PARAMETER ( localDW ) ; systemRan [ 0 ] = ( sysRanDType * )
rootSysRanPtr ; systemRan [ 1 ] = ( NULL ) ; systemTid [ 1 ] = ey5bsreltl ->
Timing . mdlref_GlobalTID [ 0 ] ; systemTid [ 0 ] = rootTid ;
rtContextSystems [ 0 ] = 0 ; rtContextSystems [ 1 ] = 0 ; }
#endif
#ifndef HOST_CAPI_BUILD
void cell_ecm_2rc_InitializeDataMapInfo ( hjkdgfps1n * const ey5bsreltl ,
gfjhxexy1w * localDW , itmyhcym4e * localX , void * sysRanPtr , int
contextTid ) { rtwCAPI_SetVersion ( ey5bsreltl -> DataMapInfo . mmi , 1 ) ;
rtwCAPI_SetStaticMap ( ey5bsreltl -> DataMapInfo . mmi , & mmiStatic ) ;
rtwCAPI_SetLoggingStaticMap ( ey5bsreltl -> DataMapInfo . mmi , &
mmiStaticInfoLogging ) ; cell_ecm_2rc_InitializeDataAddr ( ey5bsreltl ->
DataMapInfo . dataAddress , localDW , localX ) ; rtwCAPI_SetDataAddressMap ( ey5bsreltl -> DataMapInfo . mmi , ey5bsreltl -> DataMapInfo . dataAddress ) ; cell_ecm_2rc_InitializeVarDimsAddr ( ey5bsreltl -> DataMapInfo . vardimsAddress ) ; rtwCAPI_SetVarDimsAddressMap ( ey5bsreltl -> DataMapInfo . mmi , ey5bsreltl -> DataMapInfo . vardimsAddress ) ; rtwCAPI_SetPath ( ey5bsreltl -> DataMapInfo . mmi , ( NULL ) ) ; rtwCAPI_SetFullPath ( ey5bsreltl -> DataMapInfo . mmi , ( NULL ) ) ; cell_ecm_2rc_InitializeLoggingFunctions ( ey5bsreltl -> DataMapInfo . loggingPtrs ) ; rtwCAPI_SetLoggingPtrs ( ey5bsreltl -> DataMapInfo . mmi , ey5bsreltl -> DataMapInfo . loggingPtrs ) ; rtwCAPI_SetInstanceLoggingInfo ( ey5bsreltl -> DataMapInfo . mmi , & ey5bsreltl -> DataMapInfo . mmiLogInstanceInfo ) ; rtwCAPI_SetChildMMIArray ( ey5bsreltl -> DataMapInfo . mmi , ( NULL ) ) ; rtwCAPI_SetChildMMIArrayLen ( ey5bsreltl -> DataMapInfo . mmi , 0 ) ; cell_ecm_2rc_InitializeSystemRan ( ey5bsreltl , ey5bsreltl -> DataMapInfo . systemRan , localDW , ey5bsreltl -> DataMapInfo . systemTid , sysRanPtr , contextTid ) ; rtwCAPI_SetSystemRan ( ey5bsreltl -> DataMapInfo . mmi , ey5bsreltl -> DataMapInfo . systemRan ) ; rtwCAPI_SetSystemTid ( ey5bsreltl -> DataMapInfo . mmi , ey5bsreltl -> DataMapInfo . systemTid ) ; rtwCAPI_SetGlobalTIDMap ( ey5bsreltl -> DataMapInfo . mmi , & ey5bsreltl -> Timing . mdlref_GlobalTID [ 0 ] ) ; }
#else
#ifdef __cplusplus
extern "C" {
#endif
void cell_ecm_2rc_host_InitializeDataMapInfo ( cell_ecm_2rc_host_DataMapInfo_T
* dataMap , const char * path ) { rtwCAPI_SetVersion ( dataMap -> mmi , 1 ) ;
rtwCAPI_SetStaticMap ( dataMap -> mmi , & mmiStatic ) ;
rtwCAPI_SetDataAddressMap ( dataMap -> mmi , ( NULL ) ) ;
rtwCAPI_SetVarDimsAddressMap ( dataMap -> mmi , ( NULL ) ) ; rtwCAPI_SetPath
( dataMap -> mmi , path ) ; rtwCAPI_SetFullPath ( dataMap -> mmi , ( NULL ) )
; rtwCAPI_SetChildMMIArray ( dataMap -> mmi , ( NULL ) ) ;
rtwCAPI_SetChildMMIArrayLen ( dataMap -> mmi , 0 ) ; }
#ifdef __cplusplus
}
#endif
#endif
