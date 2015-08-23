/*------------------------------------------------------------------------
This file is part of the OEOdbc library, an OpenEdge ABL wrapper
around the ODBC libraries.


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
{net/universe/oe/odbc/oe-odbc-defs.i}

ROUTINE-LEVEL ON ERROR UNDO, THROW.
CLASS net.universe.oe.odbc.OEOdbcGenericResultsMapper INHERITS OEOdbcResultsMapper:
  /* {net/universe/oe/odbc/examples/customer/ttcustomer.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE} */
  
  {net/universe/oe/odbc/ttOEOdbcColumnMetadata.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}

  CONSTRUCTOR PUBLIC OEOdbcGenericResultsMapper(input table-handle hTT bind):
    super(hTT, ?, ?).
  END CONSTRUCTOR.

  METHOD PUBLIC OVERRIDE INT iterateAndMapResults(INPUT oPStmt AS OEOdbcPreparedStatement):

  {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyVars}
    
    def var iSortOrder     as int    no-undo.
    def var iDataType      as int    no-undo.
    def var i              as int    no-undo.
    def var hBuf           as handle no-undo.
    
    assign hBuf = hDefaultTempTable:default-buffer-handle.
    
    /* Mapping metadata statement to temp-table can happen in different ways:
       - Only by position
       - By position & type
       - By name & type
       - Mapping list
       - ...
       
       The current mapper is only based upon position, but this will be extended by the other mechanisms
       
       Mapping concept: 
         Using a list to map SourceResultSet[Index] = DestinationTempTable[Index]
         There will be one SourceResultSetMapping per dataType.
         The mapping will contain the field handle of the destination Temp-Table buffer.
         
         IntMapperDestBuf[1] = Buffer:buffer-field('destfield')
         IntMapperSrcIdx[1]  = ResultSetIndex
    */
    
    
    /* First step: Get access to the metadata of the ResultSet (using structure ttOEOdbcColumnMetaData) */
    
    def var oStatementMetadata as net.universe.oe.odbc.OEOdbcStatementMetadata no-undo.
    def var iNrOfCols          as int no-undo.
    def var iNrOfIntCols       as int no-undo.
    def var iNrOfDecCols       as int no-undo.
    def var iNrOfTimestampCols as int no-undo.
    def var iNrOfLogCols       as int no-undo.
    def var iNrOfCharCols      as int no-undo.
    
    oStatementMetadata = oPstmt:oStatementMetadata.
    oStatementMetadata:bindColumnMetadata(output table ttOEOdbcColumnMetadata bind).
    assign iNrOfCols          = oStatementMetadata:iNrOfCols
           iNrOfCharCols      = oStatementMetadata:iNrOfCharCols
           iNrOfIntCols       = oStatementMetadata:iNrOfIntCols
           iNrOfDecCols       = oStatementMetadata:iNrOfDecCols
           iNrOfLogCols       = oStatementMetadata:iNrOfLogCols
           iNrOfTimestampCols = oStatementMetadata:iNrOfTimestampCols.
            
    /*       
    output to c:\test\colmeta.txt.
    for each ttOEOdbcColumnMetaData no-lock:
        export ttOEOdbcColumnMetaData.
    end.
    output close.
    */
    

    def var iColsIdx     as int no-undo init 0.
    def var iCharColsIdx as int no-undo init 0.
    def var iDecColsIdx  as int no-undo init 0.
    def var iLogColsIdx  as int no-undo init 0.
    def var iIntColsIdx  as int no-undo init 0.    
    
    def var iIntMapperSrcIdx   as int extent.
    def var hIntMapperDestBuf  as handle extent.
    def var iCharMapperSrcIdx  as int extent.
    def var hCharMapperDestBuf as handle extent.
    def var iDecMapperSrcIdx   as int extent.
    def var hDecMapperDestBuf  as handle extent.
    def var iLogMapperSrcIdx   as int extent.
    def var hLogMapperDestBuf  as handle extent.

    if iNrOfIntCols > 0 then do:
      extent(iIntMapperSrcIdx)   = iNrOfIntCols.
      extent(hIntMapperDestBuf)  = iNrOfIntCols.
    end.
    if iNrOfCharCols > 0 then do:
        extent(iCharMapperSrcIdx)  = iNrOfCharCols.
      extent(hCharMapperDestBuf) = iNrOfCharCols.
    end.
    if iNrOfDecCols > 0 then do:
      extent(iDecMapperSrcIdx)   = iNrOfDecCols.
      extent(hDecMapperDestBuf)  = iNrOfDecCols.
    end.
    if iNrOfLogCols > 0 then do:
      extent(iLogMapperSrcIdx)   = iNrOfLogCols.
      extent(hLogMapperDestBuf)  = iNrOfLogCols.
    end.

    /* Here the source positions get filled per type */
    for each ttOEOdbcColumnMetaData no-lock:
      assign iColsIdx = iColsIdx + 1
             iDataType = ttOEOdbcColumnMetaData.DataType.
 
      if iDataType = {&SQL_WVARCHAR} or
         iDataType = {&SQL_VARCHAR}  or
         iDataType = {&SQL_CHAR}     then
        
        assign iCharColsIdx = iCharColsIdx + 1
               iCharMapperSrcIdx[iCharColsIdx] = iColsIdx.

      else if iDataType = {&SQL_INTEGER} then

        assign iIntColsIdx = iIntColsIdx + 1
               iIntMapperSrcIdx[iIntColsIdx] = iColsIdx.
               
      else if iDataType = {&SQL_BIT} then
         assign iLogColsIdx = iLogColsIdx + 1
               iLogMapperSrcIdx[iLogColsIdx] = iColsIdx.           
           
      else  if iDataType = {&SQL_DOUBLE} or iDataType = {&SQL_DECIMAL} or iDataType = {&SQL_BIGINT} or iDataType = {&SQL_NUMERIC} then 
        assign iDecColsIdx = iDecColsIdx + 1
               iDecMapperSrcIdx[iDecColsIdx] = iColsIdx.           
    end.
    
    /* In the destination buffers, we can do all kinds of mappings. For now we do a one-to-one. 
       This could also be resolved by some kind of a callback later on.
       This would give full flexibility to override what is wanted.
    */
    do i = 1 to iNrOfIntCols:
      assign hIntMapperDestBuf[i]  = hBuf:buffer-field(iIntMapperSrcIdx[i]).
    end.
    do i = 1 to iNrOfCharCols:
      assign hCharMapperDestBuf[i] = hBuf:buffer-field(iCharMapperSrcIdx[i]).
    end.
    do i = 1 to iNrOfDecCols:
      assign hDecMapperDestBuf[i]  = hBuf:buffer-field(iDecMapperSrcIdx[i]).
    end.
    do i = 1 to iNrOfLogCols:
      assign hLogMapperDestBuf[i]  = hBuf:buffer-field(iLogMapperSrcIdx[i]).
    end.
    
    /* The SortOrder field */
    def var hSortOrder as handle no-undo.
    hSortOrder = hBuf:buffer-field('sortOrder').
    
    hBuf:empty-temp-table().

    /*    
    {net/universe/oe/odbc/OEOdbcDateConvVars.i &Idx="idxSomeDate"}
    */    
    
    hBuf:find-last("use-index idxSortOrder", no-lock, no-wait) no-error.
    assign iSortOrder = (if hBuf:avail then integer(hBuf:buffer-field('sortOrder')) + 1 else 1).
  
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyIterate}

    hBuf:buffer-create().

    do i = 1 to iNrOfIntCols:
      assign hIntMapperDestBuf[i]:buffer-value = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="iIntMapperSrcIdx[i]"  &AsType="LONG"}.
    end.
    do i = 1 to iNrOfDecCols:
      assign hDecMapperDestBuf[i]:buffer-value = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="iDecMapperSrcIdx[i]"  &AsType="DOUBLE"}.
    end.
    do i = 1 to iNrOfCharCols:
      assign hCharMapperDestBuf[i]:buffer-value = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="iCharMapperSrcIdx[i]"  &AsType="STRING"}.
    end.
    do i = 1 to iNrOfLogCols:
      assign hLogMapperDestBuf[i]:buffer-value = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="iLogMapperSrcIdx[i]"  &AsType="LONG"}.
    end.
    assign iSortOrder              = iSortOrder + 1
           hSortOrder:buffer-value = iSortOrder.

    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_end.i}
    
  END METHOD.

END CLASS.
