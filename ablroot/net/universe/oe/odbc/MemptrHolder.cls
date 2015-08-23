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


CLASS net.universe.oe.odbc.MemptrHolder:

  DEF PRIVATE VAR mMemptr      AS MEMPTR NO-UNDO.
  DEF PRIVATE VAR mStrlenOrInd AS MEMPTR NO-UNDO. /* Here we will add indicators for SQL */

  CONSTRUCTOR PUBLIC MemptrHolder():
    SET-SIZE(mStrlenOrInd) = 4.
  END CONSTRUCTOR.

  CONSTRUCTOR PUBLIC MemptrHolder(INPUT iSize AS INT):
    SET-SIZE(mMemptr) = iSize.
    SET-SIZE(mStrlenOrInd) = 4.
  END CONSTRUCTOR.

  /* Make sure that the memptr is freed when the holder is freed */
  DESTRUCTOR PUBLIC MemptrHolder():
    SET-SIZE(mMemptr) = 0.
    SET-SIZE(mStrlenOrInd) = 0.
  END DESTRUCTOR.

  METHOD PUBLIC STATIC MemptrHolder newForInt(INPUT iVal AS INT):
    DEF VAR oMemptrHolder AS MemptrHolder NO-UNDO.
    ASSIGN oMemptrHolder = NEW MemptrHolder().
    oMemptrHolder:putInt(iVal).

    RETURN oMemptrHolder.
  END METHOD.

  METHOD PUBLIC STATIC MemptrHolder newForInt64(INPUT iVal AS INT64):
    DEF VAR oMemptrHolder AS MemptrHolder NO-UNDO.
    ASSIGN oMemptrHolder = NEW MemptrHolder().
    oMemptrHolder:putInt64(iVal).

    RETURN oMemptrHolder.
  END METHOD.

  
  METHOD PUBLIC STATIC MemptrHolder newForChar(INPUT cVal AS char):
    DEF VAR oMemptrHolder AS MemptrHolder NO-UNDO.
    ASSIGN oMemptrHolder = NEW MemptrHolder().
    oMemptrHolder:putChar(cVal).
    RETURN oMemptrHolder.
  END METHOD.

  METHOD PUBLIC STATIC MemptrHolder newForBit(INPUT lVal AS log):
    DEF VAR oMemptrHolder AS MemptrHolder NO-UNDO.
    ASSIGN oMemptrHolder = NEW MemptrHolder().
    oMemptrHolder:putBit(lVal).
    RETURN oMemptrHolder.
  END METHOD.

  METHOD PUBLIC STATIC MemptrHolder newForTimestamp(INPUT dtTimestamp AS datetime):
    DEF VAR oMemptrHolder AS MemptrHolder NO-UNDO.
    ASSIGN oMemptrHolder = NEW MemptrHolder().
    oMemptrHolder:putTimestamp(dtTimestamp).
    RETURN oMemptrHolder.
  END METHOD.

  METHOD PUBLIC STATIC MemptrHolder newForDate(INPUT dtDate AS date):
    DEF VAR oMemptrHolder AS MemptrHolder NO-UNDO.
    ASSIGN oMemptrHolder = NEW MemptrHolder().
    oMemptrHolder:putDate(dtDate).
    RETURN oMemptrHolder.
  END METHOD.

  METHOD PUBLIC VOID putInt(INPUT iVal AS INT):
    if iVal = ? then DO: 
      put-long(mStrlenOrInd, 1) = {&SQL_NULL_DATA}.
      return.
    END.
    put-long(mStrlenOrInd, 1) = 0.
    
    if mMemptr <> ? and GET-SIZE(mMemptr) <> 4 THEN SET-SIZE(mMemptr) = 0.
    SET-SIZE(mMemptr) = 4.
    PUT-LONG(mMemptr, 1) = iVal.
  END METHOD.
  
  METHOD PUBLIC VOID putInt64(INPUT iVal AS INT64):
    if iVal = ? then DO: 
      put-long(mStrlenOrInd, 1) = {&SQL_NULL_DATA}.
      return.
    END.
    put-long(mStrlenOrInd, 1) = 0.
   
    IF mMemptr <> ? AND GET-SIZE(mMemptr) <> 8 THEN SET-SIZE(mMemptr) = 0.
    SET-SIZE(mMemptr) = 8.
    PUT-INT64(mMemptr, 1) = iVal.
  END METHOD.

  METHOD PUBLIC VOID putChar(INPUT cVal AS char):
    if cVal = ? then DO: 
      put-long(mStrlenOrInd, 1) = {&SQL_NULL_DATA}.
      return.
    END.
    put-long(mStrlenOrInd, 1) = {&SQL_NTS}.
 
  
    def var iLength as int no-undo.
    assign iLength =  length(cVal, "raw") + 1.
    IF mMemptr <> ? AND GET-SIZE(mMemptr) < iLength THEN SET-SIZE(mMemptr) = 0.

    SET-SIZE(mMemptr) = iLength.
    PUT-string(mMemptr, 1) = cVal.

  END METHOD.

  METHOD PUBLIC VOID putBit(INPUT lVal AS log):
    if lVal = ? then DO: 
      put-long(mStrlenOrInd, 1) = {&SQL_NULL_DATA}.
      return.
    END.
    put-long(mStrlenOrInd, 1) = 0.
  
    IF mMemptr <> ? AND GET-SIZE(mMemptr) <> 1 THEN SET-SIZE(mMemptr) = 0.
    SET-SIZE(mMemptr) = 1.
    PUT-byte(mMemptr, 1) = (if lVal then 1 else 0).
  END METHOD.

  METHOD PUBLIC VOID putTimestamp(INPUT dtTimestamp AS DATETIME):
    if dtTimestamp = ? then DO: 
      put-long(mStrlenOrInd, 1) = {&SQL_NULL_DATA}.
      return.
    END.
    put-long(mStrlenOrInd, 1) = 0.
  
    IF mMemptr <> ? AND GET-SIZE(mMemptr) <> 16 THEN SET-SIZE(mMemptr) = 0.
    SET-SIZE(mMemptr) = 16.
    
    DEF VAR iTimeCalc AS INT NO-UNDO.
    DEF VAR iHour AS INT NO-UNDO.
    DEF VAR iMin  AS INT NO-UNDO.
    DEF VAR iSec  AS INT NO-UNDO.
    DEF VAR iMSec AS INT NO-UNDO.

    ASSIGN iTimeCalc = MTIME(dtTimestamp)
           iMSec     = iTimeCalc MOD 1000
           iTimeCalc = (iTimeCalc - iMSec) / 1000
           iSec      = iTimeCalc MOD 60
           iTimeCalc = (iTimeCalc - iSec)  / 60
           iMin      = iTimeCalc MOD 60
           iHour     = (iTimeCalc - iMin) / 60.
    
    put-short(mMemptr,  1) = year(dtTimestamp).
    put-short(mMemptr,  3) = month(dtTimestamp). 
    put-short(mMemptr,  5) = day(dtTimestamp).
    put-short(mMemptr,  7) = iHour.
    put-short(mMemptr,  9) = iMin.
    put-short(mMemptr, 11) = iSec. 
    put-long (mMemptr, 13) = (iMSec * 1000000).
    
  END METHOD.

  METHOD PUBLIC VOID putDate(INPUT dtDate AS DATE):
    if dtDate = ? then DO: 
      put-long(mStrlenOrInd, 1) = {&SQL_NULL_DATA}.
      return.
    END.
    put-long(mStrlenOrInd, 1) = 0.
  	
    IF mMemptr <> ? AND GET-SIZE(mMemptr) <> 6 THEN SET-SIZE(mMemptr) = 0.
    SET-SIZE(mMemptr) = 6.
    if dtDate <> ? then do:
      put-short(mMemptr,  1) = year(dtDate).
      put-short(mMemptr,  3) = month(dtDate). 
      put-short(mMemptr,  5) = day(dtDate).
    end.
  END METHOD.
  
  METHOD PUBLIC {&DEF_POINTER} getPointerValue():
    RETURN GET-POINTER-VALUE(mMemptr).
  END METHOD.
  
  METHOD PUBLIC {&DEF_POINTER} getStrlenOrInd():
    RETURN GET-POINTER-VALUE(mStrlenOrInd).
  END METHOD.
  
  method public int64 getSize():
    return get-size(mMemptr).
  end method.
END CLASS.
