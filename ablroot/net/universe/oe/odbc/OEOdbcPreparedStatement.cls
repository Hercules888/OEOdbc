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

using net.universe.oe.odbc.*.

{net/universe/oe/odbc/oe-odbc-defs.i}

routine-level on error undo, throw.
class net.universe.oe.odbc.OEOdbcPreparedStatement:
  {net/universe/oe/odbc/ttOEOdbcColumnMetadata.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}
  
  def property oStatementMetadata as net.universe.oe.odbc.OEOdbcStatementMetadata no-undo
  get.
  private set.
  
  def property iStmtHandle as {&DEF_SQLHSTMT} no-undo init 0
  get.
  private set.

  DEF PROPERTY iNrOfRecs AS INT NO-UNDO INIT ?
  GET.
  SET.

  DEF PROPERTY mDBTableCols     as memptr no-undo extent {&MAX_COLS_IN_TABLE}
  GET.
  PRIVATE SET.
  
  DEF PROPERTY mColStrLen_or_ind AS MEMPTR NO-UNDO EXTENT {&MAX_COLS_IN_TABLE}
  GET.
  PRIVATE SET.

  def property iNrOfCols as INT NO-UNDO INIT ?
  GET.
  PRIVATE SET.
  
  def property iResultSet as int no-undo init ?
  get.
  private set.
  
  def property lSkipExecute as log no-undo init false
  get.
  set.
  


  constructor public OEOdbcPreparedStatement(input oOdbcCon as net.universe.oe.odbc.OEOdbcConnection,
                                           input cSQL as char):
    def var iRetVal    as {&DEF_SQLSMALLINT} no-undo.
    def var iDbcHandle as {&DEF_SQLHDBC}     no-undo.
    
    if not valid-object(oOdbcCon) then OEOdbcUtil:Instance:throwException("No connection specified to construct Prepared Statement").
    assign iDbcHandle = oOdbcCon:iDbcHandle.

    iRetVal = OEOdbcApi:Instance:SQLAllocHandle({&SQL_HANDLE_STMT}, iDbcHandle, output iStmtHandle).
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to allocate Prepared Statement").
   
    iRetVal = OEOdbcApi:Instance:SQLPrepare(iStmtHandle, cSQL).
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to prepare Prepared Statement").

    oStatementMetadata = new OEOdbcStatementMetadata().
    oStatementMetadata:bindColumnMetadata(output table ttOEOdbcColumnMetadata bind).
  end constructor.
  
  destructor public OEOdbcPreparedStatement():
    def var iRetVal as {&DEF_SQLSMALLINT} no-undo.
    
    if iStmtHandle <> 0 and iStmtHandle <> ? then do:
      iRetVal = OEOdbcApi:Instance:SQLFreeHandle({&SQL_HANDLE_STMT}, iStmtHandle).
      OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to free Prepared Statement").
    end.
    if valid-object(oStatementMetadata) then delete object oStatementMetadata no-error.
  end destructor.
  
 
  
  method public INT executeQuery(INPUT oOEOdbcParamsMapper AS net.universe.oe.odbc.IOEOdbcParamsMapper, INPUT oOEOdbcResultsMapper AS net.universe.oe.odbc.IOEOdbcResultsMapper /* , input cPhysToTmpTableMapping as char */):
    def var iRetVal        as {&DEF_SQLSMALLINT} no-undo.

    def var iDataType      as {&DEF_SQLSMALLINT} no-undo.
    def var iColumnSize    as {&DEF_SQLULEN}     no-undo.
    def var iDecimalDigits as {&DEF_SQLSMALLINT} no-undo.
    def var iNullable      as {&DEF_SQLSMALLINT} no-undo.
    def var iCol           as int    no-undo.
    def var cColumnName    as char   no-undo.
    def var hBufFld        as handle no-undo.
    def var iSqlCType      as int    no-undo.
    def var iColBufSize    as int    no-undo.

    def var hTTBufFldMap     as handle no-undo extent {&MAX_COLS_IN_TABLE}.

    def var iDBColDataTypes  as int    no-undo extent {&MAX_COLS_IN_TABLE}.


    def var hTTBufFldHdls      as handle no-undo extent {&MAX_COLS_IN_TABLE}.
    def var hDefTTBuf          as handle no-undo.
    def var cMappingEntry      as char   no-undo.
    def var q                  as int    no-undo.
    def var cMappedTTColName   as char   no-undo.
    DEF VAR iBatchSize         AS INT    NO-UNDO INIT 0.
    DEF VAR hProc              AS HANDLE NO-UNDO.
    def var iStatusMoreResults as {&DEF_SQLRETURN} no-undo init {&SQL_SUCCESS}.

    def var iNrOfCharCols      as int no-undo init 0.
    def var iNrOfIntCols       as int no-undo init 0.
    def var iNrOfDecCols       as int no-undo init 0.
    def var iNrOfLogCols       as int no-undo init 0.
    def var iNrOfTimestampCols as int no-undo init 0.

    IF VALID-OBJECT(oOEOdbcParamsmapper) THEN oOEOdbcParamsMapper:iterateAndMapParams(THIS-OBJECT).


	
    if not lSkipExecute then iRetVal = OEOdbcApi:Instance:SQLExecute(iStmtHandle).
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to execute Prepared Statement").

      iResultSet = 1.
      if valid-object(oOEOdbcResultsMapper) then 
      do while iStatusMoreResults = {&SQL_SUCCESS} 
            or iStatusMoreResults = {&SQL_SUCCESS_WITH_INFO} on error undo, throw: 
    
        iRetVal = OEOdbcApi:Instance:SQLNumResultCols(iStmtHandle, output iNrOfCols).
        OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to retrieve number of columns from Prepared Statement").

        empty temp-table ttOEOdbcColumnMetaData.
        oStatementMetadata:iNrOfCols = iNrOfCols.
        do iCol = 1 to iNrOfCols:
          iRetVal = OEOdbcApi:Instance:SQLDescribeCol(iStmtHandle, iCol, output cColumnName,
                                                      output iDataType,  output iColumnSize, 
                                                      output iDecimalDigits, output  iNullable).

          OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to retrieve column descriptions in Prepared Statement").

          ASSIGN iDBColDataTypes[iCol] = iDataType.

           /* Here we need to check if the temp-table fields are matching with the physical table fields */

          /* assign hTTBufFldHdls[iCol] = hDefTTBuf:buffer-field(iCol):handle. */

          create ttOEOdbcColumnMetadata.
          assign ttOEOdbcColumnMetaData.ColumnIndex   = iCol
                 ttOEOdbcColumnMetaData.ColumnName    = cColumnName
                 ttOEOdbcColumnMetaData.DataType      = iDataType
                 ttOEOdbcColumnMetaData.ColumnSize    = iColumnSize
                 ttOEOdbcColumnMetaData.DecimalDigits = iDecimalDigits
                 ttOEOdbcColumnMetaData.Nullable      = iNullable.
 
          /* Needs to be ported to 64-bit */
          SET-SIZE(mColStrLen_or_ind[iCol])    = 8.
          PUT-LONG(mColStrLen_or_ind[iCol], 1) = 0.
        
          /* Allocate the memory zones that will receive the data from the record */
          IF iDataType = {&SQL_WVARCHAR} or
             iDataType = {&SQL_VARCHAR}  or
             iDataType = {&SQL_CHAR}     or
             iDataType = {&SQL_WCHAR}    then
            assign iSqlCType     = {&SQL_C_CHAR}
                   iColBufSize   = {&RESBUF_SIZE_VARCHAR}
                   iColumnSize   = iColumnSize + 2
                   iNrOfCharCols = iNrOfCharCols + 1.
          else if iDataType = {&SQL_INTEGER} then
            assign iSqlCType    = {&SQL_C_LONG}
                   iColBufSize  = 4
                   iNrOfIntCols = iNrOfIntCols + 1.
          else if iDataType = {&SQL_BIT} THEN
            assign iSqlCType    = {&SQL_C_BIT}
                   iColBufSize  = 1
                   iNrOfLogCols = iNrOfLogCols + 1.
          else IF iDataType = {&SQL_TYPE_DATE} then
            assign iSqlCType   = {&SQL_C_DATE}
                   iColBufSize = 8.
          else if iDataType = {&SQL_TYPE_TIMESTAMP} then
            assign iSqlCType          = {&SQL_C_TIMESTAMP}
                   iColBufSize        =  16
                   iNrOfTimestampCols = iNrOfTimestampCols + 1.
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
          else if iDataType = {&SQL_BIGINT}  /* or
                   iDataType = {&SQL_NUMERIC} */ then
            assign iSqlCType    = {&SQL_C_SBIGINT}
                   iColBufSize  =  8
                   iNrOfDecCols = iNrOfDecCols + 1.
          else if iDataType = {&SQL_FLOAT}   or
                  iDataType = {&SQL_DOUBLE}  or
                  iDataType = {&SQL_DECIMAL} then
            assign iSqlCType    = {&SQL_C_DOUBLE}
                   iColBufSize  =  8
                   iNrOfDecCols = iNrOfDecCols + 1.
          else if  iDataType = {&SQL_NUMERIC} then
		    assign iSqlCType = {&SQL_C_NUMERIC}
			       iColBufSize = 128
				   iNrOfTimestampCols = iNrOfTimestampCols + 1.
		  else
		  
            undo, throw new OEOdbcException("Unimplemented datatype " + String(iDataType) + " for column " + String(iCol), -1).     
         
		  message "Setting column " iCol.
          set-size(mDBTableCols[iCol]) = iColBufSize.
          iRetVal = OEOdbcApi:Instance:SQLBindColV2(iStmtHandle, iCol, iSqlCType, mDBTableCols[iCol],
                                                    iColumnSize, INPUT  mColStrLen_or_Ind[iCol]).

          OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to bind columns to buffers in Prepared Statement").
        end.

        oStatementMetadata:SetNrOfColsPerType(iNrOfCharCols, iNrOfIntCols, iNrOfDecCols, iNrOfLogCols, iNrOfTimestampCols).
  
        iStatusMoreResults = oOEOdbcResultsMapper:iterateAndMapResults(THIS-OBJECT).

        iResultSet = iResultSet + 1.

        /* Cleanup of allocated memptrs used for receiving data */
        finally:
          empty temp-table ttOEOdbcColumnMetaData.
          do iCol = 1 to iNrOfCols:
          set-size(mDBTableCols[iCol]) = 0.
            set-size(mColStrLen_or_ind[iCol]) = 0.
          end.
        end.
      end.

      /* We have to check if this is still required */
      /*
      iRetVal = OEOdbcApi:Instance:SQLCloseCursor(iStmtHandle).
      OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, iStmtHandle, iRetVal, "Unable to close cursor in Prepared Statement").
      */

   
    RETURN iNrOfRecs.

  end method.
end class.
