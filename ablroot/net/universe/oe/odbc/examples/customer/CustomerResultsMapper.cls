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
using net.universe.oe.odbc.examples.customer.*.

{net/universe/oe/odbc/oe-odbc-defs.i}

ROUTINE-LEVEL ON ERROR UNDO, THROW.
CLASS net.universe.oe.odbc.examples.customer.CustomerResultsMapper inherits OEOdbcResultsMapper:
  {net/universe/oe/odbc/examples/customer/ttCustomer.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}
  {net/universe/oe/odbc/ttOEOdbcColumnMetadata.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}

  constructor public CustomerResultsMapper(input table for ttCustomer bind,
                                         input oResultsCallback as IOEOdbcResultsCallback,
                                         input iNrOfRecsPerBatch as int):
 
    super(temp-table ttCustomer:handle, oResultsCallback, iNrOfRecsPerBatch).

  END CONSTRUCTOR.

  constructor public CustomerResultsMapper(input table for ttCustomer bind):

    super(temp-table ttCustomer:handle, ?, ?).

  END CONSTRUCTOR.

  METHOD PUBLIC override INT iterateAndMapResults(INPUT oPStmt AS OEOdbcPreparedStatement):
  
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyVars}

    def var idxCustomerId                 as int no-undo.
    def var idxCustomerName               as int no-undo.
    def var idxIsActive                   as int no-undo.
    def var idxAnnualIncome               as int no-undo.
    def var idxSex                        as int no-undo.
    def var idxState                      as int no-undo.
    def var idxBirthDate                  as int no-undo.
    def var idxCreatedOn                  as int no-undo.
    
    def var iSortOrder     as int  no-undo.

    def var oStatementMetadata as net.universe.oe.odbc.OEOdbcStatementMetadata no-undo.

    oStatementMetadata = oPstmt:oStatementMetadata.
    
    /* To see how the dataset is built, we can use the commented out code 
       to dump the metadata of the statement. 
       This could be the plugin point to start generating this mapper class.
    */
    /*
    oStatementMetadata:bindColumnMetadata(output table ttOEOdbcColumnMetadata bind).
    
    output to c:\test\colmeta.txt.
    for each ttOEOdbcColumnMetaData no-lock:
      export ttOEOdbcColumnMetaData.
    end.
    output close.
    */

    assign 
      idxCustomerId    = oStatementMetadata:getColumnIndex("customerId")
      idxCustomerName  = oStatementMetadata:getColumnIndex("customerName")
      idxIsActive      = oStatementMetadata:getColumnIndex("isActive")
      idxAnnualIncome  = oStatementMetadata:getColumnIndex("AnnualIncome")
      idxSex           = oStatementMetadata:getColumnIndex("Sex")
      idxState         = oStatementMetadata:getColumnIndex("State")
      idxBirthDate     = oStatementMetadata:getColumnIndex("birthDate")
      idxCreatedOn     = oStatementMetadata:getColumnIndex("createdOn")
      .
 
    empty temp-table ttCustomer.
    
    /* There are helper variables required for date or timestamp fields */

    {net/universe/oe/odbc/OEOdbcDateConvVars.i      &Idx="idxBirthDate"}
    {net/universe/oe/odbc/OEOdbcTimestampConvVars.i &Idx="idxCreatedOn"}
 
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_begin.i &OnlyIterate}

      find last ttCustomer use-index idxSortOrder no-lock no-error.
      assign iSortOrder = (if avail ttCustomer then ttCustomer.sortOrder + 1 else 1).
      
      CREATE ttCustomer.

      assign ttCustomer.SortOrder    = iSortOrder
             ttCustomer.CustomerId   = {net/universe/oe/odbc/OEOdbcGetFieldVal.i              &Idx="idxCustomerId"   &AsType="LONG" &NoNull}
             ttCustomer.CustomerName = {net/universe/oe/odbc/OEOdbcGetFieldVal.i              &Idx="idxCustomerName" &AsType="STRING"}
             ttCustomer.IsActive     = {net/universe/oe/odbc/OEOdbcGetFieldVal.i              &Idx="idxIsActive"     &AsType="LONG"} <> 0
             ttCustomer.AnnualIncome = {net/universe/oe/odbc/OEOdbcGetFieldVal.i              &Idx="idxAnnualIncome" &AsType="DOUBLE"}
             ttCustomer.Sex          = {net/universe/oe/odbc/OEOdbcGetFieldVal.i              &Idx="idxSex"          &AsType="STRING"}
             ttCustomer.State        = {net/universe/oe/odbc/OEOdbcGetFieldVal.i              &Idx="idxState"        &AsType="STRING"}
             ttCustomer.BirthDate    = {net/universe/oe/odbc/OEOdbcGetFieldValDateConv.i      &Idx="idxBirthDate"}
             ttCustomer.CreatedOn    = {net/universe/oe/odbc/OEOdbcGetFieldValTimestampConv.i &Idx="idxCreatedOn"}
      .
 
    {net/universe/oe/odbc/IOEOdbcResultsMapper_maprec_end.i}

  END METHOD.

END CLASS.
