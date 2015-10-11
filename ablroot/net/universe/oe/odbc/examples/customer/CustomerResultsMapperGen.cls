USING net.universe.oe.odbc.*.
{net/universe/oe/odbc/oe-odbc-defs.i}
ROUTINE-LEVEL ON ERROR UNDO, THROW.
CLASS net.universe.oe.odbc.examples.customer.CustomerResultsMapperGen INHERITS OEOdbcResultsMapper:
  {net/universe/oe/odbc/examples/customer/ttCustomer.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}
  {net/universe/oe/odbc/ttOEOdbcColumnMetadata.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}
  CONSTRUCTOR PUBLIC CustomerResultsMapperGen(INPUT TABLE FOR ttCustomer BIND,
                                         input oResultsCallback as IOEOdbcResultsCallback,
                                         input iNrOfRecsPerBatch as int):
    super(temp-table ttCustomer:handle, ?, ?).
  END CONSTRUCTOR.
  METHOD PUBLIC OVERRIDE INT iterateAndMapResults(INPUT oPStmt AS OEOdbcPreparedStatement):
  
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyVars}
    
    def var idxcustomerId       as int no-undo.    
    def var idxcustomerName       as int no-undo.    
    def var idxisActive       as int no-undo.    
    def var idxAnnualIncome       as int no-undo.    
    def var idxSex       as int no-undo.    
    def var idxState       as int no-undo.    
    
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
      idxcustomerName                  = oStatementMetadata:getColumnIndex("customerName")      
      idxisActive                  = oStatementMetadata:getColumnIndex("isActive")      
      idxAnnualIncome                  = oStatementMetadata:getColumnIndex("AnnualIncome")      
      idxSex                  = oStatementMetadata:getColumnIndex("Sex")      
      idxState                  = oStatementMetadata:getColumnIndex("State")      
      .
 
    empty temp-table ttCustomer.
    /*    
    {net/universe/oe/odbc/OEOdbcDateConvVars.i &Idx="idxSomeDateField"}
    */    
  
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyIterate}
    find last ttCustomer use-index idxSortOrder no-lock no-error.
    assign iSortOrder = (if avail ttCustomer then ttCustomer.sortOrder + 1 else 1).
    CREATE ttCustomer.
    assign 
        ttCustomer.SortOrder                  = iSortOrder
        
        ttCustomer.customerId = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxcustomerId"  &AsType="LONG" &NoNull}        
        ttCustomer.customerName = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxcustomerName"  &AsType="STRING" &NoNull}        
        ttCustomer.isActive = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxisActive"  &AsType="STRING" &NoNull}        
        ttCustomer.AnnualIncome = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxAnnualIncome"  &AsType="FLOAT" &NoNull}        
        ttCustomer.Sex = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxSex"  &AsType="STRING" &NoNull}        
        ttCustomer.State = {net/universe/oe/odbc/OEOdbcGetFieldVal.i &Idx="idxState"  &AsType="STRING" &NoNull}        
        .
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_end.i}
  END METHOD.
END CLASS.
