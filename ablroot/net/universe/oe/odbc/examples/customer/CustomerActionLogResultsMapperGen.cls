USING net.universe.oe.odbc.*.
{net/universe/oe/odbc/oe-odbc-defs.i}
ROUTINE-LEVEL ON ERROR UNDO, THROW.
CLASS net.universe.oe.odbc.examples.customer.CustomerActionLogResultsMapperGen INHERITS OEOdbcResultsMapper:
  {net/universe/oe/odbc/examples/customer/ttCustomerActionLog.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}
  {net/universe/oe/odbc/ttOEOdbcColumnMetadata.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}
  CONSTRUCTOR PUBLIC CustomerActionLogResultsMapperGen(INPUT TABLE FOR ttCustomerActionLog BIND,
                                         input oResultsCallback as IOEOdbcResultsCallback,
                                         input iNrOfRecsPerBatch as int):
    super(temp-table ttCustomerActionLog:handle, oResultsCallback, iNrOfRecsPerBatch).
  END CONSTRUCTOR.
  METHOD PUBLIC OVERRIDE INT iterateAndMapResults(INPUT oPStmt AS OEOdbcPreparedStatement):
  
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyVars}
    
    def var idxcustomerId       as int no-undo.    
    def var idxlogEntryId       as int no-undo.    
    def var idxlogEntry       as int no-undo.    
    
    def var iSortOrder     as int  no-undo.
    def var oStatementMetadata as net.universe.oe.odbc.OEOdbcStatementMetadata no-undo.
    oStatementMetadata = oPstmt:oStatementMetadata.
    
    /*
    oStatementMetadata:bindColumnMetadata(output table ttOEOdbcColumnMetadata bind).
    output to c:\test\colmeta.txt.
    for each ttOEOdbcColumnMetaData no-lock:
    	export ttOEOdbcColumnMetaData.
    end.
    output close.
    */
    assign 
      
      idxcustomerId                  = oStatementMetadata:getColumnIndex("customerId")      
      idxlogEntryId                  = oStatementMetadata:getColumnIndex("logEntryId")      
      idxlogEntry                  = oStatementMetadata:getColumnIndex("logEntry")      
      .
 
    empty temp-table ttCustomerActionLog.
    /*    
    {net/universe/oe/odbc/OEOdbcDateConvVars.i &Idx="idxSomeDateField"}
    */    
  
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyIterate}
   
    find last ttCustomerActionLog use-index idxSortOrder no-lock no-error.
    assign iSortOrder = (if avail ttCustomerActionLog then ttCustomerActionLog.sortOrder + 1 else 1).
    CREATE ttCustomerActionLog.
    assign 
        ttCustomerActionLog.SortOrder                  = iSortOrder
        
        ttCustomerActionLog.customerId = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxcustomerId"  &AsType="LONG" &NoNull}        
        ttCustomerActionLog.logEntryId = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxlogEntryId"  &AsType="LONG" &NoNull}        
        ttCustomerActionLog.logEntry = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxlogEntry"  &AsType="STRING" &NoNull}        
        .
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_end.i}
  END METHOD.
END CLASS.
