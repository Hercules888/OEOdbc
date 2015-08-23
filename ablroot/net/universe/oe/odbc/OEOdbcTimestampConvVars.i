/*
struct tagTIMESTAMP_STRUCT {
   SQLSMALLINT year;
   SQLUSMALLINT month;
   SQLUSMALLINT day;
   SQLUSMALLINT hour;
   SQLUSMALLINT minute;
   SQLUSMALLINT second;
   SQLUINTEGER fraction;[b] 
} TIMESTAMP_STRUCT;[a]
*/
&IF DEFINED(OnlyAssignment) &THEN
&ELSE
def var x__mTSMonthTmp{&Idx}__x    as memptr no-undo.
def var x__mTSDayTmp{&Idx}__x      as memptr no-undo.
def var x__mTSHourTmp{&Idx}__x     as memptr no-undo.
def var x__mTSMinuteTmp{&Idx}__x   as memptr no-undo.
def var x__mTSSecondTmp{&Idx}__x   as memptr no-undo.
def var x__mTSFractionTmp{&Idx}__x as memptr no-undo.
&ENDIF

&IF DEFINED(OnlyVars) &THEN
&ELSE
set-pointer-value(x__mTSMonthTmp{&Idx}__x)    = get-pointer-value(mDBTableCols[{&Idx}])     + 2.
set-pointer-value(x__mTSDayTmp{&Idx}__x)      = get-pointer-value(x__mTSMonthTmp{&Idx}__x)  + 2.
set-pointer-value(x__mTSHourTmp{&Idx}__x)     = get-pointer-value(x__mTSDayTmp{&Idx}__x)    + 2.
set-pointer-value(x__mTSMinuteTmp{&Idx}__x)   = get-pointer-value(x__mTSHourTmp{&Idx}__x)   + 2.
set-pointer-value(x__mTSSecondTmp{&Idx}__x)   = get-pointer-value(x__mTSMinuteTmp{&Idx}__x) + 2.
set-pointer-value(x__mTSFractionTmp{&Idx}__x) = get-pointer-value(x__mTSSecondTmp{&Idx}__x) + 2.
&ENDIF