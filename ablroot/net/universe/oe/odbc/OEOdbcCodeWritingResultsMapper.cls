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



CLASS net.universe.oe.odbc.OEOdbcCodeWritingResultsMapper INHERITS OEOdbcResultsMapper:

  def stream sIn.
  def stream sOut.
  def private var hTT as handle no-undo.

  def public property cOutputFilePath    as char no-undo init ?
  public get.
  public set.
  
  def public property cTemplateFilePath  as char no-undo init 'net/universe/oe/odbc/OEOdbcResultsMapperClass.template'
  public get.
  public set.
  
  def public property cOEOdbcPackage     as char no-undo
  public get.
  public set.
  
  def public property cOEOdbcClass       as char no-undo
  public get.
  public set.
  
  def public property cOEOdbcPackagePath as char no-undo init ?
  public get.
  public set.
  
  def public property cOEOdbcTemptable   as char no-undo init ?
  public get.
  public set.
  
  def private var cTagOEOdbcPackage          as char no-undo init '~{~&OE_ODBC_PACKAGE~}'.
  def private var cTagOEOdbcClass            as char no-undo init '~{~&OE_ODBC_CLASS~}'.
  def private var cTagOEOdbcPackagePath      as char no-undo init '~{~&OE_ODBC_PACKAGE_PATH~}'.
  def private var cTagOEOdbcTemptable        as char no-undo init '~{~&OE_ODBC_TEMPTABLE~}'.
  def private var cTagOEOdbcBeginFieldRepeat as char no-undo init '~{~&OE_ODBC_BEGIN_FIELD_REPEAT~}'.
  def private var cTagOEOdbcEndFieldRepeat   as char no-undo init '~{~&OE_ODBC_END_FIELD_REPEAT~}'.
  def private var cTagOEOdbcFieldName        as char no-undo init '~{~&OE_ODBC_FIELDNAME~}'.
  def private var cTagOEOdbcFieldNullable    as char no-undo init '~{~&OE_ODBC_FIELD_NULLABLE~}'.
  def private var cTagOEOdbcABLFieldType     as char no-undo init '~{~&OE_ODBC_ABL_FIELDTYPE~}'.
  def private var cTagOEOdbcABLMemptrGetFunc as char no-undo init '~{~&OE_ODBC_ABL_MEMPTR_GETFUNC~}'.
  
  
  {net/universe/oe/odbc/ttOEOdbcColumnMetadata.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}

  CONSTRUCTOR PUBLIC OEOdbcCodeWritingResultsMapper(input table-handle hTT bind):
    super(hTT, ?, ?).
  END CONSTRUCTOR.
  
  METHOD PRIVATE CHAR getABLFieldTypeBySQLFieldType(input iDataType as int):
 
    IF iDataType = {&SQL_WVARCHAR} or
       iDataType = {&SQL_VARCHAR} or
       iDataType = {&SQL_CHAR} or
       iDataType = {&SQL_WCHAR} then return 'CHARACTER'.

    IF iDataType = {&SQL_INTEGER} then return 'INTEGER'.
  
    IF iDataType = {&SQL_BIT}     then return 'LOGICAL'.
    if iDataType = {&SQL_BIGINT} or iDataType = {&SQL_NUMERIC} then return 'DECIMAL'.
    if iDataType = {&SQL_DOUBLE} or iDataType = {&SQL_DECIMAL} then return 'DECIMAL'.
    if iDataType = {&SQL_FLOAT} then return 'DECIMAL'.
    if iDataType = {&SQL_TYPE_DATE} then return 'DATE'.
    if iDataType = {&SQL_TYPE_TIMESTAMP} then return 'DATETIME-TZ'.
    
    return "??? UNSUPPORTED TYPE(" + string(iDataType) + ") ???".
 
  END METHOD.

  METHOD PRIVATE CHAR getABLMemptrGetfuncBySQLFieldType(input iDataType as int):
    IF iDataType = {&SQL_WVARCHAR} or
       iDataType = {&SQL_VARCHAR} or
       iDataType = {&SQL_CHAR} or
       iDataType = {&SQL_WCHAR}  then return 'STRING'.


    IF iDataType = {&SQL_INTEGER} then return 'LONG'.
  
    IF iDataType = {&SQL_BIT}     then return 'LONG'.
    /* if iDataType = {&SQL_TYPE_TIMESTAMP} then */ /* Not supported yet */
    if iDataType = {&SQL_BIGINT} or iDataType = {&SQL_NUMERIC} then return 'DOUBLE'.
    if iDataType = {&SQL_DOUBLE} or iDataType = {&SQL_DECIMAL} then return 'DOUBLE'.
    if iDataType = {&SQL_FLOAT} then return 'FLOAT'.
    return "??? UNSUPPORTED TYPE(" + string(iDataType) + ") ???".
  END METHOD.
  

  METHOD PUBLIC OVERRIDE INT iterateAndMapResults(INPUT oPStmt AS OEOdbcPreparedStatement):

    def var cLine          as char no-undo.
    def var cNewLine       as char no-undo.
    def var lInBlock       as log  no-undo init false.
    def var iStartIdx      as int  no-undo.
    def var iEndIdx        as int  no-undo.
    def var cRepeatPart    as char no-undo init ''.
    def var cRepeatPartNew as char no-undo.

    def var oStatementMetadata as net.universe.oe.odbc.OEOdbcStatementMetadata no-undo.

    
    oStatementMetadata = oPstmt:oStatementMetadata.
    oStatementMetadata:bindColumnMetadata(output table ttOEOdbcColumnMetadata bind).

    IF cOEOdbcPackagePath = ? THEN 
      assign cOEOdbcPackagePath = replace(cOEOdbcPackage, '.', '/').
    IF cOEOdbcTemptable = ? THEN
       assign cOEOdbcTempTable = 'tt' + cOEOdbcClass.

			
    input stream sIn from value(search(cTemplateFilePath)).
    output stream sOut to value(cOutputFilePath).
    REPEAT:
      import stream sIn unformatted cLine.
    
      IF not lInBlock THEN do:
          assign cNewLine = cLine
                 cNewLine = replace(cNewLine, cTagOEOdbcPackage,     cOEOdbcPackage)
                 cNewLine = replace(cNewLine, cTagOEOdbcClass,       cOEOdbcClass)
                 cNewLine = replace(cNewLine, cTagOEOdbcPackagePath, cOEOdbcPackagePath)
                 cNewLine = replace(cNewLine, cTagOEOdbcTemptable,   cOEOdbcTemptable)
                 cLine = cNewLine.
    
          iStartIdx = index(cLine, cTagOEOdbcBeginFieldRepeat).
    
    
          IF iStartIdx > 0 THEN
              assign cNewLine = substr(cLine, 1, iStartIdx - 1) 
                     cLine    = substr(cLine, iStartIdx + length(cTagOEOdbcBeginFieldRepeat)) 
                     lInBlock = true.
          
          put stream sOut unformatted cNewLine skip.
      END.
      
      IF lInBlock THEN do:
    
        iEndIdx = r-index(cLine, cTagOEOdbcEndFieldRepeat).
        assign cRepeatPart = cRepeatPart + (IF iEndIdx > 0 THEN substr(cLine, 1, iEndIdx - 1) else cLine). 
           
           
        IF iEndIdx > 0 THEN do:
          assign cRepeatPart = Replace(cRepeatPart, cTagOEOdbcTemptable, cOEOdbcTemptable).
          FOR each ttOEOdbcColumnMetadata where columnname <> '' no-lock by columnindex:
            assign cRepeatPartNew = Replace(cRepeatPart, cTagOEOdbcFieldName, ttOEOdbcColumnMetadata.ColumnName).
            IF index(cRepeatPartNew, cTagOEOdbcABLFieldType) > 0 then
              assign cRepeatPartNew = replace(cRepeatPartNew, cTagOEOdbcABLFieldType, getABLFieldTypeBySQLFieldType(ttOEOdbcColumnMetadata.DataType)).
    
            IF index(cRepeatPartNew, cTagOEOdbcABLMemptrGetFunc) > 0 then
              assign cRepeatPartNew = replace(cRepeatPartNew, cTagOEOdbcABLMemptrGetFunc, getABLMemptrGetfuncBySQLFieldType(ttOEOdbcColumnMetadata.DataType)).
                
            IF index(cRepeatPartNew, cTagOEOdbcFieldNullable) > 0 then
              assign cRepeatPartNew = replace(cRepeatPartNew, cTagOEOdbcFieldNullable, (if ttOEOdbcColumnMetadata.Nullable <> 0 then "" else "~&NoNull")).
    
    
            put stream sOut unformatted /* "<<<" */ cRepeatPartNew /* ">>>" */ skip.
          END.
          
          assign cRepeatPart = ''.
          lInBlock = false.
          put stream sOut unformatted substr(cLine, iEndIdx + length(cTagOEOdbcEndFieldRepeat))  skip.
    
    
        END.
    
        iStartIdx = 1.
      END.
    
      
    END.
    input  stream sIn close.
    output stream sOut close.
    
    /* Consume the resultset */
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i}
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_end.i}
    
  END METHOD.

END CLASS.
