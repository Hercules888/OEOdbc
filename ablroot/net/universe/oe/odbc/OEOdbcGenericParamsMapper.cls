/*------------------------------------------------------------------------
This file is part of the OEOdbc library, an OpenEdge ABL wrapper
around the ODBC libraries.


Copyright (C) 2013-2015 hercules888@gmail.com

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

http://www.gnu.org/licenses/lgpl-2.1.txt
----------------------------------------------------------------------*/

USING net.universe.oe.odbc.*.
ROUTINE-LEVEL ON ERROR UNDO, THROW.
{net/universe/oe/odbc/oe-odbc-defs.i}


CLASS net.universe.oe.odbc.OEOdbcGenericParamsMapper IMPLEMENTS IOEOdbcParamsMapper:

  DEF PRIVATE TEMP-TABLE ttParam NO-UNDO
      FIELD paramIdx         AS INT
      FIELD paramType        AS INT
      FIELD paramValue       AS progress.lang.Object
      INDEX idxPK IS PRIMARY UNIQUE paramIdx.


  CONSTRUCTOR PUBLIC OEOdbcGenericParamsMapper():
  END CONSTRUCTOR.

  DESTRUCTOR PUBLIC OEOdbcGenericParamsMapper():
    FOR EACH ttParam NO-LOCK:
        IF VALID-OBJECT(ttParam.paramValue)   THEN DELETE OBJECT ttParam.paramValue.
    END.
    EMPTY TEMP-TABLE ttParam.
  END DESTRUCTOR.

  METHOD PUBLIC VOID setInt64(INPUT iIdx AS INT, INPUT iValue AS INT64):
    FIND FIRST ttParam WHERE ttParam.paramIdx = iIdx EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL ttParam THEN DO: 
      CREATE ttParam.
      ASSIGN ttParam.paramType     = {&SQL_C_SBIGINT}
             ttParam.paramIdx      = iIdx
             .
    END.

    IF VALID-OBJECT(ttParam.paramValue) THEN
      CAST(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder"):putInt64(iValue).
    ELSE
      ASSIGN ttParam.paramValue = MemptrHolder:newForInt64(iValue).

    /* CAST(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder"):test(). */
  END METHOD.
  
  
  METHOD PUBLIC VOID setInt(INPUT iIdx AS INT, INPUT iValue AS INT):
    FIND FIRST ttParam WHERE ttParam.paramIdx = iIdx EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL ttParam THEN DO: 
      CREATE ttParam.
      ASSIGN ttParam.paramType = {&SQL_C_LONG}
             ttParam.paramIdx  = iIdx
             .
    END.

    IF VALID-OBJECT(ttParam.paramValue) THEN
      CAST(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder"):putInt(iValue).
    ELSE
      ASSIGN ttParam.paramValue = MemptrHolder:newForInt(iValue).

  END METHOD.
  
  METHOD PUBLIC VOID setString(INPUT iIdx AS INT, INPUT cValue AS CHAR):
    FIND FIRST ttParam WHERE ttParam.paramIdx = iIdx EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL ttParam THEN DO: 
      CREATE ttParam.
      ASSIGN ttParam.paramType = {&SQL_C_CHAR}
             ttParam.paramIdx  = iIdx
             .
    END.

    IF VALID-OBJECT(ttParam.paramValue) THEN
      CAST(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder"):putChar(cValue).
    ELSE
      ASSIGN ttParam.paramValue = MemptrHolder:newForChar(cValue). 
      
  END METHOD.

  METHOD PUBLIC VOID setDecimal
     ( INPUT iIdx     AS INTEGER, 
       INPUT ideValue AS DECIMAL ):
         
    THIS-OBJECT:setString
      ( iIdx,
        REPLACE(STRING(ideValue), SESSION:NUMERIC-DECIMAL-POINT, ".") ).

    RETURN. 
      
  END METHOD.  

  METHOD PUBLIC VOID setBit(INPUT iIdx AS INT, INPUT lValue AS LOG):
    FIND FIRST ttParam WHERE ttParam.paramIdx = iIdx EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL ttParam THEN DO: 
      CREATE ttParam.
      ASSIGN ttParam.paramType = {&SQL_C_BIT}
             ttParam.paramIdx  = iIdx
             .
    END.


    IF VALID-OBJECT(ttParam.paramValue) THEN 
      CAST(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder"):putBit(lValue).
    ELSE
      ASSIGN ttParam.paramValue = MemptrHolder:newForBit(lValue).

  END METHOD.

  METHOD PUBLIC VOID setTimestamp(INPUT iIdx AS INT, INPUT dtValue as datetime):
    FIND FIRST ttParam WHERE ttParam.paramIdx = iIdx EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL ttParam THEN DO: 
      CREATE ttParam.
      ASSIGN ttParam.paramType = {&SQL_C_TIMESTAMP}
             ttParam.paramIdx  = iIdx
             .
    END.
    

    IF VALID-OBJECT(ttParam.paramValue) THEN 
      CAST(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder"):putTimestamp(dtValue).
    ELSE
      ASSIGN ttParam.paramValue = MemptrHolder:newForTimestamp(dtValue).

  END METHOD.

  METHOD PUBLIC VOID setDate(INPUT iIdx AS INT, INPUT dtValue as date):
    FIND FIRST ttParam WHERE ttParam.paramIdx = iIdx EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL ttParam THEN DO: 
      CREATE ttParam.
      ASSIGN ttParam.paramType = {&SQL_C_DATE}
             ttParam.paramIdx  = iIdx
             .
    END.
    

    IF VALID-OBJECT(ttParam.paramValue) THEN 
      CAST(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder"):putDate(dtValue).
    ELSE
      ASSIGN ttParam.paramValue = MemptrHolder:newForDate(dtValue).

  END METHOD.



  METHOD PUBLIC VOID iterateAndMapParams(oPStmt AS OEOdbcPreparedStatement):
    /*
    DEF VAR iLen_or_indic_Int       AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Char      AS INT NO-UNDO init {&SQL_NTS}.
    DEF VAR iLen_or_indic_Bit       AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Long      AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Date      AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Timestamp AS INT NO-UNDO.
    */
    
    DEF VAR iRetVal       AS INT NO-UNDO.
    DEF VAR iStmtHandle   AS {&DEF_SQLHSTMT} NO-UNDO.
    def var iPointerValue as {&DEF_POINTER} no-undo.
    
    DEF VAR hCallSQLBindParamInt       AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamChar      AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamBit       AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamLong      AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamDate      AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamTimestamp AS HANDLE NO-UNDO.
    
    def var mMemptr       as memptr no-undo.
    def var oMemptrHolder as net.universe.oe.odbc.MemptrHolder no-undo.
    def var iStrlLen_or_indicPtr as {&DEF_POINTER} no-undo init 0.
    
    def var iMemptrSize   as int64  no-undo.

    ASSIGN iStmtHandle = oPStmt:iStmtHandle
           hCallSQLBindParamInt       = OEOdbcApi:Instance:getCallHdlSQLBindParamInt()
           hCallSQLBindParamChar      = OEOdbcApi:Instance:getCallHdlSQLBindParamChar()
           hCallSQLBindParamBit       = OEOdbcApi:Instance:getCallHdlSQLBindParamBit()
           hCallSQLBindParamLong      = OEOdbcApi:Instance:getCallHdlSQLBindParamLong()
           hCallSQLBindParamDate      = OEOdbcApi:Instance:getCallHdlSQLBindParamDate()
           hCallSQLBindParamTimestamp = OEOdbcApi:Instance:getCallHdlSQLBindParamTimestamp().
    hCallSQLBindParamInt:SET-PARAMETER       (1,  "{&SQLHSTMT}", "input", iStmtHandle).
    hCallSQLBindParamChar:set-parameter      (1,  "{&SQLHSTMT}", "input", iStmtHandle).
    hCallSQLBindParamBit:set-parameter       (1,  "{&SQLHSTMT}", "input", iStmtHandle).
    hCallSQLBindParamLong:set-parameter      (1,  "{&SQLHSTMT}", "input", iStmtHandle).
    hCallSQLBindParamDate:set-parameter      (1,  "{&SQLHSTMT}", "input", iStmtHandle).
    hCallSQLBindParamTimestamp:set-parameter (1,  "{&SQLHSTMT}", "input", iStmtHandle).


    def var mStrlenOrIndic as memptr no-undo.
    def var lValueIsNull   as log    no-undo.

    FOR EACH ttParam NO-LOCK:
      /* if ttParam.Len_or_indic <> {&SQL_NULL_DATA} THEN DO: */
      oMemptrHolder = cast(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder").
      iPointerValue = oMemptrHolder:getPointerValue().
      set-pointer-value(mMemptr) = iPointerValue.
      set-pointer-value(mStrlenOrIndic) = oMemptrHolder:getStrlenOrInd().
      lValueIsNull = (get-long(mStrlenOrIndic, 1) = {&SQL_NULL_DATA}).
      
      iMemptrSize = oMemptrHolder:getSize().
      IF ttParam.paramType = {&SQL_C_LONG} THEN DO:
        hCallSQLBindParamInt:set-parameter(2,  "{&SQLUSMALLINT}", "input",  ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamInt:set-parameter(8,  "{&SQLPOINTER}",   "input",  mMemptr).             /* The actual data to use */
        hCallSQLBindParamInt:SET-PARAMETER(10, "{&SQLPOINTER}",   "input",  mStrlenOrIndic). 
        hCallSQLBindParamInt:INVOKE().  
        iRetVal=hCallSQLBindParamInt:RETURN-VALUE.
      end.
      ELSE IF ttParam.paramType = {&SQL_C_CHAR} THEN DO:
        hCallSQLBindParamChar:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamChar:set-parameter(6,  "{&SQLULEN}",      "input", iMemptrSize /* iLength */).
        hCallSQLBindParamChar:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr).   /* The actual data to use */
        hCallSQLBindParamChar:set-parameter(9,  "{&SQLLEN}",       "input",  0). /* The length of the buffer containing the data */.
        hCallSQLBindParamChar:SET-PARAMETER(10, "{&SQLPOINTER}",   "input", mStrlenOrIndic). 
        hCallSQLBindParamChar:INVOKE().  
        iRetVal=hCallSQLBindParamChar:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_BIT} THEN DO:
        hCallSQLBindParamBit:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamBit:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        hCallSQLBindParamBit:SET-PARAMETER(10, "{&SQLPOINTER}",   "input", mStrlenOrIndic). 
        hCallSQLBindParamBit:INVOKE().  
        iRetVal=hCallSQLBindParamBit:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_SBIGINT} THEN DO:
        /* assign iLen_or_indic_Long = (if iPointerValue = 0 then {&SQL_NULL_DATA} else 0). */
        hCallSQLBindParamLong:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamLong:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        hCallSQLBindParamLong:SET-PARAMETER(10, "{&SQLPOINTER}",   "input", mStrlenOrIndic). 
        hCallSQLBindParamLong:INVOKE().  
        iRetVal=hCallSQLBindParamLong:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_DATE} THEN DO:
        hCallSQLBindParamDate:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        if lValueIsNull then do:
          hCallSQLBindParamDate:set-parameter(8,  "{&POINTER}",      "input", 0). /* The actual data to use */ 
          hCallSQLBindParamDate:set-parameter(9,  "{&SQLLEN}",       "input", 0). /* The length of the buffer containing the data */
        end.
        else do:
          hCallSQLBindParamDate:set-parameter(8,  "{&POINTER}",      "input", mMemptr). /* The actual data to use */ 
          hCallSQLBindParamDate:set-parameter(9,  "{&SQLLEN}",       "input", 6). /* The length of the buffer containing the data */
        end. 
        hCallSQLBindParamDate:SET-PARAMETER(10, "{&SQLPOINTER}",      "input", mStrlenOrIndic). 
        hCallSQLBindParamDate:INVOKE().  
        iRetVal=hCallSQLBindParamDate:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_TIMESTAMP} THEN DO:
        /* assign iLen_or_indic_Timestamp = (if iPointerValue = 0 then {&SQL_NULL_DATA} else 0). */
        hCallSQLBindParamTimestamp:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamTimestamp:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        /*
        hCallSQLBindParamTimestamp:SET-PARAMETER(10, "{&SQLLEN}",       "input-output", ttParam.Len_or_indic).
        */
        hCallSQLBindParamTimestamp:SET-PARAMETER(10, "{&SQLPOINTER}",       "input", mStrlenOrIndic). 
        hCallSQLBindParamTimestamp:INVOKE().  
        iRetVal=hCallSQLBindParamTimestamp:RETURN-VALUE.
      END.
      ELSE DO:
        undo, throw new OEOdbcException("unsupported parameter type " + String(ttParam.paramType), -1).
      END.  
        
        
      IF iRetVal <> {&SQL_SUCCESS} AND iRetVal <> {&SQL_SUCCESS_WITH_INFO} THEN 
        OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to bind parameter " + String(ttParam.paramIdx) + " in Prepared Statement").
 
    END.
  
  
  END METHOD.

END CLASS.
