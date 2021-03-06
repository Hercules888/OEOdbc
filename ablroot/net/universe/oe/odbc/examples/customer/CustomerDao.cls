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

using net.universe.oe.odbc.examples.customer.*.
using net.universe.oe.odbc.*.


ROUTINE-LEVEL ON ERROR UNDO, THROW.
CLASS net.universe.oe.odbc.examples.customer.CustomerDao:
  {net/universe/oe/odbc/examples/customer/ttCustomer.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}

  def PRIVATE var oOdbcCon as OEOdbcConnection no-undo.

  Constructor public CustomerDao(input oOdbcCon as OEOdbcConnection):
     assign this-object:oOdbcCon = oOdbcCon.
  end constructor.

  &global-define CUSTOMER_DB_FIELDS "customerId", "customerName", "isActive", "AnnualIncome", "Sex", "State", "birthDate", "createdOn"
  &global-define CUSTOMER_DB_TABLE "Customer"

  method public int insertCustomers(input table ttCustomer):
  
    def var cSQL    as char no-undo.
    def var iRetVal as int  no-undo.

    DEF VAR oOdbcPStmt            AS OEOdbcPreparedStatement   NO-UNDO.
    DEF VAR oCustomerParamsMapper AS OEOdbcGenericParamsMapper NO-UNDO.

    oCustomerParamsMapper  = new OEOdbcGenericParamsMapper().
    oCustomerParamsMapper:setInt(1, 3). 
    oCustomerParamsMapper:setString(2, "Junior Doe").
    oCustomerParamsMapper:setDecimal(3, 531.0246). 
    oCustomerParamsMapper:setString(4, "M"). 
    oCustomerParamsMapper:setString(5, "IL"). 
    oCustomerParamsMapper:setDate(6, date(1,31,2007)). 
    oCustomerParamsMapper:setTimestamp(7, now). 
	oCustomerParamsMapper:setBit(8, true). 
    
    //ASSIGN cSQL = 'insert into {&CUSTOMER_DB_TABLE} ("customerId", "customerName") values(?,?)'.
	ASSIGN cSQL = 'insert into {&CUSTOMER_DB_TABLE} ("customerId", "customerName", "AnnualIncome", "Sex", "State", "birthDate", "createdOn" "isActive") values(?,?,?,?,?,?,?,?)'.
    
    oOdbcPStmt = oOdbcCon:prepareStatement(cSQL).

    iRetVal = oOdbcPStmt:executeQuery(oCustomerParamsMapper, ?).

    return iRetVal.
    FINALLY:
      IF VALID-OBJECT(oOdbcPstmt) THEN DELETE OBJECT oOdbcPstmt NO-ERROR.
      IF valid-object(oCustomerParamsMapper) then delete object oCustomerParamsMapper no-error.
    END FINALLY.

  end method.
  /*
  method public int GetAllCustomers(output table ttCustomer):
     return GetCustomerById(?, output table ttCustomer by-reference).
  end method.
  */
  METHOD PUBLIC INT GetAllCustomersByCallback(output table ttCustomer, 
                                              input oResultsCallback as IOEOdbcResultsCallback,
                                              input iNrOfRecsPerBatch as int):

    DEF VAR iNrOfRecs AS INT  NO-UNDO.
    def var cSQL      as char no-undo.
   
    DEF VAR oOdbcPStmt             AS OEOdbcPreparedStatement   NO-UNDO.
    DEF VAR oCustomerResultsMapper AS CustomerResultsMapper     NO-UNDO. 

    ASSIGN cSQL = 'select {&CUSTOMER_DB_FIELDS} from {&CUSTOMER_DB_TABLE}'.
    
    oOdbcPStmt = oOdbcCon:prepareStatement(cSQL).

    oCustomerResultsMapper = NEW CustomerResultsMapper (INPUT TABLE ttCustomer BIND, oResultsCallback, iNrOfRecsPerBatch).


    iNrOfrecs = oOdbcPStmt:executeQuery(?, oCustomerResultsMapper).
    RETURN iNrOfRecs.

    FINALLY:
      IF VALID-OBJECT(oOdbcPstmt) THEN DELETE OBJECT oOdbcPstmt NO-ERROR.
      IF valid-object(oCustomerResultsMapper) then delete object oCustomerResultsMapper no-error.
    END FINALLY.

  END METHOD.  
  
  METHOD PUBLIC INT GetCustomerById(INPUT iCustomerId as int, output table ttCustomer):

    DEF VAR iNrOfRecs AS INT  NO-UNDO.
    def var cSQL      as char no-undo.
   
    DEF VAR oOdbcPStmt             AS OeOdbcPreparedStatement   NO-UNDO.
    def var oCustomerParamsMapper  as OEOdbcGenericParamsMapper no-undo.
    DEF VAR oCustomerResultsMapper AS CustomerResultsMapper     NO-UNDO. 

    ASSIGN cSQL = 'select {&CUSTOMER_DB_FIELDS} from {&CUSTOMER_DB_TABLE}'.
    
    oOdbcPStmt = oOdbcCon:prepareStatement(cSQL).

    oCustomerParamsMapper  = new OEOdbcGenericParamsMapper().
    
    if iCustomerId <> ? then do:
      assign cSQL = cSQL + ' WHERE "CustomerId" = ? '.
      oCustomerParamsMapper:setInt(1, iCustomerId). 
    end.

    oCustomerResultsMapper = NEW CustomerResultsMapper (INPUT TABLE ttCustomer BIND).

    iNrOfrecs = oOdbcPStmt:executeQuery(oCustomerParamsMapper, oCustomerResultsMapper).
    RETURN iNrOfRecs.

    FINALLY:
      IF VALID-OBJECT(oOdbcPstmt) THEN DELETE OBJECT oOdbcPstmt NO-ERROR.
      IF valid-object(oCustomerParamsMapper)  THEN DELETE OBJECT oCustomerParamsMapper  no-eRROR. 
      IF valid-object(oCustomerResultsMapper) then delete object oCustomerResultsMapper no-error.
    END FINALLY.

    
  END METHOD.

END CLASS.  

