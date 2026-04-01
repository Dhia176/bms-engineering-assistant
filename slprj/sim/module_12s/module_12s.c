#include "module_12s.h"
#include "rtwtypes.h"
#include "module_12s_capi.h"
#include "module_12s_private.h"
#include <string.h>
#include "cell_ecm_2rc.h"
static RegMdlInfo rtMdlInfo_module_12s [ 57 ] = { { "a3pux1dfzm" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"lespy1ekyy" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "h1bzjfir22" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "abst2yuy21" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"je3ccaikdk" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "okmdwidedi" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "jbjcxivkeg" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"fvhtwdgkmr" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "cartvl4gn1" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "gibfgsmd1v" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"mfgzgx5xwo" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "ptnsy2k4dg" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "oe40wukmey" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"eukyfajbmmh" , MDL_INFO_NAME_MDLREF_DWORK , 0 , - 1 , ( void * )
"module_12s" } , { "ozjksjcxkp" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "kpsqmxudoi" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"g5h3oyjv3g" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "gq41qyk14t" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "g3blwi2tzk" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"mzmnekx0vt" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "mgyoq5wkxu" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "cic2ozcbch" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"d4o2sajq5z" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "br3poeyzbz" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "ln3cy1k2aa" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"jj5jikjqb0" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "l4ucheu2n0" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "ijqh5fy2ka" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"btwsdrwuu2" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "ngn0jwsrvp" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "coyppjg3er" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"kekbfk5ydx" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "hpcskk5akc" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "cmytdbuhw4" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"garwwd4yu1" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "ftro1fofar" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "bay2nfbqmj" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"module_12s" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , 0 , ( NULL ) } , {
"avxhutcz1v" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "nkkhioc114l" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1
, ( void * ) "module_12s" } , { "cutisc5bcg" ,
MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * ) "module_12s" } , {
"o3m5zhn2ea" , MDL_INFO_ID_GLOBAL_RTW_CONSTRUCT , 0 , - 1 , ( void * )
"module_12s" } , { "lwl5utzxb0q" , MDL_INFO_ID_DATA_TYPE , 0 , - 1 , ( NULL )
} , { "mr_module_12s_GetSimStateDisallowedBlocks" ,
MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_extractBitFieldFromCellArrayWithOffset" ,
MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_cacheBitFieldToCellArrayWithOffset" ,
MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_restoreDataFromMxArrayWithOffset" , MDL_INFO_ID_MODEL_FCN_NAME
, 0 , - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_cacheDataToMxArrayWithOffset" , MDL_INFO_ID_MODEL_FCN_NAME , 0
, - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_extractBitFieldFromMxArray" , MDL_INFO_ID_MODEL_FCN_NAME , 0 ,
- 1 , ( void * ) "module_12s" } , { "mr_module_12s_cacheBitFieldToMxArray" ,
MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_restoreDataFromMxArray" , MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1
, ( void * ) "module_12s" } , { "mr_module_12s_cacheDataAsMxArray" ,
MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_RegisterSimStateChecksum" , MDL_INFO_ID_MODEL_FCN_NAME , 0 , -
1 , ( void * ) "module_12s" } , { "mr_module_12s_SetDWork" ,
MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1 , ( void * ) "module_12s" } , {
"mr_module_12s_GetDWork" , MDL_INFO_ID_MODEL_FCN_NAME , 0 , - 1 , ( void * )
"module_12s" } , { "module_12s.h" , MDL_INFO_MODEL_FILENAME , 0 , - 1 , ( NULL
) } , { "module_12s.c" , MDL_INFO_MODEL_FILENAME , 0 , - 1 , ( void * )
"module_12s" } } ; void cmytdbuhw4 ( jj5jikjqb0 * localDW , mgyoq5wkxu *
localX ) { real_T dte4mwnxnx ; real_T aw0hfuwaia ; real_T lho2gun22u ; real_T
edvy03o1xm ; real_T mhr2qxvgyz ; int32_T ascja01dzv ; for ( ascja01dzv = 0 ;
ascja01dzv < 12 ; ascja01dzv ++ ) { dte4mwnxnx = 0.0 ; aw0hfuwaia = 0.0 ;
lho2gun22u = 0.0 ; edvy03o1xm = 0.0 ; mhr2qxvgyz = 0.0 ; n03twtt14d ( & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtm ) , & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtdw ) , & ( localX -> i4vuwvowf0 [ ascja01dzv ] . moqrhxu5gp ) ) ; } } void hpcskk5akc ( jj5jikjqb0 * localDW , mgyoq5wkxu * localX ) { real_T dte4mwnxnx ; real_T aw0hfuwaia ; real_T lho2gun22u ; real_T edvy03o1xm ; real_T mhr2qxvgyz ; int32_T ascja01dzv ; for ( ascja01dzv = 0 ; ascja01dzv < 12 ; ascja01dzv ++ ) { dte4mwnxnx = 0.0 ; aw0hfuwaia = 0.0 ; lho2gun22u = 0.0 ; edvy03o1xm = 0.0 ; mhr2qxvgyz = 0.0 ; ehc0w2q3bn ( & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtm ) , & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtdw ) , & ( localX -> i4vuwvowf0 [ ascja01dzv ] . moqrhxu5gp ) ) ; } } void module_12s ( const real_T * b51xywccig , const real_T obknyzuaia [ 12 ] , const real_T * ezcdbvfkl0 , const real_T avachjvr55 [ 12 ] , const real_T ks5hzw4qzh [ 12 ] , const real_T ndo3fu1df2 [ 12 ] , const real_T * pzx01gxel4 , const real_T * bhsmv5a3cp , const real_T * chwyoniak2 , const real_T * h1rni01dgp , const real_T b5tfvg4vfb [ 12 ] , real_T * lln1lyw5vu , real_T ibfjd5g23i [ 12 ] , real_T h4yqjsgwwu [ 12 ] , real_T adohlixmfn [ 12 ] , real_T hy0qoxsopd [ 12 ] , jj5jikjqb0 * localDW , mgyoq5wkxu * localX ) { real_T dte4mwnxnx ; real_T aw0hfuwaia ; real_T lho2gun22u ; real_T edvy03o1xm ; real_T mhr2qxvgyz ; real_T ovuxtk10s0 ; real_T eh5uj1xvj4 ; real_T dkoqjr3a25 ; real_T jk0l3jub0n ; int32_T ascja01dzv ; real_T tmp ; int32_T i ; ascja01dzv = 0 ; while ( ascja01dzv < 12 ) { dte4mwnxnx = obknyzuaia [ ascja01dzv ] ; aw0hfuwaia = avachjvr55 [ ascja01dzv ] ; lho2gun22u = ks5hzw4qzh [ ascja01dzv ] ; edvy03o1xm = ndo3fu1df2 [ ascja01dzv ] ; mhr2qxvgyz = b5tfvg4vfb [ ascja01dzv ] ; cell_ecm_2rc ( & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtm ) , b51xywccig , & dte4mwnxnx , ezcdbvfkl0 , & aw0hfuwaia , & lho2gun22u , & edvy03o1xm , pzx01gxel4 , bhsmv5a3cp , chwyoniak2 , h1rni01dgp , & mhr2qxvgyz , & ovuxtk10s0 , & dkoqjr3a25 , & jk0l3jub0n , & eh5uj1xvj4 , & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtb ) , & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtdw ) , & ( localX -> i4vuwvowf0 [ ascja01dzv ] . moqrhxu5gp ) ) ; ibfjd5g23i [ ascja01dzv ] = ovuxtk10s0 ; hy0qoxsopd [ ascja01dzv ] = eh5uj1xvj4 ; h4yqjsgwwu [ ascja01dzv ] = dkoqjr3a25 ; adohlixmfn [ ascja01dzv ] = jk0l3jub0n ; ascja01dzv ++ ; } tmp = - 0.0 ; for ( i = 0 ; i < 12 ; i ++ ) { tmp += ibfjd5g23i [ i ] ; } * lln1lyw5vu = tmp ; } void kekbfk5ydx ( const real_T obknyzuaia [ 12 ] , const real_T avachjvr55 [ 12 ] , const real_T ks5hzw4qzh [ 12 ] , const real_T ndo3fu1df2 [ 12 ] , const real_T b5tfvg4vfb [ 12 ] , jj5jikjqb0 * localDW ) { real_T dte4mwnxnx ; real_T aw0hfuwaia ; real_T lho2gun22u ; real_T edvy03o1xm ; real_T mhr2qxvgyz ; int32_T ascja01dzv ; for ( ascja01dzv = 0 ; ascja01dzv < 12 ; ascja01dzv ++ ) { dte4mwnxnx = obknyzuaia [ ascja01dzv ] ; aw0hfuwaia = avachjvr55 [ ascja01dzv ] ; lho2gun22u = ks5hzw4qzh [ ascja01dzv ] ; edvy03o1xm = ndo3fu1df2 [ ascja01dzv ] ; mhr2qxvgyz = b5tfvg4vfb [ ascja01dzv ] ; iqaf22scse ( & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtdw ) ) ; } } void coyppjg3er ( const real_T obknyzuaia [ 12 ] , const real_T avachjvr55 [ 12 ] , const real_T ks5hzw4qzh [ 12 ] , const real_T ndo3fu1df2 [ 12 ] , const real_T b5tfvg4vfb [ 12 ] , jj5jikjqb0 * localDW , mzmnekx0vt * localXdot ) { real_T dte4mwnxnx ; real_T aw0hfuwaia ; real_T lho2gun22u ; real_T edvy03o1xm ; real_T mhr2qxvgyz ; int32_T ascja01dzv ; for ( ascja01dzv = 0 ; ascja01dzv < 12 ; ascja01dzv ++ ) { dte4mwnxnx = obknyzuaia [ ascja01dzv ] ; aw0hfuwaia = avachjvr55 [ ascja01dzv ] ; lho2gun22u = ks5hzw4qzh [ ascja01dzv ] ; edvy03o1xm = ndo3fu1df2 [ ascja01dzv ] ; mhr2qxvgyz = b5tfvg4vfb [ ascja01dzv ] ; bawlksqdxc ( & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtb ) , & ( localXdot -> i4vuwvowf0 [ ascja01dzv ] . moqrhxu5gp ) ) ; } } void btwsdrwuu2 ( jj5jikjqb0 * localDW , o3m5zhn2ea * const mhbwal3yff ) { int32_T ascja01dzv ; for ( ascja01dzv = 0 ; ascja01dzv < 12 ; ascja01dzv ++ ) { c2rhooelty ( & ( localDW -> i4vuwvowf0 [ ascja01dzv ] . f0l11pwf3l . rtm ) ) ; } if ( ! slIsRapidAcceleratorSimulating ( ) ) { slmrRunPluginEvent ( mhbwal3yff -> _mdlRefSfcnS , "module_12s" , "SIMSTATUS_TERMINATING_MODELREF_ACCEL_EVENT" ) ; } } void garwwd4yu1 ( SimStruct * _mdlRefSfcnS , int_T mdlref_TID0 , o3m5zhn2ea * const mhbwal3yff , jj5jikjqb0 * localDW , mgyoq5wkxu * localX , void * sysRanPtr , int contextTid , rtwCAPI_ModelMappingInfo * rt_ParentMMI , const char_T * rt_ChildPath , int_T rt_ChildMMIIdx , int_T rt_CSTATEIdx ) { ( void ) memset ( ( void * ) mhbwal3yff , 0 , sizeof ( o3m5zhn2ea ) ) ; mhbwal3yff -> Timing . mdlref_GlobalTID [ 0 ] = mdlref_TID0 ; mhbwal3yff -> _mdlRefSfcnS = ( _mdlRefSfcnS ) ; if ( ! slIsRapidAcceleratorSimulating ( ) ) { slmrRunPluginEvent ( mhbwal3yff -> _mdlRefSfcnS , "module_12s" , "START_OF_SIM_MODEL_MODELREF_ACCEL_EVENT" ) ; } ( void ) memset ( ( void * ) localDW , 0 , sizeof ( jj5jikjqb0 ) ) ; module_12s_InitializeDataMapInfo ( mhbwal3yff , localDW , sysRanPtr , contextTid ) ; { int32_T i_1 ; for ( i_1 = 0 ; i_1 < 12 ; i_1 ++ ) { esbq2vopok ( _mdlRefSfcnS , mdlref_TID0 , & ( localDW -> i4vuwvowf0 [ i_1 ] . f0l11pwf3l . rtm ) , & ( localDW -> i4vuwvowf0 [ i_1 ] . f0l11pwf3l . rtb ) , & ( localDW -> i4vuwvowf0 [ i_1 ] . f0l11pwf3l . rtdw ) , & ( localX -> i4vuwvowf0 [ i_1 ] . moqrhxu5gp ) , mhbwal3yff -> DataMapInfo . systemRan [ 0 ] , mhbwal3yff -> DataMapInfo . systemTid [ 0 ] , ( NULL ) , ( NULL ) , 0 , - 1 ) ; } } if ( ( rt_ParentMMI != ( NULL ) ) && ( rt_ChildPath != ( NULL ) ) ) { rtwCAPI_SetChildMMI ( * rt_ParentMMI , rt_ChildMMIIdx , & ( mhbwal3yff -> DataMapInfo . mmi ) ) ; rtwCAPI_SetPath ( mhbwal3yff -> DataMapInfo . mmi , rt_ChildPath ) ; rtwCAPI_MMISetContStateStartIndex ( mhbwal3yff -> DataMapInfo . mmi , rt_CSTATEIdx ) ; } } void mr_module_12s_MdlInfoRegFcn ( SimStruct * mdlRefSfcnS , char_T * modelName , int_T * retVal ) { * retVal = 0 ; { boolean_T regSubmodelsMdlinfo = false ; ssGetRegSubmodelsMdlinfo ( mdlRefSfcnS , & regSubmodelsMdlinfo ) ; if ( regSubmodelsMdlinfo ) { mr_cell_ecm_2rc_MdlInfoRegFcn ( mdlRefSfcnS , "cell_ecm_2rc" , retVal ) ; if ( * retVal == 0 ) return ; * retVal = 0 ; } } * retVal = 0 ; ssRegModelRefMdlInfo ( mdlRefSfcnS , modelName , rtMdlInfo_module_12s , 57 ) ; * retVal = 1 ; } static void mr_module_12s_cacheDataAsMxArray ( mxArray * destArray , mwIndex i , int j , const void * srcData , size_t numBytes ) ; static void mr_module_12s_cacheDataAsMxArray ( mxArray * destArray , mwIndex i , int j , const void * srcData , size_t numBytes ) { mxArray * newArray = mxCreateUninitNumericMatrix ( ( size_t ) 1 , numBytes , mxUINT8_CLASS , mxREAL ) ; memcpy ( ( uint8_T * ) mxGetData ( newArray ) , ( const uint8_T * ) srcData , numBytes ) ; mxSetFieldByNumber ( destArray , i , j , newArray ) ; } static void mr_module_12s_restoreDataFromMxArray ( void * destData , const mxArray * srcArray , mwIndex i , int j , size_t numBytes ) ; static void mr_module_12s_restoreDataFromMxArray ( void * destData , const mxArray * srcArray , mwIndex i , int j , size_t numBytes ) { memcpy ( ( uint8_T * ) destData , ( const uint8_T * ) mxGetData ( mxGetFieldByNumber ( srcArray , i , j ) ) , numBytes ) ; } static void mr_module_12s_cacheBitFieldToMxArray ( mxArray * destArray , mwIndex i , int j , uint_T bitVal ) ; static void mr_module_12s_cacheBitFieldToMxArray ( mxArray * destArray , mwIndex i , int j , uint_T bitVal ) { mxSetFieldByNumber ( destArray , i , j , mxCreateDoubleScalar ( ( real_T ) bitVal ) ) ; } static uint_T mr_module_12s_extractBitFieldFromMxArray ( const mxArray * srcArray , mwIndex i , int j , uint_T numBits ) ; static uint_T mr_module_12s_extractBitFieldFromMxArray ( const mxArray * srcArray , mwIndex i , int j , uint_T numBits ) { const uint_T varVal = ( uint_T ) mxGetScalar ( mxGetFieldByNumber ( srcArray , i , j ) ) ; return varVal & ( ( 1u << numBits ) - 1u ) ; } static void mr_module_12s_cacheDataToMxArrayWithOffset ( mxArray * destArray , mwIndex i , int j , mwIndex offset , const void * srcData , size_t numBytes ) ; static void mr_module_12s_cacheDataToMxArrayWithOffset ( mxArray * destArray , mwIndex i , int j , mwIndex offset , const void * srcData , size_t numBytes ) { uint8_T * varData = ( uint8_T * ) mxGetData ( mxGetFieldByNumber ( destArray , i , j ) ) ; memcpy ( ( uint8_T * ) & varData [ offset * numBytes ] , ( const uint8_T * ) srcData , numBytes ) ; } static void mr_module_12s_restoreDataFromMxArrayWithOffset ( void * destData , const mxArray * srcArray , mwIndex i , int j , mwIndex offset , size_t numBytes ) ; static void mr_module_12s_restoreDataFromMxArrayWithOffset ( void * destData , const mxArray * srcArray , mwIndex i , int j , mwIndex offset , size_t numBytes ) { const uint8_T * varData = ( const uint8_T * ) mxGetData ( mxGetFieldByNumber ( srcArray , i , j ) ) ; memcpy ( ( uint8_T * ) destData , ( const uint8_T * ) & varData [ offset * numBytes ] , numBytes ) ; } static void mr_module_12s_cacheBitFieldToCellArrayWithOffset ( mxArray * destArray , mwIndex i , int j , mwIndex offset , uint_T fieldVal ) ; static void mr_module_12s_cacheBitFieldToCellArrayWithOffset ( mxArray * destArray , mwIndex i , int j , mwIndex offset , uint_T fieldVal ) { mxSetCell ( mxGetFieldByNumber ( destArray , i , j ) , offset , mxCreateDoubleScalar ( ( real_T ) fieldVal ) ) ; } static uint_T mr_module_12s_extractBitFieldFromCellArrayWithOffset ( const mxArray * srcArray , mwIndex i , int j , mwIndex offset , uint_T numBits ) ; static uint_T mr_module_12s_extractBitFieldFromCellArrayWithOffset ( const mxArray * srcArray , mwIndex i , int j , mwIndex offset , uint_T numBits ) { const uint_T fieldVal = ( uint_T ) mxGetScalar ( mxGetCell ( mxGetFieldByNumber ( srcArray , i , j ) , offset ) ) ; return fieldVal & ( ( 1u << numBits ) - 1u ) ; } mxArray * mr_module_12s_GetDWork ( const eukyfajbmmh * mdlrefDW ) { static const char_T * ssDWFieldNames [ 3 ] = { "NULL->rtb" , "rtdw" , "NULL->rtzce" , } ; mxArray * ssDW = mxCreateStructMatrix ( 1 , 1 , 3 , ssDWFieldNames ) ; { static const char_T * rtdwDataFieldNames [ 1 ] = { "mdlrefDW->rtdw.i4vuwvowf0[0].f0l11pwf3l" , } ; mxArray * rtdwData = mxCreateStructMatrix ( 1 , 1 , 1 , rtdwDataFieldNames ) ; int k0 ; mxSetFieldByNumber ( rtdwData , 0 , 0 , mxCreateCellMatrix ( 1 , 12 ) ) ; for ( k0 = 0 ; k0 < 12 ; ++ k0 ) { const mwIndex offset0 = k0 ; { mxArray * varData = mr_cell_ecm_2rc_GetDWork ( & ( mdlrefDW -> rtdw . i4vuwvowf0 [ k0 ] . f0l11pwf3l ) ) ; mxSetCell ( mxGetFieldByNumber ( rtdwData , 0 , 0 ) , offset0 , varData ) ; } } mxSetFieldByNumber ( ssDW , 0 , 1 , rtdwData ) ; } ( void ) mdlrefDW ; return ssDW ; } void mr_module_12s_SetDWork ( eukyfajbmmh * mdlrefDW , const mxArray * ssDW ) { ( void ) ssDW ; ( void ) mdlrefDW ; { const mxArray * rtdwData = mxGetFieldByNumber ( ssDW , 0 , 1 ) ; int k0 ; for ( k0 = 0 ; k0 < 12 ; ++ k0 ) { const mwIndex offset0 = k0 ; mr_cell_ecm_2rc_SetDWork ( & ( mdlrefDW -> rtdw . i4vuwvowf0 [ k0 ] . f0l11pwf3l ) , mxGetCell ( mxGetFieldByNumber ( rtdwData , 0 , 0 ) , offset0 ) ) ; } } } void mr_module_12s_RegisterSimStateChecksum ( SimStruct * S ) { const uint32_T chksum [ 4 ] = { 4171529631U , 4160890552U , 1692599168U , 54616872U , } ; slmrModelRefRegisterSimStateChecksum ( S , "module_12s" , & chksum [ 0 ] ) ; mr_cell_ecm_2rc_RegisterSimStateChecksum ( S ) ; } mxArray * mr_module_12s_GetSimStateDisallowedBlocks ( ) { return mr_cell_ecm_2rc_GetSimStateDisallowedBlocks ( ) ; }
#if defined(_MSC_VER)
#pragma warning(disable: 4505) //unreferenced local function has been removed
#endif
