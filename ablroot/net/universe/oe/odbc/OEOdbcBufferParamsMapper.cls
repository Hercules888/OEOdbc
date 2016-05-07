/*------------------------------------------------------------------------
This file is part of the openedge-odbc library, an OpenEdge
ABL wrapper around ODBC Api, intended to invoke SQL calls
directly from OpenEdge ABL code.

Copyright (C) 2013 hercules888@gmail.com

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

&global-define DEF_PTR int
&global-define PTR long

CLASS net.universe.oe.odbc.OEOdbcBufferParamsMapper IMPLEMENTS IOEOdbcParamsMapper:

  def private var mIterateBufferParams as memptr no-undo.
  def private var hTempTable as handle no-undo.
  
  def private temp-table ttRaw no-undo
    field data as raw.

  def private var hBuf    as handle no-undo.
  def private var hBufRaw as handle no-undo.
  def private var hFldRaw as handle no-undo.
  def private var hQry    as handle no-undo.
  
  CONSTRUCTOR PUBLIC OEOdbcBufferParamsMapper(input table-handle htemptable):
    OEOdbcHelperApi:Instance:SQLHOdbcInitialize().
	
	set-size(mIterateBufferParams) = 16.
	put-long(mIterateBufferParams, 1)  = 0. /* statementHandle */
	put-long(mIterateBufferParams, 5)  = 0. /* openedgeBuffer */
	put-long(mIterateBufferParams, 9)  = 0. /* openedgeBufferLen */
	put-long(mIterateBufferParams, 13) = 0. /* sqlbindBufferContext */
	
	assign hBufRaw = temp-table ttRaw:default-buffer-handle
           hFldRaw = hBufRaw:buffer-field('data')
		   hBuf    = hTempTable:default-buffer-handle.

    create ttRaw.
  END CONSTRUCTOR.

  DESTRUCTOR PUBLIC OEOdbcBufferParamsMapper():
    set-size(mIterateBufferParams) = 0.
  END DESTRUCTOR.

  METHOD PUBLIC VOID iterateAndMapParams(oPStmt AS OEOdbcPreparedStatement):
    
	message "StatementHandle (openedge): " oPStmt:iStmtHandle.
    put-long(mIterateBufferParams, 1)  = oPStmt:iStmtHandle. /* statementHandle */
	put-long(mIterateBufferParams, 13) = 0. /* sqlbindBufferContext */



    message "Iterating & mapping parameters".
	def var oOEOdbcHelperApi as net.universe.oe.odbc.OEOdbcHelperApi no-undo.
	def var hCallSQLHExecuteBuffer  as handle no-undo.
	def var mBufferData as memptr no-undo.
	def var iSize as int no-undo.
	def var ptrContext as {&DEF_POINTER} no-undo.
	
	oOEOdbcHelperApi = OEOdbcHelperApi:Instance.
	hCallSQLHExecuteBuffer=oOEOdbcHelperApi:getCallHdlSQLHExecuteBuffer().
    /*
	hCallSQLHExecuteBuffer=oOEOdbcHelperApi:getCallHdlSQLHDummy().
    */
    def var i as int no-undo.
	
     etime(true).	
	create query hQry.
	hQry:set-buffers(hBuf).
	hQry:query-prepare("for each " + hBuf:name + " no-lock").
	do i = 1 to 1:
	  hQry:query-open().
      hQry:get-first().
	  /* Currently we don't use the size, so let's leave it here */
	
      hCallSQLHExecuteBuffer:set-parameter(1,  "long",   "input",  get-pointer-value(mIterateBufferParams)).
	  do while not hQry:query-off-end:
	    hBuf:raw-transfer(true, hFldRaw).
	    mBufferData = ttRaw.data.
   	    put-long(mIterateBufferParams, 5)  = get-pointer-value(mBufferData). /* openedgeBuffer */
	    put-long(mIterateBufferParams, 9)  = get-size(mBufferData).          /* openedgeBufferLen */
		/* message "invoking..." view-as alert-box. */
	    hCallSQLHExecuteBuffer:invoke().
	    /* message "Context (openedge)? " get-{&POINTER}(mIterateBufferParams, 13) view-as alert-box. */
	    set-size(mBufferData)=0.
		if(hCallSQLHExecuteBuffer:return-value <> {&SQL_SUCCESS}) then 
		          OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, oPStmt:iStmtHandle, hCallSQLHExecuteBuffer:return-value, "Unable to execute buffer through helper").

	    hQry:get-next().
  	  end.
	end.
	finally:
	
	  if valid-handle(hQry) then do:
	    hQry:query-close() no-error.
	    delete object hQry.
	  end.
	  oOEOdbcHelperApi:SQLHFreeContext(ptrContext).
	  
	message etime(false) view-as alert-box.	
    end.
	
  /*
    DEF VAR iLen_or_indic_Int       AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Char      AS INT NO-UNDO init {&SQL_NTS}.
    DEF VAR iLen_or_indic_Bit       AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Long      AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Date      AS INT NO-UNDO.
    DEF VAR iLen_or_indic_Timestamp AS INT NO-UNDO.
    
    DEF VAR iRetVal       AS INT NO-UNDO.
    DEF VAR iStmtHandle   AS INT NO-UNDO.
    def var iPointerValue as int no-undo.
    
    DEF VAR hCallSQLBindParamInt       AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamChar      AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamBit       AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamLong      AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamDate      AS HANDLE NO-UNDO.
    DEF VAR hCallSQLBindParamTimestamp AS HANDLE NO-UNDO.
    
    def var mMemptr       as memptr no-undo.
    def var oMemptrHolder as net.universe.oe.odbc.MemptrHolder no-undo.
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


    hCallSQLBindParamInt:SET-PARAMETER       (10, "{&SQLLEN}", "input-output", iLen_or_indic_Int).
    hCallSQLBindParamChar:set-parameter      (10, "{&SQLLEN}", "input-output", iLen_or_indic_Char).
    hCallSQLBindParamBit:set-parameter       (10, "{&SQLLEN}", "input-output", iLen_or_indic_Bit).
    hCallSQLBindParamLong:set-parameter      (10, "{&SQLLEN}", "input-output", iLen_or_indic_Long).
    hCallSQLBindParamDate:set-parameter      (10, "{&SQLLEN}", "input-output", iLen_or_indic_Date).
    hCallSQLBindParamTimestamp:set-parameter (10, "{&SQLLEN}", "input-output", iLen_or_indic_Timestamp).

    FOR EACH ttParam NO-LOCK:
      oMemptrHolder = cast(ttParam.paramValue, "net.universe.oe.odbc.MemptrHolder").
      iPointerValue = oMemptrHolder:getPointerValue().
      set-pointer-value(mMemptr) = iPointerValue.
      
      iMemptrSize = oMemptrHolder:getSize().
      IF ttParam.paramType = {&SQL_C_LONG} THEN DO:
        /* assign iLen_or_indic_Int = (if iPointerValue = 0 then {&SQL_NULL_DATA} else 0). */
      
        hCallSQLBindParamInt:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamInt:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        hCallSQLBindParamInt:INVOKE().  
        iRetVal=hCallSQLBindParamInt:RETURN-VALUE.
      end.
      ELSE IF ttParam.paramType = {&SQL_C_CHAR} THEN DO:
  
        /* assign iLen_or_indic_Char = (if iPointerValue = 0 then {&SQL_NULL_DATA} else 0). */
        hCallSQLBindParamChar:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamChar:set-parameter(6,  "{&SQLULEN}",      "input", iMemptrSize /* iLength */).
        hCallSQLBindParamChar:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr).   /* The actual data to use */
        hCallSQLBindParamChar:set-parameter(9,  "{&SQLLEN}",       "input",  0). /* The length of the buffer containing the data */.

        
        hCallSQLBindParamChar:INVOKE().  
        iRetVal=hCallSQLBindParamChar:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_BIT} THEN DO:
        /* assign iLen_or_indic_Bit = (if iPointerValue = 0 then  {&SQL_NULL_DATA} else 0). */
        hCallSQLBindParamBit:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamBit:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        hCallSQLBindParamBit:INVOKE().  
        iRetVal=hCallSQLBindParamBit:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_SBIGINT} THEN DO:
        /* assign iLen_or_indic_Long = (if iPointerValue = 0 then {&SQL_NULL_DATA} else 0). */
        hCallSQLBindParamLong:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamLong:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        hCallSQLBindParamLong:INVOKE().  
        iRetVal=hCallSQLBindParamLong:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_DATE} THEN DO:
      	message "now date param "  get-short(mMemptr, 1)  "-"  get-short(mMemptr, 3)  "-"  get-short(mMemptr, 5). 
        /* assign iLen_or_indic_Date = (if iPointerValue = 0 then {&SQL_NULL_DATA} else 0). */
        hCallSQLBindParamDate:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamDate:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        hCallSQLBindParamDate:INVOKE().  
        iRetVal=hCallSQLBindParamDate:RETURN-VALUE.
      END.
      else IF ttParam.paramType = {&SQL_C_TIMESTAMP} THEN DO:
        /* assign iLen_or_indic_Timestamp = (if iPointerValue = 0 then {&SQL_NULL_DATA} else 0). */
        hCallSQLBindParamTimestamp:set-parameter(2,  "{&SQLUSMALLINT}", "input", ttParam.paramIdx).   /* What parameter */
        hCallSQLBindParamTimestamp:set-parameter(8,  "{&SQLPOINTER}",   "input", mMemptr). /* The actual data to use */
        hCallSQLBindParamTimestamp:INVOKE().  
        iRetVal=hCallSQLBindParamTimestamp:RETURN-VALUE.
      END.
      ELSE DO:
        undo, throw new OEOdbcException("unsupported parameter type " + String(ttParam.paramType), -1).
      END.  
        
        
      IF iRetVal <> {&SQL_SUCCESS} AND iRetVal <> {&SQL_SUCCESS_WITH_INFO} THEN 
        OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to bind parameter " + String(ttParam.paramIdx) + " in Prepared Statement").
 
    END.
  
  */
  END METHOD.

END CLASS.
